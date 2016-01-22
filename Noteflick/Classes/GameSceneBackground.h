//
//  BGAnimation.h
//  NoteFlick
//
//  Created by Joshua Nanami on 14-8-12.
//  Copyright 2014年 Joshua Kirino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MusicInfo.h"

@interface GameSceneBackground:CCNode
@property MusicRecord* record;
-(id)initWithBeats:(int)beats_num;
-(void)starJump:(float)t score:(int)incre;
-(void)updateInfo:(int)incre;
@end
