//
//  TestViewController.m
//  MHKan
//
//  Created by Yinjw on 2017/12/1.
//  Copyright © 2017年 yinjianwei. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()

@property(nonatomic, strong)CAShapeLayer* shapeLayer;
@property(nonatomic, strong)UIBezierPath* path;

@property(nonatomic)CGPoint pos;

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.backgroundColor = [UIColor yellowColor];
    self.pos = CGPointMake(100, 100);
    
    self.path = [[UIBezierPath alloc] init];
    self.path.lineWidth = 5;
    
    self.shapeLayer = [CAShapeLayer layer];
    self.shapeLayer.frame = self.view.bounds;
    self.shapeLayer.path = self.path.CGPath;
    self.shapeLayer.strokeColor = [UIColor redColor].CGColor;
    [self.view.layer addSublayer:self.shapeLayer];
    
    UIButton* btn1 = [[UIButton alloc] initWithFrame:CGRectMake(20, 20, 50, 30)];
    [btn1 setTitle:@"开始" forState:UIControlStateNormal];
    [btn1 addTarget:self action:@selector(onBtn1:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn1];
    
    UIButton* btn2 = [[UIButton alloc] initWithFrame:CGRectMake(80, 20, 50, 30)];
    [btn2 setTitle:@"移动" forState:UIControlStateNormal];
    [btn2 addTarget:self action:@selector(onBtn2:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn2];
}

-(void)onBtn1:(id)sender
{
    [self.path moveToPoint:self.pos];
}

-(void)onBtn2:(id)sender
{
    CGPoint pos = self.pos;
    pos.x = 5 + self.pos.x;
    pos.y = 5 + self.pos.y;
    self.pos = pos;
    [self.path addLineToPoint:self.pos];
    self.shapeLayer.path = self.path.CGPath;
    NSLog(@"path:%@", self.path);
}

@end
