//
//  MBMyScene.m
//  MyBlocks
//
//  Created by Vadim Zhepetov on 12/08/14.
//  Copyright (c) 2014 Vadim Zhepetov. All rights reserved.
//

#import "MBMyScene.h"
#import "MBBonusBlock.h"
#import "MBBuildingBlock.h"
#import "MBHUD.h"

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
@property (nonatomic) NSMutableArray *bonuses;
@property (nonatomic) CGFloat viewPortScale;
@property (nonatomic) MBHUD *hud;

@end

static const NSTimeInterval kDefaultBlockMovementDuration = 2.0;
static const NSTimeInterval kViewportScaleDuration = 1.0;
static const CGFloat kScaleStep = 0.8;
static const CGFloat kUpscaleThreshhold = 0.6;

@implementation MBMyScene

#pragma mark - Utility

- (int)availableLines
{
    CGFloat currentBlockTop = CGRectGetMaxY(self.currentBlock.frame);
    CGFloat visiblePortion = [self visiblePortionHeight];
    return ceil((visiblePortion - currentBlockTop) / kBlockWidth) - 1;
}

- (CGFloat)visiblePortionHeight
{
    return self.size.height / self.viewPortScale;
}

#pragma mark - Object lifecycle

-(id)initWithSize:(CGSize)size {
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor blackColor];
        self.viewPort = [SKNode node];
        [self addChild:self.viewPort];
        self.bonuses = [NSMutableArray array];
        self.hud = [[MBHUD alloc] init];
        [self addChild:self.hud];
        [self.hud setup];
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


#pragma mark - Gameplay

- (void)lowerBlock
{
    [self.currentBlock removeAllActions];
    self.currentBlock.position = CGPointMake(self.currentBlock.position.x, self.currentBlock.position.y - kBlockWidth);
    [self animateBlock:self.currentBlock];
    [self checkScale];
}

- (void)resetGame
{
    [self.viewPort removeAllChildren];

    self.viewPortScale = 1.0;
    self.viewPort.xScale = self.viewPort.yScale = self.viewPortScale;
    self.gameState = GSPlaying;
    self.currentBlock = nil;
    self.previousBlock = nil;
    self.stoppedBlocks = 0;
    self.currentLevel = 1;
    [self.hud reset];
    [self.bonuses removeAllObjects];
    [self addBlock];
    [self spawnBonus];
}

- (void)checkScale
{
    CGFloat visibleBlockTop = CGRectGetMaxY(self.currentBlock.frame);
    CGFloat visiblePortion = [self visiblePortionHeight];
    if (visibleBlockTop > visiblePortion) {
        CGFloat nextScale = self.viewPort.yScale * kScaleStep;
        [self scaleViewportTo:nextScale];
        self.currentLevel++;
        [self spawnBonus];
    } else if (self.currentLevel > 1 && visiblePortion * kUpscaleThreshhold > visibleBlockTop) {
        CGFloat nextScale = MIN(self.viewPort.yScale / kScaleStep, 1.0);
        [self scaleViewportTo:nextScale];
        self.currentLevel--;
    }
}

- (void)showLose
{
    [self.hud showLose];
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

- (void)stopCurrentBlock
{
    self.stoppedBlocks++;
    [self.currentBlock removeAllActions];
    self.gameState = [self checkGameState];
    if (self.gameState == GSLose) {
        [self showLose];
        return;
    }
    [self.hud updateScore:self.stoppedBlocks];
    [self addBlock];
}

#pragma mark - Spawning and animations

- (void)scaleViewportTo:(CGFloat)scale
{
    [self.viewPort runAction:[SKAction scaleTo:scale duration:kViewportScaleDuration]];
    self.viewPortScale = scale;
}

- (MBBonusBlock *)spawnBonusWithAvailableLines:(int)lines
{
    MBBonusBlock *result = [MBBonusBlock bonusWithType:BTRemoveBlocks3];
    int destinationLine = arc4random_uniform(lines) + 1;
    CGFloat destinationY = self.currentBlock.position.y + kBlockWidth * destinationLine;
    result.position = [self randomPositionForY:destinationY];

    return result;
}

- (void)spawnBonus
{
    BOOL shouldSpawnBonus = (arc4random_uniform(100) + 1) >= 50;
    if (shouldSpawnBonus){
        MBBonusBlock *bonus = [self spawnBonusWithAvailableLines:[self availableLines]];
        [self.viewPort addChild:bonus];
        [self.bonuses addObject:bonus];
    }
}

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

- (CGPoint)randomPositionForY:(CGFloat)y
{
    return CGPointMake(arc4random_uniform(self.size.width), y);
}

- (void)addBlock
{
    MBBuildingBlock *result = [MBBuildingBlock standardBlock];
    CGFloat nextLine;
    if (self.currentBlock){
        nextLine = self.currentBlock.position.y + result.size.height;
    } else {
        nextLine = result.size.height / 2;
    }
    result.position = [self randomPositionForY:nextLine];
    [self animateBlock:result];
    [self.viewPort addChild:result];
    self.previousBlock = self.currentBlock;
    self.currentBlock = result;
    [self checkScale];
}

#pragma mark - User controls

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
