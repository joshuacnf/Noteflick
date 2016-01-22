//
//  MusicRecord.h
//  NoteFlick
//
//  Created by Joshua Nanami on 14-8-25.
//  Copyright (c) 2014年 Joshua Kirino. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MusicRecord:NSObject<NSCoding>
-(float)AC:(int)i;
-(void)updateInfo:(int)incre;
-(void)calculateRank;
@property (nonatomic,readwrite) float ac;
@property (nonatomic,readwrite) int it;
@property (nonatomic,readwrite) int beats,score,combo,temp_combo,hp;
@property (nonatomic,readwrite) int total_rank,score_rank,combo_rank,temp_combo_rank,ac_rank;
@end