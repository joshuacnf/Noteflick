//
//  BGAnimation.m
//  NoteFlick
//
//  Created by Joshua Nanami on 14-8-12.
//  Copyright 2014年 Joshua Kirino. All rights reserved.
//

#import "GameSceneBackground.h"
#import "GameScene.h"
#import "Colors.h"

@implementation GameSceneBackground
{
    CGSize scrSize;
    Colors *color_set;
    NSArray *color_name;
    
    CCClippingNode *star_clip;
    NSMutableArray *Stars;int star_num;
    bool in_air[19];
    
    CCSprite *score_bar_frame,*score_bar1,*score_bar2;
    CCClippingNode *score_bar_clip;
    CCLabelTTF *score_label,*combo_label;
    
    BOOL score_rank_change,combo_rank_change,ac_rank_change;
    BOOL combo_change;
}
@synthesize record;
-(id)initWithBeats:(int)beats_num
{
    self=[super init];
    if(!self) return self;
    
    scrSize=[CCDirector sharedDirector].viewSize;
    color_set=[Colors node];
    self.contentSize=scrSize;
    self.anchorPoint=ccp(0,0);
    Stars=[NSMutableArray array];
    record=[[MusicRecord alloc]init];
    record.beats=beats_num;
    record=[record init];
    color_name=@[@"red",@"pink",@"purple",@"deep purple",@"indigo",@"blue",@"light blue",@"cyan",@"teal",@"green",@"light green",@"lime",@"yellow",@"amber",@"orange",@"deep orange",@"brown",@"grey",@"blue grey"];
    star_num=19;
    
    
    CCSprite *background=[CCSprite spriteWithImageNamed:@"GameSceneBackground.png"];
    background.position=ccp(scrSize.width/2.0,scrSize.height/2.0);
    [self addChild:background z:0];
    
    score_bar_frame=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"ScoreBarFrame.png"]];
    score_bar_frame.position=ccp(scrSize.width/2.0,scrSize.height-30);
    score_bar_frame.color=[color_set.preset_colors objectForKey:@"D"];
    [self addChild:score_bar_frame z:2];
    
    CCSprite *stencil=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"ScoreBarClip.png"]];
    stencil.anchorPoint=ccp(0,0.5);
    stencil.position=ccpAdd(score_bar_frame.position,ccp(-stencil.contentSize.width/2.0,0));
    score_bar_clip=[CCClippingNode clippingNodeWithStencil:stencil];
    score_bar_clip.stencil.scaleX=0;
    score_bar_clip.alphaThreshold=0;
    [self addChild:score_bar_clip z:1];
    
    score_bar1=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"ScoreBar.png"]];
    score_bar1.position=score_bar_frame.position;
    [score_bar_clip addChild:score_bar1];
    score_bar2=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"ScoreBar.png"]];
    score_bar2.position=ccpAdd(score_bar_frame.position,ccp(-score_bar2.contentSize.width,0));
    [score_bar_clip addChild:score_bar2];
    
    CCActionMoveBy *move_by1=[CCActionMoveBy actionWithDuration:5 position:ccp(score_bar1.contentSize.width,0)];
    CCActionCallBlock *call=[CCActionCallBlock actionWithBlock:^(void){
        score_bar1.position=ccpAdd(score_bar_frame.position,ccp(-score_bar2.contentSize.width,0));
    }];
    CCActionMoveBy *move_by2=[CCActionMoveBy actionWithDuration:5 position:ccp(score_bar1.contentSize.width,0)];
    CCActionRepeatForever *repeat1=[CCActionRepeatForever actionWithAction:[CCActionSequence actions:move_by1,call,move_by2,nil]];
    
    
    move_by1=[CCActionMoveBy actionWithDuration:5 position:ccp(score_bar1.contentSize.width,0)];
    move_by2=[CCActionMoveBy actionWithDuration:5 position:ccp(score_bar1.contentSize.width,0)];
    call=[CCActionCallBlock actionWithBlock:^(void){
        score_bar2.position=ccpAdd(score_bar_frame.position,ccp(-score_bar2.contentSize.width,0));
    }];
    CCActionRepeatForever *repeat2=[CCActionRepeatForever actionWithAction:[CCActionSequence actions:move_by1,move_by2,call,nil]];
    [score_bar1 runAction:repeat1];
    [score_bar2 runAction:repeat2];
    
    
    score_label=[CCLabelTTF labelWithString:@"000000" fontName:@"Roboto-Light" fontSize:45];
    score_label.anchorPoint=ccp(0.5,0.5);
    score_label.position=ccpAdd(score_bar_frame.position,ccp(0,-score_bar_frame.contentSize.height-score_label.contentSize.height/2.0));
    score_label.color=[color_set.preset_colors objectForKey:@"D"];
    [self addChild:score_label z:1];
    
    
    combo_label=[CCLabelTTF labelWithString:@"0" fontName:@"Roboto-Light" fontSize:60];
    combo_label.anchorPoint=ccp(0,0);
    combo_label.position=ccp(0,0);
    combo_label.color=[color_set.preset_colors objectForKey:@"D"];
    [self addChild:combo_label z:1];
    
    
    CCNodeColor *stencil2=[CCNodeColor nodeWithColor:[color_set.preset_colors objectForKey:@"bg grey"]
                                               width:scrSize.width height:scrSize.height/6.0+12];
    stencil2.position=ccp(0,0);
    star_clip=[CCClippingNode clippingNodeWithStencil:stencil2];
    star_clip.alphaThreshold=0;
    star_clip.inverted=YES;
    
    [self addChild:star_clip z:1];
    
    CCSprite *star=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Star.png"]];
    int star_h=scrSize.height/6.0-star.contentSize.height/2.0;
    int width=scrSize.width-100;
    CCActionRepeatForever *rot;
    for(int i=0;i<star_num;i++)
    {
        star=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Star.png"]];
        star.position=ccp(50+i/(star_num*1.0)*width,star_h);
        star.color=[color_set.preset_colors objectForKey:color_name[i]];
        rot=[CCActionRepeatForever actionWithAction:[CCActionRotateBy actionWithDuration:2.5 angle:360]];
        [star runAction:rot];
        [star_clip addChild:star];
        Stars[i]=star;
    }
    
    [self scheduleOnce:@selector(countDown) delay:0.5];
    
    return self;
}
-(void)countDown
{
    CCSprite *three,*two,*one,*start;
    three=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Three.png"]];
    two=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Two.png"]];
    one=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"One.png"]];
    start=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Start.png"]];
    start.opacity=three.opacity=two.opacity=one.opacity=0;
    start.position=three.position=two.position=one.position=ccp(scrSize.width/2.0,scrSize.height/2.0);
    start.scale=three.scale=two.scale=one.scale=2.5;
    [self addChild:three z:2];
    [self addChild:two z:2];
    [self addChild:one z:2];
    [self addChild:start z:2];
    
    NSArray *counts=[NSArray arrayWithObjects:three,two,one,start,nil];
    for(int i=0;i<4;i++)
    {
        CCActionInterval *pre=[CCActionInterval actionWithDuration:1+i];
        CCActionEaseBackOut *scale_to=[CCActionEaseBackOut actionWithAction:[CCActionScaleTo actionWithDuration:0.5 scale:1]];
        CCActionFadeIn *fade_in=[CCActionFadeIn actionWithDuration:0.5];
        CCActionSpawn *spawn=[CCActionSpawn actions:scale_to,fade_in,nil];
        CCActionInterval *interval=[CCActionInterval actionWithDuration:0.3];
        CCActionFadeOut *fade_out=[CCActionFadeOut actionWithDuration:0.2];
        CCActionCallBlock *call=[CCActionCallBlock actionWithBlock:^(void){
            [counts[i] removeFromParent];
        }];
        CCActionSequence *seq=[CCActionSequence actions:pre,spawn,interval,fade_out,call,nil];
        [counts[i] runAction:seq];
    }
    
    score_bar_clip.stencil.scaleX=0;
    CCActionInterval *pre=[CCActionInterval actionWithDuration:1];
    CCActionScaleTo *scale_to=[CCActionScaleTo actionWithDuration:4 scaleX:1 scaleY:1];
    CCActionCallBlock *call=[CCActionCallBlock actionWithBlock:^(void){
        GameScene *P=self.parent;
        [P gameStart];
    }];
    CCActionSequence *seq=[CCActionSequence actions:pre,scale_to,call,nil];
    [score_bar_clip.stencil runAction:seq];
}
-(void)starJump:(float)t score:(int)incre
{
    if(incre<50) return;
    float h=scrSize.height/2.0;
    if(incre==50) h*=0.5;
    CCSprite *star;CCActionJumpBy *jump;int i;
    while(in_air[i=rand()%star_num]);
    star=Stars[i];
    jump=[CCActionJumpBy actionWithDuration:t position:ccp(0,0) height:h jumps:1];
    [star runAction:jump];
    in_air[i]=true;
    [self scheduleBlock:^(CCTimer *timer){
        in_air[i]=false;
    }delay:t];
}
-(void)updateScoreBar:(int)incre
{
    score_label.string=[NSString stringWithFormat:@"%06d",record.score];
    if(score_rank_change)
    {
        CCColor *color=[color_set.preset_colors objectForKey:[NSString stringWithFormat:@"%c",record.score_rank]];
        
        CCActionTintTo *tint_to=[CCActionTintTo actionWithDuration:0.5 color:color];
        [score_label stopAllActions];
        [score_label runAction:tint_to];
        
        tint_to=[CCActionTintTo actionWithDuration:0.5 color:color];
        [score_bar_frame stopAllActions];
        [score_bar_frame runAction:tint_to];
    }
    
    CCActionEaseSineInOut *scale_to=[CCActionEaseSineInOut actionWithAction:
                                     [CCActionScaleTo actionWithDuration:0.5 scaleX:record.hp/100.0 scaleY:1]];
    [score_bar_clip.stencil stopAllActions];
    [score_bar_clip.stencil runAction:scale_to];
    
    if(!record.hp)
    {
        GameScene *P=self.parent;
        [P gameOver];
    }
}
-(void)updateCombo:(int)incre
{
    if(!combo_change) return;
    
    [combo_label stopAllActions];
    CCActionEaseSineIn *magnify=[CCActionEaseSineIn actionWithAction:[CCActionScaleTo actionWithDuration:0.15 scale:1.5]];
    CCActionEaseSineIn *minimize=[CCActionEaseSineIn actionWithAction:[CCActionScaleTo actionWithDuration:0.15 scale:1]];
    CCActionCallBlock *call;
    if(combo_rank_change)
        call=[CCActionCallBlock actionWithBlock:^(void){
            combo_label.color=[color_set.preset_colors objectForKey:[NSString stringWithFormat:@"%c",record.temp_combo_rank]];
            NSLog(@"%c",record.temp_combo_rank);
            combo_label.string=[NSString stringWithFormat:@"%d",record.temp_combo];
        }];
    else call=[CCActionCallBlock actionWithBlock:^(void){
        combo_label.string=[NSString stringWithFormat:@"%d",record.temp_combo];
    }];
    CCActionSequence *seq=[CCActionSequence actions:magnify,call,minimize,nil];
    [combo_label runAction:seq];
}
-(void)updateInfo:(int)incre
{
    combo_change=YES;
    if(incre<50&&record.temp_combo==0)
        combo_change=NO;
    
    
    score_rank_change=combo_rank_change=ac_rank_change=NO;
    int pre_score_rank=record.score_rank;
    int pre_combo_rank=record.temp_combo_rank;
    int pre_ac_rank=record.ac_rank;
    
    [record updateInfo:incre];
    
    if(record.score_rank!=pre_score_rank) score_rank_change=YES;
    if(record.temp_combo_rank!=pre_combo_rank) combo_rank_change=YES;
    if(record.ac_rank!=pre_ac_rank) ac_rank_change=YES;
    
    
    [self updateScoreBar:incre];
    [self updateCombo:incre];
}
-(void)dealloc{
    NSLog(@"GameSceneBackground deallocated!");
}
@end
