//
//  MusicInfo.h
//  NoteFlick
//
//  Created by Joshua Kirino on 14-3-11.
//  Copyright 2014年 Joshua Kirino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MusicRecord.h"

@interface MusicInfo:NSObject
@property (nonatomic,readwrite) int ID;
@property (nonatomic,readwrite) NSURL *url;
@property (nonatomic,readwrite) NSString *title,*artist;
@property (nonatomic,readwrite) MusicRecord *easy,*normal,*hard;
@end
