//
//  SGMyScene.m
//  Brick Breaker
//
//  Created by Rob Norback on 2/13/15.
//  Copyright (c) 2015 Sidecar Games. All rights reserved.
//

#import "SGMyScene.h"
#import "SGBrick.h"
#import "SGMenu.h"

@implementation SGMyScene
{
    SGMenu *_menu;
    
    // Game elements
    SKSpriteNode *_paddle;
    SKSpriteNode *_ball;
    SKSpriteNode *_bar;
    SKLabelNode *_levelLabel;
    NSArray *_hearts;
    SKNode *_brickLayer;
    
    // Game sounds
    SKAction *_bounceSound;
    SKAction *_brickSmashSound;
    SKAction *_paddleSound;
    SKAction *_loseLifeSound;
    SKAction *_levelUpSound;
    
    // Game attributes
    CGFloat _ballSpeed;
    int _lives;
    // Tells if ball is attached to paddle
    BOOL _ballReleased;
    // Where a touch starts in a touch event
    CGPoint _startPosition;
}

static const int MAX_LEVEL = 4;

static const uint32_t kSGBallCategory = 0x1 << 0;
static const uint32_t kSGPaddleCategory = 0x1 << 1;
static const uint32_t kSGEdgeCategory = 0x1 << 2;

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.name = @"Self";
        
        // Turn off gravity
        self.physicsWorld.gravity = CGVectorMake(0.0, 0.0);
        self.physicsWorld.contactDelegate = self;
        
        // Create background
        self.backgroundColor = [SKColor whiteColor];
        
        //Create bricklayer
        _brickLayer = [SKNode node];
        _brickLayer.position = CGPointMake(0, self.size.height-28);
        _brickLayer.name = @"BrickLayer";
        [self addChild:_brickLayer];
        
        // Create HUD bar
        _bar = [SKSpriteNode spriteNodeWithColor:[SKColor grayColor] size:CGSizeMake(self.size.width, 28)];
        _bar.position = CGPointMake(0, self.size.height);
        _bar.anchorPoint = CGPointMake(0, 1);
        [self addChild:_bar];
        
        // Create level label
        _levelLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura"];
        _levelLabel.position = CGPointMake(10, -20);
        _levelLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
        _levelLabel.fontSize = 15;
        [_bar addChild:_levelLabel];
        
        // Create hearts
        _hearts = @[[SKSpriteNode spriteNodeWithImageNamed:@"HeartFull"],
                    [SKSpriteNode spriteNodeWithImageNamed:@"HeartFull"],
                    [SKSpriteNode spriteNodeWithImageNamed:@"HeartFull"]];
        for (int i=0; i < _hearts.count; i++) {
            SKSpriteNode *heart = [_hearts objectAtIndex:i];
            heart.position = CGPointMake(self.size.width - 25 - (i * 28), -15);
            [_bar addChild:heart];
        }
        
        // Create edges
        SKNode *border = [[SKNode alloc] init];
        border.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, self.size.width, self.size.height-28)];
        border.physicsBody.categoryBitMask = kSGEdgeCategory;
        [self addChild:border];
        
        // Create paddle
        _paddle = [SKSpriteNode spriteNodeWithImageNamed:@"Paddle"];
        _paddle.position = CGPointMake(self.size.width * 0.5, 100);
        _paddle.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:CGSizeMake(80, 15)];
        _paddle.physicsBody.categoryBitMask = kSGPaddleCategory;
        _paddle.physicsBody.collisionBitMask = 0;
        _paddle.physicsBody.contactTestBitMask = 0;
        [self addChild:_paddle];
        
        // Create menu
        _menu = [[SGMenu alloc] init];
        _menu.position = CGPointMake(self.size.width/2, self.size.height/2);
        [self addChild:_menu];
        
        // Setup sounds
        _bounceSound = [SKAction playSoundFileNamed:@"BallBounce.caf" waitForCompletion:NO];
        _brickSmashSound = [SKAction playSoundFileNamed:@"BrickSmash.caf" waitForCompletion:NO];
        _paddleSound = [SKAction playSoundFileNamed:@"PaddleBounce.caf" waitForCompletion:NO];
        _loseLifeSound = [SKAction playSoundFileNamed:@"LoseLife.caf" waitForCompletion:NO];
        _levelUpSound = [SKAction playSoundFileNamed:@"LevelUp.caf" waitForCompletion:NO];
        
        // Setup game attirbutes
        _ballSpeed = 350.0;
        self.currentLevel = 0;
        self.lives = 3;
        
        // Load level
        [self loadLevel:self.currentLevel];
        [self newBall];
    }
    return self;
}

