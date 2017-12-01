//
//  PaintProtocols.h
//  MHKan
//
//  Created by Yinjw on 2017/11/30.
//  Copyright © 2017年 yinjianwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseProtocols.h"

@interface PaintProtocols : BaseProtocols

+(instancetype)sharedProtols;

-(void)startDrawWithParams:(NSDictionary*)param;
-(void)drawWithParams:(NSDictionary*)param;
-(void)endDrawWithParams:(NSDictionary*)param;

@end
