//
//  Utils.m
//  MHKan
//
//  Created by Yinjw on 2017/12/11.
//  Copyright © 2017年 yinjianwei. All rights reserved.
//

#import "Utils.h"

static NSUInteger increaseIndex = 0;

@implementation Utils

+(NSUInteger)getIncreaseIndex
{
    return increaseIndex++;
}

+(void)resetIncreaseIndex
{
    increaseIndex = 0;
}

@end
