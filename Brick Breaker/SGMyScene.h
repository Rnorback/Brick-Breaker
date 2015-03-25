//
//  SGMyScene.h
//  Brick Breaker
//

//  Copyright (c) 2015 Sidecar Games. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface SGMyScene : SKScene <SKPhysicsContactDelegate>

@property (nonatomic) int lives;
@property (nonatomic) int currentLevel;

@end
