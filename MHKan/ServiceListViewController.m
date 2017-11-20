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
    
    [[NetworkManager sharedManager] startServiceWithFindFunc:^{
        [self refreshList];
    }];
    [[NetworkManager sharedManager] setNewConnetFunc:^{
        [self openTalkViewController];
    }];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray* datas = [[NetworkManager sharedManager] getAllFindServices];
    return datas.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* datas = [[NetworkManager sharedManager] getAllFindServices];
    NSNetService* data = [datas objectAtIndex:indexPath.row];
    UITableViewCell* cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = data.name;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSArray* datas = [[NetworkManager sharedManager] getAllFindServices];
    NSNetService* data = [datas objectAtIndex:indexPath.row];
    [[NetworkManager sharedManager] initStreamWithService:data];
    
    [self openTalkViewController];
}

-(void)refreshList
{
    [self.tableView reloadData];
}

-(void)openTalkViewController
{
    TalkViewController* talkVC = [[TalkViewController alloc] init];
    [self.navigationController pushViewController:talkVC animated:YES];
}

@end
