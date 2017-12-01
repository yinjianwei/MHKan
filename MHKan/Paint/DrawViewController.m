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
#import "SizeMenuView.h"
#import "PaintProtocols.h"
#import "ProtocolType.h"

@interface DrawViewController () <SizeMenuViewDelegate, DrawViewDelegate, BaseProtocolsDelegate>

@property(nonatomic, strong)DrawView*       drawView;
@property(nonatomic, strong)UIView*         functionAreaView;
@property(nonatomic, strong)UIView*         selectedBgView;
@property(nonatomic, strong)SizeMenuView*   sizeMenuView;

@property(nonatomic, strong)NSMutableArray* functionImageAry;
@property(nonatomic)BOOL    useEraser;

@end

@implementation DrawViewController

-(void)viewSafeAreaInsetsDidChange
{
    [super viewSafeAreaInsetsDidChange];
    
    CGFloat bottomOffset = -self.view.safeAreaInsets.bottom;
    [self.functionAreaView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.view).offset(bottomOffset);
        make.height.equalTo(@40);
        make.left.right.equalTo(self.view);
    }];
    
    [self.drawView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.functionAreaView.mas_top).offset(-10);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.functionImageAry = [[NSMutableArray alloc] init];
    self.useEraser = NO;
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.title = @"绘图板";
    self.view.backgroundColor = [UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self setupUI];
    
    [[PaintProtocols sharedProtols] registerProcessObj:self];
}

-(void)setupUI
{
    self.drawView = [[DrawView alloc] init];
    self.drawView.backgroundColor = [UIColor whiteColor];
    self.drawView.delegate = self;
    [self.view addSubview:self.drawView];
    if (@available(iOS 11.0, *))
    {
    }
    else
    {
        [self.drawView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.equalTo(self.view);
            make.bottom.equalTo(self.view).offset(-50);
        }];
    }
    
    self.functionAreaView = [[UIView alloc] init];
    self.functionAreaView.backgroundColor = [UIColor colorWithRed:0xad/255.0 green:0xa9/255.0 blue:0x9f/255.0 alpha:1];
    [self.view addSubview:self.functionAreaView];
    if(@available(iOS 11.0, *))
    {
    }
    else
    {
        [self.functionAreaView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.drawView.mas_bottom).offset(10);
            make.bottom.equalTo(self.view);
        }];
    }
    
    self.sizeMenuView = [[SizeMenuView alloc] initWithFrame:CGRectMake(0, 0, 50, 160)];
    self.sizeMenuView.hidden = YES;
    self.sizeMenuView.delegate = self;
    [self.view addSubview:self.sizeMenuView];
    
    self.selectedBgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, 40)];
    self.selectedBgView.backgroundColor = [UIColor colorWithRed:0.8 green:0.8 blue:0.8 alpha:1];
    [self.functionAreaView addSubview:self.selectedBgView];
    
    UIImageView* clearImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"shanchu"]];
    [self.functionAreaView addSubview:clearImage];
    clearImage.contentMode = UIViewContentModeCenter;
    clearImage.userInteractionEnabled = YES;
    [clearImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapClear:)]];
    [clearImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.functionAreaView);
        make.centerY.equalTo(self.functionAreaView);
        make.width.equalTo(self.selectedBgView);
        make.height.equalTo(@(30));
    }];
    
    UIImageView* eraserImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"xiangpica"]];
    [self.functionAreaView addSubview:eraserImage];
    eraserImage.contentMode = UIViewContentModeCenter;
    eraserImage.userInteractionEnabled = YES;
    [eraserImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapEraser:)]];
    [self.functionImageAry addObject:eraserImage];
    [eraserImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(clearImage.mas_right);
        make.centerY.equalTo(self.functionAreaView);
        make.width.height.equalTo(clearImage);
    }];
    
    UIImageView* penImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bi"]];
    [self.functionAreaView addSubview:penImage];
    penImage.userInteractionEnabled = YES;
    penImage.contentMode = UIViewContentModeCenter;
    [penImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTapPen:)]];
    [self.functionImageAry addObject:penImage];
    [penImage mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(eraserImage.mas_right);
        make.centerY.equalTo(self.functionAreaView);
        make.width.height.equalTo(clearImage);
    }];
    
    [self performSelector:@selector(moveSelectedBgImage:) withObject:penImage afterDelay:0];
}

#pragma mark - recognizer event

-(void)onTapClear:(UITapGestureRecognizer*)recognizer
{
    UIAlertController* alertVC = [UIAlertController alertControllerWithTitle:@"" message:@"是否清除画板内容？" preferredStyle:UIAlertControllerStyleAlert];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alertVC addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.drawView clear];
    }]];
    [self presentViewController:alertVC animated:YES completion:nil];
}

