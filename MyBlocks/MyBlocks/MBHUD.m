//
//  MBHUD.m
//  MyBlocks
//
//  Created by Vadim Zhepetov on 07/09/14.
//  Copyright (c) 2014 Vadim Zhepetov. All rights reserved.
//

#import "MBHUD.h"

@interface MBHUD()

@property (nonatomic) SKLabelNode *centralLabel;
@property (nonatomic) SKLabelNode *scoreLabel;

@end

static const CGFloat kScoreOffsetY = 40.;
static const CGFloat kScoreOffsetX = 50.;

@implementation MBHUD

- (void)showLose
{
    if (!self.centralLabel){
        self.centralLabel = [SKLabelNode labelNodeWithFontNamed:@"DIN Condensed"];
        self.centralLabel.fontSize = 42;
        [self addChild:self.centralLabel];
    }

    self.centralLabel.text = @"You lose";
}

- (void)reset
{
    [self.centralLabel removeFromParent];

    self.centralLabel = nil;
    [self updateScore:0];
}

- (void)updateScore:(int)score
{
    self.scoreLabel.text = [NSString stringWithFormat:@"Score: %d", score];
}

- (void)setup
{
    //TODO: Make it automatic, if SKNode didMoveToParent will be implemented

    CGSize parentSize = self.parent.frame.size;

    self.position =  CGPointMake(parentSize.width / 2, parentSize.height / 2);
    self.size = parentSize;

    self.scoreLabel = [SKLabelNode labelNodeWithFontNamed:@"Optima-Regular"];
    self.scoreLabel.fontSize = 16;
    self.scoreLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
    self.scoreLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
    self.scoreLabel.position = CGPointMake(parentSize.width / 2 - kScoreOffsetX, parentSize.height / 2 - kScoreOffsetY);
    [self addChild:self.scoreLabel];
}

@end
