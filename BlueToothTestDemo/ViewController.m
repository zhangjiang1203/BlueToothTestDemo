//
//  ViewController.m
//  BlueToothTestDemo
//
//  Created by pg on 2016/12/21.
//  Copyright © 2016年 DZHFCompany. All rights reserved.
//

#import "ViewController.h"
#import "BlueToothViewController.h"
#import "RotationViewController.h"
@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>
{
    NSArray <NSString*>*titleArr;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.title = @"蓝牙测试";
    titleArr = @[@"视图旋转",@"GameKit",@"MultipeerConnectivity",@"ExternalAccessory",@"CoreBlueTooth"];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return titleArr.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"systemCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    cell.textLabel.text = titleArr[indexPath.row];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    if (indexPath.row == 0) {
        RotationViewController *rotationVC = [storyBoard instantiateViewControllerWithIdentifier:@"RotationViewController"];
        [self.navigationController pushViewController:rotationVC animated:YES];
    }else{
        BlueToothViewController *blueVC = [storyBoard instantiateViewControllerWithIdentifier:@"BlueToothViewController"];
        [self.navigationController pushViewController:blueVC animated:YES];
    }
    
    
}
















































@end