-(void)onTapEraser:(UITapGestureRecognizer*)recognizer
{
    if(self.useEraser)
    {
        [self showSizeMenuViewWithFuncImage:(UIImageView*)recognizer.view];
    }
    else
    {
        [self showSizeMenuViewWithFuncImage:nil];
    }
    
    self.useEraser = YES;
    [self.drawView useEraser:self.useEraser];
    [self moveSelectedBgImage:(UIImageView*)recognizer.view];
}

-(void)onTapPen:(UITapGestureRecognizer*)recognizer
{
    if(!self.useEraser)
    {
        [self showSizeMenuViewWithFuncImage:(UIImageView*)recognizer.view];
    }
    else
    {
        [self showSizeMenuViewWithFuncImage:nil];
    }
    
    self.useEraser = NO;
    [self.drawView useEraser:self.useEraser];
    [self moveSelectedBgImage:(UIImageView*)recognizer.view];
}

#pragma mark - touch event

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self showSizeMenuViewWithFuncImage:nil];
}

#pragma mark - BaseProtocolsDelegate

-(void)processServerData:(NSDictionary *)serverData
{
    NSNumber* processType = [serverData objectForKey:PROCESS_TYPE];
    switch (processType.integerValue) {
        case ProcessTypeStartDraw:
        {
            NSNumber* eraserValue = [serverData objectForKey:@"isEraser"];
            [self.drawView useEraser:eraserValue.boolValue];
            NSString* posValue = [serverData objectForKey:@"pos"];
            CGPoint pos = CGPointFromString(posValue);
            [self.drawView beganDrawWithPos:pos];
        }
            break;
        case ProcessTypeDrawPos:
        {
            NSNumber* eraserValue = [serverData objectForKey:@"isEraser"];
            [self.drawView useEraser:eraserValue.boolValue];
            NSString* posValue = [serverData objectForKey:@"pos"];
            CGPoint pos = CGPointFromString(posValue);
            [self.drawView drawWithPos:pos];
        }
        case ProcessTypeEndDraw:
        {
            NSNumber* eraserValue = [serverData objectForKey:@"isEraser"];
            [self.drawView useEraser:eraserValue.boolValue];
            NSString* posValue = [serverData objectForKey:@"pos"];
            CGPoint pos = CGPointFromString(posValue);
            [self.drawView drawWithPos:pos];
            [self.drawView endDraw];
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - DrawViewDelegate

-(void)beginDraw:(CGPoint)pos
{
    NSDictionary* params = @{@"pos":NSStringFromCGPoint(pos), @"isEraser":@([self.drawView isEraserMode])};
    [[PaintProtocols sharedProtols] startDrawWithParams:params];
}

-(void)drawMove:(CGPoint)pos
{
    NSDictionary* params = @{@"pos":NSStringFromCGPoint(pos), @"isEraser":@([self.drawView isEraserMode])};
    [[PaintProtocols sharedProtols] drawWithParams:params];
}

-(void)endDraw:(CGPoint)pos
{
    NSDictionary* params = @{@"pos":NSStringFromCGPoint(pos), @"isEraser":@([self.drawView isEraserMode])};
    [[PaintProtocols sharedProtols] endDrawWithParams:params];
}

#pragma mark - SizeMenuViewDelegate

-(void)sizeValueChanged:(CGFloat)value
{
    if(self.useEraser)
    {
        [self.drawView setEraserWidth:value];
    }
    else
    {
        [self.drawView setLineWidth:value];
    }
}

#pragma mark - self method

-(void)moveSelectedBgImage:(UIImageView*)target
{
    if(!self.selectedBgView)
        return;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.selectedBgView.frame = CGRectMake(target.frame.origin.x, 0, self.selectedBgView.frame.size.width, self.selectedBgView.frame.size.height);
    }];
}

-(void)showSizeMenuViewWithFuncImage:(UIImageView*)imageView
{
    if(!self.sizeMenuView)
    {
        return;
    }
    
    if(!self.sizeMenuView.hidden || !imageView)
    {
        self.sizeMenuView.hidden = YES;
        self.drawView.userInteractionEnabled = YES;
        return;
    }
    
    self.drawView.userInteractionEnabled = NO;
    
    if(self.useEraser)
    {
        [self.sizeMenuView setSizeValue:[self.drawView getEraserWidth]];
    }
    else
    {
        [self.sizeMenuView setSizeValue:[self.drawView getLineWidth]];
    }
    self.sizeMenuView.hidden = NO;
    CGRect frame = self.sizeMenuView.frame;
    self.sizeMenuView.frame = CGRectMake(imageView.frame.origin.x, self.functionAreaView.frame.origin.y-frame.size.height, frame.size.width, frame.size.height);
}

@end
