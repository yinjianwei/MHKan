//
//  NetworkManager.h
//  MHKan
//
//  Created by Yinjw on 2017/11/16.
//  Copyright © 2017年 yinjianwei. All rights reserved.
//

#import <Foundation/Foundation.h>

//发现新的可连接service时的回调函数
typedef void(^FindFunc)(void);
//接受连接时的回调函数
typedef void(^ConnetFunc)(void);
//从流中接收到数据时的回调函数
typedef void(^RecvFunc)(NSDictionary*);

@interface NetworkManager : NSObject

+(NetworkManager*)sharedManager;

-(void)initManager;

-(void)startServiceWithFindFunc:(FindFunc)findFunc;
-(void)stopService;

-(void)initStreamWithService:(NSNetService*)service;
-(void)closeStream;

-(void)setStreamRecvFunc:(RecvFunc)recvFunc;
-(void)setNewConnetFunc:(ConnetFunc)connectFunc;

-(NSArray*)getAllFindServices;

-(void)sendData:(NSDictionary*)datas;

@end
