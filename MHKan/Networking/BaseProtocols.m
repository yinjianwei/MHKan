//
//  BaseProtocols.m
//  MHKan
//
//  Created by Yinjw on 2017/11/30.
//  Copyright © 2017年 yinjianwei. All rights reserved.
//

#import "BaseProtocols.h"

@implementation BaseProtocols

-(void)initProtocols
{
    
}

-(void)registerProcessObj:(id<BaseProtocolsDelegate>)obj
{
    [self.processObjs addObject:obj];
}

-(void)processServerData:(NSDictionary*)serverData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        for(id<BaseProtocolsDelegate> obj in self.processObjs)
        {
            if([obj respondsToSelector:@selector(processServerData:)])
            {
                [obj processServerData:serverData];
            }
        }
    });
}

-(NSMutableArray*)processObjs
{
    if(!_processObjs)
    {
        _processObjs = [[NSMutableArray alloc] init];
    }
    return _processObjs;
}

@end
