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

+(instancetype)sharedProtocols;

-(void)drawWithParams:(NSDictionary*)param;
-(void)clearDrawWithParam:(NSDictionary*)param;

@end
