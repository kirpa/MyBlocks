//
//  MBBonusBlock.m
//  MyBlocks
//
//  Created by Vadim Zhepetov on 05/09/14.
//  Copyright (c) 2014 Vadim Zhepetov. All rights reserved.
//

#import "MBBonusBlock.h"

@implementation MBBonusBlock

#pragma mark - Initialization

+ (UIColor *)standardColor
{
    return [UIColor redColor];
}

- (SKPhysicsBody *)createPhysicsBody
{
    return nil;
}

+ (instancetype)bonusWithType:(BonusType)type
{
    MBBonusBlock *result = [self standardBlock];
    result.bonusType = type;
    return result;
}

@end
