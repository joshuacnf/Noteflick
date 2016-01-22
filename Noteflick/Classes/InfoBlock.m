//
//  InfoBlock.m
//  NoteFlick
//
//  Created by Joshua Nanami on 14-8-9.
//  Copyright 2014年 Joshua Kirino. All rights reserved.
//

#import "InfoBlock.h"
#import "RankBlock.h"

@implementation InfoBlock
{
    CCLabelTTF *score,*combo,*accurracy;
    RankBlock *score_rank,*combo_rank,*ac_rank;
}
-(id)init;
{
    self=[super init];
    if(!self) return self;
    
    NSString *font=@"Roboto-Light";
    int font_size=29;
    float interval=65,base_y=10;
    float block_width=240;
    
    self.contentSize=CGSizeMake(block_width,interval*3);
    
    score=[CCLabelTTF labelWithString:@"Score: 000000" fontName:font fontSize:font_size];
    combo=[CCLabelTTF labelWithString:@"Combo: 0000" fontName:font fontSize:font_size];
    accurracy=[CCLabelTTF labelWithString:@"Accuracy: 00\%" fontName:font fontSize:font_size];
    score_rank=[[RankBlock alloc]initWithStr:@"mini"];
    combo_rank=[[RankBlock alloc]initWithStr:@"mini"];
    ac_rank=[[RankBlock alloc]initWithStr:@"mini"];
    
    score.anchorPoint=combo.anchorPoint=accurracy.anchorPoint=ccp(0,0.5);
    
    score.position=ccp(0,interval*2+base_y);
    combo.position=ccp(0,interval+base_y);
    accurracy.position=ccp(0,0+base_y);
    score_rank.position=ccp(block_width-score_rank.contentSize.width/2.0,score.position.y);
    combo_rank.position=ccp(block_width-combo_rank.contentSize.width/2.0,combo.position.y);
    ac_rank.position=ccp(block_width-ac_rank.contentSize.width/2.0,accurracy.position.y);
    
    self.cascadeOpacityEnabled=YES;
    [self addChild:score];
    [self addChild:combo];
    [self addChild:accurracy];
    [self addChild:score_rank];
    [self addChild:combo_rank];
    [self addChild:ac_rank];
    self.opacity=0;
    
    return self;
}
-(void)updateWithRecord:(MusicRecord *)record
{
    if(!record&&self.opacity>0)
    {
        CCActionFadeOut *fade_out=[CCActionFadeOut actionWithDuration:0.3];
        [self stopAllActions];
        [self runAction:fade_out];
    }
    else if(record)
    {
        score.string=[NSString stringWithFormat:@"Score: %06d",record.score];
        combo.string=[NSString stringWithFormat:@"Combo: %04d",record.combo];
        accurracy.string=[NSString stringWithFormat:@"Accuracy: %02d",(int)record.ac];
        [score_rank switchTo:record.score_rank];
        [combo_rank switchTo:record.combo_rank];
        [ac_rank switchTo:record.ac_rank];
        
        CCActionFadeIn *fade_in=[CCActionFadeIn actionWithDuration:0.3];
        [self stopAllActions];
        [self runAction:fade_in];
    }
}
-(void)dealloc
{
    NSLog(@"info_block deallocated!");
}
@end
