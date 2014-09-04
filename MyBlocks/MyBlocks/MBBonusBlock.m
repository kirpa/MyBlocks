//
//  MBBonusBlock.m
//  MyBlocks
//
//  Created by Vadim Zhepetov on 05/09/14.
//  Copyright (c) 2014 Vadim Zhepetov. All rights reserved.
//

#import "MBBonusBlock.h"

@implementation MBBonusBlock

+ (UIColor *)colorForType:(BonusType)type
{
    return [UIColor redColor];
}

+ (instancetype)bonusWithType:(BonusType)type
{
    MBBonusBlock *result = [[self alloc] initWithColor:[self colorForType:type]
                                                          size:CGSizeMake(kBlockWidth, kBlockWidth)];


    return result;
}

@end
