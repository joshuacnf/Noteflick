//
//  GameOverScene.h
//  NoteFlick
//
//  Created by Joshua Nanami on 14-9-11.
//  Copyright 2014年 Joshua Kirino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@protocol GameOverSceneDelegate <NSObject>
-(void)quit;
@end

@interface GameOverScene:CCScene
@property (weak) id <GameOverSceneDelegate>delegate;
@end
