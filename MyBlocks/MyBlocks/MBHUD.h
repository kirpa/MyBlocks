//
//  MBHUD.h
//  MyBlocks
//
//  Created by Vadim Zhepetov on 07/09/14.
//  Copyright (c) 2014 Vadim Zhepetov. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface MBHUD : SKSpriteNode

- (void)setup;
- (void)showLose;
- (void)reset;
- (void)updateScore:(int)score;

@end
