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
#import "Utils.h"

@interface DrawView()

@property(nonatomic, strong)NSMutableArray*     points;
@property(nonatomic, strong)UIBezierPath*       drawPath;
@property(nonatomic, strong)UIBezierPath*       eraserPath;
@property(nonatomic, strong)CAShapeLayer*       drawLayer;
@property(nonatomic, strong)UIImageView*        drawImage;
@property(nonatomic, strong)UIImageView*        backImage;

@property(nonatomic)BOOL                        isUseEraser;
@property(nonatomic, strong)NSMutableArray*     drawDataAry;

//@property(nonatomic)NSUInteger                  lastDrawIndex;

@end

@implementation DrawView

-(instancetype)init
{
    self = [super init];
    if(self)
    {
        self.layer.masksToBounds = YES;
        self.isUseEraser = NO;
        self.drawDataAry = [[NSMutableArray alloc] init];
//        self.lastDrawIndex = 0;
        
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
        
        CADisplayLink* displaylink = [CADisplayLink displayLinkWithTarget:self selector:@selector(displaylink:)];
        [displaylink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    }
    return self;
}

#pragma mark - touch event

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint pos = [[touches anyObject] locationInView:self];
    NSUInteger index = [Utils getIncreaseIndex];
    [self addDrawDataWithPos:pos index:index type:PointTypeBegan];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(drawWithPos:index:type:)])
    {
        CGSize size = self.frame.size;
        CGPoint newPos = CGPointMake(pos.x/size.width, pos.y/size.height);
        [self.delegate drawWithPos:newPos index:index type:PointTypeBegan];
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint pos = [[touches anyObject] locationInView:self];
    NSUInteger index = [Utils getIncreaseIndex];
    [self addDrawDataWithPos:pos index:index type:PointTypeMove];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(drawWithPos:index:type:)])
    {
        CGSize size = self.frame.size;
        CGPoint newPos = CGPointMake(pos.x/size.width, pos.y/size.height);
        [self.delegate drawWithPos:newPos index:index type:PointTypeMove];
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint pos = [[touches anyObject] locationInView:self];
    NSUInteger index = [Utils getIncreaseIndex];
    [self addDrawDataWithPos:pos index:index type:PointTypeEnd];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(drawWithPos:index:type:)])
    {
        CGSize size = self.frame.size;
        CGPoint newPos = CGPointMake(pos.x/size.width, pos.y/size.height);
        [self.delegate drawWithPos:newPos index:index type:PointTypeEnd];
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

-(void)addDrawDataWithPos:(CGPoint)pos index:(NSUInteger)index type:(PointType)type
{
    DrawData* data = [[DrawData alloc] init];
    data.pos = pos;
    data.index = index;
    data.pointType = type;
    [self.drawDataAry addObject:data];
    
    [self.drawDataAry sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        return ((DrawData*)obj1).index > ((DrawData*)obj2).index;
    }];
}

#pragma mark - self method

-(void)beganDrawWithPos:(CGPoint)pos
{
    [self clearPath];
    
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
}

-(void)displaylink:(CADisplayLink *)sender
{
    if(self.drawDataAry.count < 1)
    {
        return;
    }
    
    DrawData* data = [self.drawDataAry objectAtIndex:0];
//    if(data.index > 0 && data.index != self.lastDrawIndex+1)
//    {
//        return;
//    }
    if(data.pointType == PointTypeBegan)
    {
        [self beganDrawWithPos:data.pos];
    }
    else if(data.pointType == PointTypeMove)
    {
        [self drawWithPos:data.pos];
    }
    else if(data.pointType == PointTypeEnd)
    {
        [self drawWithPos:data.pos];
        [self endDraw];
    }
    
//    self.lastDrawIndex = data.index;
    [self.drawDataAry removeObjectAtIndex:0];
}

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
