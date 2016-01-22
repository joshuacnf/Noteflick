//
//  Colors.h
//  NoteFlick
//
//  Created by Joshua Kirino on 14-3-9.
//  Copyright 2014年 Joshua Kirino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@interface Colors : CCNode {
    NSMutableDictionary *preset_colors;
}
@property (readonly) NSMutableDictionary *preset_colors;
@end
