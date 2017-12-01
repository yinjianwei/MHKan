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

#define PROCESS_TYPE    @"processType"
#define PROTOCOL_TYPE   @"protocolType"

typedef NS_ENUM(NSInteger, ProtocolType)
{
    ProtocolTypeDraw,
};

typedef NS_ENUM(NSInteger, ProcessType)
{
    ProcessTypeStartDraw,
    ProcessTypeDrawPos,
    ProcessTypeEndDraw,
};

#endif /* ProtocolType_h */
