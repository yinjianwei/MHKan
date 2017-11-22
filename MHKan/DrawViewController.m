//
//  DrawViewController.m
//  MHKan
//
//  Created by Yinjw on 2017/11/20.
//  Copyright © 2017年 yinjianwei. All rights reserved.
//

#import "DrawViewController.h"
#import "Masonry.h"
#import "DrawView.h"

@interface DrawViewController ()

@property(nonatomic, strong)DrawView*     drawView;

@end

@implementation DrawViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"绘图板";
    self.view.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.drawView = [[DrawView alloc] init];
    self.drawView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.drawView];
    [self.drawView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-70);
    }];
    
    UIView* functionAreaView = [[UIView alloc] init];
    functionAreaView.backgroundColor = [UIColor blueColor];
    [self.view addSubview:functionAreaView];
    [functionAreaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self.view);
        make.top.equalTo(self.drawView.mas_bottom).offset(10);
    }];
    
    UIButton* clearBtn = [[UIButton alloc] init];
    [clearBtn setImage:[UIImage imageNamed:@"shanchu"] forState:UIControlStateNormal];
    [clearBtn addTarget:self action:@selector(onBtnClear:) forControlEvents:UIControlEventTouchUpInside];
    [functionAreaView addSubview:clearBtn];
    [clearBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(functionAreaView).offset(15);
        make.centerY.equalTo(functionAreaView);
    }];
    
    UIButton* eraserBtn = [[UIButton alloc] init];
    [eraserBtn setImage:[UIImage imageNamed:@"xiangpica"] forState:UIControlStateNormal];
    [eraserBtn addTarget:self action:@selector(onBtnEraser:) forControlEvents:UIControlEventTouchUpInside];
    [functionAreaView addSubview:eraserBtn];
    [eraserBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(clearBtn.mas_right).offset(15);
        make.centerY.equalTo(functionAreaView);
    }];
}

-(void)onBtnClear:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    btn.selected = !btn.selected;
    [self.drawView clear];
}

-(void)onBtnEraser:(id)sender
{
    UIButton* btn = (UIButton*)sender;
    btn.selected = !btn.selected;
    [self.drawView useEraser:btn.selected];
}

@end
