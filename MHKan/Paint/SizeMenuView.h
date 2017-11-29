//
//  SizeMenuView.h
//  MHKan
//
//  Created by Yinjw on 2017/11/28.
//  Copyright © 2017年 yinjianwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SizeMenuViewDelegate <NSObject>

-(void)sizeValueChanged:(CGFloat)value;

@end

@interface SizeMenuView : UIView

@property(nonatomic, weak)id<SizeMenuViewDelegate>  delegate;

-(void)setSizeValue:(CGFloat)value;

@end
