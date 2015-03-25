//
//  SGBrick.m
//  Brick Breaker
//
//  Created by Rob Norback on 2/16/15.
//  Copyright (c) 2015 Sidecar Games. All rights reserved.
//

#import "SGBrick.h"

@implementation SGBrick

-(instancetype)initWithType:(BrickType)type
{
    switch (type) {
        case Green:
            self = [super initWithImageNamed:@"BrickGreen"];
            break;
        case Blue:
            self = [super initWithImageNamed:@"BrickBlue"];
            break;
        case Grey:
            self = [super initWithImageNamed:@"BrickGrey"];
            break;
        case Yellow:
            self = [super initWithImageNamed:@"BrickYellow"];
            break;
        default:
            self = nil;
            break;
    }
    
    if (self) {
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.size];
        self.physicsBody.dynamic = NO;
        self.physicsBody.categoryBitMask = kSGBrickCategory;
        self.type = type;
        self.indestructable = (type == Grey);
        self.name = @"brick";
    }
    
    return self;
}

-(void)hit
{
    switch (self.type) {
        case Green:
            [self runAction:[SKAction removeFromParent]];
            break;
        case Blue:
            self.texture = [SKTexture textureWithImageNamed:@"BrickGreen"];
            self.type = Green;
            break;
        case Yellow:
            [self runAction:[SKAction removeFromParent]];
            break;
        default:
            break;
    }
}

@end