// Sets up the paddle to have a ball on it and be positioned in the middle of the screen
-(void)newBall
{
    _ballReleased = NO;
    SKSpriteNode *ball = [SKSpriteNode spriteNodeWithImageNamed:@"BallBlue"];
    ball.position = CGPointMake(0, _paddle.size.height);
    _paddle.position = CGPointMake(self.size.width * 0.5, _paddle.position.y);
    [_paddle addChild:ball];
}

// Creates a new ball heading in a direction at a location
-(SKSpriteNode*)createBallWithLocation:(CGPoint)position andVelocity:(CGVector)velocity
{
    SKSpriteNode *ball = [SKSpriteNode spriteNodeWithImageNamed:@"BallBlue"];
    ball.name = @"ball";
    ball.position = position;//MUST BE BEFORE PHYSICS BODY DECLARATION
    ball.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:ball.size.width * 0.5];
    ball.physicsBody.velocity = velocity;
    ball.physicsBody.restitution = 1.0;
    ball.physicsBody.friction = 0;
    ball.physicsBody.linearDamping = 0;
    ball.physicsBody.categoryBitMask = kSGBallCategory;
    ball.physicsBody.collisionBitMask = kSGPaddleCategory | kSGBrickCategory | kSGEdgeCategory;
    ball.physicsBody.contactTestBitMask = kSGPaddleCategory | kSGBrickCategory | kSGEdgeCategory;
    [self addChild:ball];
    return ball;
}


-(void)setCurrentLevel:(int)currentLevel
{
    _currentLevel = currentLevel;
    _levelLabel.text = [NSString stringWithFormat:@"LEVEL %i",(currentLevel+1)];
    _menu.panelLabel.text = [NSString stringWithFormat:@"LEVEL %i",(currentLevel+1)];
}

-(void)setLives:(int)lives
{
    _lives = lives;
    
    // When you need to update a scene object use texture!
    for (NSUInteger i = 0; i < _hearts.count; i++) {
        SKSpriteNode *heart = (SKSpriteNode *)[_hearts objectAtIndex:i];
        if (lives > i) {
            heart.texture = [SKTexture textureWithImageNamed:@"HeartFull"];
        }
        else {
            heart.texture = [SKTexture textureWithImageNamed:@"HeartEmpty"];
        }
    }
    
}

