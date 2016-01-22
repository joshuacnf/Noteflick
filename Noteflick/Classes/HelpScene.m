//
//  HelpScene.m
//  NoteFlick
//
//  Created by Joshua Nanami on 14-9-13.
//  Copyright 2014年 Joshua Kirino. All rights reserved.
//

#import "HelpScene.h"
#import "MainScene.h"

@implementation HelpScene{
    CGSize scrSize;
    CCSprite *Frame;
    CCNode *Node;
    CCSprite *BeforeYouStart,*HowToPlay,*Staff;
    CCSprite *back,*back_shade,*left,*left_shade,*right,*right_shade;
    int selected_no;
}
-(id)init
{
    self=[super init];
    if(!self) return self;
    
    [[CCDirector sharedDirector]purgeCachedData];
    CCSpriteFrameCache *cache=[CCSpriteFrameCache sharedSpriteFrameCache];
    [cache removeSpriteFrames];
    
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSNumber *played_before=[userDefaults objectForKey:@"played_before"];
    if(![played_before boolValue])
    {
        played_before=[NSNumber numberWithBool:YES];
        [userDefaults setObject:played_before forKey:@"played_before"];
        [userDefaults synchronize];
    }
    
    self.cascadeOpacityEnabled=YES;
    scrSize=[CCDirector sharedDirector].viewSize;
    selected_no=0;
    
    [self initBackground];
    
    Frame=[CCSprite spriteWithImageNamed:@"HelpSceneFrame.png"];
    Frame.position=ccp(scrSize.width/2.0,scrSize.height/2.0);
    [self addChild:Frame z:2];
    
    Node=[CCNode node];
    Node.position=ccp(scrSize.width/2.0,scrSize.height/2.0);
    [self addChild:Node z:1];
    
    BeforeYouStart=[CCSprite spriteWithImageNamed:@"BeforeYouStart.png"];
    BeforeYouStart.position=ccp(0,0);
    [Node addChild:BeforeYouStart z:1];
    
    HowToPlay=[CCSprite spriteWithImageNamed:@"HowToPlay.png"];
    HowToPlay.position=ccp(scrSize.width,0);
    [Node addChild:HowToPlay z:1];
    
    Staff=[CCSprite spriteWithImageNamed:@"Staff.png"];
    Staff.position=ccp(scrSize.width*2,0);
    [Node addChild:Staff z:1];
    
    back=[CCSprite spriteWithImageNamed:@"Resume.png"];
    back.position=ccp(scrSize.width-back.contentSize.width*3/4.0,scrSize.height-back.contentSize.height*3/4.0);
    [self addChild:back z:3];
    back_shade=[CCSprite spriteWithImageNamed:@"Resume.png"];
    [self makeShade:back_shade];
    [back addChild:back_shade];
    
    left=[CCSprite spriteWithImageNamed:@"Arrow.png"];
    left.position=ccp(920,71);
    left.rotation=-180;
    [self addChild:left z:1];
    left_shade=[CCSprite spriteWithImageNamed:@"HelpSceneCircleShade.png"];
    [self makeShade:left_shade];
    [left addChild:left_shade];
    
    right=[CCSprite spriteWithImageNamed:@"Arrow.png"];
    right.position=ccp(966,71);
    [self addChild:right z:1];
    right_shade=[CCSprite spriteWithImageNamed:@"HelpSceneCircleShade.png"];
    [self makeShade:right_shade];
    [right addChild:right_shade];
    
    self.opacity=0;
    
    CCActionFadeIn *fade_in=[CCActionFadeIn actionWithDuration:0.8];
    [self runAction:fade_in];
    
    self.userInteractionEnabled=YES;
    
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
    shade.opacity=0.8;
    [self addChild:shade z:0];
}
-(void)makeShade:(CCSprite*)sprite
{
    sprite.position=ccp(sprite.contentSize.width/2.0,sprite.contentSize.height/2.0);
    sprite.color=[CCColor colorWithCcColor3b:ccBLACK];
    sprite.opacity=0.5;
    sprite.visible=NO;
}
-(CGPoint)getTouchLocation:(UITouch*)touch
{
    CGPoint touch_location=[touch locationInView:touch.view];
    touch_location=[[CCDirector sharedDirector]convertToGL:touch_location];
    return touch_location;
}
-(double)distanceA:(CGPoint)a B:(CGPoint)b
{
    double ans;
    ans=sqrt((a.x-b.x)*(a.x-b.x)+(a.y-b.y)*(a.y-b.y));
    return  ans;
}
-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touch_loc=[self getTouchLocation:touch];
    if([self distanceA:back.position B:touch_loc]<back.contentSize.width/2.0)
        back_shade.visible=YES;
    else if([self distanceA:left.position B:touch_loc]<left.contentSize.width/2.0)
        left_shade.visible=YES;
    else if([self distanceA:right.position B:touch_loc]<right.contentSize.width/2.0)
        right_shade.visible=YES;
}
-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    back_shade.visible=left_shade.visible=right_shade.visible=NO;
    
    CGPoint touch_loc=[self getTouchLocation:touch];
    if([self distanceA:back.position B:touch_loc]<back.contentSize.width/2.0)
        [self MainScene];
    else if([self distanceA:left.position B:touch_loc]<left.contentSize.width/2.0&&selected_no>0)
        [self moveTo:selected_no-1];
    else if([self distanceA:right.position B:touch_loc]<right.contentSize.width/2.0&&selected_no<2)
        [self moveTo:selected_no+1];
}
-(void)moveTo:(int)no
{
    CCActionEaseSineInOut *move=[CCActionEaseSineInOut actionWithAction:
                                 [CCActionMoveTo actionWithDuration:0.8 position:
                                  ccp(scrSize.width/2.0-no*scrSize.width,scrSize.height/2.0)]];
    [Node stopAllActions];
    [Node runAction:move];
    selected_no=no;
}
-(void)MainScene{
    self.userInteractionEnabled=NO;
    [[CCDirector sharedDirector]replaceScene:[MainScene node]];
    [[OALSimpleAudio sharedInstance]playEffect:@"No.aif"];
}
-(void)dealloc{
    NSLog(@"HelpScene deallocated!");
}
@end
