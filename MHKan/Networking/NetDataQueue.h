//
//  NetDataQueue.h
//  MHKan
//
//  Created by Yinjw on 2017/11/30.
//  Copyright © 2017年 yinjianwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NetData.h"

@interface NetDataQueue : NSObject

-(void)addNewNetDataWithParams:(id)params;
-(NetData*)getSendData;

@end
