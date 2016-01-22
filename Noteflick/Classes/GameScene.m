//
//  GameScene.m
//  NoteFlick
//
//  Created by Joshua Nanami on 14-8-15.
//  Copyright 2014年 Joshua Kirino. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>
#import <AVFoundation/AVFoundation.h>
#import <sqlite3.h>
#import "Colors.h"
#import "BeatMap.h"
#import "GameScene.h"
#import "GameSceneBackground.h"
#import "MusicSelectionScene.h"
#import "ResultScene.h"
#import "cocos2d-ui.h"

const int MAX=3000,N=2003;
CGPoint slider_points[N];
int SL[10]={0},Intersection[20][2]={0};
#define SafeLimit 20
#define GoodLimit 10
#define PerfectLimit 6

@interface MyDrawNode : CCDrawNode
@property (readwrite) int i,v,slider_no;
@end

@implementation MyDrawNode
@synthesize i,v,slider_no;
@end

@interface ApproachingCircle:CCSprite
@property (readwrite) int i,note_no;
@end

@implementation ApproachingCircle
@synthesize i,note_no;
@end

static inline CGPoint get_touch_location(UITouch *touch)
{
    CGPoint touch_location=[touch locationInView:touch.view];
    touch_location=[[CCDirector sharedDirector]convertToGL:touch_location];
    return touch_location;
}

