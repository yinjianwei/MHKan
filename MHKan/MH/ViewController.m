//
//  ViewController.m
//  MHKan
//
//  Created by Yinjw on 2017/11/2.
//  Copyright © 2017年 yinjianwei. All rights reserved.
//

#import "ViewController.h"
#import "ViewMHViewController.h"

@interface ViewController () <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong)NSArray*    tableDatas;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.title = @"漫画列表";
    self.tableDatas = @[@"src1", @"src2", @"src3", @"src4"];
    
    UITableView* tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.tableFooterView = [[UIView alloc] init];
    [self.view addSubview:tableView];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.tableDatas.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell* cell = [[UITableViewCell alloc] init];
    cell.textLabel.text = [self.tableDatas objectAtIndex:indexPath.row];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    ViewMHViewController* mhVC = [[ViewMHViewController alloc] initWithSrc:[self.tableDatas objectAtIndex:indexPath.row]];
    [self.navigationController pushViewController:mhVC animated:YES];
}

@end
