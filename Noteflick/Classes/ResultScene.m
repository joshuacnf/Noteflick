//
//  ResultScene.m
//  NoteFlick
//
//  Created by Joshua Nanami on 14-8-24.
//  Copyright 2014年 Joshua Kirino. All rights reserved.
//

#import "ResultScene.h"
#import "Colors.h"
#import "InfoBlock.h"
#import "RankBlock.h"
#import "MusicInfo.h"
#import "MusicSelectionScene.h"
#import <sqlite3.h>

@implementation ResultScene
{
    Colors *color_set;
    CGSize scrSize;
    NSString *DataBase_Path,*Title;
    
    InfoBlock *his_block,*cur_block;
    RankBlock *his_rank,*cur_rank;
    MusicRecord *his_record,*cur_record;
    CCLabelTTF *TouchToContinue;
}
-(id)initWithID:(int)ID Dif:(int)Dif Record:(MusicRecord *)record
{
    self=[super init];
    if(!self) return 0;
    
    color_set=[Colors node];
    scrSize=[CCDirector sharedDirector].viewSize;
    
    [[CCDirector sharedDirector]purgeCachedData];
    CCSpriteFrameCache *cache=[CCSpriteFrameCache sharedSpriteFrameCache];
    [cache removeSpriteFrames];
    [cache addSpriteFramesWithFile:@"ResultSceneSprites.plist"];
    
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentDirecotry=[paths objectAtIndex:0];
    DataBase_Path=[documentDirecotry stringByAppendingPathComponent:@"DataBase.db"];
    
    CCSprite *background=[CCSprite spriteWithImageNamed:@"ResultSceneBackground.png"];
    background.position=ccp(scrSize.width/2.0,scrSize.height/2.0);
    [self addChild:background z:0];
    
    cur_record=record;
    [cur_record calculateRank];
    
    sqlite3 *DataBase;
    sqlite3_open([DataBase_Path UTF8String],&DataBase);
    sqlite3_stmt *statement;
    
    char *cmd="";
    switch(Dif)
    {
        case 0:cmd="SELECT Title,EASY_RECORD FROM Record WHERE ID=?"; break;
        case 1:cmd="SELECT Title,NORMAL_RECORD FROM Record WHERE ID=?"; break;
        case 2:cmd="SELECT Title,HARD_RECORD FROM Record WHERE ID=?"; break;
    }
    sqlite3_prepare_v2(DataBase,cmd,-1,&statement,NULL);
    sqlite3_bind_int(statement,1,ID);
    while(sqlite3_step(statement)==SQLITE_ROW)
    {
        Title=[NSString stringWithUTF8String:(const char*)sqlite3_column_text(statement,0)];
        const void *p=sqlite3_column_blob(statement,1);
        int size=sqlite3_column_bytes(statement,1);
        NSData *his_data=[NSData dataWithBytes:p length:size];
        his_record=[NSKeyedUnarchiver unarchiveObjectWithData:his_data];
    }
    sqlite3_finalize(statement);
    sqlite3_close(DataBase);
    
    his_block=[InfoBlock node];
    his_block.position=ccp(25,290);
    [his_block updateWithRecord:his_record];
    [self addChild:his_block];
    
    his_rank=[[RankBlock alloc]initWithStr:@""];
    his_rank.position=ccp(his_block.position.x+390,360);
    if(his_record)
        [his_rank switchTo:his_record.total_rank];
    else [his_rank switchTo:12450];
    [self addChild:his_rank];
    
    cur_block=[InfoBlock node];
    cur_block.position=ccpAdd(his_block.position,ccp(scrSize.width/2.0,0));
    [cur_block updateWithRecord:cur_record];
    [self addChild:cur_block];
    
    cur_rank=[[RankBlock alloc]initWithStr:@""];
    cur_rank.position=ccp(cur_block.position.x+390,360);
    [cur_rank switchTo:cur_record.total_rank];
    [self addChild:cur_rank];
    
    TouchToContinue=[CCLabelTTF labelWithString:@"Touch To Continue" fontName:@"Roboto-Light" fontSize:45];
    TouchToContinue.anchorPoint=ccp(0.5,0.5);
    TouchToContinue.position=ccp(scrSize.width/2.0,scrSize.height/6.0);
    TouchToContinue.opacity=0;
    TouchToContinue.color=[color_set.preset_colors objectForKey:@"light blue"];
    [self addChild:TouchToContinue z:1];
    
    CCActionEaseSineIn *fade_in=[CCActionEaseSineIn actionWithAction:[CCActionFadeIn actionWithDuration:1]];
    CCActionEaseSineInOut *fade_out=[CCActionEaseSineIn actionWithAction:[CCActionFadeOut actionWithDuration:0.5]];
    CCActionRepeatForever *repeat=[CCActionRepeatForever actionWithAction:
                                   [CCActionSequence actions:fade_in,fade_out,nil]];
    [TouchToContinue runAction:repeat];
    
    
    [self updateRecord:ID Dif:Dif];
    
    self.userInteractionEnabled=YES;
    
    return self;
}
-(void)updateRecord:(int)ID Dif:(int)Dif
{
    if(his_record)
    {
        cur_record.score=(int)fmax(cur_record.score,his_record.score);
        cur_record.combo=(int)fmax(cur_record.combo,his_record.combo);
        cur_record.ac=fmax(cur_record.ac,his_record.ac);
    }
    [cur_record calculateRank];
    NSData *data=[NSKeyedArchiver archivedDataWithRootObject:cur_record];
    
    sqlite3 *DataBase;
    sqlite3_open([DataBase_Path UTF8String],&DataBase);
    sqlite3_stmt *statement;
    
    char *cmd="";
    switch(Dif)
    {
        case 0:cmd="UPDATE Record SET EASY_RECORD=? WHERE ID=?"; break;
        case 1:cmd="UPDATE Record SET NORMAL_RECORD=? WHERE ID=?"; break;
        case 2:cmd="UPDATE Record SET HARD_RECORD=? WHERE ID=?"; break;
    }
    sqlite3_prepare_v2(DataBase,cmd,-1,&statement,NULL);
    sqlite3_bind_blob(statement,1,[data bytes],(int)[data length],NULL);
    sqlite3_bind_int(statement,2,ID);
    sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(DataBase);
}
-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    [self scheduleOnce:@selector(MusicSelectionScene) delay:0.1];
    self.userInteractionEnabled=NO;
}
-(void)MusicSelectionScene
{
    CCTransition *transition=[CCTransition transitionFadeWithColor:[CCColor colorWithCcColor3b:ccWHITE] duration:0.3];
    [[CCDirector sharedDirector]replaceScene:[MusicSelectionScene node] withTransition:transition];
    [[OALSimpleAudio sharedInstance]playEffect:@"Yes.aif"];
}
-(void)dealloc{
    NSLog(@"ResultScene deallocated!");
}
@end
