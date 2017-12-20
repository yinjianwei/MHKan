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

+(instancetype)sharedProtocols
{
    static PaintProtocols* sharedProtocols;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedProtocols = [[PaintProtocols alloc] init];
        [sharedProtocols initProtocols];
    });
    
    return sharedProtocols;
}

-(void)initProtocols
{
    [super initProtocols];
    
    [[NetworkManager sharedManager] registerProcessObjWithType:self type:ProtocolTypeDraw];
}

-(void)drawWithParams:(NSDictionary *)param
{
    NSMutableDictionary* newParam = [[NSMutableDictionary alloc] init];
    for(NSString* key in param)
    {
        [newParam setObject:[param objectForKey:key] forKey:key];
    }
    [newParam setObject:@(ProtocolTypeDraw) forKey:PROTOCOL_TYPE];
    [newParam setObject:@(ProcessTypeDraw) forKey:PROCESS_TYPE];
    [[NetworkManager sharedManager] sendDataWithParams:newParam];
}

-(void)clearDrawWithParam:(NSDictionary *)param
{
    NSMutableDictionary* newParam = [[NSMutableDictionary alloc] init];
    for(NSString* key in param)
    {
        [newParam setObject:[param objectForKey:key] forKey:key];
    }
    [newParam setObject:@(ProtocolTypeDraw) forKey:PROTOCOL_TYPE];
    [newParam setObject:@(ProcessTypeClear) forKey:PROCESS_TYPE];
    [[NetworkManager sharedManager] sendDataWithParams:newParam];
}

@end
