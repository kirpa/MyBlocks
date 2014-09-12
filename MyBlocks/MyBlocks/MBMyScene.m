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
    GSLose,
    GSConsumingBonus
};

@interface MBMyScene()

@property (nonatomic) SKNode *viewPort;
@property (nonatomic) MBBuildingBlock *previousBlock;
@property (nonatomic) MBBuildingBlock *currentBlock;
@property (nonatomic) int stoppedBlocks;
@property (nonatomic) kGameState gameState;
@property (nonatomic) int currentLevel;
@property (nonatomic) NSMutableArray *bonuses;
@property (nonatomic) NSMutableArray *blocks;
@property (nonatomic) CGFloat viewPortScale;
@property (nonatomic) MBHUD *hud;

@end

static const NSTimeInterval kDefaultBlockMovementDuration = 2.0;
static const NSTimeInterval kViewportScaleDuration = 1.0;
static const CGFloat kScaleStep = 0.8;
static const CGFloat kUpscaleThreshhold = 0.7;
static const CGFloat kBlockAutomovingDuration = 0.3;
static const CGFloat kTowerDropDuration = 0.3;
static const CGFloat kSerialActionDelay = 0.1;

static const CGFloat kBlockZ = 10.;
static const CGFloat kHUDZ = 30.;

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

#pragma mark - Bonus system

- (BOOL)checkForBonuses
{
    MBBonusBlock *collectedBonus = [self collectedBonusForBlock:self.currentBlock];
    if (collectedBonus){
        [self consumeBonus:collectedBonus];
        return YES;
    }

    return NO;
}

- (MBBonusBlock *)collectedBonusForBlock:(MBBuildingBlock *)block
{
    for (MBBonusBlock *bonus in self.bonuses){
        if ([bonus intersectsNode:block])
            return bonus;
    }

    return nil;
}

- (void)consumeBonus:(MBBonusBlock *)bonus
{
    self.gameState = GSConsumingBonus;
    [bonus consume];
    [self.bonuses removeObject:bonus];
    __weak __typeof(self) weakSelf = self;
    void (^restoreGame)() = ^void(){
        weakSelf.gameState = GSPlaying;
        [self addBlock];
    };
    [self removeMultipleBlocks:3 completion:^(){
        [weakSelf dropDownTheTowerCompletion:^{
            restoreGame();
        }];
    }];
}

- (void)removeMultipleBlocks:(int)count completion:(void(^)(void))completion
{
    if (count > 0) {
        [self removeBlockAnimated:YES completion:nil];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kSerialActionDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self removeMultipleBlocks:count - 1 completion:completion];
        });
    } else {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kSerialActionDelay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            if (completion)
                completion();
        });
    }
}

#pragma mark - Block modification

- (void)dropDownTheTowerCompletion:(void(^)(void))completion
{
    MBBuildingBlock *firstBlock = [self.blocks firstObject];
    CGFloat gap = CGRectGetMinY(firstBlock.frame);
    if (gap > 0) {
        SKAction *dropDown = [SKAction moveByX:0 y:-gap duration:kTowerDropDuration];
        [self.blocks makeObjectsPerformSelector:@selector(runAction:) withObject:dropDown];
        [firstBlock runAction:[SKAction waitForDuration:kTowerDropDuration] completion:completion];
    }
}

- (void)removeBlockAnimated:(BOOL)animated completion:(void(^)(void))completion
{
    if (self.blocks.count > 1) {
        MBBuildingBlock *block = [self.blocks firstObject];
        [self.blocks removeObject:block];
        SKAction *moveAction = [SKAction moveToX:-kBlockWidth duration:animated ? kBlockAutomovingDuration : 0.0f];
        [block runAction:moveAction completion:completion];
    } else {
        if (completion)
            completion();
    }
}

#pragma mark - Gameplay

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
    [self.blocks removeAllObjects];
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
        NSLog(@"Downscellado!");
        CGFloat nextScale = MIN(self.viewPort.yScale / kScaleStep, 1.0);
        [self scaleViewportTo:nextScale];
        self.currentLevel--;
    }

    NSLog(@"VIs: %.0f -> %.0f", visiblePortion * kUpscaleThreshhold, visibleBlockTop);
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

    if (![self checkForBonuses])
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
    BonusType type = arc4random_uniform(BTTotalBonusCount);
    MBBonusBlock *result = [MBBonusBlock bonusWithType:type];
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

    SKAction *moveAction = [SKAction moveToX:nextX duration:duration];
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
    result.zPosition = kBlockZ;
    [self animateBlock:result];
    [self.viewPort addChild:result];
    self.previousBlock = self.currentBlock;
    self.currentBlock = result;
    [self.blocks addObject:result];
    [self checkScale];
}

#pragma mark - User controls

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.gameState == GSPlaying)
        [self stopCurrentBlock];
    else if (self.gameState == GSLose)
        [self resetGame];
}

#pragma mark - Object lifecycle

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor blackColor];
        self.viewPort = [SKNode node];
        [self addChild:self.viewPort];
        self.bonuses = [NSMutableArray array];
        self.blocks = [NSMutableArray array];
        self.hud = [[MBHUD alloc] init];
        self.hud.zPosition = kHUDZ;
        [self addChild:self.hud];
        [self.hud setup];
        [self resetGame];
    }

    return self;
}

@end
