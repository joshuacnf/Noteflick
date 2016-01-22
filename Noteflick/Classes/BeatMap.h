//
//  BeatMap.h
//  NoteFlick
//
//  Created by Joshua Nanami on 14-8-25.
//  Copyright (c) 2014年 Joshua Kirino. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface iNote:NSObject <NSCoding>
@property (readwrite) char type;
@property (readwrite) float offset;
@property (readwrite) CGPoint start,end,control,control2;
@property (readwrite) float duration,slider_length;
@end

@interface BeatMap:NSObject <NSCoding>
@property (readwrite) NSMutableArray *Notes;
@property (readwrite) int notes_num,beatpoint_num;
@property (readwrite) float sec_per_beat;

@end