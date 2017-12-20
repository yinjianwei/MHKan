//
//  ProtocolType.h
//  MHKan
//
//  Created by Yinjw on 2017/11/30.
//  Copyright © 2017年 yinjianwei. All rights reserved.
//

#ifndef ProtocolType_h
#define ProtocolType_h

#import <Foundation/Foundation.h>

#define INCREASE_INDEX  @"increaseIndex"
#define PROCESS_TYPE    @"processType"
#define PROTOCOL_TYPE   @"protocolType"

//接口处理一级类别
typedef NS_ENUM(NSInteger, ProtocolType)
{
    ProtocolTypeDraw,
};

//接口处理二级类别
typedef NS_ENUM(NSInteger, ProcessType)
{
    ProcessTypeDraw,
    ProcessTypeClear,
};

#endif /* ProtocolType_h */
