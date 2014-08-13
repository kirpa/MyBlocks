//
//  MBMyScene.m
//  MyBlocks
//
//  Created by Vadim Zhepetov on 12/08/14.
//  Copyright (c) 2014 Vadim Zhepetov. All rights reserved.
//

#import "MBMyScene.h"

@interface MBMyScene()

@property (nonatomic) SKSpriteNode *currentBlock;

@end

@implementation MBMyScene

- (void)animateBlock:(SKSpriteNode *)block
{
    CGFloat nextX = block.position.x < self.size.width / 2 ?
        self.size.width - block.size.width / 2 :
        block.size.width / 2;

    SKAction *moveAction = [SKAction moveTo:CGPointMake(nextX, block.position.y) duration:3];
    __weak SKSpriteNode *weakBlock = block;
    [block runAction:moveAction completion:^(){
        [self animateBlock:weakBlock];
    }];
}

- (void)addBlock
{
    SKSpriteNode *result = [[SKSpriteNode alloc] initWithColor:[UIColor blueColor]
                                                          size:CGSizeMake(self.size.height / 6, self.size.height / 6)];
    CGFloat previousLine = self.currentBlock.position.y;
    result.position = CGPointMake(result.size.width / 2, previousLine + result.size.height);
    [self animateBlock:result];
    [self addChild:result];
    self.currentBlock = result;
}

- (void)resetGame
{
    [self addBlock];
}

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        self.backgroundColor = [SKColor blackColor];
        [self resetGame];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    

}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
