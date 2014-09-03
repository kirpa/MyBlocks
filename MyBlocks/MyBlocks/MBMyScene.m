//
//  MBMyScene.m
//  MyBlocks
//
//  Created by Vadim Zhepetov on 12/08/14.
//  Copyright (c) 2014 Vadim Zhepetov. All rights reserved.
//

#import "MBMyScene.h"

typedef NS_ENUM(NSUInteger, kGameState)
{
    GSPlaying,
    GSLose
};

@interface MBMyScene()

@property (nonatomic) SKNode *viewPort;
@property (nonatomic) SKSpriteNode *previousBlock;
@property (nonatomic) SKSpriteNode *currentBlock;
@property (nonatomic) int stoppedBlocks;
@property (nonatomic) kGameState gameState;
@property (nonatomic) int currentLevel;

@end

static const NSTimeInterval kDefaultBlockMovementDuration = 2.0;
static const NSTimeInterval kViewportScaleDuration = 1.0;
static const CGFloat kBlockWidth = 54.;
static const CGFloat kScaleStep = 0.8;
static const CGFloat kUpscaleThreshhold = 0.6;

@implementation MBMyScene

- (void)animateBlock:(SKSpriteNode *)block
{
    NSTimeInterval duration = kDefaultBlockMovementDuration;
    CGFloat nextX = block.position.x < self.size.width / 2 ?
        self.size.width - block.size.width / 2 :
        block.size.width / 2;

    SKAction *moveAction = [SKAction moveTo:CGPointMake(nextX, block.position.y) duration:duration];
    __weak SKSpriteNode *weakBlock = block;
    [block runAction:moveAction completion:^(){
        [self animateBlock:weakBlock];
    }];
}

- (UIColor *)randomColor
{
    CGFloat red = arc4random_uniform(255) / 255.0;
    CGFloat green = arc4random_uniform(255) / 255.0;
    CGFloat blue = arc4random_uniform(255) / 255.0;
    if (red + green + blue < 0.15f)
        return [UIColor blueColor];

    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

- (void)addBlock
{
    SKSpriteNode *result = [[SKSpriteNode alloc] initWithColor:[self randomColor]
                                                          size:CGSizeMake(kBlockWidth, kBlockWidth)];
    CGFloat nextLine;
    if (self.currentBlock){
        nextLine = self.currentBlock.position.y + result.size.height;
    } else {
        nextLine = result.size.height / 2;
    }
    result.position = CGPointMake(result.size.width / 2, nextLine);
    [self animateBlock:result];
    [self.viewPort addChild:result];
    self.previousBlock = self.currentBlock;
    self.currentBlock = result;
    [self checkScale];
}

- (void)lowerBlock
{
    [self.currentBlock removeAllActions];
    self.currentBlock.position = CGPointMake(self.currentBlock.position.x, self.currentBlock.position.y - kBlockWidth);
    [self animateBlock:self.currentBlock];
    [self checkScale];
}

- (void)resetGame
{
    [self.viewPort removeFromParent];
    self.viewPort = [SKNode node];
    [self addChild:self.viewPort];

    self.gameState = GSPlaying;
    self.currentBlock = nil;
    self.previousBlock = nil;
    self.stoppedBlocks = 0;
    self.currentLevel = 0;
    [self addBlock];
}

- (void)addLabelWithText:(NSString *)text
{
    SKLabelNode *textNode = [SKLabelNode labelNodeWithFontNamed:@"Chalkduster"];
    textNode.text = text;
    textNode.fontSize = 42;
    textNode.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
    [self addChild:textNode];
}

- (CGFloat)visiblePortionHeight
{
    return self.size.height / self.viewPort.yScale;
}

- (void)checkScale
{
    CGFloat visibleBlockTop = CGRectGetMaxY(self.currentBlock.frame);
    CGFloat visiblePortion = [self visiblePortionHeight];
    if (visibleBlockTop > visiblePortion) {
        CGFloat nextScale = self.viewPort.yScale * kScaleStep;
        [self.viewPort runAction:[SKAction scaleTo:nextScale duration:kViewportScaleDuration]];
    } else if (visiblePortion * kUpscaleThreshhold > visibleBlockTop) {
        CGFloat nextScale = MIN(self.viewPort.yScale / kScaleStep, 1.0);
        [self.viewPort runAction:[SKAction scaleTo:nextScale duration:kViewportScaleDuration]];
    }
}

- (void)showLose
{
    [self addLabelWithText:@"You lose!"];
}

- (kGameState)checkGameState
{
    CGFloat difference = self.currentBlock.position.x - self.previousBlock.position.x;
    if (abs(difference) > self.currentBlock.size.width / 2) {
        if (self.stoppedBlocks > 1)
            return GSLose;
    }

    return GSPlaying;
}

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor blackColor];
        [self resetGame];
    }
    return self;
}

- (void)didMoveToView:(SKView *)view
{
    UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapRecognized)];
    tapRecognizer.numberOfTapsRequired = 1;
    [self.view addGestureRecognizer:tapRecognizer];

    UISwipeGestureRecognizer *swipeRecognizer = [[UISwipeGestureRecognizer alloc]
                                                 initWithTarget:self action:@selector(swipeRecognized)];
    swipeRecognizer.direction = UISwipeGestureRecognizerDirectionRight | UISwipeGestureRecognizerDirectionLeft | UISwipeGestureRecognizerDirectionUp | UISwipeGestureRecognizerDirectionDown;
    [self.view addGestureRecognizer:swipeRecognizer];
}

- (void)stopCurrentBlock
{
    self.stoppedBlocks++;
    [self.currentBlock removeAllActions];
    self.gameState = [self checkGameState];
    if (self.gameState == GSLose) {
        [self showLose];
        return;
    }

    [self addBlock];
}

- (void)tapRecognized
{
    if (self.gameState == GSPlaying)
        [self stopCurrentBlock];
    else
        [self resetGame];
}

- (void)swipeRecognized
{
    [self lowerBlock];
}

@end
