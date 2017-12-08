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

const NSString* start_pos = @"startPos";
const NSString* move_pos = @"movePos";
const NSString* end_pos = @"endPos";

@interface DrawView()

@property(nonatomic, strong)NSMutableArray*     points;
@property(nonatomic, strong)UIBezierPath*       drawPath;
@property(nonatomic, strong)UIBezierPath*       eraserPath;
@property(nonatomic, strong)CAShapeLayer*       drawLayer;
@property(nonatomic, strong)UIImageView*        drawImage;
@property(nonatomic, strong)UIImageView*        backImage;

@property(nonatomic)BOOL                        isUseEraser;
@property(nonatomic, strong)NSMutableDictionary*     drawPosDict;

@end

@implementation DrawView

-(instancetype)init
{
    self = [super init];
    if(self)
    {
        self.layer.masksToBounds = YES;
        self.isUseEraser = NO;
        self.drawPosDict = [[NSMutableDictionary alloc] init];
        [self.drawPosDict setObject:@"" forKey:start_pos];
        [self.drawPosDict setObject:[[NSMutableArray alloc] init] forKey:move_pos];
        [self.drawPosDict setObject:@"" forKey:end_pos];
        
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
    
    [self.drawPosDict setObject:NSStringFromCGPoint(pos) forKey:start_pos];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(beginDraw:)])
    {
        CGSize size = self.frame.size;
        CGPoint newPos = CGPointMake(pos.x/size.width, pos.y/size.height);
        [self.delegate beginDraw:newPos];
    }
}

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint pos = [[touches anyObject] locationInView:self];
    
    NSMutableArray* ary = [self.drawPosDict objectForKey:move_pos];
    [ary addObject:NSStringFromCGPoint(pos)];
    [self.drawPosDict setObject:ary forKey:move_pos];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(drawMove:)])
    {
        CGSize size = self.frame.size;
        CGPoint newPos = CGPointMake(pos.x/size.width, pos.y/size.height);
        [self.delegate drawMove:newPos];
    }
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    CGPoint pos = [[touches anyObject] locationInView:self];
    
    [self.drawPosDict setObject:NSStringFromCGPoint(pos) forKey:end_pos];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(endDraw:)])
    {
        CGSize size = self.frame.size;
        CGPoint newPos = CGPointMake(pos.x/size.width, pos.y/size.height);
        [self.delegate endDraw:newPos];
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

-(void)setStartPos:(CGPoint)pos
{
    [self.drawPosDict setObject:NSStringFromCGPoint(pos) forKey:start_pos];
}

-(void)addMoveToPos:(CGPoint)pos
{
    NSMutableArray* ary = [self.drawPosDict objectForKey:move_pos];
    [ary addObject:NSStringFromCGPoint(pos)];
    [self.drawPosDict setObject:ary forKey:move_pos];
}

-(void)setEndPos:(CGPoint)pos
{
    [self.drawPosDict setObject:NSStringFromCGPoint(pos) forKey:end_pos];
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
    NSString* startPos = [self.drawPosDict objectForKey:start_pos];
    if(![startPos isEqualToString:@""])
    {
        [self beganDrawWithPos:CGPointFromString(startPos)];
        [self.drawPosDict setObject:@"" forKey:start_pos];
    }
    
    NSMutableArray* ary = [self.drawPosDict objectForKey:move_pos];
    if(ary.count > 0)
    {
        CGPoint pos = CGPointFromString([ary objectAtIndex:0]);
        [self drawWithPos:pos];
        [ary removeObjectAtIndex:0];
        [self.drawPosDict setObject:ary forKey:move_pos];
    }
    
    NSString* endPos = [self.drawPosDict objectForKey:end_pos];
    if(ary.count <= 0 && ![endPos isEqualToString:@""])
    {
        [self drawWithPos:CGPointFromString(endPos)];
        [self endDraw];
        [self.drawPosDict setObject:@"" forKey:end_pos];
    }
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
