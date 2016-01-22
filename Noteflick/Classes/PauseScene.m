//
//  PauseScene.m
//  NoteFlick
//
//  Created by Joshua Nanami on 14-8-24.
//  Copyright 2014年 Joshua Kirino. All rights reserved.
//

#import "PauseScene.h"
#import "Colors.h"

@implementation PauseScene
{
    Colors *color_set;
    
    CCSprite *alert_win,*option_cell1,*option_cell2;
    CCLabelTTF *pause,*quit,*option_quit,*option_yes,*option_resume,*option_no;
    
    bool QUIT;
}
@synthesize delegate;
-(id)init
{
    self=[super init];
    if(!self) return 0;
    
    CGSize scrSize=[CCDirector sharedDirector].viewSize;
    color_set=[Colors node];
    QUIT=false;
    
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
    shade.opacity=0.5;
    [self addChild:shade z:0];
    
    alert_win=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"AlertWin.png"]];
    alert_win.position=ccp(scrSize.width/2.0,scrSize.height/2.0);
    alert_win.color=[color_set.preset_colors objectForKey:@"light grey"];
    alert_win.cascadeOpacityEnabled=YES;
    [self addChild:alert_win z:1];
    
    NSString *font_name=@"Roboto-Light";
    pause=[CCLabelTTF labelWithString:@"PAUSED" fontName:font_name fontSize:50];
    pause.anchorPoint=ccp(0.5,0.5);
    pause.position=ccp(alert_win.contentSize.width/2.0,alert_win.contentSize.height/2.0+40);
    pause.color=[color_set.preset_colors objectForKey:@"light blue"];
    [alert_win addChild:pause];
    
    quit=[CCLabelTTF labelWithString:@"QUIT?" fontName:font_name fontSize:50];
    quit.anchorPoint=ccp(0.5,0.5);
    quit.position=pause.position;
    quit.color=[color_set.preset_colors objectForKey:@"light blue"];
    quit.visible=NO;
    [alert_win addChild:quit];
    
    option_cell1=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"AlertWinOptionCell1.png"]];
    option_cell1.position=ccp(option_cell1.contentSize.width/2.0,option_cell1.contentSize.height/2.0);
    option_cell1.color=[color_set.preset_colors objectForKey:@"record_win grey"];
    option_cell1.opacity=0.65;option_cell1.visible=NO;
    [alert_win addChild:option_cell1 z:2];
    
    option_quit=[CCLabelTTF labelWithString:@"Quit" fontName:font_name fontSize:30];
    option_quit.anchorPoint=ccp(0.5,0.5);
    option_quit.position=option_cell1.position;
    option_quit.color=[color_set.preset_colors objectForKey:@"red"];
    [alert_win addChild:option_quit z:1];
    
    option_yes=[CCLabelTTF labelWithString:@"Yes" fontName:font_name fontSize:30];
    option_yes.anchorPoint=ccp(0.5,0.5);
    option_yes.position=option_cell1.position;
    option_yes.color=[color_set.preset_colors objectForKey:@"red"];
    option_yes.visible=NO;
    [alert_win addChild:option_yes z:1];
    
    option_cell2=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"AlertWinOptionCell2.png"]];
    option_cell2.position=ccp(alert_win.contentSize.width-option_cell2.contentSize.width/2.0,option_cell2.contentSize.height/2.0);
    option_cell2.color=[color_set.preset_colors objectForKey:@"record_win grey"];
    option_cell2.opacity=0.65;option_cell2.visible=NO;
    [alert_win addChild:option_cell2 z:2];
    
    option_resume=[CCLabelTTF labelWithString:@"Resume" fontName:font_name fontSize:30];
    option_resume.anchorPoint=ccp(0.5,0.5);
    option_resume.position=option_cell2.position;
    option_resume.color=[color_set.preset_colors objectForKey:@"light blue"];
    [alert_win addChild:option_resume z:1];

    option_no=[CCLabelTTF labelWithString:@"No" fontName:font_name fontSize:30];
    option_no.anchorPoint=ccp(0.5,0.5);
    option_no.position=option_cell2.position;
    option_no.color=[color_set.preset_colors objectForKey:@"light blue"];
    option_no.visible=NO;
    [alert_win addChild:option_no z:1];
    
    alert_win.scale=0.05;
    alert_win.opacity=0;
    CCActionEaseBackOut *magnify=[CCActionEaseBackOut actionWithAction:[CCActionScaleTo actionWithDuration:0.5 scale:1]];
    CCActionEaseSineIn *fadein=[CCActionEaseSineIn actionWithAction:[CCActionFadeIn actionWithDuration:0.5]];
    CCActionSpawn *spawn=[CCActionSpawn actions:magnify,fadein,nil];
    CCActionCallBlock *call=[CCActionCallBlock actionWithBlock:^(void){
        self.userInteractionEnabled=YES;
    }];
    CCActionSequence *seq=[CCActionSequence actions:spawn,call,nil];
    [alert_win runAction:seq];
    
    self.userInteractionEnabled=NO;
    
    return self;
}
-(void)toggleAlertWin:(BOOL)Quit
{
    CCActionEaseBackIn *minimize=[CCActionEaseBackIn actionWithAction:[CCActionScaleTo actionWithDuration:0.25 scale:0.05]];
    CCActionCallBlock *call;
    if(Quit)
        call=[CCActionCallBlock actionWithBlock:^(void){
            quit.visible=option_yes.visible=option_no.visible=YES;
            pause.visible=option_quit.visible=option_resume.visible=NO;
        }];
    else
        call=[CCActionCallBlock actionWithBlock:^(void){
            quit.visible=option_yes.visible=option_no.visible=NO;
            pause.visible=option_quit.visible=option_resume.visible=YES;
        }];
    CCActionEaseBackOut *magnify=[CCActionEaseBackOut actionWithAction:[CCActionScaleTo actionWithDuration:0.25 scale:1]];
    CCActionCallBlock *call2=[CCActionCallBlock actionWithBlock:^(void){
        self.userInteractionEnabled=YES;
    }];
    CCActionSequence *seq=[CCActionSequence actions:minimize,call,magnify,call2,nil];
    [alert_win runAction:seq];
    self.userInteractionEnabled=NO;
}
-(CGPoint)getTouchLocation:(UITouch *)touch
{
    CGPoint touch_location=[touch locationInView:touch.view];
    touch_location=[[CCDirector sharedDirector]convertToGL:touch_location];
    touch_location=[alert_win convertToNodeSpace:touch_location];
    return touch_location;
}
-(void)touchBegan:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touch_loc=[self getTouchLocation:touch];
    if(CGRectContainsPoint([option_cell1 boundingBox],touch_loc))
        option_cell1.visible=YES;
    else if(CGRectContainsPoint([option_cell2 boundingBox],touch_loc))
        option_cell2.visible=YES;
}
-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    option_cell1.visible=option_cell2.visible=NO;
    CGPoint touch_loc=[self getTouchLocation:touch];
    
    
    if(CGRectContainsPoint([option_cell1 boundingBox],touch_loc))
    {
        [[OALSimpleAudio sharedInstance]playEffect:@"Yes.aif"];
        if(!QUIT)
        {
            QUIT=true;
            [self toggleAlertWin:QUIT];
        }
        else
        {
            self.userInteractionEnabled=NO;
            [self.delegate quit];
        }
    }
    else if(CGRectContainsPoint([option_cell2 boundingBox],touch_loc))
    {
        [[OALSimpleAudio sharedInstance]playEffect:@"No.aif"];
        if(!QUIT)
        {
            self.userInteractionEnabled=NO;
            [self.delegate resume];
        }
        else
        {
            QUIT=false;
            [self toggleAlertWin:QUIT];
        }
    }
}
-(void)dealloc{
    NSLog(@"PauseScene deallocated!");
}
@end
