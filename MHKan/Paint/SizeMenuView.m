//
//  SizeMenuView.m
//  MHKan
//
//  Created by Yinjw on 2017/11/28.
//  Copyright © 2017年 yinjianwei. All rights reserved.
//

#import "SizeMenuView.h"
#import "Masonry.h"

@interface SizeMenuView()

@property(nonatomic, strong)UISlider* slider;
@property(nonatomic, strong)UILabel*  valueLabel;

@end

@implementation SizeMenuView

-(instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
    {
        self.backgroundColor = [UIColor colorWithRed:0xad/255.0 green:0xa9/255.0 blue:0x9f/255.0 alpha:1];
        
        [self setupUI];
    }
    return self;
}

-(void)setupUI
{
    self.valueLabel = [[UILabel alloc] init];
    self.valueLabel.backgroundColor = [UIColor colorWithWhite:1 alpha:0.3];
    self.valueLabel.text = @"5";
    self.valueLabel.textColor = [UIColor blackColor];
    self.valueLabel.font = [UIFont systemFontOfSize:14];
    self.valueLabel.textAlignment = NSTextAlignmentCenter;
    [self addSubview:self.valueLabel];
    [self.valueLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.right.equalTo(self);
        make.height.equalTo(@20);
    }];
    
    self.slider = [[UISlider alloc] init];
    self.slider.minimumValue = 3;
    self.slider.maximumValue = 15;
    self.slider.value = 5;
    self.slider.continuous = YES;
    self.slider.backgroundColor = [UIColor clearColor];
    self.slider.minimumTrackTintColor = [UIColor colorWithWhite:1 alpha:0.3];
    self.slider.maximumTrackTintColor = [UIColor colorWithWhite:1 alpha:0.8];
    self.slider.thumbTintColor = [UIColor whiteColor];
    [self.slider setThumbImage:[self circleImage:10] forState:UIControlStateNormal];
    [self.slider setThumbImage:[self circleImage:10] forState:UIControlStateHighlighted];
    self.slider.transform = CGAffineTransformRotate(CGAffineTransformIdentity, -M_PI_2);
    [self.slider addTarget:self action:@selector(sliderValueChanged) forControlEvents:UIControlEventValueChanged];
    [self addSubview:self.slider];
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self);
        make.width.equalTo(self.mas_height).offset(-40);
        make.top.equalTo(self.valueLabel.mas_bottom).offset(10);
        make.bottom.equalTo(self).offset(-10);
    }];
}

-(UIImage*)circleImage:(CGFloat)radius
{
    UIGraphicsBeginImageContext(CGSizeMake(radius*2, radius*2));
    [[UIColor whiteColor] setFill];
    [[UIColor blackColor] setStroke];
    UIBezierPath* fillPath = [UIBezierPath bezierPath];
    [fillPath addArcWithCenter:CGPointMake(radius, radius) radius:radius-2 startAngle:0 endAngle:M_PI*2 clockwise:YES];
    [fillPath fill];
    UIImage* image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

-(UIView*)circleView:(NSInteger)radius
{
    UIView* view = [[UIView alloc] init];
    view.backgroundColor = [UIColor clearColor];
    CAShapeLayer* layer = [CAShapeLayer layer];
    layer.fillColor = [UIColor redColor].CGColor;
    UIBezierPath* path = [UIBezierPath bezierPath];
    [path addArcWithCenter:CGPointMake(radius, radius) radius:radius startAngle:0 endAngle:M_PI*2 clockwise:YES];
    layer.path = path.CGPath;
    [view.layer addSublayer:layer];;
    
    return view;
}

-(void)sliderValueChanged
{
    self.valueLabel.text = [NSString stringWithFormat:@"%.f", self.slider.value];
    
    if(self.delegate && [self.delegate respondsToSelector:@selector(sizeValueChanged:)])
    {
        [self.delegate sizeValueChanged:self.slider.value];
    }
}

-(void)setSizeValue:(CGFloat)value
{
    self.valueLabel.text = [NSString stringWithFormat:@"%.f", value];
    [self.slider setValue:value animated:NO];
}

@end
