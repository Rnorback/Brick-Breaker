//
//  SGMenu.m
//  Brick Breaker
//
//  Created by Rob Norback on 2/20/15.
//  Copyright (c) 2015 Sidecar Games. All rights reserved.
//

#import "SGMenu.h"

@implementation SGMenu
{
    SKSpriteNode *_menuPanel;
    SKSpriteNode *_playButton;
    SKLabelNode *_buttonLabel;
    
}

-(id)init
{
    self = [super init];
    
    _menuPanel = [SKSpriteNode spriteNodeWithImageNamed:@"MenuPanel"];
    _menuPanel.position = CGPointMake(0, 0);
    [self addChild:_menuPanel];
    
    _panelLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura"];
    _panelLabel.position = CGPointMake(0, -8);
    _panelLabel.fontSize = 20;
    _panelLabel.fontColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    _panelLabel.text = [NSString stringWithFormat:@"LEVEL 1"];
    [_menuPanel addChild:_panelLabel];
    
    _playButton = [SKSpriteNode spriteNodeWithImageNamed:@"Button"];
    _playButton.position = CGPointMake(0, -_menuPanel.size.height);
    _playButton.name = @"Play";
    [self addChild:_playButton];
    
    _buttonLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura"];
    _buttonLabel.name = @"Play";
    _buttonLabel.position = CGPointMake(0, -7);
    _buttonLabel.fontSize = 20;
    _buttonLabel.fontColor = [UIColor colorWithRed:0.5 green:0.5 blue:0.5 alpha:1.0];
    _buttonLabel.text = @"PLAY";
    [_playButton addChild:_buttonLabel];
    
    self.touchable = YES;
    
    return self;
}

//-(void)setCurrentLevel:(int)currentLevel
//{
//    _currentLevel = currentLevel;
//    _panelLabel.text = [NSString stringWithFormat:@"Level %i",(currentLevel+1)];
//}

-(void)show
{
    self.hidden = NO;
    self.touchable = YES;

    // Make menu fly off screen
    _menuPanel.position = CGPointMake(-300, 0);
    SKAction *flyRight = [SKAction moveToX:0 duration:0.5];
    flyRight.timingMode = SKActionTimingEaseIn;
    [_menuPanel runAction:flyRight];
    
    _playButton.position = CGPointMake(300, -_menuPanel.size.height);
    SKAction *flyLeft = [SKAction moveToX:0 duration:0.5];
    flyLeft.timingMode = SKActionTimingEaseIn;
    [_playButton runAction:flyLeft];

    
}

-(void)hide
{
    self.touchable = NO;
    
    // Make menu fly off screen
    SKAction *flyLeft = [SKAction moveToX:-300.0 duration:1.0];
    flyLeft.timingMode = SKActionTimingEaseOut;
    [_menuPanel runAction:flyLeft];
    
    SKAction *flyRight = [SKAction moveToX:300.0 duration:1.0];
    flyRight.timingMode = SKActionTimingEaseOut;
    [_playButton runAction:flyRight completion:^{
        self.hidden = YES;
    }];
}

@end
