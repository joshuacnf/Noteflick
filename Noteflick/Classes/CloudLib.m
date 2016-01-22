//
//  CloudScene.m
//  NoteFlick
//
//  Created by Joshua Nanami on 14-8-17.
//  Copyright 2014年 Joshua Kirino. All rights reserved.
//

#import "CloudLib.h"
#import "Colors.h"
#import "MusicSelectionScene.h"
#import "BeatMap.h"
#import <sqlite3.h>

@implementation CloudLib
{
    Colors *color_set;
    CGSize scrSize;
    NSString *tmp_dir,*DataBase_Path;
    NSMutableArray *Titles;
    CCSprite *checkButton,*checkButtonShade,*check;
    CCSprite *back,*backShade;
    MusicList *List;int options_num;
    ASINetworkQueue *queue;
    int q_no[1003],q_dif[1003];
    NSMutableData *temp_data;
    bool success,select[1003];
    int finished_task,select_num;
}
-(id)init
{
    self=[super init];
    if(!self) return self;

    color_set=[Colors node];
    scrSize=[CCDirector sharedDirector].viewSize;
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentDirecotry=[paths objectAtIndex:0];
    DataBase_Path=[documentDirecotry stringByAppendingPathComponent:@"DataBase.db"];
    
    self.contentSize=scrSize;
    self.anchorPoint=ccp(0,0);
    
    finished_task=select_num=0;
    success=false;
    [self requestList];
    if(success)
    {
        List=[MusicList alloc];
        List.delegate=self;
        List=[List init];
        List.contentSize=CGSizeMake(List.contentSize.width,List.contentSize.height-150);
        List.position=ccp(scrSize.width/2.0,List.contentSize.height/2.0);
        [self addChild:List z:1];
        
        queue=[[ASINetworkQueue alloc]init];
        [queue reset];
        [queue setDelegate:self];
        [queue setQueueDidFinishSelector:@selector(queueDidFinished:)];
        [queue setShouldCancelAllRequestsOnFailure:YES];
        [queue setMaxConcurrentOperationCount:1];
    }
    
    checkButton=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"CheckButton.png"]];
    checkButton.position=ccp(scrSize.width/2.0,scrSize.height-checkButton.contentSize.height/2.0);
    [self addChild:checkButton z:2];
    
    checkButtonShade=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"CheckButton.png"]];
    checkButtonShade.position=ccp(checkButton.contentSize.width/2.0,checkButton.contentSize.height/2.0);
    checkButtonShade.color=[CCColor colorWithCcColor3b:ccBLACK];
    checkButtonShade.opacity=0.5;
    checkButtonShade.visible=NO;
    [checkButton addChild:checkButtonShade z:2];
    
    check=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"CheckMark.png"]];
    check.position=ccp(checkButton.contentSize.width/2.0,checkButton.contentSize.height/2.0);
    check.color=[color_set.preset_colors objectForKey:@"bg grey"];
    [checkButton addChild:check z:1];
    
    back=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Download.png"]];
    back.flipY=YES;
    back.position=ccp(back.contentSize.width*3/4.0,back.contentSize.height*3/4.0);
    back.color=[color_set.preset_colors objectForKey:@"bg grey"];
    [self addChild:back z:1];
    
    backShade=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"SelectionSceneShadeCircle.png"]];
    backShade.position=ccp(back.contentSize.width/2.0,back.contentSize.height/2.0);
    backShade.color=[CCColor colorWithCcColor3b:ccBLACK];
    backShade.opacity=0.5;
    backShade.visible=NO;
    [back addChild:backShade z:1];
    
    CCNodeColor *background=[CCNodeColor nodeWithColor:[CCColor colorWithCcColor3b:ccBLACK]];
    background.opacity=0.75;
    [self addChild:background z:0];
    
    self.userInteractionEnabled=YES;
    
    return self;
}
-(void)requestList
{
    NSURL *url=[NSURL URLWithString:@"http://MaxXSoft.net/Joshua/beatmap.php"];
    ASIFormDataRequest *request=[ASIFormDataRequest requestWithURL:url];
    [request setDelegate:self];
    [request setPostValue:@"glist" forKey:@"request"];
    [request setDidFailSelector:@selector(requestFailed:)];
    [request setDidReceiveDataSelector:@selector(request:didReceiveData:)];
    [request setTimeOutSeconds:1];
    [request startSynchronous];
}
-(void)insertNewRowInDataBase:(NSString*)title
{
    sqlite3 *DataBase;
    sqlite3_open([DataBase_Path UTF8String],&DataBase);
    sqlite3_stmt *statement;
    
    char *c_title=[title UTF8String];
    sqlite3_prepare_v2(DataBase,"INSERT INTO BeatMaps(Title) VALUES(?)",-1,&statement,NULL);
    sqlite3_bind_text(statement,1,c_title,strlen(c_title),SQLITE_STATIC);
    sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    sqlite3_prepare_v2(DataBase,"INSERT INTO Record(Title) VALUES(?)",-1,&statement,NULL);
    sqlite3_bind_text(statement,1,c_title,strlen(c_title),SQLITE_STATIC);
    sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(DataBase);
}
-(void)requestBeatMap
{
    self.userInteractionEnabled=NO;
    memset(q_no,0,sizeof(q_no));
    memset(q_dif,0,sizeof(q_dif));
    
    MusicSelectionScene *P=self.parent;
    NSURL *url=[NSURL URLWithString:@"http://MaxXSoft.net/Joshua/beatmap.php"];
    ASIFormDataRequest *request;
    finished_task=0;
    for(int i=0;i<options_num;i++)
        if(select[i]&&(![P exist:Titles[i]]))
        {
            [self insertNewRowInDataBase:Titles[i]];
            for(int k=1;k<=3;k++)
            {
                NSString *value=[NSString stringWithFormat:@"%@%d",Titles[i],k];
                request=[ASIFormDataRequest requestWithURL:url];
                [request setDelegate:self];
                [request setPostValue:value forKey:@"request"];
                [request setDidStartSelector:@selector(requestBeatMapStarted:)];
                [request setDidReceiveDataSelector:@selector(requestBeatMap:didReceiveData:)];
                [request setDidFailSelector:@selector(requestBeatMapFailed:)];
                [request setDidFinishSelector:@selector(requestBeatMapFinished:)];
                [queue addOperation:request];
                q_no[++q_no[0]]=i,q_dif[++q_dif[0]]=k;
            }
        }
    if(!queue.requestsCount)
    {
        [P hideCloudLib];
        return;
    }
    [queue go];
}
-(void)queueDidFinished:(ASINetworkQueue*)queue
{
    finished_task/=3;
    
    sqlite3 *DataBase;
    sqlite3_open([DataBase_Path UTF8String],&DataBase);
    sqlite3_stmt *statement;
    
    int ID=0,valid_row=0,tot_row=0;
    bool found=false;
    sqlite3_prepare_v2(DataBase,"SELECT ID,EASY,NORMAL,HARD FROM BeatMaps",-1,&statement,NULL);
    while(sqlite3_step(statement)==SQLITE_ROW&&(!found))
    {
        valid_row++;
        for(int k=1;k<=3;k++)
            if(!sqlite3_column_bytes(statement,k))
            {
                ID=sqlite3_column_int(statement,0);
                found=true;
                break;
            }
    }
    sqlite3_finalize(statement);
    ID--;

    if(found)
    {
        valid_row--;
        sqlite3_prepare_v2(DataBase,"SELECT COUNT(*) FROM BeatMaps",-1,&statement,NULL);
        sqlite3_step(statement);
        tot_row=sqlite3_column_int(statement,0);
        finished_task-=tot_row-valid_row;
        sqlite3_finalize(statement);
        
        sqlite3_prepare_v2(DataBase,"DELETE FROM BeatMaps WHERE ID>?",-1,&statement,NULL);
        sqlite3_bind_int(statement,1,ID);
        sqlite3_step(statement);
        sqlite3_finalize(statement);
        
        sqlite3_prepare_v2(DataBase,"DELETE FROM Record WHERE ID>?",-1,&statement,NULL);
        sqlite3_bind_int(statement,1,ID);
        sqlite3_step(statement);
        sqlite3_finalize(statement);
    }
    sqlite3_close(DataBase);
    
    MusicSelectionScene *P=self.parent;
    [P updateList:finished_task];
    
    [P hideCloudLib];
}
-(void)requestFailed:(ASIHTTPRequest *)request
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Failed to reach the server, please check you network settting or try again" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
    [alert setDelegate:self];
    [alert show];
}
-(void)request:(ASIHTTPRequest *)request didReceiveData:(NSData *)data
{
    if(!data)
    {
        [self requestFailed:request];
        return;
    }
    success=true;
    tmp_dir=NSTemporaryDirectory();
    tmp_dir=[tmp_dir stringByAppendingPathComponent:@"List"];
    [data writeToFile:tmp_dir atomically:NO];
    
    freopen([tmp_dir UTF8String],"r",stdin);
    char msg[10],msg_code[5];
    scanf("%s%s",&msg,&msg_code);
    printf("%s:%s\n",msg,msg_code);
}
-(void)requestBeatMapStarted:(ASIHTTPRequest *)request{
    temp_data=[NSMutableData data];
}
-(void)requestBeatMap:(ASIHTTPRequest *)request didReceiveData:(NSData *)data{
    [temp_data appendData:data];
}
-(void)requestBeatMapFailed:(ASIHTTPRequest *)request
{
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Error" message:@"Download failed, please try again later" delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
    [alert setDelegate:self];
    [alert show];
}
-(void)requestBeatMapFinished:(ASIHTTPRequest *)request{
    finished_task++;
    MusicSelectionScene *P=self.parent;
    [P insertBeatMap:Titles[q_no[finished_task]]
                Data:temp_data Dif:q_dif[q_dif[finished_task]]];
}
-(float)optionsInterval{
    CCSprite *option=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"MusicOption.png"]];
    return 15+option.contentSize.height;
}
-(float)xPositionShift{
    return 0;
}
-(void)optionTouched:(int)i
{
    if(!select[i])
        [List addMark:i];
    else [List removeMark:i];
    select[i]=(!select[i]);
    select_num+=(select[i]?1:-1);
}
-(NSArray*)dataSource
{
    int i=0;
    Titles=[NSMutableArray array];
    char num[10]={0},title[50]={0};
    scanf("%s",&num);int n=num[0]-'0';
    getchar();
    for(int i=0;i<n;i++)
    {
        scanf("%[^\n]",&title);
        getchar();
        Titles[i]=[NSString stringWithUTF8String:title];
    }
    options_num=[Titles count];
    return Titles;
}
-(void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    MusicSelectionScene *P=self.parent;
    [P hideCloudLib];
}
-(CGPoint)getTouchLocation:(UITouch*)touch
{
    CGPoint touch_location=[touch locationInView:touch.view];
    touch_location=[[CCDirector sharedDirector]convertToGL:touch_location];
    return touch_location;
}
-(double)distanceA:(CGPoint)a B:(CGPoint)b
{
    double ans;
    ans=sqrt((a.x-b.x)*(a.x-b.x)+(a.y-b.y)*(a.y-b.y));
    return  ans;
}
-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touch_loc=[self getTouchLocation:touch];
    if(CGRectContainsPoint([checkButton boundingBox],touch_loc))
        checkButtonShade.visible=YES;
    else if([self distanceA:back.position B:touch_loc]<back.contentSize.width/2.0)
        backShade.visible=YES;
}
-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touch_loc=[self getTouchLocation:touch];
    touch_loc=[self convertToNodeSpace:touch_loc];
    MusicSelectionScene *P=self.parent;
    
    checkButtonShade.visible=NO;
    backShade.visible=NO;
    
    if(CGRectContainsPoint([checkButton boundingBox],touch_loc))
        [self requestBeatMap];
    else if(CGRectContainsPoint([back boundingBox],touch_loc))
        [P hideCloudLib];
}
-(void)dealloc
{
    NSLog(@"CloudLib deallocated!");
}
@end
