//
//  DrawData.h
//  MHKan
//
//  Created by Yinjw on 2017/12/18.
//  Copyright © 2017年 yinjianwei. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, PointType)
{
    PointTypeBegan,
    PointTypeMove,
    PointTypeEnd,
};

@interface DrawData : NSObject

@property(nonatomic)NSUInteger  index;
@property(nonatomic)CGPoint     pos;
@property(nonatomic)PointType   pointType;

@end
