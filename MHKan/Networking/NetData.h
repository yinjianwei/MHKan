//
//  NetData.h
//  MHKan
//
//  Created by Yinjw on 2017/11/30.
//  Copyright © 2017年 yinjianwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetData : NSObject

@property(nonatomic, readonly)NSUInteger    dataIndex;
@property(nonatomic, strong)NSDictionary*   sendDatas;
@property(nonatomic)BOOL                    isSend;

@end
