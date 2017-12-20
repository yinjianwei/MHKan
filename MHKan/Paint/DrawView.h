//
//  DrawView.h
//  MHKan
//
//  Created by Yinjw on 2017/11/20.
//  Copyright © 2017年 yinjianwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DrawData.h"

@protocol DrawViewDelegate <NSObject>

-(void)drawWithPos:(CGPoint)pos index:(NSUInteger)index type:(PointType)type;

@end

@interface DrawView : UIView

@property(nonatomic, weak)id<DrawViewDelegate>  delegate;

-(void)clear;
-(void)useEraser:(BOOL)isUse;

-(void)setLineWidth:(CGFloat)width;
-(CGFloat)getLineWidth;
-(void)setLineColor:(UIColor*)color;

-(void)setEraserWidth:(CGFloat)width;
-(CGFloat)getEraserWidth;

-(BOOL)isEraserMode;

-(void)addDrawDataWithPos:(CGPoint)pos index:(NSUInteger)index type:(PointType)type;

@end
