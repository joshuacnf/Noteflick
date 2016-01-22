//
//  GameOverScene.m
//  NoteFlick
//
//  Created by Joshua Nanami on 14-9-11.
//  Copyright 2014年 Joshua Kirino. All rights reserved.
//

#import "GameOverScene.h"
#import "Colors.h"

@implementation GameOverScene{
    CGSize scrSize;
    Colors *color_set;
}
-(id)init
{
    self=[super init];
    if(!self) return 0;
    
    scrSize=[CCDirector sharedDirector].viewSize;
    color_set=[Colors node];
    
    [self initBackground];
    
    CCSprite *GameOver=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Game Over.png"]];
    GameOver.position=ccp(scrSize.width/2.0,scrSize.height/2.0);
    GameOver.scale=2.5;
    GameOver.opacity=0;
    [self addChild:GameOver z:1];
    
    
    CCActionEaseBackOut *scale_to=[CCActionEaseBackOut actionWithAction:[CCActionScaleTo actionWithDuration:1 scale:1]];
    CCActionFadeIn *fade_in=[CCActionFadeIn actionWithDuration:1];
    CCActionSpawn *spawn=[CCActionSpawn actions:scale_to,fade_in,nil];
    CCActionCallBlock *call=[CCActionCallBlock actionWithBlock:^(void){
        self.userInteractionEnabled=YES;
    }];
    CCActionSequence *seq=[CCActionSequence actions:spawn,call,nil];
    [GameOver runAction:seq];
    
    
    CCLabelTTF *TouchToContinue;
    TouchToContinue=[CCLabelTTF labelWithString:@"Touch To Continue" fontName:@"Roboto-Light" fontSize:45];
    TouchToContinue.anchorPoint=ccp(0.5,0.5);
    TouchToContinue.position=ccp(scrSize.width/2.0,scrSize.height/6.0);
    TouchToContinue.opacity=0;
    TouchToContinue.color=[color_set.preset_colors objectForKey:@"light blue"];
    [self addChild:TouchToContinue z:1];
    
    fade_in=[CCActionEaseSineIn actionWithAction:[CCActionFadeIn actionWithDuration:1]];
    CCActionEaseSineInOut *fade_out=[CCActionEaseSineIn actionWithAction:[CCActionFadeOut actionWithDuration:0.5]];
    CCActionRepeatForever *repeat=[CCActionRepeatForever actionWithAction:
                                   [CCActionSequence actions:fade_in,fade_out,nil]];
    [TouchToContinue runAction:repeat];
    
    
    self.userInteractionEnabled=NO;
    
    return self;
}
-(void)initBackground
{
    CCRenderTexture *rtx=[CCRenderTexture renderTextureWithWidth:scrSize.width height:scrSize.height pixelFormat:CCTexturePixelFormat_RGBA4444 depthStencilFormat:GL_DEPTH24_STENCIL8];
    [CCDirector sharedDirector].nextDeltaTimeZero=YES;
    
    [rtx beginWithClear:0 g:0 b:0 a:0 depth:1.0f];
    [[[CCDirector sharedDirector]runningScene]visit];
    [rtx end];
    
    CCSprite *background=rtx.sprite;
    [rtx.sprite removeFromParent];
    background.position=ccp(scrSize.width/2.0,scrSize.height/2.0);
    [self addChild:background z:-1];
    
    CCNodeColor *shade=[CCNodeColor nodeWithColor:[CCColor colorWithCcColor3b:ccBLACK] width:scrSize.width height:scrSize.height];
    shade.opacity=0.75;
    [self addChild:shade z:0];
}
-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event{
    self.userInteractionEnabled=NO;
    [[OALSimpleAudio sharedInstance]playEffect:@"Yes.aif"];
    [self.delegate quit];
}
-(void)dealloc{
    NSLog(@"GameOverScene deallocated!");
}
@end
