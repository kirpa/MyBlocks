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

- (SKPhysicsBody *)setupPhysicsBody:(SKPhysicsBody *)body
{
    body.affectedByGravity = NO;
    return body;
}

- (SKPhysicsBody *)createPhysicsBody
{
    return [SKPhysicsBody bodyWithRectangleOfSize:self.size];
}

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
    result.physicsBody = [result setupPhysicsBody:[result createPhysicsBody]];
    return result;
}

@end
