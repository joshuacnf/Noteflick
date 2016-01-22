//
//  ListControlPanel.h
//  NoteFlick
//
//  Created by Joshua Nanami on 14-7-23.
//  Copyright 2014年 Joshua Kirino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MusicInfo.h"

@interface ListControlPanel:CCSprite <UITextFieldDelegate,UIAlertViewDelegate>
@property (nonatomic,readwrite) CCColor *ThemeColor;
@property (nonatomic,readwrite) NSString *SelectedTitle;
-(void)selectionChanged;
-(void)ShowSearchBar;
-(void)HideSearchBar;
@end
