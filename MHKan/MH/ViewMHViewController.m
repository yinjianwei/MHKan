//
//  ViewMHViewController.m
//  MHKan
//
//  Created by Yinjw on 2017/11/2.
//  Copyright © 2017年 yinjianwei. All rights reserved.
//

#import "ViewMHViewController.h"
#import "Masonry.h"

@interface ViewMHViewController () <UIScrollViewDelegate>

@property(nonatomic, strong)UIScrollView*   scrollView;
@property(nonatomic, strong)UIImageView*    centerImageView;
@property(nonatomic, strong)UIImageView*    leftImageView;
@property(nonatomic, strong)UIImageView*    rightImageView;
@property(nonatomic, copy)NSString*     src;
@property(nonatomic)NSInteger           curPage;

@end

@implementation ViewMHViewController

-(instancetype)initWithSrc:(NSString *)src
{
    self = [super init];
    if(self)
    {
        self.src = src;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    self.curPage = 1;
    
    [self setupUI];
}

-(void)setupUI
{
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.pagingEnabled = YES;
    self.scrollView.delegate = self;
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UIView* contentView = [[UIView alloc] init];
    [self.scrollView addSubview:contentView];
    [contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.scrollView);
        make.height.equalTo(self.scrollView);
    }];
    
    self.leftImageView = [[UIImageView alloc] init];
    self.leftImageView.contentMode = UIViewContentModeScaleToFill;
    [contentView addSubview:self.leftImageView];
    [self.leftImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.bottom.equalTo(contentView);
        make.width.equalTo(self.view);
    }];
    
    self.centerImageView = [[UIImageView alloc] init];
    self.centerImageView.contentMode = UIViewContentModeScaleToFill;
    [contentView addSubview:self.centerImageView];
    [self.centerImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(contentView);
        make.left.equalTo(self.leftImageView.mas_right);
        make.width.equalTo(self.leftImageView);
    }];
    
    self.rightImageView = [[UIImageView alloc] init];
    self.rightImageView.contentMode = UIViewContentModeScaleToFill;
    [contentView addSubview:self.rightImageView];
    [self.rightImageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.right.equalTo(contentView);
        make.left.equalTo(self.centerImageView.mas_right);
        make.width.equalTo(self.centerImageView);
    }];
}

-(void)viewDidAppear:(BOOL)animated
{
    [self refreshImage];
    
    [self.scrollView scrollRectToVisible:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height) animated:NO];
}

-(void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate)
    {
        NSInteger page = scrollView.contentOffset.x/self.view.frame.size.width+1;
        if(page >= 2)
        {
            self.curPage++;
        }
        else if(page <= 1)
        {
            self.curPage--;
        }
        [self refreshImage];
        [scrollView scrollRectToVisible:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height) animated:NO];
    }
}

-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger page = scrollView.contentOffset.x/self.view.frame.size.width+1;
    if(page >= 2)
    {
        self.curPage++;
    }
    else if(page <= 1)
    {
        self.curPage--;
    }
    [self refreshImage];
    [scrollView scrollRectToVisible:CGRectMake(self.view.frame.size.width, 0, self.view.frame.size.width, self.view.frame.size.height) animated:NO];
}

-(void)refreshImage
{
    NSString* fileName = [NSString stringWithFormat:@"img%d", (int)self.curPage];
    NSString* path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"jpg"];
    NSData* data = [NSData dataWithContentsOfFile:path];
    self.centerImageView.image = [UIImage imageWithData:data];
    
    if(self.curPage > 0)
    {
        fileName = [NSString stringWithFormat:@"img%d", self.curPage-1];
        path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"jpg"];
        data = [NSData dataWithContentsOfFile:path];
        self.leftImageView.image = [UIImage imageWithData:data];
    }
    
    fileName = [NSString stringWithFormat:@"img%d", self.curPage+1];
    path = [[NSBundle mainBundle] pathForResource:fileName ofType:@"jpg"];
    data = [NSData dataWithContentsOfFile:path];
    if(data)
    {
        self.rightImageView.image = [UIImage imageWithData:data];
    }
}

@end
