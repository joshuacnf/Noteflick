//
//  InfoBlock.h
//  NoteFlick
//
//  Created by Joshua Nanami on 14-8-9.
//  Copyright 2014年 Joshua Kirino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MusicInfo.h"

@interface InfoBlock:CCNode
-(void)updateWithRecord:(MusicRecord *)record;
@end
