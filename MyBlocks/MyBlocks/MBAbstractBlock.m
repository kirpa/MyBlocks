//
//  MBAbstractBlock.m
//  MyBlocks
//
//  Created by Vadim Zhepetov on 07/09/14.
//  Copyright (c) 2014 Vadim Zhepetov. All rights reserved.
//

#import "MBAbstractBlock.h"

@implementation MBAbstractBlock


#pragma mark - Init

+ (UIColor *)standardColor
{
    NSAssert (YES, @"Abstract method call");
    return nil;
}

+ (CGSize)standardSize
{
    static CGSize size = {kBlockWidth, kBlockWidth};
    return size;
}

+ (instancetype)standardBlock
{
    MBAbstractBlock *result = [[self alloc] initWithColor:[self standardColor] size:[self standardSize]];
    return result;
}

@end
