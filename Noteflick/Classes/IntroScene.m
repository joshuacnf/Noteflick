//
//  IntroScene.m
//  NoteFlick
//
//  Created by Joshua Kirino on 14-3-2.
//  Copyright 2014年 Joshua Kirino. All rights reserved.
//

#import "IntroScene.h"
#import "MainScene.h"
#import <sqlite3.h>
@implementation IntroScene
{
    CGSize scrSize;
    NSMutableArray *Bars;
    int order[33]; bool vis[33];
    
    CCSprite *Background,*BlueBar,*ColorBar,*ColorBackground;
    CCSprite *ColorNote,*Note;
    
    double interval;
}
+(id)scene
{
    return [self node];
}
-(id)init
{
    self=[super init];
    if(!self) return self;

    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSNumber *played_before=[userDefaults objectForKey:@"played_before"];
    if(!played_before)
        [self initializeDataBase];
    
    srand((int)time(0));
    
    CCSpriteFrameCache *cache=[CCSpriteFrameCache sharedSpriteFrameCache];
    [cache addSpriteFramesWithFile:@"IntroSceneSprites.plist"];
    
    scrSize=[CCDirector sharedDirector].viewSize;
    interval=1.5/16.0;
    Bars=[NSMutableArray array];

    [self initBars];
    [self initTransitionSprites];
    
    [self scheduleOnce:@selector(transitionIn) delay:0.3];
    [self scheduleOnce:@selector(transitionOut) delay:interval*16+0.6];
    [self scheduleOnce:@selector(MainScene) delay:interval*16+0.6+2.8];
    
    return self;
}
-(void)initializeDataBase
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentDirecotry=[paths objectAtIndex:0];
    NSString *DataBase_Path=[documentDirecotry stringByAppendingPathComponent:@"DataBase.db"];
    
    sqlite3 *DataBase;
    sqlite3_open([DataBase_Path UTF8String],&DataBase);
    sqlite3_stmt *statement;
    
    sqlite3_prepare_v2(DataBase,"CREATE TABLE IF NOT EXISTS BeatMaps(ID INTEGER PRIMARY KEY AUTOINCREMENT,Title TEXT,Artist TEXT,EASY BLOB,NORMAL BLOB,HARD BLOB,URL BLOB)",-1,&statement,NULL);
    sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    sqlite3_prepare_v2(DataBase,"CREATE TABLE IF NOT EXISTS Record(ID INTEGER PRIMARY KEY AUTOINCREMENT,Title TEXT,Artist TEXT,EASY_RECORD BLOB,NORMAL_RECORD BLOB,HARD_RECORD BLOB)",-1,&statement,NULL);
    sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    sqlite3_prepare_v2(DataBase,"CREATE TABLE IF NOT EXISTS UserRecord(ID INTEGER PRIMARY KEY AUTOINCREMENT,Exp INT,Achievement TEXT)",-1,&statement,NULL);
    sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    NSString *name;
    NSData *beatmap_data;
    
    sqlite3_prepare_v2(DataBase,"INSERT INTO BeatMaps(Title,Artist,EASY,NORMAL,HARD)VALUES('Bad Apple','Nomico',?,?,?)"
                       ,-1,&statement,NULL);
    for(int i=1;i<=3;i++)
    {
        name=[NSString stringWithFormat:@"Bad Apple%d",i];
        NSString *path=[[NSBundle mainBundle]pathForResource:name ofType:@""];
        beatmap_data=[NSData dataWithContentsOfFile:path];
        sqlite3_bind_blob(statement,i,[beatmap_data bytes],(int)[beatmap_data length],NULL);
    }
    sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    sqlite3_prepare_v2(DataBase,"INSERT INTO BeatMaps(Title,Artist,EASY,NORMAL,HARD)VALUES('Start Dash (TV size)','μs',?,?,?)",-1,&statement,NULL);
    for(int i=1;i<=3;i++)
    {
        name=[NSString stringWithFormat:@"Start Dash (TV size)%d",i];
        NSString *path=[[NSBundle mainBundle]pathForResource:name ofType:@""];
        beatmap_data=[NSData dataWithContentsOfFile:path];
        sqlite3_bind_blob(statement,i,[beatmap_data bytes],(int)[beatmap_data length],NULL);
    }
    sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    sqlite3_prepare_v2(DataBase,"INSERT INTO BeatMaps(Title,Artist,EASY,NORMAL,HARD)VALUES('You Belong With Me','Taylor Swift',?,?,?)",-1,&statement,NULL);
    for(int i=1;i<=3;i++)
    {
        name=[NSString stringWithFormat:@"You Belong With Me%d",i];
        NSString *path=[[NSBundle mainBundle]pathForResource:name ofType:@""];
        beatmap_data=[NSData dataWithContentsOfFile:path];
        sqlite3_bind_blob(statement,i,[beatmap_data bytes],(int)[beatmap_data length],NULL);
    }
    sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    sqlite3_prepare_v2(DataBase,"INSERT INTO Record(Title,Artist) VALUES('Bad Apple','Nomico')",-1,&statement,NULL);
    sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    sqlite3_prepare_v2(DataBase,"INSERT INTO Record(Title,Artist) VALUES('Start Dash (TV size)','μs')",-1,&statement,NULL);
    sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    sqlite3_prepare_v2(DataBase,"INSERT INTO Record(Title,Artist) VALUES('You Belong With Me','Taylor Swift')",-1,&statement,NULL);
    sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(DataBase);
}
-(void)initBars
{
    CCSprite *bar;NSString *name;
    double pre_y=scrSize.height;
    double origin_x=-scrSize.width/4.0;
    for(int i=0;i<16;i++)
    {
        name=[NSString stringWithFormat:@"%d.png",i+1];
        bar=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:name]];
        bar.position=ccp(origin_x,pre_y-bar.contentSize.height/2.0);
        bar.scaleX=1.005;bar.scaleY=1.015;
        [self addChild:bar z:1];
        Bars[i]=bar;
        pre_y=bar.position.y-bar.contentSize.height/2.0;
    }
    
    pre_y=scrSize.height;
    origin_x=scrSize.width*5/4.0;
    for(int i=16;i<32;i++)
    {
        name=[NSString stringWithFormat:@"%d.png",i-15];
        bar=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:name]];
        bar.position=ccp(origin_x,pre_y-bar.contentSize.height/2.0);
        [self addChild:bar z:4];
        Bars[i]=bar;
        pre_y=bar.position.y-bar.contentSize.height/2.0;
    }
    
    for(int i=0,k;i<32;i++)
    {
        do{
            k=rand()%32;
        }while(vis[k]);
        order[i]=k,vis[k]=true;
    }
}
-(void)initTransitionSprites
{
    Background=[CCSprite spriteWithImageNamed:@"IntroSceneBackground.png"];
    Background.position=ccp(scrSize.width/2.0,scrSize.height/2.0);
    [self addChild:Background z:0];
    
    BlueBar=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"BlueBar.png"]];
    BlueBar.position=ccp(507,245);
    BlueBar.opacity=0;
    [self addChild:BlueBar z:1];
    
    ColorBar=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"ColorBar.png"]];
    ColorBar.position=ccp(scrSize.width/2.0,scrSize.height/2.0);
    ColorBar.opacity=0;
    [self addChild:ColorBar z:2];
    
    ColorBackground=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"ColorBackground.png"]];
    ColorBackground.position=ccp(scrSize.width/2.0,scrSize.height/2.0);
    ColorBackground.visible=NO;
    [self addChild:ColorBackground z:3];
    
    Note=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"IntroSceneNote.png"]];
    Note.position=ccp(scrSize.width/2.0,scrSize.height/2.0);
    [self addChild:Note z:5];
    
    ColorNote=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"ColorNote.png"]];
    ColorNote.position=ccp(Note.contentSize.width/2.0,Note.contentSize.height/2.0);
    ColorNote.opacity=0;
    [Note addChild:ColorNote z:0];
}
-(void)transitionIn
{
    CGPoint vec;
    for(int i=0;i<32;i+=2)
        for(int j=0;j<2;j++)
        {
            int k=order[i+j];
            vec=ccp(scrSize.width/2.0,0);
            if(k>=16)
                vec=ccpMult(vec,-1);
            [self scheduleBlock:^(CCTimer *timer){
                CCActionEaseSineInOut *move_by=[CCActionEaseSineInOut actionWithAction:
                                                [CCActionMoveBy actionWithDuration:0.3 position:vec]];
                [Bars[k] runAction:move_by];
            }delay:(i>>1)*interval];
        }
}
-(void)transitionOut
{
    float move_time=1.5,fade_time=0.7;
    for(int i=0;i<32;i++) [Bars[i] removeFromParent];
    
    ColorBackground.visible=YES;
    CCActionEaseSineInOut *narrow=[CCActionEaseSineInOut actionWithAction:
                                   [CCActionScaleTo actionWithDuration:move_time scaleX:1 scaleY:0.22916]];
    CCActionFadeOut *fade_out=[CCActionFadeOut actionWithDuration:fade_time];
    CCActionCallBlock *call=[CCActionCallBlock actionWithBlock:^(void){
        [ColorBackground removeFromParent];
    }];
    CCActionSequence *seq=[CCActionSequence actions:narrow,fade_out,call,nil];
    [ColorBackground runAction:seq];
    
    
    CCActionInterval *pre=[CCActionInterval actionWithDuration:move_time];
    CCActionFadeIn *fade_in=[CCActionFadeIn actionWithDuration:fade_time];
    seq=[CCActionSequence actions:pre,fade_in,nil];
    [ColorBar runAction:seq];
    
    pre=[CCActionInterval actionWithDuration:move_time+fade_time];
    fade_in=[CCActionFadeIn actionWithDuration:0.3];
    seq=[CCActionSequence actions:pre,fade_in,nil];
    [BlueBar runAction:seq];
    
    
    fade_in=[CCActionFadeIn actionWithDuration:move_time];
    [ColorNote runAction:fade_in];

    CCActionEaseSineInOut *move_to=[CCActionEaseSineInOut actionWithAction:
                                    [CCActionMoveTo actionWithDuration:move_time position:ccp(280,scrSize.height/2.0)]];
    fade_out=[CCActionFadeOut actionWithDuration:move_time];
    CCActionSpawn *spawn=[CCActionSpawn actions:move_to,fade_out,nil];
    [Note runAction:spawn];
}
-(void)MainScene{
    [[CCDirector sharedDirector]replaceScene:[MainScene node]];
}
-(void)dealloc
{
    NSLog(@"intro_scene deallocated!");
}
@end
