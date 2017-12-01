//
//  BaseProtocols.h
//  MHKan
//
//  Created by Yinjw on 2017/11/30.
//  Copyright © 2017年 yinjianwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol BaseProtocolsDelegate <NSObject>

-(void)processServerData:(NSDictionary*)serverData;

@end

@interface BaseProtocols : NSObject

@property(nonatomic, strong)NSMutableArray<id<BaseProtocolsDelegate>>*   processObjs;

-(void)initProtocols;

-(void)registerProcessObj:(id<BaseProtocolsDelegate>)obj;
-(void)processServerData:(NSDictionary*)serverData;

@end
