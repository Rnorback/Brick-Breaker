//
//  SGBrick.h
//  Brick Breaker
//
//  Created by Rob Norback on 2/16/15.
//  Copyright (c) 2015 Sidecar Games. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef enum : NSUInteger {
    Green = 1,
    Blue = 2,
    Grey = 3,
    Yellow = 4,
} BrickType;

static const uint32_t kSGBrickCategory = 0x1 << 3;

@interface SGBrick : SKSpriteNode

@property (nonatomic) BrickType type;
@property (nonatomic) BOOL indestructable;

-(instancetype)initWithType: (BrickType) type;
-(void)hit;

@end
