//
//  ScrollList.h
//  NoteFlick
//
//  Created by Joshua Kirino on 14-3-9.
//  Copyright 2014年 Joshua Kirino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MusicInfo.h"

@protocol MusicListDelegate <NSObject>
-(float)optionsInterval;
-(float)xPositionShift;
-(NSArray*)dataSource;
@optional
-(void)selectionChanged;
-(void)listDragged;
-(void)optionTouched:(int)i;
@end

@interface MusicList:CCNode
@property (readwrite,weak) id<MusicListDelegate> delegate;
@property (readonly) int SelectedNo;
@property (readonly) NSString *SelectedTitle;
@property (readonly) CCColor *SelectedColor;
@property (readonly) BOOL Moving,touch_moved;
@property (readonly) double INTERVAL;
-(int)optionsNum;
-(void)insertOption:(NSString*)title;
-(void)deleteOption;
-(BOOL)exist:(NSString*)title;
-(int)searchOption:(NSString*)title;
-(void)moveToOption:(int)i;
-(void)addMark:(int)i;
-(void)removeMark:(int)i;
@end
