//
//  NetDataManager.m
//  MHKan
//
//  Created by Yinjw on 2017/11/30.
//  Copyright © 2017年 yinjianwei. All rights reserved.
//

#import "NetDataQueue.h"

@interface NetDataQueue()

@property(atomic, strong)NSMutableArray<NetData*>*     dataQueue;
@property(atomic, strong)NSMutableArray<NetData*>*     sendQueue;

@end

@implementation NetDataQueue

-(instancetype)init
{
    self = [super init];
    if(self)
    {
        self.dataQueue = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void)addNewNetDataWithParams:(id)params
{
    [self removeSendedData];
    
    NetData* newData = [[NetData alloc] init];
    newData.sendDatas = params;
    
    //check data.dataIndex is repeat
    for(NetData* data in self.dataQueue)
    {
        if(data.dataIndex == newData.dataIndex)
        {
            return;
        }
    }
    
    [self.dataQueue addObject:newData];
}

-(NetData*)getSendData
{
    return [self.dataQueue objectAtIndex:0];
}

-(void)removeSendedData
{
    for(NetData* data in self.dataQueue)
    {
        if(data.isSend)
        {
            [self.dataQueue removeObject:data];
        }
    }
}

@end