-(void)loadLevel:(int)levelNumber
{
    [_brickLayer removeAllChildren];
    [_menu show];
    
    NSArray *level;
    switch (levelNumber) {
        case 0:
            level = @[@[@1,@1,@1,@1,@1,@1],
                      @[@0,@1,@1,@1,@1,@0],
                      @[@0,@0,@0,@0,@0,@0],
                      @[@0,@0,@0,@0,@0,@0],
                      @[@0,@2,@2,@2,@2,@0]];
            break;
        case 1:
            level = @[@[@1,@0,@1,@1,@0,@1],
                      @[@1,@1,@1,@1,@1,@1],
                      @[@1,@0,@1,@1,@0,@1],
                      @[@1,@0,@1,@1,@0,@1],
                      @[@0,@2,@4,@4,@2,@0]];
            break;
        case 2:
            level = @[@[@1,@1,@1,@1,@1,@1],
                      @[@1,@0,@0,@0,@0,@1],
                      @[@1,@4,@0,@0,@4,@1],
                      @[@1,@0,@0,@0,@0,@1],
                      @[@0,@0,@3,@3,@0,@0]];
            break;
        case 3:
            level = @[@[@0,@1,@0,@0,@1,@0],
                      @[@1,@0,@1,@1,@0,@1],
                      @[@0,@1,@0,@0,@1,@0],
                      @[@0,@0,@0,@0,@0,@0],
                      @[@2,@0,@3,@3,@0,@2]];
            break;
        case 4:
            level = @[@[@1,@1,@1,@1,@1,@1],
                      @[@2,@0,@1,@1,@0,@2],
                      @[@2,@0,@0,@0,@0,@2],
                      @[@2,@0,@0,@0,@0,@2],
                      @[@2,@0,@4,@4,@0,@2],
                      @[@2,@0,@4,@4,@0,@2],
                      @[@2,@0,@4,@4,@0,@2]];
            break;
        default:
            break;
    }
    
    int row = 0;
    int col = 0;
    for (NSArray *levelRow in level) {
        col = 0;
        for (NSNumber *brickNumber in levelRow) {
            
            if ([brickNumber intValue] > 0) {
                SGBrick *brick = [[SGBrick alloc] initWithType:(BrickType)[brickNumber intValue]];
                brick.position = CGPointMake(2 + (brick.size.width * 0.5) + ((brick.size.width + 3) * col),
                                             -2 + (-brick.size.height * 0.5) + (-(brick.size.height + 3) * row));
                [_brickLayer addChild:brick];
            }
            col++;
        }
        row++;
    }
}

-(void)addExplosion:(CGPoint)position withName:(NSString *)name
{
    NSString *explosionPath =  [[NSBundle mainBundle] pathForResource:name ofType:@"sks"];
    SKEmitterNode *explosion = [NSKeyedUnarchiver unarchiveObjectWithFile:explosionPath];
    
    explosion.position = position;
    [_brickLayer addChild:explosion];
    
    SKAction *removeExplosion = [SKAction sequence:@[[SKAction waitForDuration:1.5],
                                                     [SKAction removeFromParent]]];
    [explosion runAction:removeExplosion];
}

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    SKPhysicsBody *firstBody;
    SKPhysicsBody *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask) {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if (firstBody.categoryBitMask == kSGBallCategory && secondBody.categoryBitMask == kSGPaddleCategory) {
        // Ball hits paddle
        
        // Make sure ball is hitting the top side of the paddle
        CGPoint contactPoint = [_paddle convertPoint:contact.contactPoint fromNode:self];
        
        if (contactPoint.y > 0) {
            // Map -40 to 40 onto 3/4pi to 1/4pi using y = mx + b
            if ([firstBody.node isKindOfClass:[SKSpriteNode class]]) {
                [self runAction:_paddleSound];
                ((SKSpriteNode*)firstBody.node).physicsBody.velocity = CGVectorMake(cosf(-M_PI/160 * contactPoint.x + M_PI_2) * _ballSpeed,
                                              sinf(-M_PI/160 * contactPoint.x + M_PI_2) * _ballSpeed);
            }
        }
    }
    
    if (firstBody.categoryBitMask == kSGBallCategory && secondBody.categoryBitMask == kSGBrickCategory) {
        // Ball hits brick
        if ([secondBody.node respondsToSelector:@selector(hit)]) {
            
            
            // If brick is green, explode!
            if (((SGBrick*)secondBody.node).type == (BrickType) Green) {
                [self runAction:_brickSmashSound];
                [self addExplosion:secondBody.node.position withName:@"BrickExplosion"];
            }
            
            // If brick is yellow, spawn ball!
            if (((SGBrick*)secondBody.node).type == (BrickType) Yellow) {
                [self runAction:_brickSmashSound];
                [self addExplosion:secondBody.node.position withName:@"BrickExplosion"];
                
                //CGPoint position = CGPointMake(secondBody.node.position.x, secondBody.node.position.y + 540);
                CGPoint position = [self convertPoint:secondBody.node.position fromNode:_brickLayer];
                [self spawnExtraBall:position];
            }
            [secondBody.node performSelector:@selector(hit)];
            
        }
    }
    
    if (firstBody.categoryBitMask == kSGBallCategory && secondBody.categoryBitMask == kSGEdgeCategory){
        [self runAction:_bounceSound];
    }
    
}

