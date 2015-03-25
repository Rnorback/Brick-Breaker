//
//  SGMenu.h
//  Brick Breaker
//
//  Created by Rob Norback on 2/20/15.
//  Copyright (c) 2015 Sidecar Games. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SGMenu : SKNode

//@property (nonatomic) int currentLevel;
@property (nonatomic) BOOL touchable;
@property (nonatomic) SKLabelNode* panelLabel;

-(void)show;
-(void)hide;

@end
