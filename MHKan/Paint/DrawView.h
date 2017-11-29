//
//  DrawView.h
//  MHKan
//
//  Created by Yinjw on 2017/11/20.
//  Copyright © 2017年 yinjianwei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DrawView : UIView

-(void)clear;
-(void)useEraser:(BOOL)isUse;

-(void)setLineWidth:(CGFloat)width;
-(CGFloat)getLineWidth;
-(void)setLineColor:(UIColor*)color;

-(void)setEraserWidth:(CGFloat)width;
-(CGFloat)getEraserWidth;

@end
