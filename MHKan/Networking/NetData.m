//
//  NetData.m
//  MHKan
//
//  Created by Yinjw on 2017/11/30.
//  Copyright © 2017年 yinjianwei. All rights reserved.
//

#import "NetData.h"

@implementation NetData

+(NSUInteger)increaseIndex
{
    static NSUInteger index = 0;
    index++;
    if(index >= NSUIntegerMax)
    {
        index = 0;
    }
    return index;
}

-(instancetype)init
{
    self = [super init];
    if(self)
    {
        _dataIndex = [NetData increaseIndex];
        self.isSend = NO;
    }
    return self;
}

@end
