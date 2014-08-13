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
    GSWin,
    GSLose
};

@interface MBMyScene()

@property (nonatomic) SKSpriteNode *previousBlock;
@property (nonatomic) SKSpriteNode *currentBlock;
@property (nonatomic) int stoppedBlocks;
@property (nonatomic) kGameState gameState;

@end

static const int kTotalBlocks = 6;
static const NSTimeInterval kDefaultAnimationDuration = 3.0;

@implementation MBMyScene

- (void)animateBlock:(SKSpriteNode *)block
{
    NSTimeInterval duration = kDefaultAnimationDuration / (self.stoppedBlocks + 1);
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
                                                          size:CGSizeMake(self.size.height / kTotalBlocks, self.size.height / kTotalBlocks)];
    CGFloat nextLine;
    if (self.currentBlock){
        nextLine = self.currentBlock.position.y + result.size.height;
    } else {
        nextLine = result.size.height / 2;
    }
    result.position = CGPointMake(result.size.width / 2, nextLine);
    [self animateBlock:result];
    [self addChild:result];
    self.previousBlock = self.currentBlock;
    self.currentBlock = result;
}

- (void)resetGame
{
    [self removeAllChildren];
    self.gameState = GSPlaying;
    self.currentBlock = nil;
    self.previousBlock = nil;
    self.stoppedBlocks = 0;
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

- (void)showLose
{
    [self addLabelWithText:@"You lose!"];
}

- (void)showWin
{
    [self addLabelWithText:@"You won!"];
}

- (kGameState)checkGameState
{
    CGFloat difference = self.currentBlock.position.x - self.previousBlock.position.x;
    if (abs(difference) > self.currentBlock.size.width / 2) {
        if (self.stoppedBlocks > 1)
            return GSLose;
    } else if (self.stoppedBlocks == kTotalBlocks) {
        return GSWin;
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

- (void)stopCurrentBlock
{
    self.stoppedBlocks++;
    [self.currentBlock removeAllActions];
    self.gameState = [self checkGameState];
    if (self.gameState == GSLose) {
        [self showLose];
        return;
    } else if (self.gameState == GSWin) {
        [self showWin];
        return;
    }
    [self addBlock];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.gameState == GSPlaying)
        [self stopCurrentBlock];
    else
        [self resetGame];
}

@end
