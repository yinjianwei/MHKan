//
//  ServiceListViewController.m
//  MHKan
//
//  Created by Yinjw on 2017/11/17.
//  Copyright © 2017年 yinjianwei. All rights reserved.
//

#import "ServiceListViewController.h"
#import "NetworkManager.h"
#import "Masonry.h"
#import "TalkViewController.h"
#import "DrawViewController.h"

@interface ServiceListViewController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong)UITableView*    tableView;

@end

@implementation ServiceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"连接设备列表";
    
    self.tableView = [[UITableView alloc] init];
    self.tableView.rowHeight = 40;
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [[NetworkManager sharedManager] setNewConnetFunc:^{
        [self openDrawViewController];
    }];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [[NetworkManager sharedManager] closeStream];
    [[NetworkManager sharedManager] startServiceWithFindFunc:^{
        [self refreshList];
    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray* datas = [[NetworkManager sharedManager] getAllFindServiceNames];
    return datas.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* datas = [[NetworkManager sharedManager] getAllFindServiceNames];
    UITableViewCell* cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = [datas objectAtIndex:indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NetworkManager sharedManager] initStreamWithServiceIndex:indexPath.row];
    
    [self openDrawViewController];
}

-(void)refreshList
{
    [self.tableView reloadData];
}

-(void)openDrawViewController
{
    DrawViewController* drawVC = [[DrawViewController alloc] init];
    [self.navigationController pushViewController:drawVC animated:YES];
}

-(void)openTalkViewController
{
    TalkViewController* talkVC = [[TalkViewController alloc] init];
    [self.navigationController pushViewController:talkVC animated:YES];
}

@end
