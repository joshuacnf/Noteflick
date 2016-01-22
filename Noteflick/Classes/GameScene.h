//
//  GameScene.h
//  NoteFlick
//
//  Created by Joshua Nanami on 14-8-15.
//  Copyright 2014年 Joshua Kirino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "PauseScene.h"
#import "GameOverScene.h"

@interface GameScene : CCScene <PauseSceneDelegate,GameOverSceneDelegate>
-(id)initWithID:(int)ID Dif:(int)dif;
-(void)gameStart;
-(void)gameOver;
-(void)pause;
@end
