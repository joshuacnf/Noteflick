//
//  RankBlock.m
//  NoteFlick
//
//  Created by Joshua Nanami on 14-9-7.
//  Copyright 2014年 Joshua Kirino. All rights reserved.
//

#import "RankBlock.h"

@implementation RankBlock{
    NSMutableArray *Ranks;
}
-(id)initWithStr:(NSString *)str
{
    self=[super init];
    if(!self) return self;
    
    NSString *name[4]={@"S",@"A",@"B",@"C"};
    Ranks=[NSMutableArray arrayWithCapacity:4];
    CCSprite *rank;
    for(int i=0;i<4;i++)
    {
        rank=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:
                                              [name[i] stringByAppendingString:[NSString stringWithFormat:@"%@.png",str]]]];
        rank.position=ccp(0,0);
        rank.opacity=0;
        [self addChild:rank];
        Ranks[i]=rank;
    }
    return self;
}
-(void)switchTo:(int)ascii
{
    int rank;
    switch(ascii)
    {
        case 'S':rank=0; break;
        case 'A':rank=1; break;
        case 'B':rank=2; break;
        case 'C':rank=3; break;
        default:rank=4; break;
    }
    for(int i=0;i<4;i++)
        if(i!=rank&&((CCSprite*)Ranks[i]).opacity>0)
        {
            CCActionFadeOut *fade_out=[CCActionFadeOut actionWithDuration:0.3];
            [Ranks[i] runAction:fade_out];
        }
        else if(i==rank)
        {
            CCActionFadeIn *fade_in=[CCActionFadeIn actionWithDuration:0.3];
            [Ranks[i] runAction:fade_in];
        }
}
@end
