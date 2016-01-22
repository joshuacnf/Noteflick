//
//  MusicSelectionScene.h
//  NoteFlick
//
//  Created by Joshua Kirino on 14-3-9.
//  Copyright 2014年 Joshua Kirino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "cocos2d.h"
#import "MusicList.h"

#define MAX_POS 10000
@interface MusicSelectionScene : CCScene <UITableViewDataSource,UITableViewDelegate,UIAlertViewDelegate,MusicListDelegate>
@property (nonatomic,readonly) BOOL library_show;
@property (nonatomic,readonly) BOOL list_moving;
@property (nonatomic,retain) NSArray *dataList;
@property (nonatomic,retain) UITableView *tableView;
@property (nonatomic,retain) NSArray *keys;
@property (nonatomic,retain) NSDictionary *items;
-(void)GameScene;
-(void)hideCloudLib;
-(void)showLibraryList;
-(void)hideLibraryList;
-(void)insertBeatMap:(NSString*)title Data:(NSData*)data Dif:(int)dif;
-(void)updateList:(int)num;
-(void)searchOption:(NSString*)title;
-(BOOL)deleteAble;
-(void)deleteOption;
-(BOOL)exist:(NSString*)Title;
@end