@implementation GameScene
{
    Colors *color_set;NSArray *color_name;
    AVAudioPlayer *Player;float volumn_desc_per_frame;
    GameSceneBackground *background;
    PauseScene *pause_scene;
    GameOverScene *game_over_scene;
    
    NSMutableArray *Notes;
    int notes_num;float sec_per_beat;
    NSMutableArray *Draw_Slider,*ApproachCircles,*DelegateNotes,*DelegateCircles;
    BOOL START;
    int frames_passed;
    
    int draw_nodes_num,slider_num;
    int notes_iterator,sliders_iterator;
    BOOL Active[20],Action_Running[19],slider_on_track;
    CGPoint circle_points[500],Sliders[300][N];int points_num[300];
    CCNode *current_note_moving;CCSprite *limit_circle;
    NSMutableArray *Halo,*Nimbus,*Cross;int effect_num;
    BOOL effect_running[10],note_vis[1003],slider_vis[1003];
    
    int circle_segments_num,segment_per_frame,frame_num_for_approachment;
    float segments_num_per_unit;
    double approachment_percentage_per_frame,circle_approach_time;
    
    int MUSIC_ID,DIF;
    
    CCSprite *Pause,*PauseShade;
}
-(id)initWithID:(int)ID Dif:(int)dif
{
    self=[super init];
    if(!self) return self;
    
    
    MUSIC_ID=ID;DIF=dif;
    color_set=[Colors node];
    color_name=@[@"red",@"pink",@"purple",@"deep purple",@"indigo",@"blue",@"light blue",@"cyan",@"teal",@"green",@"light green",@"lime",@"yellow",@"amber",@"orange",@"deep orange",@"brown",@"grey",@"blue grey"];
    CGSize scrSize=[CCDirector sharedDirector].viewSize;
    draw_nodes_num=19;effect_num=10;
    START=NO;
    
    [[CCDirector sharedDirector]purgeCachedData];
    CCSpriteFrameCache *cache=[CCSpriteFrameCache sharedSpriteFrameCache];
    [cache removeSpriteFrames];
    [cache addSpriteFramesWithFile:@"GameSceneSprites.plist"];
    [cache addSpriteFramesWithFile:@"PauseSceneSprites.plist"];
    
    NSString *DataBase_Path;
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentDirecotry=[paths objectAtIndex:0];
    DataBase_Path=[documentDirecotry stringByAppendingPathComponent:@"DataBase.db"];
    
    Draw_Slider=[NSMutableArray array];
    ApproachCircles=[NSMutableArray array];
    DelegateNotes=[NSMutableArray array];
    DelegateCircles=[NSMutableArray array];
    Halo=[NSMutableArray array];
    Nimbus=[NSMutableArray array];
    Cross=[NSMutableArray array];
    for(int i=0;i<draw_nodes_num;i++)
        Active[i]=NO;
    
    MyDrawNode *node;
    ApproachingCircle *approach_circle;
    CCSprite *note_sprite,*circle_sprite;
    NSString *name;
    for(int i=0;i<draw_nodes_num;i++)
    {
        name=[NSString stringWithFormat:@"%@.png",color_name[i]];
        circle_sprite=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:name]];
        circle_sprite.visible=NO;
        circle_sprite.cascadeOpacityEnabled=YES;
        [self addChild:circle_sprite z:3];
        DelegateCircles[i]=circle_sprite;
        
        note_sprite=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"TouchNote.png"]];
        [circle_sprite addChild:note_sprite z:1];
        note_sprite.position=ccp(circle_sprite.contentSize.width/2.0,circle_sprite.contentSize.height/2.0);
        DelegateNotes[i]=note_sprite;
        note_sprite.visible=NO;
        
        node=[MyDrawNode node];
        [self addChild:node z:1];
        Draw_Slider[i]=node;
        
        approach_circle=[ApproachingCircle spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"ApproachCircle.png"]];
        approach_circle.visible=NO;
        [self addChild:approach_circle z:1];
        ApproachCircles[i]=approach_circle;
    }
    
    CCSprite *sprite;
    ccBlendFunc func={GL_SRC_ALPHA,GL_ONE};
    for(int i=0;i<effect_num;i++)
    {
        sprite=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Halo.png"]];
        sprite.visible=NO;
        sprite.blendFunc=func;
        Halo[i]=sprite;
        [self addChild:sprite z:2];
        
        sprite=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Nimbus.png"]];
        sprite.visible=NO;
        sprite.blendFunc=func;
        Nimbus[i]=sprite;
        [self addChild:sprite z:2];
        
        sprite=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Cross.png"]];
        sprite.visible=NO;
        sprite.color=[CCColor colorWithCcColor3b:ccRED];
        Cross[i]=sprite;
        [self addChild:sprite z:4];
    }
    
    sqlite3 *DataBase;
    sqlite3_open([DataBase_Path UTF8String],&DataBase);
    sqlite3_stmt *statement;
    
    NSData *url_data,*beatmap_data;
    char *cmd;
    switch (dif)
    {
        case 0:cmd="SELECT EASY,URL FROM BeatMaps WHERE ID=?"; break;
        case 1:cmd="SELECT NORMAL,URL FROM BeatMaps WHERE ID=?"; break;
        case 2:cmd="SELECT HARD,URL FROM BeatMaps WHERE ID=?"; break;
    }
    sqlite3_prepare_v2(DataBase,cmd,-1,&statement,NULL);
    sqlite3_bind_int(statement,1,ID);
    while(sqlite3_step(statement)==SQLITE_ROW)
    {
        const void* p=sqlite3_column_blob(statement,0);
        int size=sqlite3_column_bytes(statement,0);
        beatmap_data=[NSData dataWithBytes:p length:size];
        
        const void* p2=sqlite3_column_blob(statement,1);
        int size2=sqlite3_column_bytes(statement,1);
        url_data=[NSData dataWithBytes:p2 length:size2];
    }
    sqlite3_finalize(statement);
    sqlite3_close(DataBase);
    
    
    BeatMap *beatmap=[NSKeyedUnarchiver unarchiveObjectWithData:beatmap_data];
    Notes=beatmap.Notes;
    sec_per_beat=beatmap.sec_per_beat;
    notes_num=beatmap.notes_num;
    
    iNote *note=Notes[notes_num-1];
    double pure_time=note.offset;
    note=Notes[0];
    if(note.offset>3)
        pure_time-=note.offset;
    iNote *note2;
    for(int i=1;i<notes_num;i++)
    {
        note=Notes[i-1];
        note2=Notes[i];
        if(note2.offset-note.offset>3)
            pure_time-=note2.offset-note.offset;
    }
    note=Notes[0];
    segments_num_per_unit=1.0;
    circle_segments_num=segments_num_per_unit*50*3.141592653589793*2;
    circle_approach_time=(int)fmin(pure_time/((notes_num-1)*1.0)*3,note.offset);
    circle_approach_time=1.2;
    segment_per_frame=ceil(circle_segments_num/(45.0*circle_approach_time));
    frame_num_for_approachment=circle_approach_time*60;
    volumn_desc_per_frame=1/(1.0*(frame_num_for_approachment+600));
    approachment_percentage_per_frame=pow(0.25,1/(frame_num_for_approachment*1.0));
    
    [self calculateRequiredCoordinates];
    
    
    limit_circle=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"LimitCircle.png"]];
    CCActionRepeatForever *repeat=[CCActionRepeatForever actionWithAction:[CCActionRotateBy actionWithDuration:1 angle:360]];
    [limit_circle runAction:repeat];
    [self addChild:limit_circle z:4];
    limit_circle.opacity=0;
    
    Pause=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Pause.png"]];
    Pause.position=ccp(scrSize.width-Pause.contentSize.width*2/3.0,Pause.contentSize.height*2/3.0);
    [self addChild:Pause z:3];
    
    PauseShade=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"PauseShade.png"]];
    PauseShade.position=ccp(Pause.contentSize.width/2.0,Pause.contentSize.height/2.0);
    PauseShade.color=[color_set.preset_colors objectForKey:@"record_win grey"];
    PauseShade.opacity=0.5;PauseShade.visible=NO;
    [Pause addChild:PauseShade];
    
    background=[[GameSceneBackground alloc]initWithBeats:beatmap.beatpoint_num];
    [self addChild:background z:0];
    
    NSURL *URL=[NSKeyedUnarchiver unarchiveObjectWithData:url_data];
    Player=[[AVAudioPlayer alloc]initWithContentsOfURL:URL fileTypeHint:@"m4a"error:nil];
    
    self.userInteractionEnabled=YES;
    
    return self;
}
-(void)update:(CCTime)delta
{
    if(!START) return;
    
    if(notes_iterator!=notes_num)
    {
        iNote *note=Notes[notes_iterator];
        if(frames_passed==note.offset-frame_num_for_approachment)
        {
            [self newNote];
            notes_iterator++;
            if(note.type!='c')
                sliders_iterator++;
        }
    }
    else if(Player.volume>=volumn_desc_per_frame)
        Player.volume-=volumn_desc_per_frame;
    else [self ResultScene];
    
    ApproachingCircle *approach_circle;
    for(int i=0;i<draw_nodes_num;i++)
        if(Active[i])
        {
            approach_circle=ApproachCircles[i];
            if(approach_circle.i<frame_num_for_approachment-1)
                [self drawNote:i];
            else if(!Action_Running[i]) [self runNoteAction:i];
        }
    
    if(slider_on_track)
        limit_circle.position=current_note_moving.position,limit_circle.opacity=1;
    else limit_circle.opacity=0;
    
    frames_passed++;
    
    if(frames_passed==0)
    {
        [Player play];
        Player.volume=1;
    }
}
-(void)calculateRequiredCoordinates
{
    const double angle_delta=M_PI*2.0/(circle_segments_num*1.0);
    const double MAXN=(double)INT_MAX;
    double angle=0;
    for(int i=0;i<circle_segments_num;i++)
    {
        circle_points[i].x=cos(angle)*50;
        circle_points[i].y=sin(angle)*50;
        angle+=angle_delta;
    }
    
    for(int i=0;i<notes_num;i++)
    {
        iNote *note=Notes[i];
        if(note.type!='c')
        {
            double k1=0,k2=0; //k1 slope at start, k2 slope at end;
            points_num[slider_num]=note.slider_length*segments_num_per_unit;
            int temp_points_num=points_num[slider_num];
            if(note.type=='b')
            {
                Sliders[slider_num][0].x=note.start.x;
                Sliders[slider_num][0].y=note.start.y;
                CGPoint p,q,new_p;
                double k,pre_k=0;
                int coe_x=0,coe_y=0;
                for(int j=1;j<=temp_points_num;j++)
                {
                    double t=j/(temp_points_num*1.0);
                    q=Sliders[slider_num][j-1];
                    p.x=(1-t)*(1-t)*note.start.x+2*(1-t)*t*note.control.x+t*t*note.end.x;
                    p.y=(1-t)*(1-t)*note.start.y+2*(1-t)*t*note.control.y+t*t*note.end.y;
                    
                    if(p.y-q.y)
                    {
                        k=-1*(p.x-q.x)/(p.y-q.y);
                        if(!coe_x)
                        {
                            coe_x=1;
                            if(k>0) coe_y=1;
                            else coe_y=-1;
                        }
                        if(k*pre_k<-1)  coe_x=-coe_x;
                        else if(k*pre_k<=0&&pre_k)  coe_y=-coe_y;
                        pre_k=k;
                        
                        new_p.x=sqrt(2500.0/(k*k+1.0));
                        new_p.y=fabs(k*new_p.x);
                        
                        new_p.x*=coe_x;new_p.y*=coe_y;
                    }
                    else
                    {
                        new_p.x=0;
                        new_p.y=50*coe_y;
                        k=MAXN;
                    }
                    
                    if(j==1) k1=k;
                    if(j==temp_points_num) k2=k;
                    
                    Sliders[slider_num][j-1]=ccpAdd(q,new_p);
                    Sliders[slider_num][j-1+temp_points_num+circle_segments_num/2]=ccpAdd(q,ccpMult(new_p,-1));
                    
                    if(j!=temp_points_num)
                        Sliders[slider_num][j]=p;
                }
            }
            else
            {
                CGPoint p,new_p;
                double k;
                if(fabs(note.end.y-note.start.y)>5)
                {
                    k=-1*(note.end.x-note.start.x)/(note.end.y-note.start.y);
                    new_p.x=sqrt(2500.0/(k*k+1));
                    if(k<0) new_p.x=-new_p.x;
                    new_p.y=k*new_p.x;
                }
                else
                {
                    new_p.x=0;
                    new_p.y=50;
                    k=MAXN;
                }
                k1=k2=k;
                
                double delta_x=note.end.x-note.start.x;
                for(int j=0;j<temp_points_num&&k;j++)
                {
                    p.x=j/(temp_points_num*1.0)*delta_x+note.start.x;
                    p.y=-1/k*(p.x-note.start.x)+note.start.y;
                    Sliders[slider_num][j]=ccpAdd(p,new_p);
                    Sliders[slider_num][j+temp_points_num+circle_segments_num/2]=ccpAdd(p,ccpMult(new_p,-1));
                }
                double delta_y=note.end.y-note.start.y;
                for(int j=0;j<temp_points_num&&(!k);j++)
                {
                    p.x=note.start.x;
                    p.y=j/(temp_points_num*1.0)*delta_y+note.start.y;
                    Sliders[slider_num][j]=ccpAdd(p,new_p);
                    Sliders[slider_num][j+temp_points_num+circle_segments_num/2]=ccpAdd(p,ccpMult(new_p,-1));
                }
            }
            
            int s=temp_points_num+circle_segments_num/2;
            int e=temp_points_num+circle_segments_num/2+temp_points_num-1;
            int len=(e-s+1)/2+s-1;
            CGPoint temp_pos;
            for(int i=s;i<=len;i++)
            {
                temp_pos=Sliders[slider_num][i];
                Sliders[slider_num][i]=Sliders[slider_num][e-(i-s)];
                Sliders[slider_num][e-(i-s)]=temp_pos;
            }
            
            CGPoint start,end;
            start=Sliders[slider_num][temp_points_num-1];
            end=Sliders[slider_num][temp_points_num+circle_segments_num/2];
            [self insert_circle_coordinates_at:temp_points_num from:start to:end k:k2];
            start=Sliders[slider_num][2*temp_points_num-1+circle_segments_num/2];
            end=Sliders[slider_num][0];
            [self insert_circle_coordinates_at:2*temp_points_num+circle_segments_num/2 from:start to:end k:k1];
            
            points_num[slider_num]=2*temp_points_num+circle_segments_num/2*2;
            if(note.type=='b')
            {
                [self bentleyOttmann];
                note.control2=ccpAdd(ccpMult(note.control,2/3.0),ccpMult(note.end,1/3.0));
                note.control=ccpAdd(ccpMult(note.start,1/3.0),ccpMult(note.control,2/3.0));
            }
            
            slider_num++;
        }
    }
}
-(void)insert_circle_coordinates_at:(int)s from:(CGPoint)start to:(CGPoint)end k:(double)k
{
    const double MAXN=(double)INT_MAX;
    const double angle_delta=M_PI*2.0/(circle_segments_num*1.0);
    
    CGPoint mid;
    mid.x=(start.x+end.x)/2.0;
    mid.y=(start.y+end.y)/2.0;
    
    BOOL increase;
    CGPoint q=Sliders[slider_num][s-6];
    if(k<(MAXN-10))
    {
        double b=start.y-k*start.x;
        if(q.x*k+b<q.y)
            increase=false;
        else increase=true;
    }
    else
    {
        if(q.x<start.x)
            increase=false;
        else increase=true;
    }
    
    int start_p=atan(k)/angle_delta;
    if(start_p<0) start_p+=circle_segments_num;
    if(ccpDistance(ccpAdd(circle_points[start_p],mid),start)>20)
    {
        increase=!increase;
        start_p=(start_p+circle_segments_num/2)%circle_segments_num;
    }
    
    int end_p=(start_p+circle_segments_num/2)%circle_segments_num;
    for(int i=start_p,j=s;i!=end_p;j++)
    {
        Sliders[slider_num][j]=ccpAdd(mid,circle_points[i%circle_segments_num]);
        if(increase)
            i++;
        else i--;
        if(i<0)
            i+=circle_segments_num;
        if(i>=circle_segments_num)
            i%=circle_segments_num;
    }
}
struct Event
{
    CGPoint p;
    int left_num,right_num;
    int left[2],right[2];
}events[N];
int comp(const void *a,const void *b)
{
    struct Event *x=a,*y=b;
    if(x->p.x!=y->p.x) return x->p.x*1000-y->p.x*1000;
    else return x->p.y*1000-y->p.y*1000;
}
-(bool)intersect:(int)x with:(int)y
{
    CGPoint a,b,c,d;
    a=slider_points[x];
    b=slider_points[(x+1)%points_num[slider_num]];
    c=slider_points[y];
    d=slider_points[(y+1)%points_num[slider_num]];
    
    float ans1=(a.x-d.x)*(c.y-d.y)-(c.x-d.x)*(a.y-d.y);
    float ans2=(b.x-d.x)*(c.y-d.y)-(c.x-d.x)*(b.y-d.y);
    if(ans1*ans2>=0)
        return false;
    ans1=(c.x-a.x)*(b.y-a.y)-(b.x-a.x)*(c.y-a.y);
    ans2=(d.x-a.x)*(b.y-a.y)-(b.x-a.x)*(d.y-a.y);
    if(ans1*ans2>=0)
        return false;
    
    return true;
}
-(void)bentleyOttmann
{
    int line_a=-1,line_b=-1;
    memset(SL,0,sizeof(SL));
    Intersection[0][0]=0;
    
    for(int i=0;i<points_num[slider_num];i++)
    {
        events[i].p=Sliders[slider_num][i];
        events[i].left_num=events[i].right_num=0;
        events[i].left[0]=events[i].left[1]=-1;
        events[i].right[0]=events[i].right[1]=-1;
        int pre=(i-1+points_num[slider_num])%points_num[slider_num];
        int post=(i+1)%points_num[slider_num];
        if(Sliders[slider_num][pre].x>events[i].p.x)
        {
            events[i].left[events[i].left_num]=pre;
            events[i].left_num++;
        }
        else
        {
            events[i].right[events[i].right_num]=pre;
            events[i].right_num++;
        }
        if(Sliders[slider_num][post].x>events[i].p.x)
        {
            events[i].left[events[i].left_num]=i;
            events[i].left_num++;
        }
        else
        {
            events[i].right[events[i].right_num]=i;
            events[i].right_num++;
        }
        slider_points[i]=ccpMult(Sliders[slider_num][i],1000);
    }
    qsort(events,points_num[slider_num],sizeof(events[0]),comp);
    
    
    for(int i=0;i<points_num[slider_num];i++)
    {
        if(slider_num==12)
        {
            int pause=2;
        }
        int edge;
        int above,below;
        for(int j=0;j<events[i].left_num;j++)
        {
            edge=events[i].left[j];
            if(edge!=-1)
            {
                SL[++SL[0]]=edge;
                for(int k=1;k<=SL[0];k++)
                    if(SL[k]!=edge)
                        if([self intersect:edge with:SL[k]])
                        {
                            Intersection[0][0]++;
                            Intersection[Intersection[0][0]][0]=edge;
                            Intersection[Intersection[0][0]][1]=SL[k];
                        }
            }
        }
        for(int j=0;j<events[i].right_num;j++)
        {
            edge=events[i].right[j];
            if(edge!=-1)
            {
                for(int k=1;k<=SL[0];k++)
                    if(SL[k]==edge)
                    {
                        for(int p=k+1;p<=SL[0];p++)
                            SL[p-1]=SL[p];
                        SL[SL[0]]=0;
                        SL[0]--;
                    }
            }
        }
    }
    
    for(int i=1;i<=Intersection[0][0];i++)
    {
        line_a=Intersection[i][0];
        line_b=Intersection[i][1];
        int s,e;
        int delta=(int)fmax(line_a,line_b)-(int)fmin(line_a,line_b)-1;
        if(delta<points_num[slider_num]/2)
        {
            s=(int)fmax(line_a,line_b)+1;
            for(int j=s;j<points_num[slider_num];j++)
                Sliders[slider_num][j-delta]=Sliders[slider_num][j];
            
            points_num[slider_num]-=delta;
            
            for(int j=i+1;j<=Intersection[0][0];j++)
            {
                if(Intersection[j][0]>s)
                    Intersection[j][0]-=delta;
                if(Intersection[j][1]>s)
                    Intersection[j][1]-=delta;
            }
        }
        else
        {
            s=(int)fmin(line_a,line_b);
            e=(int)fmax(line_a,line_b);
            for(int j=s;j<=e;j++)
                Sliders[slider_num][j-s]=Sliders[slider_num][j];
            
            points_num[slider_num]=e-s+1;
            
            for(int j=i+1;j<=Intersection[0][0];j++)
            {
                Intersection[j][0]-=s;
                Intersection[j][1]-=s;
            }
        }
    }
}
-(void)newNote
{
    iNote *note=Notes[notes_iterator];
    MyDrawNode *draw_slider;
    ApproachingCircle *approach_circle;
    CCSprite *delegate_note,*delegate_circle;
    
    int i=notes_iterator%draw_nodes_num;
    
    delegate_circle=DelegateCircles[i];
    delegate_note=DelegateNotes[i];
    draw_slider=Draw_Slider[i];
    approach_circle=ApproachCircles[i];
    
    delegate_circle.visible=YES;
    delegate_circle.opacity=1;
    delegate_circle.position=note.start;
    delegate_circle.scale=0.1;
    delegate_circle.rotation=1+rand()%360;
    CCActionScaleTo *raw_magnify=[CCActionScaleTo actionWithDuration:frame_num_for_approachment/120.0 scale:1];
    CCActionEaseBackOut *magnify=[CCActionEaseBackOut actionWithAction:raw_magnify];
    [delegate_circle runAction:magnify];
    
    delegate_note.visible=YES;
    delegate_note.scale=0.1;
    delegate_note.rotation=delegate_circle.rotation;
    raw_magnify=[CCActionScaleTo actionWithDuration:frame_num_for_approachment/120.0 scale:1];
    magnify=[CCActionEaseBackOut actionWithAction:raw_magnify];
    [delegate_note runAction:magnify];
    
    approach_circle.i=0;
    approach_circle.note_no=notes_iterator;
    approach_circle.position=note.start;
    approach_circle.scale=1;
    approach_circle.visible=1;
    approach_circle.color=[color_set.preset_colors objectForKey:color_name[i]];;
    
    if(note.type!='c')
    {
        draw_slider.color=[color_set.preset_colors objectForKey:color_name[i]];
        draw_slider.i=0;
        draw_slider.v=ceil(points_num[sliders_iterator]/frame_num_for_approachment*2);
        draw_slider.slider_no=sliders_iterator;
    }
    
    Active[i]=YES;
}
-(void)drawNote:(int)i
{
    MyDrawNode *draw_slider=Draw_Slider[i];
    ApproachingCircle *approach_circle=ApproachCircles[i];
    iNote *note=Notes[approach_circle.note_no];
    
    if(note.type!='c'&&draw_slider.i!=points_num[slider_num]-1)
    {
        int slider_no=draw_slider.slider_no,j;
        for(j=draw_slider.i;j<draw_slider.i+draw_slider.v&&j<points_num[slider_no]-1;j++)
            [draw_slider drawSegmentFrom:Sliders[slider_no][j]to:Sliders[slider_no][j+1] radius:3.5 color:draw_slider.color];
        draw_slider.i=j;
    }
    
    if(approach_circle.i!=frame_num_for_approachment-1)
    {
        approach_circle.scale*=approachment_percentage_per_frame;
        approach_circle.i++;
    }
}
-(void)runNoteAction:(int)i
{
    MyDrawNode *draw_slider=Draw_Slider[i];
    ApproachingCircle *approach_circle=ApproachCircles[i];
    iNote *note=Notes[approach_circle.note_no];
    CCSprite *delegate_note=DelegateNotes[i],*delegate_circle=DelegateCircles[i];
    
    approach_circle.visible=NO;
    approach_circle.scale=1;
    
    if(note.type=='c')
    {
        CCActionFadeOut *fade_out=[CCActionFadeOut actionWithDuration:SafeLimit/60.0];
        CCActionCallBlock *call=[CCActionCallBlock actionWithBlock:^(void){
            if(!note_vis[approach_circle.note_no])
            {
                [self touchEffect:note.start Precision:MAX];
                note_vis[approach_circle.note_no]=true;
            }
            Active[i]=Action_Running[i]=NO;
            delegate_circle.visible=delegate_note.visible=NO;
        }];
        CCActionSequence *seq=[CCActionSequence actions:fade_out,call,nil];
        [delegate_circle runAction:seq];
    }
    else
    {
        CCActionInterval *pre=[CCActionInterval actionWithDuration:SafeLimit/60.0];
        CCActionCallBlock *call=[CCActionCallBlock actionWithBlock:^(void){
            if(!note_vis[approach_circle.note_no])
            {
                [self touchEffect:note.start Precision:MAX];
                note_vis[approach_circle.note_no]=true;
            }
        }];
        CCActionSequence *seq=[CCActionSequence actions:pre,call,nil];
        [approach_circle runAction:seq];
        
        CCAction *move_to;
        if(note.type=='b')
        {
            ccBezierConfig bezier;
            
            bezier.controlPoint_1=note.control;
            bezier.controlPoint_2=note.control2;
            bezier.endPosition=note.end;
            
            move_to=[CCActionBezierTo actionWithDuration:note.duration bezier:bezier];
        }
        else move_to=[CCActionMoveTo actionWithDuration:note.duration position:note.end];
        
        CCActionFadeOut *fade_out=[CCActionFadeOut actionWithDuration:SafeLimit/60.0];
        CCActionCallBlock *call2=[CCActionCallBlock actionWithBlock:^(void){
            slider_on_track=false;
            if(!slider_vis[approach_circle.note_no])
            {
                [self touchEffect:note.end Precision:MAX];
                slider_vis[approach_circle.note_no]=true;
            }
            [draw_slider clear];
            Active[i]=Action_Running[i]=NO;
        }];
        CCActionSequence *seq2=[CCActionSequence actions:move_to,fade_out,call2,nil];
        [delegate_circle runAction:seq2];
        
        current_note_moving=delegate_circle;
    }
    Action_Running[i]=YES;
}
-(void)touchEffect:(CGPoint)pos Precision:(int)precision
{
    int incre=100;
    if(precision>PerfectLimit) incre=50;
    if(precision>GoodLimit) incre=10;
    if(precision>SafeLimit) incre=0;
    [background updateInfo:incre];
    [background starJump:sec_per_beat*2/1000.0 score:incre];
    
    if(precision>SafeLimit)
        for(int i=0;i<effect_num;i++)
            if(!effect_running[i])
            {
                CCSprite *cross;
                cross=Cross[i];
                cross.position=pos;cross.visible=YES;
                cross.scale=1.2;cross.opacity=0;
                
                CCActionEaseBackIn *scale_to=[CCActionEaseBackIn actionWithAction:[CCActionScaleTo actionWithDuration:0.15 scale:1]];
                CCActionFadeIn *fade_in=[CCActionFadeIn actionWithDuration:0.15];
                CCActionSpawn *spawn=[CCActionSpawn actions:scale_to,fade_in,nil];
                CCActionFadeOut *fade_out=[CCActionFadeOut actionWithDuration:0.05];
                CCActionCallBlock *call=[CCActionCallBlock actionWithBlock:^(void){
                    effect_running[i]=false;
                    cross.visible=NO;
                }];
                CCActionSequence *seq=[CCActionSequence actions:spawn,fade_out,call,nil];
                [cross runAction:seq];
                effect_running[i]=true;
                return;
            }
    
    
    for(int i=0;i<effect_num;i++)
        if(!effect_running[i])
        {
            [[OALSimpleAudio sharedInstance]playEffect:@"Pa.aif"];
            
            CCSprite *halo,*nimbus;
            halo=Halo[i],nimbus=Nimbus[i];
            halo.position=nimbus.position=pos;
            halo.visible=YES;nimbus.visible=YES;
            halo.scale=0.8;nimbus.scale=0.6;
            halo.opacity=nimbus.opacity=0;
            
            CCActionFadeIn *fade_in=[CCActionFadeIn actionWithDuration:0.25];
            CCActionScaleTo *scale_to=[CCActionScaleTo actionWithDuration:0.25 scale:1];
            CCActionEaseSineIn *magnify1=[CCActionEaseSineIn actionWithAction:[CCActionSpawn actions:fade_in,scale_to,nil]];
            CCAction *fade_out=[CCActionFadeOut actionWithDuration:0.1];
            CCActionCallBlock *call=[CCActionCallBlock actionWithBlock:^(void){
                effect_running[i]=false;
                halo.visible=NO;
            }];
            CCActionSequence *seq=[CCActionSequence actions:magnify1,fade_out,call,nil];
            [halo runAction:seq];
            
            CCActionEaseSineOut *fade_in2=[CCActionEaseSineOut actionWithAction:[CCActionFadeIn actionWithDuration:0.25]];
            CCActionEaseBackIn *scale_to2=[CCActionEaseBackIn actionWithAction:[CCActionScaleTo actionWithDuration:0.25 scale:0.8]];
            CCActionSpawn *magnify2=[CCActionSpawn actions:fade_in2,scale_to2,nil];
            fade_out=[CCActionFadeOut actionWithDuration:0.1];
            call=[CCActionCallBlock actionWithBlock:^(void){
                nimbus.visible=NO;
            }];
            seq=[CCActionSequence actions:magnify2,fade_out,call,nil];
            [nimbus runAction:seq];
            
            effect_running[i]=true;
            
            return;
        }
}
-(double)distanceA:(CGPoint)a B:(CGPoint)b
{
    double ans;
    ans=sqrt((a.x-b.x)*(a.x-b.x)+(a.y-b.y)*(a.y-b.y));
    return  ans;
}
-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    if(!START) return;
    CGPoint touch_loc=get_touch_location(touch);
    
    if([self distanceA:Pause.position B:touch_loc]<Pause.contentSize.width/2.0)
        PauseShade.visible=YES;
    
    iNote *note;
    int low=(int)fmax(notes_iterator-20,0),p=-1,precision=MAX;
    for(int i=notes_iterator-1;i>=low;i--)
        if(!note_vis[i])
        {
            note=Notes[i];
            if([self distanceA:note.start B:touch_loc]<=50&&abs(frames_passed-note.offset)<precision)
                precision=abs(frames_passed-note.offset),p=i;
        }
        else break;
    
    if(p>0)
    {
        int t=((iNote*)Notes[p]).offset;
        for(int i=p-1;i>=0;i--)
        {
            note=Notes[i];
            if(t-note.offset<SafeLimit&&(!note_vis[i]))
            {
                [self touchEffect:note.start Precision:MAX];
                note_vis[i]=true;
                if(note.type!='c')
                {
                    [self touchEffect:note.end Precision:MAX];
                    slider_vis[i]=true;
                }
            }
            else break;
        }
    }
    
    if(p>=0)
    {
        note=Notes[p];
        [self touchEffect:note.start Precision:precision];
        if(note.type!='c'&&precision<=SafeLimit)
        {
            slider_on_track=true;
            limit_circle.position=note.start;
            limit_circle.opacity=1;
            for(int i=0;i<draw_nodes_num;i++)
            {
                ApproachingCircle *circle=ApproachCircles[i];
                if(circle.note_no==p)
                {
                    current_note_moving=DelegateCircles[i];
                    break;
                }
            }
        }
        note_vis[p]=true;
    }
}
-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    if([self distanceA:current_note_moving.position B:get_touch_location(touch)]>limit_circle.contentSize.width/2.0)
        slider_on_track=false;
}
-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    PauseShade.visible=NO;
    if(!START) return;
    
    CGPoint touch_loc=get_touch_location(touch);
    if([self distanceA:Pause.position B:touch_loc]<Pause.contentSize.width/2.0)
        [self pause];
    
    if(!slider_on_track) return;
    
    iNote *note;
    int low=(int)fmax(notes_iterator-10,0),precision;
    for(int i=notes_iterator-1;i>=low;i--)
    {
        note=Notes[i];
        if(note_vis[i]&&(!slider_vis[i])&&note.type!='c')
        {
            if([self distanceA:note.end B:touch_loc]<=limit_circle.contentSize.width/2.0)
                precision=abs(frames_passed-note.offset-note.duration*60);
            else precision=MAX;
            
            [self touchEffect:note.end Precision:precision];
            
            slider_on_track=false;
            slider_vis[i]=true;
            
            break;
        }
    }
}
-(void)gameStart
{
    notes_iterator=sliders_iterator=0;
    frames_passed=-frame_num_for_approachment;
    START=YES;
}
-(void)gameOver
{
    game_over_scene=[GameOverScene node];
    game_over_scene.delegate=self;
    [Player stop];
    [[CCDirector sharedDirector]pushScene:game_over_scene];
}
-(void)pause
{
    pause_scene=[PauseScene node];
    pause_scene.delegate=self;
    Player.volume=0;
    [Player pause];
    [[CCDirector sharedDirector]pushScene:pause_scene];
    [[OALSimpleAudio sharedInstance]playEffect:@"Yes.aif"];
}
-(void)quit
{
    [[CCDirector sharedDirector]popScene];
    [self scheduleBlock:^(CCTimer *timer){
        CCTransition *transition=[CCTransition transitionFadeWithColor:[color_set.preset_colors objectForKey:@"bg grey"] duration:0.5];
        [[CCDirector sharedDirector]replaceScene:[MusicSelectionScene node] withTransition:transition];
    }delay:0.2]; //schedule a delay or not?
}
-(void)resume
{
    [[CCDirector sharedDirector]popScene];
    if(START)
    {
        Player.currentTime=frames_passed/60.0;
        Player.volume=1;
        [Player play];
    }
}
-(void)ResultScene
{
    CCTransition *transition=[CCTransition transitionFadeWithColor:[CCColor colorWithCcColor3b:ccWHITE] duration:0.5];
    ResultScene *result_scene=[[ResultScene alloc]initWithID:MUSIC_ID Dif:DIF Record:background.record];
    [[CCDirector sharedDirector]replaceScene:result_scene withTransition:transition];
}
-(void)dealloc{
    NSLog(@"GameScene deallocated!");
}
@end
