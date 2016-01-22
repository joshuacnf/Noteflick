//
//  ScrollList.m
//  NoteFlick
//
//  Created by Joshua Kirino on 14-3-9.
//  Copyright 2014年 Joshua Kirino. All rights reserved.
//
#import <sqlite3.h>
#import "MusicList.h"
#import "Colors.h"
#import "MusicSelectionScene.h"

static inline CGPoint get_touch_location(UITouch *touch)
{
    CGPoint touch_location=[touch locationInView:touch.view];
    touch_location=[[CCDirector sharedDirector]convertToGL:touch_location];
    return touch_location;
}
@implementation MusicList
{
    CCNode *ListNode;
    NSMutableArray *Options,*Titles,*Labels;
    int Options_Num;
    
    Colors *color_set;
    BOOL touch_moved,UPDATE;
    BOOL adjusted,slide_finished,strengthened_friction,touch_ended,deleting;
    CGPoint First_Touch_Location,Last_Touch_Location,previous_touch_location;
    CCSprite *SelectedOption,*ShadeOption;
    float Top,Bottom;
    NSString *DataBase_Path;
    
    CGSize scrSize;
    double velocity;
    int adjust_time_elapsed;
    double touch_start_time,touch_end_time;
    double sensitivity,acceleration;
    int MidLine,Line_Above_Mid,Line_Beneath_Mid;
    
    int ADJUST_TIME,NUM_IN_VIEW;
    double PROTO_ACCEL,MIN_VELOCITY,MID_XPOSTION_RATIO,INIT_POS_TIME;
    int pressed_no;

}
@synthesize SelectedNo,SelectedTitle,SelectedColor;
@synthesize Moving,touch_moved;
@synthesize INTERVAL;
-(id)init
{
    self=[super init];
    if(!self) return self;
    
    color_set=[Colors node];
    scrSize=[CCDirector sharedDirector].viewSize;
    CCSprite *option_sprite=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"MusicOption.png"]];
    [OALSimpleAudio sharedInstance].preloadCacheEnabled=YES;
    [[OALSimpleAudio sharedInstance]preloadEffect:@"ListMoved.aif"];
    
    ADJUST_TIME=31;
    MIN_VELOCITY=PROTO_ACCEL=1;
    INIT_POS_TIME=1;
    MidLine=scrSize.height/2.0;
    UPDATE=NO;
    
    INTERVAL=[self.delegate optionsInterval];
    NUM_IN_VIEW=ceil(scrSize.height/INTERVAL)+1;
    Line_Above_Mid=MidLine+INTERVAL;
    Line_Beneath_Mid=MidLine-INTERVAL;
    ListNode=[CCNode node];
    Titles=[self.delegate dataSource];
    MID_XPOSTION_RATIO=[self.delegate xPositionShift];
    Options_Num=[Titles count];
    
    touch_moved=adjusted=false;
    slide_finished=true;
    velocity=acceleration=0;
    pressed_no=-1;
    
    int edge_width=100;
    self.contentSize=CGSizeMake(option_sprite.contentSize.width+edge_width,
                                scrSize.height);//-2*INTERVAL+option_sprite.contentSize.height/2);
    self.anchorPoint=ccp(0.5,0.5);
    

    NSString *color_name[4]={@"red",@"yellow",@"light blue",@"light green"};
    Options=[NSMutableArray array];
    Labels=[NSMutableArray array];
    ListNode=[CCNode node];
    ListNode.position=ccp(self.contentSize.width/2.0,MidLine);
    
    CCLabelTTF *label;
    for(int i=0;i<Options_Num;i++)
    {
        option_sprite=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"MusicOption.png"]];
        option_sprite.anchorPoint=ccp(0.5,0.5);
        option_sprite.position=ccp(0,-i*INTERVAL);
        option_sprite.color=[color_set.preset_colors objectForKey:color_name[i%4]];
        Options[i]=option_sprite;
        
        label=[CCLabelTTF labelWithString:Titles[i%Options_Num] fontName:@"Roboto-Light" fontSize:28];
        label.position=ccp(option_sprite.contentSize.width/2.0,option_sprite.contentSize.height/2.0);
        [option_sprite addChild:label z:1];
        Labels[i]=label;
        
        [ListNode addChild:option_sprite z:1];
        
        if(i>10) option_sprite.visible=NO;
    }
    ListNode.position=ccp(self.contentSize.width/2.0,MidLine);
    [self addChild:ListNode z:1];
    
    Top=ListNode.position.y;
    Bottom=ListNode.position.y-(Options_Num-1)*INTERVAL;
    ((CCSprite*)Options[0]).position=ccp(-INTERVAL*MID_XPOSTION_RATIO,0);
    
    ShadeOption=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"MusicOption.png"]];
    ShadeOption.color=[CCColor colorWithCcColor3b:ccBLACK];
    ShadeOption.opacity=0.5;
    ShadeOption.position=ccp(option_sprite.contentSize.width/2.0,option_sprite.contentSize.height/2.0);
    
    SelectedNo=0;
    SelectedOption=Options[0];
    SelectedColor=SelectedOption.color;
    
    self.userInteractionEnabled=NO;
    
    [self ListEnter];
    
    [self scheduleBlock:^(CCTimer *timer)
    {
        self.userInteractionEnabled=YES;
        UPDATE=YES;
    }delay:INIT_POS_TIME+0.2];
    
    return self;
}
-(void)update:(CCTime)delta
{
    if(((!UPDATE)||(!touch_ended))&&(!deleting)) return;
    
    Top=ListNode.position.y;
    Bottom=ListNode.position.y-(Options_Num-1)*INTERVAL;
    
    if(Top<0||Bottom>scrSize.height) self.userInteractionEnabled=NO;
    else self.userInteractionEnabled=YES;
    
    if(fabs(velocity)<MIN_VELOCITY&&(!slide_finished))
    {
        velocity=0;
        acceleration=0;
        slide_finished=true;
    }
    if((slide_finished||(!touch_moved))&&(!adjusted))
        [self adjustAccel:[self getAdjustDistance]];
    
    if((Top<MidLine||Bottom>MidLine)&&(!strengthened_friction)&&(!adjusted))
    {
        acceleration=-velocity/15;
        strengthened_friction=true;
    }
    
    velocity+=acceleration;
    
    if(adjusted)
        adjust_time_elapsed++;
    if(adjust_time_elapsed==(int)(ADJUST_TIME/2)+1)
        acceleration=-acceleration;
    if(adjust_time_elapsed==ADJUST_TIME)
    {
        velocity=0;
        acceleration=0;
        touch_ended=false;
        touch_moved=false;
        if([self.delegate respondsToSelector:@selector(selectionChanged)])
            [self.delegate selectionChanged];
    }
    if(velocity||deleting||acceleration||touch_moved)   //Touch Moved Changed to velocity
        Moving=true;
    else Moving=false;
    
    if(velocity||deleting) [self updatePos:velocity];
}
-(void)adjustAccel:(double)distance
{
    velocity=0;
    int t=0;
    for(int i=1;i<=ADJUST_TIME;i+=2)
        t+=i;
    acceleration=distance/(t*1.0);
    touch_ended=slide_finished=adjusted=true;
    adjust_time_elapsed=0;
}
-(double)getAdjustDistance
{
    Top=ListNode.position.y;
    Bottom=ListNode.position.y-(Options_Num-1)*INTERVAL;
    double distance=0,pos_y=0;
    if(Top>=MidLine&&Bottom<=MidLine)
    {
        pos_y=Top;
        pos_y-=MidLine;
        int low=floor(pos_y/INTERVAL)*INTERVAL;
        int high=ceil(pos_y/INTERVAL)*INTERVAL;
        if(pos_y-low<high-pos_y)
            distance=low-pos_y;
        else distance=high-pos_y;
    }
    else if(Top<MidLine)
        distance=MidLine-Top;
    else if(Bottom>MidLine)
        distance=MidLine-Bottom;
    return distance;
}
-(void)updatePos:(float)dx
{
    CGPoint npos=ccp(ListNode.position.x,ListNode.position.y+dx);
    ListNode.position=npos;
    
    int s=ceil((npos.y-Line_Above_Mid)/(INTERVAL*1.0));
    s=(int)fmin(s,Options_Num-1);
    int e=(int)fmin(s+3,Options_Num);
    s=(int)fmax(s,0);e=(int)fmax(e,0);
    
    CCSprite *option;
    CCLabelTTF *label;
    for(int i=s;i<e;i++)
    {
        option=Options[i],label=Labels[i];
        float y=ListNode.position.y+option.position.y;
        if(Line_Beneath_Mid<=y&&y<=Line_Above_Mid)
            option.position=ccp(-(INTERVAL-abs(y-MidLine))*MID_XPOSTION_RATIO,option.position.y);
        
        if(fabs(option.position.y+ListNode.position.y-MidLine)<10)
        {
            if(SelectedNo!=i)
                [[OALSimpleAudio sharedInstance]playEffect:@"ListMoved.aif"];
            SelectedOption=option;
            SelectedTitle=label.string;
            SelectedColor=option.color;
            SelectedNo=i;
        }
    }
    if(s)
    {
        option=Options[s-1];
        option.position=ccp(0,option.position.y);
    }
    if(e<Options_Num-1)
    {
        option=Options[e+1];
        option.position=ccp(0,option.position.y);
    }
    
    s=ceil((npos.y-scrSize.height-INTERVAL)/(INTERVAL*1.0));
    s=(int)fmin(s,Options_Num-1);
    e=(int)fmin(s+NUM_IN_VIEW,Options_Num);
    s=(int)fmax(s,0);e=(int)fmax(e,0);
    for(int i=s;i<e;i++)
    {
        option=Options[i],label=Labels[i];
        option.visible=label.visible=YES;
    }
    if(s)
    {
        option=Options[s-1],label=Labels[s-1];
        option.visible=label.visible=NO;
    }
    if(e<Options_Num-1)
    {
        option=Options[e+1],label=Labels[e+1];
        option.visible=label.visible=NO;
    }
}
-(void)ListEnter
{
    CCActionEaseBackOut *scale_to;
    int num=Options_Num<NUM_IN_VIEW?Options_Num:NUM_IN_VIEW;
    CCSprite *option;
    for(int i=0;i<num;i++)
    {
        option=Options[i];
        option.scale=0.1;
        scale_to=[CCActionEaseBackOut actionWithAction:[CCActionScaleTo actionWithDuration:0.5 scale:1]];
        [option runAction:scale_to];
    }
}
-(void)adjustPosAfterDeletion:(int)no
{
    int num=(int)[Options count];
    CCActionMoveBy *move;
    deleting=YES;
    CGPoint vec=ccp(0,INTERVAL);
    if(no==num)
    {
        move=[CCActionEaseSineInOut actionWithAction:[CCActionMoveBy actionWithDuration:0.5 position:ccpMult(vec,-1)]];
        [ListNode runAction:move];
    }
    int s=no,e=num;
    for(int i=s;i<e;i++)
    {
        move=[CCActionEaseSineInOut actionWithAction:[CCActionMoveBy actionWithDuration:0.5 position:vec]];
        [self scheduleBlock:^(CCTimer *timer)
        {
            [Options[i] runAction:move];
        }delay:(i-s)/((e-s)*1.0)*0.5];
    }
}
-(int)optionsNum{
    return Options_Num;
}
-(void)insertOption:(NSString*)title
{
    NSString *color_name[4]={@"red",@"yellow",@"light blue",@"light green"};
    Titles[Options_Num++]=title;
    
    CCSprite *option=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"MusicOption.png"]];
    option.color=[color_set.preset_colors objectForKey:color_name[Options_Num%4]];
    option.position=ccp(0,-(Options_Num-1)*INTERVAL);
    [ListNode addChild:option z:1];
    Options[Options_Num-1]=option;
    
    CCLabelTTF *label=[CCLabelTTF labelWithString:title fontName:@"Roboto-Light" fontSize:30];
    label.position=ccp(option.contentSize.width/2.0,option.contentSize.height/2.0);
    [option addChild:label z:2];
    Labels[Options_Num-1]=label;
    
    if(option.position.y>-option.contentSize.height)
    {
        option.scale=0.1;
        CCActionEaseBackIn *magnify=[CCActionEaseBackIn actionWithAction:[CCActionScaleTo actionWithDuration:0.25 scale:1]];
        [option runAction:magnify];
    }
}
-(void)deleteOption
{
    self.userInteractionEnabled=NO;
    
    [ListNode removeChild:SelectedOption];
    [Options removeObjectAtIndex:SelectedNo];
    [Titles removeObjectAtIndex:SelectedNo];
    [Labels removeObjectAtIndex:SelectedNo];

    Options_Num=[Options count];
    [self adjustPosAfterDeletion:SelectedNo];
    [self scheduleBlock:^(CCTimer *timer)
    {
        deleting=NO;
        self.userInteractionEnabled=YES;
    }delay:1];
}
-(BOOL)exist:(NSString *)title
{
    for(int i=0;i<Options_Num;i++)
        if([title compare:Titles[i]]==NSOrderedSame)
            return true;
    return false;
}
-(int)searchOption:(NSString *)title
{
    for(int i=0;i<Options_Num;i++)
        if([((NSString*)Titles[i]) rangeOfString:title options:NSCaseInsensitiveSearch].length)
            return i;
    return -1;
}
-(void)moveToOption:(int)i
{
    CCSprite *option=Options[i];
    [self adjustAccel:MidLine-ListNode.position.y-option.position.y];
}
-(void)addMark:(int)i
{
    CCSprite *option=Options[i];
    CCSprite *pin=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Pin.png"]];
    pin.scale=0.1;pin.position=ccp(15,option.contentSize.height/2.0+30);
    [option addChild:pin z:4 name:@"pin"];
    CCActionEaseBackOut *magnify=[CCActionEaseBackOut actionWithAction:[CCActionScaleTo actionWithDuration:0.25 scale:1]];
    [pin runAction:magnify];
}
-(void)removeMark:(int)i
{
    CCSprite *option=Options[i];
    CCSprite *pin=[option getChildByName:@"pin" recursively:NO];
    CCActionEaseBackIn *minimize=[CCActionEaseBackIn actionWithAction:[CCActionScaleTo actionWithDuration:0.25 scale:0.1]];
    CCActionCallBlock *call=[CCActionCallBlock actionWithBlock:^(void){
        [pin removeFromParentAndCleanup:YES];
    }];
    CCActionSequence *seq=[CCActionSequence actions:minimize,call,nil];
    [pin runAction:seq];
}
-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    touch_moved=touch_ended=adjusted=strengthened_friction=false;
    sensitivity=1;
    First_Touch_Location=get_touch_location(touch);
    previous_touch_location=First_Touch_Location;
    touch_start_time=CFAbsoluteTimeGetCurrent();
    
    CGPoint touch_location=[ListNode convertToNodeSpace:First_Touch_Location];
    CCSprite *option;
    int s=(int)fmax(SelectedNo-NUM_IN_VIEW/2+1,0),e=(int)fmin(SelectedNo+NUM_IN_VIEW/2+1,Options_Num-1);
    for(int i=s;i<=e;i++)
    {
        option=Options[i];
        if(CGRectContainsPoint([option boundingBox],touch_location))
        {
            if(ShadeOption.parent)
                [ShadeOption removeFromParent];
            [option addChild:ShadeOption z:2];
            pressed_no=i;
            break;
        }
    }
}
-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    touch_moved=true;
    if([self.delegate respondsToSelector:@selector(listDragged)])
        [self.delegate listDragged];
    
    Top=ListNode.position.y;
    Bottom=ListNode.position.y-(Options_Num-1)*INTERVAL;
    
    if((Bottom>MidLine||Top<MidLine)&&sensitivity>0.05)
        sensitivity-=0.035;
    
    CGPoint touch_location=get_touch_location(touch);
    if(!CGRectContainsPoint([self boundingBox],touch_location))
    {
        previous_touch_location=touch_location;
        return;
    }
    [self updatePos:(touch_location.y-previous_touch_location.y)*sensitivity];
    previous_touch_location=touch_location;
}
-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{    
    adjusted=false;
    touch_ended=true;
    Moving=false;
    
    if(pressed_no>=0)
    {
        [ShadeOption removeFromParent];
        pressed_no=-1;
    }
    CGPoint touch_location=get_touch_location(touch);
    if(touch_moved)
    {
        Last_Touch_Location=touch_location;
        touch_end_time=CFAbsoluteTimeGetCurrent();
        
        velocity=(Last_Touch_Location.y-First_Touch_Location.y)/
        (touch_end_time-touch_start_time)/60.0;
        
        acceleration=-PROTO_ACCEL;
        
        if(velocity<0)
            acceleration=fabs(acceleration);
        if(fabs(velocity)>120||fabs(velocity)<0.01||touch_end_time-touch_start_time>0.5)
        {
            velocity=0;
            touch_moved=false;
        }
        
        slide_finished=false;
        adjust_time_elapsed=0;
    }
    else
    {
        slide_finished=true;
        touch_location=[ListNode convertToNodeSpace:First_Touch_Location];
        if(!Moving)
        {
            CCSprite *option;
            int s=(int)fmax(SelectedNo-NUM_IN_VIEW/2+1,0),e=(int)fmin(SelectedNo+NUM_IN_VIEW/2+1,Options_Num-1);
            for(int i=s;i<=e;i++)
            {
                option=Options[i];
                if(CGRectContainsPoint([option boundingBox],touch_location))
                {
                    if([self.delegate respondsToSelector:@selector(optionTouched:)])
                        [self.delegate optionTouched:i];
                }
            }
        }
    }
}
-(void)dealloc{
    NSLog(@"Music List dealloced");
}
@end