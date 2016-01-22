//
//  MusicSelectionScene.m
//  NoteFlick
//
//  Created by Joshua Kirino on 14-3-9.
//  Copyright 2014年 Joshua Kirino. All rights reserved.
//

#import "MusicSelectionScene.h"
#import "MainScene.h"
#import "GameScene.h"
#import <sqlite3.h>
#import "Colors.h"
#import "MusicInfo.h"
#import "MusicList.h"
#import "ListControlPanel.h"
#import "RecordWin.h"
#import "CloudLib.h"

#define alert_access 1
#define alert_match 2

@implementation MusicSelectionScene
{    
    Colors *color_set;
    NSString *DataBase_Path;
    CGSize scrSize;
    BOOL UPDATE,LibraryListShownBefore;
    
    MusicList *List;
    ListControlPanel *listControlPanel;
    RecordWin *recordWin;
    CCSprite *libraryList;
    CloudLib *cloudLib;
    BOOL exis[1003];
    
    CCSprite *BackButton,*BackButtonShade;CCLabelTTF *back;
    CCSprite *Download,*DownloadShade;
    MPMediaItem *selected_item;
    
    int alert_no;
}
@synthesize library_show;
@synthesize list_moving;
@synthesize dataList;
@synthesize tableView;
@synthesize keys;
@synthesize items;
-(id)init
{   
    self=[super init];
    if(!self) return self;
    
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentDirecotry=[paths objectAtIndex:0];
    DataBase_Path=[documentDirecotry stringByAppendingPathComponent:@"DataBase.db"];
    
    UPDATE=list_moving=library_show=LibraryListShownBefore=NO;
    
    [[CCDirector sharedDirector]purgeCachedData];
    CCSpriteFrameCache *cache=[CCSpriteFrameCache sharedSpriteFrameCache];
    [cache removeSpriteFrames];
    [cache addSpriteFramesWithFile:@"MusicSelectionSprites.plist"];
    scrSize=[CCDirector sharedDirector].viewSize;
    color_set=[Colors node];
    
    CCSprite *background=[CCSprite spriteWithImageNamed:@"MusicSelectionSceneBackground.png"];
    background.position=ccp(scrSize.width/2.0,scrSize.height/2.0);
    [self addChild:background z:0];
    
    List=[MusicList alloc];
    List.delegate=self;
    List=[List init];
    List.position=ccp(scrSize.width-List.contentSize.width/2,List.contentSize.height/2);
    [self addChild:List z:2];
    
    recordWin=[[RecordWin alloc]initWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"RecordWin.png"]];
    recordWin.position=ccp(scrSize.width/2.0,scrSize.height/2.0);
    recordWin.ThemeColor=List.SelectedColor;
    recordWin.SelectedNo=List.SelectedNo;
    [recordWin selectionChanged];
    [self addChild:recordWin z:1];
    
    listControlPanel=[[ListControlPanel alloc]initWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"ListControlPanel.png"]];
    listControlPanel.position=ccp(scrSize.width-listControlPanel.contentSize.width/2.0,
                                    scrSize.height-listControlPanel.contentSize.height/2.0);
    [listControlPanel selectionChanged];
    listControlPanel.SelectedTitle=List.SelectedTitle;
    [self addChild:listControlPanel z:3];
    
    libraryList=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"LibraryList.png"]];
    libraryList.position=ccp(List.position.x,scrSize.height/2.0);
    libraryList.visible=NO;
    [self addChild:libraryList];
    
    BackButton=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"BackButton.png"]];
    BackButton.color=List.SelectedColor;
    BackButton.position=ccp(BackButton.contentSize.width/2.0,scrSize.height-BackButton.contentSize.height/2.0);
    [self addChild:BackButton z:0];
    back=[CCLabelTTF labelWithString:@"Back" fontName:@"Roboto-Light" fontSize:40];
    back.anchorPoint=ccp(0.5,0.5);
    back.rotation=-atan2(BackButton.contentSize.height,BackButton.contentSize.width)/M_PI*180;
    back.position=ccp(BackButton.contentSize.width/3.0,2*BackButton.contentSize.height/3.0);
    [BackButton addChild:back z:1];
    BackButton.cascadeOpacityEnabled=YES;
    
    BackButtonShade=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"BackButton.png"]];
    BackButtonShade.position=ccp(BackButton.contentSize.width/2.0,BackButton.contentSize.height/2.0);
    BackButtonShade.color=[CCColor colorWithCcColor3b:ccBLACK];
    BackButtonShade.opacity=0.5;
    BackButtonShade.visible=NO;
    [BackButton addChild:BackButtonShade z:2];
    
    BackButton.opacity=0;
    CCActionFadeIn *fadein=[CCActionFadeIn actionWithDuration:0.4];
    [BackButton runAction:fadein];
    
    Download=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Download.png"]];
    Download.position=ccp(Download.contentSize.width*3/4.0,Download.contentSize.height*3/4.0);
    Download.color=List.SelectedColor;
    [self addChild:Download z:1];
    
    DownloadShade=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"SelectionSceneShadeCircle.png"]];
    DownloadShade.position=ccp(Download.contentSize.width/2.0,Download.contentSize.height/2.0);
    DownloadShade.color=[CCColor colorWithCcColor3b:ccBLACK];
    DownloadShade.opacity=0.5;
    DownloadShade.visible=NO;
    [Download addChild:DownloadShade z:1];
    
    MPMediaQuery *query=[MPMediaQuery songsQuery];
    MPMediaPropertyPredicate *predicate=[MPMediaPropertyPredicate predicateWithValue:[NSNumber numberWithBool:0]forProperty:MPMediaItemPropertyIsCloudItem];
    [query addFilterPredicate:predicate];
    self.dataList=[query items];

    self.userInteractionEnabled=YES;
    
    return self;
}
-(void)update:(CCTime)delta
{
    if(List.Moving)
        list_moving=YES;
    else list_moving=NO;
}
-(void)MainScene
{
    self.userInteractionEnabled=NO;
    [self.tableView removeFromSuperview];
    [listControlPanel HideSearchBar];
    [[CCDirector sharedDirector]replaceScene:[MainScene node]];
    [[OALSimpleAudio sharedInstance]playEffect:@"Yes.aif"];
}
-(void)GameScene
{
    self.userInteractionEnabled=NO;
    [self.tableView removeFromSuperview];
    [listControlPanel HideSearchBar];
    [[CCDirector sharedDirector]replaceScene:[[GameScene alloc]initWithID:recordWin.SelectedID Dif:recordWin.Difficulty]];
}
-(void)showCloudLib
{
    self.userInteractionEnabled=NO;
    [listControlPanel HideSearchBar];
    cloudLib=[CloudLib node];
    [self addChild:cloudLib z:4];
    cloudLib.position=ccp(0,scrSize.height);
    CCActionEaseSineOut *move_by=[CCActionEaseSineOut actionWithAction:
                                  [CCActionMoveBy actionWithDuration:0.3 position:ccp(0,-scrSize.height)]];
    [cloudLib runAction:move_by];
}
-(void)hideCloudLib
{
    CCActionEaseSineOut *move_by=[CCActionEaseSineOut actionWithAction:
                                  [CCActionMoveBy actionWithDuration:0.3 position:ccp(0,scrSize.height)]];
    CCActionCallBlock *call=[CCActionCallBlock actionWithBlock:^(void){
        [cloudLib removeFromParent];
        [listControlPanel ShowSearchBar];
        self.userInteractionEnabled=YES;
    }];
    CCActionSequence *seq=[CCActionSequence actions:move_by,call,nil];
    [cloudLib runAction:seq];
}
-(void)showLibraryList
{
    if(library_show) return;
    
    library_show=YES;
    List.userInteractionEnabled=NO;
    
    CGRect rect=[libraryList boundingBox];
    UITableView *tblView=[[UITableView alloc]initWithFrame:rect style:UITableViewStylePlain];
    tblView.dataSource=self;
    tblView.delegate=self;
    tblView.layer.cornerRadius=30;
    tblView.layer.masksToBounds=YES;
    self.tableView=tblView;
    
    if(!LibraryListShownBefore)
    {
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]init];
        NSMutableArray *Arrays=[NSMutableArray array];
        for(int i=0;i<27;i++) Arrays[i]=[NSMutableArray array];
        int n=(int)[dataList count];
        NSString *title;
        for(int i=0;i<n;i++)
        {
            title=[((MPMediaItem *)dataList[i])valueForProperty:MPMediaItemPropertyTitle];
            char s=[title UTF8String][0];
            if(!isalpha(s))
                s=26;
            else
            {
                if(s<='Z'&&s>='A')
                    s-='A';
                else s-='a';
            }
            [((NSMutableArray*)Arrays[s])addObject:dataList[i]];
        }
        for(int i=0;i<26;i++)
            [dict setObject:Arrays[i] forKey:[NSString stringWithFormat:@"%c",(i+'A')]];
        [dict setObject:Arrays[26] forKey:@"#"];
        self.items=dict;
        
        NSMutableArray *array=[NSMutableArray array];
        for(int i=0,k='A';k<='Z';k++)
            if([[dict objectForKey:[NSString stringWithFormat:@"%c",k]]count])
                array[i++]=[NSString stringWithFormat:@"%c",k];
        array[(int)[array count]]=[NSString stringWithFormat:@"%c",'#'];
        self.keys=array;
    }
    
    [[CCDirector sharedDirector].view addSubview:self.tableView];
    LibraryListShownBefore=YES;
}
-(void)hideLibraryList
{
    if(!library_show) return;
    library_show=NO;
    List.userInteractionEnabled=YES;
    [tableView removeFromSuperview];
}
-(void)updateList:(int)num
{
    sqlite3 *DataBase;
    sqlite3_open([DataBase_Path UTF8String],&DataBase);
    sqlite3_stmt *statement;
    
    MusicInfo *info;
    char *cmd=[[NSString stringWithFormat:@"SELECT ID,Title FROM BeatMaps ORDER BY ID DESC LIMIT 0,%d",num]UTF8String];
    sqlite3_prepare_v2(DataBase,cmd,-1,&statement,NULL);
    while(sqlite3_step(statement)==SQLITE_ROW)
    {
        info=[[MusicInfo alloc]init];
        info.ID=sqlite3_column_int(statement,0);
        info.title=[NSString stringWithUTF8String:sqlite3_column_text(statement,1)];
        [recordWin insertInfo:info];
        [List insertOption:[NSString stringWithString:info.title]];
    }
    sqlite3_finalize(statement);
    sqlite3_close(DataBase);
}
-(void)searchOption:(NSString *)title
{
    int p=[List searchOption:title];
    if(p>=0) [List moveToOption:p];
}
-(BOOL)deleteAble{
    if([List optionsNum]>1)
        return YES;
    return NO;
}
-(void)deleteOption
{
    sqlite3 *DataBase;
    sqlite3_open([DataBase_Path UTF8String],&DataBase);
    sqlite3_stmt *statement;
    
    int ID=recordWin.SelectedID;
    sqlite3_prepare_v2(DataBase,"DELETE FROM BeatMaps WHERE ID=?",-1,&statement,NULL);
    sqlite3_bind_int(statement,1,ID);
    sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    sqlite3_prepare_v2(DataBase,"DELETE FROM Record WHERE ID=?",-1,&statement,NULL);
    sqlite3_bind_int(statement,1,ID);
    sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(DataBase);
    
    [recordWin deleteInfo];
    [List deleteOption];
}
-(BOOL)exist:(NSString*)Title{
    return [List exist:Title];
}
-(void)insertBeatMap:(NSString *)title Data:(NSData *)data Dif:(int)dif
{
    sqlite3 *DataBase;
    sqlite3_open([DataBase_Path UTF8String],&DataBase);
    sqlite3_stmt *statement;
    
    char *cmd="",*c_title=[title UTF8String];
    switch(dif)
    {
        case 1:cmd="UPDATE BeatMaps SET EASY=? WHERE Title=?";break;
        case 2:cmd="UPDATE BeatMaps SET NORMAL=? WHERE Title=?";break;
        case 3:cmd="UPDATE BeatMaps SET HARD=? WHERE Title=?";break;
    }
    sqlite3_prepare_v2(DataBase,cmd,-1,&statement,NULL);
    sqlite3_bind_blob(statement,1,[data bytes],(int)[data length],NULL);
    sqlite3_bind_text(statement,2,c_title,strlen(c_title),SQLITE_STATIC);
    sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(DataBase);
}
-(void)matchURL:(NSURL *)url ID:(int)ID
{
    sqlite3 *DataBase;
    sqlite3_open([DataBase_Path UTF8String],&DataBase);
    sqlite3_stmt *statement;
    
    NSData *url_data=[NSKeyedArchiver archivedDataWithRootObject:url];
    sqlite3_prepare_v2(DataBase,"UPDATE BeatMaps SET URL=? WHERE ID=?",-1,&statement,NULL);
    sqlite3_bind_blob(statement,1,[url_data bytes],(int)[url_data length],NULL);
    sqlite3_bind_int(statement,2,ID);
    sqlite3_step(statement);
    sqlite3_finalize(statement);
    
    sqlite3_close(DataBase);
    
    [recordWin updateURL:ID];
}
-(CGPoint)getTouchLocation:(UITouch*)touch
{
    CGPoint touch_location=[touch locationInView:touch.view];
    touch_location=[[CCDirector sharedDirector]convertToGL:touch_location];
    touch_location=[self convertToNodeSpace:touch_location];
    return touch_location;
}
-(double)distanceA:(CGPoint)a B:(CGPoint)b
{
    double ans;
    ans=sqrt((a.x-b.x)*(a.x-b.x)+(a.y-b.y)*(a.y-b.y));
    return  ans;
}
-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    CGPoint touch_loca=[self getTouchLocation:touch];
    if([self distanceA:Download.position B:touch_loca]<Download.contentSize.width/2.0)
        DownloadShade.visible=YES;
    else if(CGRectContainsPoint([BackButton boundingBox],touch_loca))
        BackButtonShade.visible=YES;
}
-(void)touchMoved:(UITouch *)touch withEvent:(UIEvent *)event{
}
-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    DownloadShade.visible=NO;
    BackButtonShade.visible=NO;
    
    CGPoint touch_loca=[self getTouchLocation:touch];
    if(library_show&&(!CGRectContainsPoint([libraryList boundingBox],touch_loca)))
    {
        [self hideLibraryList];
        return;
    }
    if([self distanceA:BackButton.position B:touch_loca]<BackButton.contentSize.width/2.0)
        [self MainScene];
    else if([self distanceA:Download.position B:touch_loca]<Download.contentSize.width/2.0)
        [self showCloudLib];
}
-(float)optionsInterval{
    return scrSize.height*5/36.0;
}
-(float)xPositionShift{
    return 0.5;
}
-(NSArray*)dataSource
{
    NSArray *paths=NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES);
    NSString *documentDirecotry=[paths objectAtIndex:0];
    DataBase_Path=[documentDirecotry stringByAppendingPathComponent:@"DataBase.db"];
    
    sqlite3 *DataBase;
    sqlite3_open([DataBase_Path UTF8String],&DataBase);
    sqlite3_stmt *statement;
    
    int Options_Num=0,ID;
    NSMutableArray *Titles=[NSMutableArray array];NSString *title;
    sqlite3_prepare_v2(DataBase,"SELECT ID,Title FROM BeatMaps",-1,&statement,NULL);
    while(sqlite3_step(statement)==SQLITE_ROW)
    {
        ID=sqlite3_column_int(statement,0);
        exis[ID]=true;
        
        title=[NSString stringWithUTF8String:(char*)sqlite3_column_text(statement,1)];
        Titles[Options_Num++]=title;
    }
    sqlite3_finalize(statement);
    
    return Titles;
}
-(void)listDragged{
    //if(self.record_win_show)
        //[self hideRecordWin];
}
-(void)optionTouched:(int)i
{
    if(i!=List.SelectedNo)
        [List moveToOption:i];
}
-(void)selectionChanged
{
    listControlPanel.ThemeColor=List.SelectedColor;
    listControlPanel.SelectedTitle=List.SelectedTitle;
    [listControlPanel selectionChanged];
    
    recordWin.ThemeColor=List.SelectedColor;
    recordWin.SelectedNo=List.SelectedNo;
    [recordWin selectionChanged];
    
    CCActionTintTo *tint_to=[CCActionTintTo actionWithDuration:0.25 color:List.SelectedColor];
    [BackButton runAction:tint_to];
    tint_to=[CCActionTintTo actionWithDuration:0.25 color:List.SelectedColor];
    [Download runAction:tint_to];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int section=[indexPath section];
    int row=[indexPath row];
    NSArray *itemSection=[items objectForKey:keys[section]];
    
    static NSString *ID=@"ID";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:ID];
    if(!cell)
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:ID];
    
    MPMediaItem *item=itemSection[row];
    cell.textLabel.text=[item valueForProperty:MPMediaItemPropertyTitle];
    MPMediaItemArtwork *artwork=[item valueForProperty:MPMediaItemPropertyArtwork];
    cell.imageView.image=[artwork imageWithSize:CGSizeMake(100,100)];
    cell.accessoryType=UITableViewCellAccessoryNone;
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    MPMediaItem *item=[items objectForKey:keys[indexPath.section]][indexPath.row];
    selected_item=item;
    NSString *msg=[NSString stringWithFormat:@"You select %@",[item valueForProperty:MPMediaItemPropertyTitle]];
    UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Match?" message:msg delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Match",nil];
    alert_no=alert_match;
    [alert show];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        [self matchURL:[selected_item valueForProperty:MPMediaItemPropertyAssetURL] ID:recordWin.SelectedID];
        [self hideLibraryList];
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40.0;
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return [keys count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSArray *array=[items objectForKey:keys[section]];
    return [array count];
}
-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    return [keys objectAtIndex:section];
}
-(NSArray*)sectionIndexTitlesForTableView:(UITableView *)tableView{
    return keys;
}
-(void)dealloc{
    NSLog(@"SelectionScene Deallocated!");
}
@end