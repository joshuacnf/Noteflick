//
//  RecordWin.m
//  NoteFlick
//
//  Created by Joshua Nanami on 14-7-25.
//  Copyright 2014年 Joshua Kirino. All rights reserved.
//

#import "RecordWin.h"
#import "MusicSelectionScene.h"
#import "Colors.h"
#import "InfoBlock.h"
#import "RankBlock.h"
#import <sqlite3.h>

static inline double distanceAB(CGPoint a,CGPoint b)
{
    double ans;
    ans=sqrt((a.x-b.x)*(a.x-b.x)+(a.y-b.y)*(a.y-b.y));
    return ans;
}

@implementation RecordWin
{
    CGSize scrSize;
    Colors *color_set;
    NSMutableArray *Info;
    float dif_option_h;
    CGPoint origin;
    NSString *DataBase_Path;
    
    CCSprite *dif_option;
    NSMutableArray *InfoBlocks;float block_interval;
    RankBlock *rank;CCLabelTTF *neverPlayed;
    MusicRecord *CurRecords[3];
    CCSprite *startButton,*startButtonShade;
    
    CCLabelTTF *easy,*normal,*hard;
    CCClippingNode *clip_option;CCSprite *cell_circle,*option_cell;
    
    NSMutableArray *Difs;
    
    CGPoint first_touch_loc,last_touch_loc,previous_touch_loc;
    BOOL touch_moved;double touch_start_time;
}
@synthesize ThemeColor;
@synthesize SelectedNo;
@synthesize SelectedID;
@synthesize Difficulty;
-(id)initWithSpriteFrame:(CCSpriteFrame *)spriteFrame
{
    self=[super initWithSpriteFrame:spriteFrame];
    if(!self) return self;
    
    color_set=[Colors node];
    scrSize=[CCDirector sharedDirector].viewSize;
    ThemeColor=[color_set.preset_colors objectForKey:@"red"];
    Difficulty=SelectedNo=0;
    origin=ccp(50,90);
    
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentDirecotry=[paths objectAtIndex:0];
    DataBase_Path=[documentDirecotry stringByAppendingPathComponent:@"DataBase.db"];
    
    [self initInfos];
    [self initDifSelectionBar];
    
    InfoBlocks=[NSMutableArray array];
    block_interval=self.contentSize.width-origin.x;
    for(int i=0;i<3;i++)
    {
        InfoBlock *info_block=[InfoBlock node];
        info_block.position=ccp(origin.x+i*block_interval,origin.y);
        [self addChild:info_block];
        InfoBlocks[i]=info_block;
    }
    
    neverPlayed=[CCLabelTTF labelWithString:@"Never Played" fontName:@"Roboto-Light" fontSize:70];
    neverPlayed.anchorPoint=ccp(0,0);
    neverPlayed.position=ccp(origin.x,self.contentSize.height/2.0);
    [self addChild:neverPlayed z:1];
    
    startButton=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Go.png"]];
    startButton.position=ccp(scrSize.width/2.0-startButton.contentSize.width,startButton.contentSize.height/2.0);
    [self addChild:startButton z:1];
    
    startButtonShade=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Go.png"]];
    startButtonShade.position=ccp(startButton.contentSize.width/2.0,startButton.contentSize.height/2.0);
    startButtonShade.color=[CCColor colorWithCcColor3b:ccBLACK];
    startButtonShade.opacity=0.5;
    startButtonShade.visible=NO;
    [startButton addChild:startButtonShade z:1];
    
    rank=[[RankBlock alloc]initWithStr:@""];
    rank.position=ccp(startButton.position.x+40,self.contentSize.height/2.0+20);
    [self addChild:rank z:1];
    
    [self updateInfo];
    
    self.userInteractionEnabled=YES;
    
    return self;
}
-(void)initInfos
{
    Info=[NSMutableArray array];
    
    sqlite3 *DataBase;
    sqlite3_open([DataBase_Path UTF8String],&DataBase);
    sqlite3_stmt *statement;
    
    int i=0;
    sqlite3_prepare_v2(DataBase,"SELECT ID,Title,URL FROM BeatMaps",-1,&statement,NULL);
    while(sqlite3_step(statement)==SQLITE_ROW)
    {
        MusicInfo *info=[[MusicInfo alloc]init];
        info.ID=sqlite3_column_int(statement,0);
        info.title=[NSString stringWithUTF8String:(char*)sqlite3_column_text(statement,1)];
        const void *p=sqlite3_column_blob(statement,2);
        int size=sqlite3_column_bytes(statement,2);
        if(size)
            info.url=[NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithBytes:p length:size]];
        else info.url=nil;
        Info[i++]=info;
    }
    sqlite3_finalize(statement);
    
    i=0;MusicInfo *info;
    sqlite3_prepare_v2(DataBase,"SELECT EASY_RECORD,NORMAL_RECORD,HARD_RECORD FROM Record",-1,&statement,NULL);
    while(sqlite3_step(statement)==SQLITE_ROW)
    {
        info=Info[i++];
        for(int k=0;k<3;k++)
        {
            const void* p=sqlite3_column_blob(statement,k);
            int size=sqlite3_column_bytes(statement,k);
            if(size)
            {
                NSData *data=[NSData dataWithBytes:p length:size];
                MusicRecord *record=[NSKeyedUnarchiver unarchiveObjectWithData:data];
                
                if(k==0) info.easy=record;
                else if(k==1) info.normal=record;
                else info.hard=record;
            }
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(DataBase);
}
-(void)initDifSelectionBar
{
    Difs=[NSMutableArray array];
    
    option_cell=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"DifOptionCell.png"]];
    clip_option=[CCClippingNode clippingNodeWithStencil:option_cell];
    clip_option.alphaThreshold=0;
    option_cell.position=ccp(easy.position.x,option_cell.contentSize.height/2.0);
    cell_circle=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"CellCircle.png"]];
    cell_circle.opacity=0;cell_circle.color=ThemeColor;
    [clip_option addChild:cell_circle];
    [self addChild:clip_option z:0];
    
    dif_option_h=option_cell.contentSize.height;
    dif_option=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"DifOption.png"]];
    [self addChild:dif_option z:1];
    dif_option.position=ccp(dif_option.contentSize.width/2.0,dif_option_h);
    dif_option.color=[color_set.preset_colors objectForKey:@"red"];
    
    NSString *font=@"Roboto-Thin";
    easy=[CCLabelTTF labelWithString:@"Easy" fontName:font fontSize:28];
    normal=[CCLabelTTF labelWithString:@"Normal" fontName:font fontSize:28];
    hard=[CCLabelTTF labelWithString:@"Hard" fontName:font fontSize:28];
    easy.position=ccp(dif_option.contentSize.width/2.0,28);//33.5
    normal.position=ccp(dif_option.contentSize.width*3/2.0,28);
    hard.position=ccp(dif_option.contentSize.width*5/2.0,28);
    [self addChild:easy z:1];
    [self addChild:normal z:1];
    [self addChild:hard z:1];
    Difs[0]=easy;Difs[1]=normal;Difs[2]=hard;
}
-(void)selectionChanged
{
    SelectedID=((MusicInfo*)Info[SelectedNo]).ID;
    
    CCActionTintTo *tint_to=[CCActionTintTo actionWithDuration:0.25 color:ThemeColor];
    [dif_option runAction:tint_to];
    
    [self updateInfo];
}
-(void)updateInfo
{
    InfoBlock *block;
    CurRecords[0]=((MusicInfo*)Info[SelectedNo]).easy;
    CurRecords[1]=((MusicInfo*)Info[SelectedNo]).normal;
    CurRecords[2]=((MusicInfo*)Info[SelectedNo]).hard;
    for(int i=0;i<3;i++)
    {
        block=InfoBlocks[i];
        [block updateWithRecord:CurRecords[i]];
    }
    [self updateRank];
}
-(void)updateRank
{
    MusicRecord *record=CurRecords[Difficulty];
    if(record)
    {
        if(neverPlayed.opacity>0)
        {
            CCActionFadeOut *fade_out=[CCActionFadeOut actionWithDuration:0.3];
            [neverPlayed runAction:fade_out];
        }
        [rank switchTo:record.total_rank];
    }
    else
    {
        if(neverPlayed.opacity!=1)
        {
            CCActionFadeIn *fade_in=[CCActionFadeIn actionWithDuration:0.3];
            [neverPlayed runAction:fade_in];
        }
        [rank switchTo:12450];
    }
}
-(void)updateURL:(int)ID
{
    sqlite3 *DataBase;
    sqlite3_open([DataBase_Path UTF8String],&DataBase);
    sqlite3_stmt *statement;
    
    sqlite3_prepare_v2(DataBase,"SELECT URL FROM BeatMaps WHERE ID=?",-1,&statement,NULL);
    sqlite3_bind_int(statement,1,ID);
    if(sqlite3_step(statement)==SQLITE_ROW)
    {
        MusicInfo *info;
        int n=(int)[Info count];
        for(int i=0;i<n;i++)
        {
            info=Info[i];
            if(info.ID==ID)
            {
                const void *p=sqlite3_column_blob(statement,0);
                int size=sqlite3_column_bytes(statement,0);
                info.url=[NSKeyedUnarchiver unarchiveObjectWithData:[NSData dataWithBytes:p length:size]];
                break;
            }
        }
    }
    sqlite3_finalize(statement);
    sqlite3_close(DataBase);
}
-(void)insertInfo:(MusicInfo*)info{
    Info[[Info count]]=info;
}
-(void)deleteInfo{
    [Info removeObjectAtIndex:SelectedNo];
}
-(void)touchEffect:(int)i
{
    CCLabelTTF *label=Difs[i];
    option_cell.position=ccp(label.position.x,option_cell.contentSize.height/2.0);
    [cell_circle stopAllActions];
    cell_circle.opacity=0; cell_circle.position=label.position;
    cell_circle.scale=0.1; cell_circle.color=ThemeColor;
    CCActionScaleTo *magnify=[CCActionScaleTo actionWithDuration:0.5 scale:2.5];
    CCActionFadeIn *fade_in=[CCActionFadeIn actionWithDuration:0.35];
    CCActionFadeOut *fade_out=[CCActionFadeOut actionWithDuration:0.15];
    CCActionSequence *seq=[CCActionSequence actions:fade_in,fade_out,nil];
    CCActionSpawn *spawn=[CCActionSpawn actions:magnify,seq,nil];
    CCActionEaseSineOut *action=[CCActionEaseSineOut actionWithAction:spawn];
    [cell_circle runAction:action];
}
-(void)switchInfoBlock:(int)i
{
    CCLabelTTF *label=Difs[i];
    CCActionEaseSineInOut *move_to=[CCActionEaseSineInOut actionWithAction:
                                 [CCActionMoveTo actionWithDuration:0.5 position:ccp(label.position.x,dif_option_h)]];
    [dif_option stopAllActions];
    [dif_option runAction:move_to];
    
    CGPoint vec;
    for(int k=0;k<3;k++)
    {
        vec=ccpAdd(ccp((k-i)*block_interval,0),origin);
        move_to=[CCActionEaseSineInOut actionWithAction:
                 [CCActionMoveTo actionWithDuration:0.5 position:vec]];
        [InfoBlocks[k] stopAllActions];
        [InfoBlocks[k] runAction:move_to];
    }
    Difficulty=i;
    [self updateRank];
}
-(CGPoint)getTouchLocation:(UITouch *)touch
{
    CGPoint touch_location=[touch locationInView:touch.view];
    touch_location=[[CCDirector sharedDirector]convertToGL:touch_location];
    return touch_location;
}
-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touch_loca=[self getTouchLocation:touch];
    touch_loca=[self convertToNodeSpace:touch_loca];
    first_touch_loc=previous_touch_loc=touch_loca;
    touch_start_time=CFAbsoluteTimeGetCurrent();
    touch_moved=false;
    
    CCLabelTTF *label;
    for(int i=0;i<3;i++)
    {
        label=Difs[i];
        if(CGRectContainsPoint([label boundingBox],touch_loca))
        {
            [self touchEffect:i];
            break;
        }
    }
    if(CGRectContainsPoint([startButton boundingBox],touch_loca))
        startButtonShade.visible=YES;
}
-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touch_location=[self getTouchLocation:touch];
    if(!CGRectContainsPoint([self boundingBox],touch_location)) return;
    touch_location=[self convertToNodeSpace:touch_location];
    
    touch_moved=true;
    CGPoint vec=ccp(touch_location.x-previous_touch_loc.x,0);
    InfoBlock *block;
    block=InfoBlocks[0]; if(block.position.x>origin.x&&vec.x>0) vec=ccpMult(vec,0.2);
    block=InfoBlocks[2]; if(block.position.x<origin.x&&vec.x<0) vec=ccpMult(vec,0.2);
    for(int i=0;i<3;i++)
    {
        block=InfoBlocks[i];
        if(block.position.x)
        block.position=ccpAdd(block.position,vec);
    }
    vec=ccpMult(vec,-dif_option.contentSize.width/block_interval);
    dif_option.position=ccpAdd(dif_option.position,vec);
    
    previous_touch_loc=touch_location;
}
-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    startButtonShade.visible=NO;
    
    CGPoint touch_location=[self getTouchLocation:touch];
    touch_location=[self convertToNodeSpace:touch_location];
    last_touch_loc=touch_location;
    
    if(touch_moved)
    {
        int p=-1;
        float dis=fabs(last_touch_loc.x-first_touch_loc.x);
        if(!(int)(dis/block_interval*2))
        {
            if(dis/(CFAbsoluteTimeGetCurrent()-touch_start_time)>450)
                p=Difficulty+((last_touch_loc.x-first_touch_loc.x)>0?-1:1);
            else p=Difficulty;
            if(p<0) p=0;
            if(p>2) p=2;
        }
        else
        {
            CCLabelTTF *label;int min=1<<30;
            for(int i=0;i<3;i++)
            {
                label=Difs[i];
                if(fabs(dif_option.position.x-label.position.x)<min)
                    min=fabs(dif_option.position.x-label.position.x),p=i;
            }
        }
        [self switchInfoBlock:p];
        
        return;
    }
    CCLabelTTF *label;
    for(int i=0;i<3;i++)
    {
        label=Difs[i];
        if(CGRectContainsPoint([label boundingBox],touch_location))
        {
            [self switchInfoBlock:i];
            Difficulty=i;
            break;
        }
    }
    if(CGRectContainsPoint([startButton boundingBox],touch_location))
    {
        MusicSelectionScene *P=(MusicSelectionScene*)self.parent;
        if(((MusicInfo*)Info[SelectedNo]).url)
        {
            [[OALSimpleAudio sharedInstance]playEffect:@"Go.aif"];
            [P GameScene];
        }
        else
        {
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Not Matched!" message:@"Please match the beatmap with a music in library before playing" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
            [alert show];
        }
    }
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex{
    MusicSelectionScene *P=(MusicSelectionScene*)self.parent;
    [P showLibraryList];
}
-(void)dealloc
{
    NSLog(@"record_win deallocated!");
}
@end