-(void)spawnExtraBall:(CGPoint)position
{
    CGVector direction;
    if (arc4random_uniform(2) == 0) {
        direction = CGVectorMake(cosf(M_PI_4), sinf(M_PI_4));
    } else {
        direction = CGVectorMake(cosf(M_PI * 0.75), sinf(M_PI * 0.75));
    }
    [self createBallWithLocation:position andVelocity:CGVectorMake(direction.dx * _ballSpeed, direction.dy * _ballSpeed)];
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        _startPosition = [touch locationInNode:self];
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        
        if (!_menu.touchable) {
            
            CGPoint endPosition = [touch locationInNode:self];
            CGPoint newPaddlePosition = CGPointMake(_paddle.position.x - (_startPosition.x - endPosition.x), _paddle.position.y);
        
            // Limit paddle range
            int paddleRange = 15;
            if (!_ballReleased){
                // make sure paddle can't go off screen while ball is on paddle
                paddleRange = -_paddle.size.width/2;
            }
                
            if (newPaddlePosition.x >= self.size.width + paddleRange) {
                newPaddlePosition.x = self.size.width + paddleRange;
            }
            else if (newPaddlePosition.x <= -paddleRange)
            {
                newPaddlePosition.x = -paddleRange;
            }
        
            _paddle.position = newPaddlePosition;
            _startPosition = endPosition;
        }
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        if (_menu.touchable) {
            SKNode *n = [_menu nodeAtPoint:[touch locationInNode:_menu]];
            if ([n.name isEqualToString:@"Play"]) {
                [_menu hide];
            }
        }
        else if (!_ballReleased && !_menu.touchable) {
            _ballReleased = YES;
            [_paddle removeAllChildren];
            [self createBallWithLocation:CGPointMake(_paddle.position.x, _paddle.position.y + _paddle.size.height) andVelocity:CGVectorMake(0.0, _ballSpeed)];
        }
        
    }
    
}

-(BOOL)isLevelComplete
{
    // Look for remaining bricks that are not indestructable
    for (SKNode *node in _brickLayer.children) {
        if ([node isKindOfClass:[SGBrick class]]) {
            if(!((SGBrick*)node).indestructable)
            {
                return NO;
            }
            
        }
    }
    // Couldn't find any non-indestructable nodes
    return YES;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    if ([self isLevelComplete]) {
        
        // Level is finished!
        [self runAction:_levelUpSound];
        [self enumerateChildNodesWithName:@"ball" usingBlock:^(SKNode *node, BOOL *stop) {
            [node removeFromParent];
        }];
        
        self.currentLevel++;
        
        // If current level is the highest level, return to level 1
        if (self.currentLevel > MAX_LEVEL) {
            self.currentLevel = 0;
            self.lives = 3;
        }
        
        [self loadLevel:self.currentLevel];
        [self newBall];
        
        
    }else if (![self childNodeWithName:@"ball"] && _ballReleased) {
        // Lost all balls
        [self runAction:_loseLifeSound];
        self.lives--;
        if (self.lives == 0) {
            self.currentLevel = 0;
            self.lives = 3;
            [self loadLevel:self.currentLevel];
        }
        [self newBall];
    }
}


-(void)didSimulatePhysics
{
    [self enumerateChildNodesWithName:@"ball" usingBlock:^(SKNode *node, BOOL *stop) {
        if (node.position.y < node.frame.size.height) {
            // Lost ball
            [node removeFromParent];
        }
    }];
    
}

@end
