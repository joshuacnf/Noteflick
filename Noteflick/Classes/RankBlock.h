//
//  RankBlock.h
//  NoteFlick
//
//  Created by Joshua Nanami on 14-9-7.
//  Copyright 2014年 Joshua Kirino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface RankBlock:CCNode
-(id)initWithStr:(NSString*)str;
-(void)switchTo:(int)ascii;
@end
