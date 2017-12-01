//
//  DrawView.m
//  MHKan
//
//  Created by Yinjw on 2017/11/20.
//  Copyright © 2017年 yinjianwei. All rights reserved.
//

#import "DrawView.h"
#import "Masonry.h"
#import "PaintProtocols.h"

@interface DrawView()

@property(nonatomic, strong)NSMutableArray*     points;
@property(nonatomic, strong)UIBezierPath*       drawPath;
@property(nonatomic, strong)UIBezierPath*       eraserPath;
@property(nonatomic, strong)CAShapeLayer*       drawLayer;
@property(nonatomic, strong)UIImageView*        drawImage;
@property(nonatomic, strong)UIImageView*        backImage;

@property(nonatomic)BOOL                        isUseEraser;

@end

@implementation DrawView

-(instancetype)init
{
    self = [super init];
    if(self)
    {
        self.layer.masksToBounds = YES;
        self.isUseEraser = NO;
        
        self.drawPath = [[UIBezierPath alloc] init];
        self.drawLayer.lineWidth = 5;
        self.eraserPath = [[UIBezierPath alloc] init];
        self.eraserPath.lineWidth = 10;
        
        self.backImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"huaban"]];
        self.backImage.contentMode = UIViewContentModeScaleAspectFill;
        [self addSubview:self.backImage];
        [self.backImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        self.drawImage = [[UIImageView alloc] init];
        self.drawImage.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.drawImage];
        [self.drawImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        self.drawLayer = [CAShapeLayer layer];
        self.drawLayer.frame = self.frame;
        self.drawLayer.path = [[UIBezierPath alloc] init].CGPath;
        self.drawLayer.strokeColor = [UIColor redColor].CGColor;
        self.drawLayer.fillColor = [UIColor clearColor].CGColor;
        self.drawLayer.lineJoin = kCALineJoinRound;
        self.drawLayer.lineCap = kCALineCapRound;
        self.drawLayer.lineWidth = 5;
        [self.drawImage.layer addSublayer:self.drawLayer];
    }
    return self;
}

#pragma mark - touch event

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint pos = [[touches anyObject] locationInView:self];
    
    [self beganDrawWithPos:pos];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(beginDraw:)])
    {
        [self.delegate beginDraw:pos];
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint pos = [[touches anyObject] locationInView:self];
    
    [self drawWithPos:pos];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(drawMove:)])
    {
        [self.delegate drawMove:pos];
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint pos = [[touches anyObject] locationInView:self];
    
    [self drawWithPos:pos];
    
    [self endDraw];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(endDraw:)])
    {
        [self.delegate endDraw:pos];
    }
}

#pragma mark - public method

-(void)clear
{
    [self clearPath];
    self.drawImage.image = nil;
}

-(void)useEraser:(BOOL)isUse
{
    self.isUseEraser = isUse;
}

-(void)setLineWidth:(CGFloat)width
{
    self.drawLayer.lineWidth = width;
    self.drawPath.lineWidth = width;
}

-(CGFloat)getLineWidth
{
    return self.drawLayer.lineWidth;
}

-(void)setLineColor:(UIColor *)color
{
    self.drawLayer.strokeColor = color.CGColor;
}

-(void)setEraserWidth:(CGFloat)width
{
    self.eraserPath.lineWidth = width;
}

-(CGFloat)getEraserWidth
{
    return self.eraserPath.lineWidth;
}

-(BOOL)isEraserMode
{
    return self.isUseEraser;
}

-(void)beganDrawWithPos:(CGPoint)pos
{
    if(self.isUseEraser)
    {
        [self.eraserPath moveToPoint:pos];
    }
    else
    {
        [self.drawPath moveToPoint:pos];
    };
}

-(void)drawWithPos:(CGPoint)pos
{
    if(self.isUseEraser)
    {
        [self.eraserPath addLineToPoint:pos];
        UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0);
        [self.drawImage.image drawInRect:self.bounds];
        [[UIColor colorWithCGColor:self.drawLayer.strokeColor] set];
        [self.drawPath stroke];
        [[UIColor clearColor] set];
        [self.eraserPath strokeWithBlendMode:kCGBlendModeClear alpha:1.0];
        [self.eraserPath stroke];
        self.drawImage.image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    else
    {
        [self.drawPath addLineToPoint:pos];
        self.drawLayer.path = self.drawPath.CGPath;
    }
}

-(void)endDraw
{
    UIImage* image = [self screenShotWithView:self];
    self.drawImage.image = image;
    
//    [self clearPath];
}

#pragma mark - self method

-(void)clearPath
{
    [self.drawPath removeAllPoints];
    [self.eraserPath removeAllPoints];
    self.drawLayer.path = self.drawPath.CGPath;
}

-(UIImage*)screenShotWithView:(UIView*)view
{
    UIGraphicsBeginImageContextWithOptions(self.frame.size, NO, 0);
    CGContextRef ref = UIGraphicsGetCurrentContext();
    [view.layer renderInContext:ref];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

@end
