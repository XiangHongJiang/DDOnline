//
//  XHDDOnlineSliderController.m
//  DDOnline
//
//  Created by qianfeng on 16/3/5.
//  Copyright © 2016年 JXHDev. All rights reserved.
//

#import "XHDDOnlineSliderController.h"
#import "RESideMenu.h"
#import "XHDDOnlineSignInController.h"
#import "XHDDOnlineRootTabBarController.h"

@interface XHDDOnlineSliderController ()<UITableViewDelegate, UITableViewDataSource>
/** *  cellImageNameArray */
@property (nonatomic, copy) NSArray *cellImageNameArray;
/** *  cellTitleArray */
@property (nonatomic, copy) NSArray *cellTitleArray;

@end

@implementation XHDDOnlineSliderController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //1.configTableView
    [self configTableView];
    
}
#pragma mark - lazyLoad
- (NSArray *)cellImageNameArray{

    if (_cellImageNameArray == nil) {
        
        _cellImageNameArray = @[@"sidemenu_QA",@"sidemenu-software",@"sidemenu_blog",@"sidemenu_setting",@"sidemenu-night"];
    }
    return _cellImageNameArray;
}
- (NSArray *)cellTitleArray{

    if (_cellTitleArray == nil) {
        
        _cellTitleArray = @[@"我的下载",@"我的收藏",@"我的分享",@"设置",@"夜间模式"];
    }
    return _cellTitleArray;
}
#pragma mark - setupUI
//配置tableView
- (void)configTableView{
    //注册cell
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"sliderCellID"];
    //去掉分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    //修改背景颜色
    self.view.backgroundColor = [UIColor colorWithWhite:218.0f/255.0f alpha:1.0f];
    
    self.tableView.rowHeight = 50;
    self.tableView.sectionHeaderHeight = JAdsViewHeight;
}
#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return 1;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    //#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return self.cellTitleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{

    //复用cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"sliderCellID" forIndexPath:indexPath];
    
    //修改背景颜色
    cell.backgroundColor = [UIColor colorWithWhite:218.0f/255.0f alpha:1.0f];
    // Configure the cell...
    cell.imageView.image = [UIImage imageNamed:self.cellImageNameArray[indexPath.row]];
    cell.textLabel.text = self.cellTitleArray[indexPath.row];
    
    return cell;

}
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{

    //添加表头视图
    UIView *headView = [[UIView alloc] init];
//    headView.backgroundColor = JColorAlert;
    headView.frame = CGRectMake(0, 0, JScreenWidth, 120);
    
    
    UIImageView *headerBG = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, JScreenWidth * 0.8, 120)];
    [headView addSubview:headerBG];
    headerBG.image = [UIImage imageNamed:@"HeaderBG01"];
    
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(15, 15, 60, 60)];
    [headView addSubview:imageView];
    imageView.image = [UIImage imageNamed:@"defaultUserIcon"];
    imageView.layer.cornerRadius = 30;
    imageView.layer.masksToBounds = YES;
    imageView.backgroundColor = [UIColor grayColor];
    imageView.userInteractionEnabled = YES;
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taped)];
    [imageView addGestureRecognizer:tapGR];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 80, 200, 30)];
    nameLabel.text = @"点击头像登录";
    nameLabel.textColor = [UIColor whiteColor];
    nameLabel.font = [UIFont systemFontOfSize:15];
    [headView addSubview:nameLabel];
    
    return headView;
}
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
#warning 跳转事件
    
    [self.sideMenuViewController hideMenuViewController];
    
    NSLog(@"%@",self.cellTitleArray[indexPath.row]);
}
- (void)taped{
    JLog(@"点击了头像");
    
    XHDDOnlineSignInController *signCtrl = [[XHDDOnlineSignInController alloc] init];
    XHDDOnlineRootTabBarController *rootTbc = self.sideMenuViewController.contentViewController.childViewControllers[0];
    UINavigationController *nav = rootTbc.selectedViewController;
    
    [nav pushViewController:signCtrl animated:YES];
    [self.sideMenuViewController hideMenuViewController];
    
}
@end
