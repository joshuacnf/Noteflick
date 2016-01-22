//
//  MusicRecord.m
//  NoteFlick
//
//  Created by Joshua Nanami on 14-8-25.
//  Copyright (c) 2014年 Joshua Kirino. All rights reserved.
//

#import "MusicRecord.h"

@implementation MusicRecord{
    float AC[1500];
    int temp_combo;
    int perfect,good,safe,miss;
    float total_score;
}
@synthesize ac;
@synthesize it;
@synthesize beats,score,combo,temp_combo,hp;
@synthesize total_rank,score_rank,combo_rank,temp_combo_rank,ac_rank;
-(float)AC:(int)i{
    return AC[i];
}
-(id)init
{
    self=[super init];
    if(!self) return self;
    
    hp=100,temp_combo=0;
    memset(AC,0,sizeof(AC));
    total_score=0;
    for(int i=1;i<=beats;i++)
        total_score+=(int)(fminf(1.5,(i/(beats*1.0)+1))*100);
    score_rank=combo_rank=temp_combo_rank=ac_rank=total_rank='D';
    
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self=[super init];
    if(!self) return self;
    
    self.beats=[aDecoder decodeIntForKey:@"beats"];
    self.score=[aDecoder decodeIntForKey:@"score"];
    self.combo=[aDecoder decodeIntForKey:@"combo"];
    self.ac=[aDecoder decodeFloatForKey:@"ac"];
    
    self.score_rank=[aDecoder decodeIntForKey:@"score_rank"];
    self.combo_rank=[aDecoder decodeIntForKey:@"combo_rank"];
    self.ac_rank=[aDecoder decodeIntForKey:@"ac_rank"];
    self.total_rank=[aDecoder decodeIntForKey:@"total_rank"];
    
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:beats forKey:@"beats"];
    [aCoder encodeInt:score forKey:@"score"];
    [aCoder encodeInt:combo forKey:@"combo"];
    [aCoder encodeFloat:ac forKey:@"ac"];
    [aCoder encodeInt:score_rank forKey:@"score_rank"];
    [aCoder encodeInt:combo_rank forKey:@"combo_rank"];
    [aCoder encodeInt:ac_rank forKey:@"ac_rank"];
    [aCoder encodeInt:total_rank forKey:@"total_rank"];
}
-(void)updateInfo:(int)incre
{
    if(incre>=50) temp_combo++;
    else temp_combo=0;
    
    combo=combo>temp_combo?combo:temp_combo;
    
    if(incre==100) hp+=10,hp=hp<100?hp:100;
    if(incre<=10) hp-=20,hp=hp>0?hp:0;
    
    score+=(int)(incre*fminf(1.5,(temp_combo/(1.0*beats)+1)));
    switch(incre)
    {
        case 100: perfect++; break;
        case 50: good++; break;
        case 10: safe++; break;
        case 0: miss++; break;
    }

    it++;
    AC[it]=(AC[it-1]*(it-1)+incre)/(it*1.0);
    ac=AC[it];
    
    [self calculateRank];
}
-(void)calculateRank
{
    float rank;
    
    rank=score/(total_score*1.0);
    score_rank='D';
    if(rank>0.6) score_rank='C';
    if(rank>0.7) score_rank='B';
    if(rank>0.9) score_rank='A';
    if(rank>0.95) score_rank='S';
    
    rank=combo/(beats*1.0);
    combo_rank='D';
    if(rank>0.3) combo_rank='C';
    if(rank>0.6) combo_rank='B';
    if(rank>0.9) combo_rank='A';
    if(combo==beats) combo_rank='S';
    
    rank=ac/100.0;
    ac_rank='D';
    if(rank>0.6) ac_rank='C';
    if(rank>0.8) ac_rank='B';
    if(rank>0.9) ac_rank='A';
    if(rank>0.95) ac_rank='S';
    
    rank=(score/(total_score*1.0)+combo/(beats*1.0)+ac/100.0)/3.0;
    total_rank='D';
    if(rank>0.6) total_rank='C';
    if(rank>0.8) total_rank='B';
    if(rank>0.9) total_rank='A';
    if(rank>0.95&&combo==beats) total_rank='S';
    
    temp_combo_rank='D';
    if(temp_combo>=50) temp_combo_rank='C';
    if(temp_combo>=100) temp_combo_rank='B';
    if(temp_combo>=200) temp_combo_rank='A';
    if(temp_combo>=300) temp_combo_rank='S';
}
@end