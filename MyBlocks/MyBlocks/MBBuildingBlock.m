//
//  MBBuildingBlock.m
//  MyBlocks
//
//  Created by Vadim Zhepetov on 08/09/14.
//  Copyright (c) 2014 Vadim Zhepetov. All rights reserved.
//

#import "MBBuildingBlock.h"

@implementation MBBuildingBlock

#pragma mark - Initialization

+ (UIColor *)standardColor
{
    CGFloat red = arc4random_uniform(255) / 255.0;
    CGFloat green = arc4random_uniform(255) / 255.0;
    CGFloat blue = arc4random_uniform(255) / 255.0;
    if (red + green + blue < 0.15f)
        return [UIColor blueColor];

    return [UIColor colorWithRed:red green:green blue:blue alpha:1.0];
}

@end
