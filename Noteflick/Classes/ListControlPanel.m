//
//  ListControlPanel.m
//  NoteFlick
//
//  Created by Joshua Nanami on 14-7-23.
//  Copyright 2014年 Joshua Kirino. All rights reserved.
//

#import "ListControlPanel.h"
#import "MusicList.h"
#import "Colors.h"
#import "MusicSelectionScene.h"

@implementation ListControlPanel
{
    CGSize scrSize;
    Colors *color_set;
    
    CCSprite *delete,*match,*shadeCircle;
    UITextField *search_bar;
}
@synthesize ThemeColor;
@synthesize SelectedTitle;
-(id)initWithSpriteFrame:(CCSpriteFrame *)spriteFrame
{
    self=[super initWithSpriteFrame:spriteFrame];
    if(!self) return self;
    
    scrSize=[CCDirector sharedDirector].viewSize;
    color_set=[Colors node];
    
    self.ThemeColor=[color_set.preset_colors objectForKey:@"red"];
    self.position=ccp(scrSize.width-self.contentSize.width/2.0,scrSize.height-self.contentSize.height/2.0);
    self.opacity=0.5;
    
    delete=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Delete.png"]];
    delete.position=ccp(delete.contentSize.width*3/4.0,delete.contentSize.height*3/4.0);
    delete.color=ThemeColor;
    [self addChild:delete z:1];
    
    match=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"Match.png"]];
    match.position=ccp(self.contentSize.width-match.contentSize.width*3/4.0,match.contentSize.height*3/4.0);
    match.color=ThemeColor;
    [self addChild:match z:1];
    
    shadeCircle=[CCSprite spriteWithSpriteFrame:[CCSpriteFrame frameWithImageNamed:@"ControlPanelShadeCircle.png"]];
    shadeCircle.color=[CCColor colorWithCcColor3b:ccBLACK];
    shadeCircle.opacity=0.5;
    shadeCircle.position=ccp(delete.contentSize.width/2.0,delete.contentSize.height/2.0);
    
    CGRect search_bar_rect=CGRectMake([self convertToWorldSpace:delete.position].x+delete.contentSize.width*3/4.0,
                                      self.contentSize.height-delete.position.y-20,
                                      match.position.x-delete.position.x-delete.contentSize.width*3/2.0,
                                      40);
    search_bar=[[UITextField alloc]initWithFrame:search_bar_rect];
    search_bar.placeholder=@"Search";
    search_bar.borderStyle=UITextBorderStyleRoundedRect;
    search_bar.delegate=self;
    search_bar.clearButtonMode=YES;
    search_bar.clearsOnBeginEditing=YES;
    [self scheduleBlock:^(CCTimer *timer){
        [[CCDirector sharedDirector].view addSubview:search_bar];
    }delay:0.5];
    
    self.userInteractionEnabled=YES;
    
    return self;
}
-(void)selectionChanged
{
    CCActionTintTo *tint_to=[CCActionTintTo actionWithDuration:0.25 color:ThemeColor];
    [delete runAction:tint_to];
    tint_to=[CCActionTintTo actionWithDuration:0.25 color:ThemeColor];
    [match runAction:tint_to];
}
-(void)ShowSearchBar{
    [[CCDirector sharedDirector].view addSubview:search_bar];
}
-(void)HideSearchBar{
    [search_bar removeFromSuperview];
}
-(CGPoint)getTouchLocation:(UITouch*)touch
{
    CGPoint touch_location=[touch locationInView:touch.view];
    touch_location=[[CCDirector sharedDirector]convertToGL:touch_location];
    touch_location=[self convertToNodeSpace:touch_location];
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
    CGPoint touch_loca=[self getTouchLocation:touch];
    if([self distanceA:delete.position B:touch_loca]<delete.contentSize.width/2.0)
        [delete addChild:shadeCircle z:1];
    else if([self distanceA:match.position B:touch_loca]<match.contentSize.width/2.0)
        [match addChild:shadeCircle z:1];
}
-(void)touchEnded:(UITouch *)touch withEvent:(UIEvent *)event
{
    [shadeCircle removeFromParent];
    
    CGPoint touch_loca=[self getTouchLocation:touch];
    MusicSelectionScene *P=self.parent;
    if([self distanceA:delete.position B:touch_loca]<delete.contentSize.width/2.0)
    {
        if([P deleteAble])
        {
            NSString *msg=[NSString stringWithFormat:@"Are you sure to delete \"%@\"?",SelectedTitle];
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Delete?" message:msg delegate:self cancelButtonTitle:@"Cancel"otherButtonTitles:@"Delete",nil];
            [alert show];
        }
        else
        {
            NSString *msg=@"Sorry, there must be at least one beatmap in your list";
            UIAlertView *alert=[[UIAlertView alloc]initWithTitle:@"Delete Failed" message:msg delegate:self cancelButtonTitle:@"Done" otherButtonTitles:nil];
            [alert show];
        }
    }
    else if([self distanceA:match.position B:touch_loca]<match.contentSize.width/2.0)
        [P showLibraryList];
}
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if(buttonIndex==1)
    {
        MusicSelectionScene *P=self.parent;
        [P deleteOption];
        [[OALSimpleAudio sharedInstance]playEffect:@"Yes.aif"];
    }
    else [[OALSimpleAudio sharedInstance]playEffect:@"No.aif"];
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if(textField.text.length)
    {
        MusicSelectionScene *P=self.parent;
        [P searchOption:textField.text];
    }
    return YES;
}
-(void)dealloc
{
    NSLog(@"control_panel deallocated!");
}
@end
