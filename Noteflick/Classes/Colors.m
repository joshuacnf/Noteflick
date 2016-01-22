//
//  Colors.m
//  NoteFlick
//
//  Created by Joshua Kirino on 14-3-9.
//  Copyright 2014年 Joshua Kirino. All rights reserved.
//

#import "Colors.h"
@implementation Colors
@synthesize preset_colors;
-(id)init
{
    self=[super init];
    if(!self) return self;
    
    preset_colors=[NSMutableDictionary dictionaryWithCapacity:12];
    CCColor *preset;
    preset=[CCColor colorWithCcColor4b:ccc4(0xF3,0xEB,0xD4,0xFF)];
    [preset_colors setObject:preset forKey:@"beige"];
    
    preset=[CCColor colorWithCcColor4b:ccc4(0xE5,0x1C,0x23,0xFF)];
    [preset_colors setObject:preset forKey:@"red"];
    
    preset=[CCColor colorWithCcColor4b:ccc4(0xE9,0x1E,0x63,0xFF)];
    [preset_colors setObject:preset forKey:@"pink"];
    
    preset=[CCColor colorWithCcColor4b:ccc4(0x9C,0x27,0xB0,0xFF)];
    [preset_colors setObject:preset forKey:@"purple"];
    
    preset=[CCColor colorWithCcColor4b:ccc4(0x67,0x3A,0xB7,0xFF)];
    [preset_colors setObject:preset forKey:@"deep purple"];
    
    preset=[CCColor colorWithCcColor4b:ccc4(0x3F,0x51,0xB5,0xFF)];
    [preset_colors setObject:preset forKey:@"indigo"];
    
    preset=[CCColor colorWithCcColor4b:ccc4(0x56,0x77,0xFC,0xFF)];
    [preset_colors setObject:preset forKey:@"blue"];
    
    preset=[CCColor colorWithCcColor4b:ccc4(0x03,0xA9,0xF4,0xFF)];
    [preset_colors setObject:preset forKey:@"light blue"];
    
    preset=[CCColor colorWithCcColor4b:ccc4(0x00,0xBC,0xD4,0xFF)];
    [preset_colors setObject:preset forKey:@"cyan"];
    
    preset=[CCColor colorWithCcColor4b:ccc4(0x00,0x96,0x88,0xFF)];
    [preset_colors setObject:preset forKey:@"teal"];
    
    preset=[CCColor colorWithCcColor4b:ccc4(0x25,0x9B,0x24,0xFF)];
    [preset_colors setObject:preset forKey:@"green"];
    
    preset=[CCColor colorWithCcColor4b:ccc4(0x8B,0xC3,0x4A,0xFF)];
    [preset_colors setObject:preset forKey:@"light green"];
    
    preset=[CCColor colorWithCcColor4b:ccc4(0xCD,0xDC,0x39,0xFF)];
    [preset_colors setObject:preset forKey:@"lime"];
    
    preset=[CCColor colorWithCcColor4b:ccc4(0xFF,0xEB,0x3B,0xFF)];
    [preset_colors setObject:preset forKey:@"yellow"];
    
    preset=[CCColor colorWithCcColor4b:ccc4(0xFF,0xC1,0x07,0xFF)];
    [preset_colors setObject:preset forKey:@"amber"];
    
    preset=[CCColor colorWithCcColor4b:ccc4(0xFF,0x98,0x00,0xFF)];
    [preset_colors setObject:preset forKey:@"orange"];
    
    preset=[CCColor colorWithCcColor4b:ccc4(0xFF,0x57,0x22,0xFF)];
    [preset_colors setObject:preset forKey:@"deep orange"];
    
    preset=[CCColor colorWithCcColor4b:ccc4(0x79,0x55,0x48,0xFF)];
    [preset_colors setObject:preset forKey:@"brown"];
    
    preset=[CCColor colorWithCcColor4b:ccc4(0x9E,0x9E,0x9E,0xFF)];
    [preset_colors setObject:preset forKey:@"grey"];
    
    preset=[CCColor colorWithCcColor4b:ccc4(0xE8,0xE8,0xE8,0xFF)];
    [preset_colors setObject:preset forKey:@"light grey"];
    
    preset=[CCColor colorWithCcColor4b:ccc4(0xBD,0xBD,0xBD,0xFF)];
    [preset_colors setObject:preset forKey:@"bg grey"];
    
    preset=[CCColor colorWithCcColor4b:ccc4(0x83,0x83,0x83,0xFF)];
    [preset_colors setObject:preset forKey:@"record_win grey"];
    
    preset=[CCColor colorWithCcColor4b:ccc4(0x60,0x7D,0x8B,0xFF)];
    [preset_colors setObject:preset forKey:@"blue grey"];
    
    preset=[CCColor colorWithCcColor4b:ccc4(0xFF,0x8B,0x00,0xFF)];
    [preset_colors setObject:preset forKey:@"S"];

    preset=[CCColor colorWithCcColor4b:ccc4(0x23,0x94,0xED,0xFF)];
    [preset_colors setObject:preset forKey:@"A"];

    preset=[CCColor colorWithCcColor4b:ccc4(0x8B,0xC3,0x4A,0xFF)];
    [preset_colors setObject:preset forKey:@"B"];

    preset=[CCColor colorWithCcColor4b:ccc4(0x83,0x83,0x83,0xFF)];
    [preset_colors setObject:preset forKey:@"C"];
    
    preset=[CCColor colorWithCcColor4b:ccc4(0x00,0x00,0x00,0xFF)];
    [preset_colors setObject:preset forKey:@"D"];
    
    preset=[CCColor colorWithCcColor4b:ccc4(0xFF,0xFF,0xFF,0xFF)];
    [preset_colors setObject:preset forKey:@"white"];
    
    return self;
}
@end
