//
//  BeatMap.m
//  NoteFlick
//
//  Created by Joshua Nanami on 14-8-25.
//  Copyright (c) 2014年 Joshua Kirino. All rights reserved.
//

#import "BeatMap.h"

@implementation iNote
@synthesize type;
@synthesize offset;
@synthesize start,end,control,control2;
@synthesize duration,slider_length;
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self=[super init];
    if(!self) return 0;
    
    self.type=[aDecoder decodeIntForKey:@"type"];
    self.offset=[aDecoder decodeIntForKey:@"offset"];
    self.start=[aDecoder decodeCGPointForKey:@"start"];
    self.end=[aDecoder decodeCGPointForKey:@"end"];
    self.control=[aDecoder decodeCGPointForKey:@"control"];
    self.duration=[aDecoder decodeFloatForKey:@"duration"];
    self.slider_length=[aDecoder decodeFloatForKey:@"slider_length"];
    
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:type forKey:@"type"];
    [aCoder encodeInt:offset forKey:@"offset"];
    [aCoder encodeCGPoint:start forKey:@"start"];
    [aCoder encodeCGPoint:end forKey:@"end"];
    [aCoder encodeCGPoint:control forKey:@"control"];
    [aCoder encodeFloat:duration forKey:@"duration"];
    [aCoder encodeFloat:slider_length forKey:@"slider_length"];
}
@end

@implementation BeatMap
@synthesize Notes;
@synthesize notes_num,beatpoint_num;
@synthesize sec_per_beat;
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self=[super init];
    if(!self) return self;
    
    self.notes_num=[aDecoder decodeIntForKey:@"notes_num"];
    self.beatpoint_num=[aDecoder decodeIntForKey:@"beatpoint_num"];
    self.sec_per_beat=[aDecoder decodeFloatForKey:@"sec_per_beat"];
    self.Notes=[aDecoder decodeObjectForKey:@"Notes"];
    
    return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeInt:notes_num forKey:@"notes_num"];
    [aCoder encodeInt:beatpoint_num forKey:@"beatpoint_num"];
    [aCoder encodeFloat:sec_per_beat forKey:@"sec_per_beat"];
    [aCoder encodeObject:Notes forKey:@"Notes"];
}
@end
