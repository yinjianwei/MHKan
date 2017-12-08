//
//  DrawView.h
//  MHKan
//
//  Created by Yinjw on 2017/11/20.
//  Copyright © 2017年 yinjianwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DrawViewDelegate <NSObject>

-(void)beginDraw:(CGPoint)pos;
-(void)drawMove:(CGPoint)pos;
-(void)endDraw:(CGPoint)pos;

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

-(void)setStartPos:(CGPoint)pos;
-(void)addMoveToPos:(CGPoint)pos;
-(void)setEndPos:(CGPoint)pos;

@end
