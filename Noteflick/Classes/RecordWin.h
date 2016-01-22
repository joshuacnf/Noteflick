//
//  RecordWin.h
//  NoteFlick
//
//  Created by Joshua Nanami on 14-7-25.
//  Copyright 2014年 Joshua Kirino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MusicInfo.h"

@interface RecordWin:CCSprite <UIAlertViewDelegate>
@property (nonatomic,retain,readwrite) CCColor *ThemeColor;
@property (nonatomic,readwrite) int SelectedNo;
@property (nonatomic,readwrite) int SelectedID;
@property (nonatomic,readwrite) int Difficulty;
-(void)selectionChanged;
-(void)updateInfo;
-(void)updateURL:(int)ID;
-(void)insertInfo:(MusicInfo*)info;
-(void)deleteInfo;
@end
