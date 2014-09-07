//
//  MBAbstractBlock.h
//  MyBlocks
//
//  Created by Vadim Zhepetov on 07/09/14.
//  Copyright (c) 2014 Vadim Zhepetov. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface MBAbstractBlock : SKSpriteNode

+ (instancetype)standardBlock;

+ (UIColor *)standardColor;
+ (CGSize)standardSize;
- (SKPhysicsBody *)setupPhysicsBody:(SKPhysicsBody *)body;
- (SKPhysicsBody *)createPhysicsBody;

@end
