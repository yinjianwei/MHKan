//
//  PaintProtocols.m
//  MHKan
//
//  Created by Yinjw on 2017/11/30.
//  Copyright © 2017年 yinjianwei. All rights reserved.
//

#import "PaintProtocols.h"
#import "NetworkManager.h"
#import "ProtocolType.h"

@implementation PaintProtocols

+(instancetype)sharedProtols
{
    static PaintProtocols* sharedProtols;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedProtols = [[PaintProtocols alloc] init];
        [sharedProtols initProtocols];
    });
    
    return sharedProtols;
}

-(void)initProtocols
{
    [super initProtocols];
    
    [[NetworkManager sharedManager] registerProcessObjWithType:self type:ProtocolTypeDraw];
}

-(void)startDrawWithParams:(NSDictionary *)param
{
    NSMutableDictionary* newParam = [[NSMutableDictionary alloc] init];
    for(NSString* key in param)
    {
        [newParam setObject:[param objectForKey:key] forKey:key];
    }
    [newParam setObject:@(ProtocolTypeDraw) forKey:PROTOCOL_TYPE];
    [newParam setObject:@(ProcessTypeStartDraw) forKey:PROCESS_TYPE];
    [[NetworkManager sharedManager] sendDataWithParams:newParam];
}

-(void)drawWithParams:(NSDictionary *)param
{
    NSMutableDictionary* newParam = [[NSMutableDictionary alloc] init];
    for(NSString* key in param)
    {
        [newParam setObject:[param objectForKey:key] forKey:key];
    }
    [newParam setObject:@(ProtocolTypeDraw) forKey:PROTOCOL_TYPE];
    [newParam setObject:@(ProcessTypeDrawPos) forKey:PROCESS_TYPE];
    [[NetworkManager sharedManager] sendDataWithParams:newParam];
}

-(void)endDrawWithParams:(NSDictionary *)param
{
    NSMutableDictionary* newParam = [[NSMutableDictionary alloc] init];
    for(NSString* key in param)
    {
        [newParam setObject:[param objectForKey:key] forKey:key];
    }
    [newParam setObject:@(ProtocolTypeDraw) forKey:PROTOCOL_TYPE];
    [newParam setObject:@(ProcessTypeEndDraw) forKey:PROCESS_TYPE];
    [[NetworkManager sharedManager] sendDataWithParams:newParam];
}

@end
