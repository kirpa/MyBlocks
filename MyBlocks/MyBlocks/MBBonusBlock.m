//
//  MBBonusBlock.m
//  MyBlocks
//
//  Created by Vadim Zhepetov on 05/09/14.
//  Copyright (c) 2014 Vadim Zhepetov. All rights reserved.
//

#import "MBBonusBlock.h"

@implementation MBBonusBlock


#pragma mark - Other methods

- (void)consume
{
    SKAction *shrink = [SKAction scaleBy:0.9 duration:0.2];
    SKAction *enlarge = [SKAction scaleBy:1.3 duration:0.1];
    [self runAction:[SKAction sequence:@[shrink, enlarge]] completion:^(){
        [self removeFromParent];
    }];
}

#pragma mark - Initialization

+ (NSString *)imageNameForType:(BonusType)type
{
    switch (type) {
        case BTRemoveBlocks3:
            return @"Blue-Candy.png";
        case BTRemoveBlocks5:
            return @"Green-Candy.png";
        case BTAddBlocks3:
            return @"Pink-Candy.png";
        case BTAddBlocks5:
            return @"Yellow-Candy.png";
        case BTTotalBonusCount:
            NSAssert(YES, @"Wrong bonus type specified!");
            return nil;
    }
}

+ (instancetype)bonusWithType:(BonusType)type
{
    MBBonusBlock *result = [[self alloc] initWithImageNamed:[self imageNameForType:type]];
    result.bonusType = type;
    return result;
}

@end
