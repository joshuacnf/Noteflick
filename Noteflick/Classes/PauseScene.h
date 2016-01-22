//
//  PauseScene.h
//  NoteFlick
//
//  Created by Joshua Nanami on 14-8-24.
//  Copyright 2014年 Joshua Kirino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"

@protocol PauseSceneDelegate <NSObject>
-(void)quit;
-(void)resume;
@end

@interface PauseScene:CCScene
@property (weak) id<PauseSceneDelegate> delegate;
@end
