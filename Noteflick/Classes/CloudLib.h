//
//  CloudScene.h
//  NoteFlick
//
//  Created by Joshua Nanami on 14-8-17.
//  Copyright 2014年 Joshua Kirino. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "MusicList.h"
#import "ASIFormDataRequest.h"
#import "ASINetworkQueue.h"

@interface CloudLib:CCNode <ASIHTTPRequestDelegate,UIAlertViewDelegate,MusicListDelegate>
@end
