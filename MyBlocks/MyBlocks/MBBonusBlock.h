//
//  MBBonusBlock.h
//  MyBlocks
//
//  Created by Vadim Zhepetov on 05/09/14.
//  Copyright (c) 2014 Vadim Zhepetov. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(NSUInteger, BonusType)
{
    BTRemoveBlocks3,
    BTRemoveBlocks5,
    BTAddBlocks3,
    BTAddBlocks5,
    BTTotalBonusCount
};

@interface MBBonusBlock : SKSpriteNode

@property (nonatomic) BonusType bonusType;

+ (instancetype)bonusWithType:(BonusType)type;

- (void)consume;

@end
