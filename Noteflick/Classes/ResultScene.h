//
//  ResultScene.h
//  NoteFlick
//
//  Created by Joshua Nanami on 14-8-24.
//  Copyright 2014年 Joshua Kirino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MusicInfo.h"

@interface ResultScene:CCScene
-(id)initWithID:(int)ID Dif:(int)Dif Record:(MusicRecord*)record;
@end
