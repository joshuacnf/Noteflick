//
//  MainScene.m
//  NoteFlick
//
//  Created by Joshua Kirino on 14-3-2.
//  Copyright 2014年 Joshua Kirino. All rights reserved.
//

#import "MainScene.h"
#import "MusicSelectionScene.h"
#import "HelpScene.h"

@implementation MainScene
{
    CGSize scrSize;
    CCSprite *Background,*top_clip,*btm_clip;
    CCSprite *MainSceneCircle,*ColorBarBlur,*ColorNote;
    CCLabelTTF *Logo,*TouchToStart;
    CCSprite *Help,*HelpShade,*Bubble;
}
-(id)init
{
    self=[super init];
    if(!self) return self;
    
    scrSize=[CCDirector sharedDirector].viewSize;
    
    [[CCDirector sharedDirector]purgeCachedData];
    CCSpriteFrameCache *cache=[CCSpriteFrameCache sharedSpriteFrameCache];
    [cache removeSpriteFrames];
    [cache addSpriteFramesWithFile:@"MainSceneSprites.plist"];
    
    
    Background=[CCSprite spriteWithImageNamed:@"MainSceneBackground.png"];
    Background.position=ccp(scrSize.width/2.0,scrSize.height/2.0);
    [self addChild:Background z:0];
    
    ColorBarBlur=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"ColorBarBlur.png"]];
    ColorBarBlur.position=ccp(280,scrSize.height/2.0);
    ColorBarBlur.cascadeOpacityEnabled=YES;
    [self addChild:ColorBarBlur z:1];
    
    MainSceneCircle=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"MainSceneCircle.png"]];
    MainSceneCircle.position=ccp(ColorBarBlur.contentSize.width/2.0,ColorBarBlur.contentSize.height/2.0);
    [ColorBarBlur addChild:MainSceneCircle z:0];
    
    Logo=[CCLabelTTF labelWithString:@"Noteflick." fontName:@"Roboto-Light" fontSize:35];
    Logo.anchorPoint=ccp(0.5,0.5);
    Logo.position=ccpAdd(ccp(ColorBarBlur.contentSize.width/2.0,ColorBarBlur.contentSize.height/2.0),ccp(99,-37));
    [ColorBarBlur addChild:Logo z:1];
    
    ColorBarBlur.opacity=0;
    
    top_clip=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"TopClip.png"]];
    top_clip.position=ccp(scrSize.width/2.0,scrSize.height-top_clip.contentSize.height/2.0);
    [self addChild:top_clip z:2];
    
    btm_clip=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"BottomClip.png"]];
    btm_clip.position=ccp(scrSize.width/2.0,btm_clip.contentSize.height/2.0);
    [self addChild:btm_clip z:2];
    
    top_clip.opacity=btm_clip.opacity=0;
    
    ColorNote=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"ColorNote.png"]];
    ColorNote.position=ColorBarBlur.position;
    [self addChild:ColorNote z:3];
    
    TouchToStart=[CCLabelTTF labelWithString:@"Touch To Start" fontName:@"Roboto-Light" fontSize:45];
    TouchToStart.anchorPoint=ccp(0.5,0.5);
    TouchToStart.position=ccp(scrSize.width/2.0,scrSize.height/6.0);
    TouchToStart.opacity=0;
    [self addChild:TouchToStart z:1];
    
    Help=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Help.png"]];
    Help.color=[CCColor colorWithCcColor3b:ccc3(0x66,0xCC,0xFF)];
    Help.position=ccp(scrSize.width-Help.contentSize.width*3/4.0,scrSize.height-Help.contentSize.height*3/4.0);
    [self addChild:Help z:1];
    HelpShade=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Help.png"]];
    HelpShade.color=[CCColor colorWithCcColor3b:ccBLACK];
    HelpShade.opacity=0.5;HelpShade.visible=NO;
    HelpShade.position=ccp(Help.contentSize.width/2.0,Help.contentSize.height/2.0);
    [Help addChild:HelpShade];
    
    NSUserDefaults *userDefaults=[NSUserDefaults standardUserDefaults];
    NSNumber *played_before=[userDefaults objectForKey:@"played_before"];
    if((!played_before)||(![played_before boolValue]))
    {
        played_before=[NSNumber numberWithBool:NO];
        [userDefaults setObject:played_before forKey:@"played_before"];
        [userDefaults synchronize];
        Bubble=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Bubble.png"]];
        Bubble.position=ccpSub(Help.position,ccp(Bubble.contentSize.width/2.0+10,Bubble.contentSize.height/2.0+15));
        [self addChild:Bubble z:1];
    }
    
    [self transitionIn];
    
    [self scheduleBlock:^(CCTimer *timer){
        self.userInteractionEnabled=YES;
    }delay:0.5];
    
    self.userInteractionEnabled=NO;
    
    return self;
}
-(void)transitionIn
{
    float fade_time=0.5;
    
    CCActionFadeIn *fade_in=[CCActionFadeIn actionWithDuration:fade_time];
    [ColorBarBlur runAction:fade_in];
    
    [self scheduleBlock:^(CCTimer *timer){
        CCActionEaseSineIn *fade_in=[CCActionEaseSineIn actionWithAction:[CCActionFadeIn actionWithDuration:1]];
        CCActionEaseSineInOut *fade_out=[CCActionEaseSineIn actionWithAction:[CCActionFadeOut actionWithDuration:0.5]];
        CCActionRepeatForever *repeat=[CCActionRepeatForever actionWithAction:
                                       [CCActionSequence actions:fade_in,fade_out,nil]];
        [TouchToStart runAction:repeat];
    }delay:fade_time];
    
    if(Bubble)
    {
        Bubble.scale=0.01;Bubble.opacity=0;
        CCActionEaseBackOut *scale_to=[CCActionEaseBackOut actionWithAction:
                                       [CCActionScaleTo actionWithDuration:0.5 scale:1]];
        CCActionFadeIn *fade_in=[CCActionFadeIn actionWithDuration:0.5];
        CCActionSpawn *spawn=[CCActionSpawn actions:scale_to,fade_in,nil];
        [Bubble runAction:spawn];
    }
}
-(void)transitionOut
{
    CCActionEaseOut *fade_out;
    fade_out=[CCActionEaseSineOut actionWithAction:[CCActionFadeOut actionWithDuration:0.5]];
    [ColorNote runAction:fade_out];
    fade_out=[CCActionEaseSineOut actionWithAction:[CCActionFadeOut actionWithDuration:0.5]];
    [Logo runAction:fade_out];
    
    CCActionEaseSineOut *fade_in=[CCActionEaseSineOut actionWithAction:[CCActionFadeIn actionWithDuration:0.3]];
    [top_clip runAction:fade_in];
    fade_in=[CCActionEaseSineOut actionWithAction:[CCActionFadeIn actionWithDuration:0.3]];
    [btm_clip runAction:fade_in];
    CCActionEaseSineIn *stretch=[CCActionEaseSineIn actionWithAction:[CCActionScaleTo actionWithDuration:0.3 scaleX:1 scaleY:2]];
    [MainSceneCircle runAction:stretch];
    
    CCActionEaseSineInOut *scale_to=[CCActionEaseSineIn actionWithAction:[CCActionScaleTo actionWithDuration:1 scaleX:3.5 scaleY:1]];
    [ColorBarBlur runAction:scale_to];
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
    if([self distanceA:Help.position B:touch_loc]<Help.contentSize.width/2.0)
        HelpShade.visible=YES;
}
-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    HelpShade.visible=NO;
    CGPoint touch_loc=[self getTouchLocation:touch];
    if([self distanceA:Help.position B:touch_loc]<Help.contentSize.width/2.0)
    {
        [self HelpScene];
        return;
    }
    [self transitionOut];
    [self scheduleOnce:@selector(MusicSelectionScene) delay:1.3];
    self.userInteractionEnabled=NO;
}
-(void)MusicSelectionScene{
    [[CCDirector sharedDirector]replaceScene:[MusicSelectionScene node]];
}
-(void)HelpScene{
    self.userInteractionEnabled=NO;
    [[CCDirector sharedDirector]replaceScene:[HelpScene node]];
    [[OALSimpleAudio sharedInstance]playEffect:@"Yes.aif"];
}
-(void)dealloc{
    NSLog(@"MainScene Deallocated!");
}
@end