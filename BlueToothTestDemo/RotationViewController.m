//
//  RotationViewController.m
//  BlueToothTestDemo
//
//  Created by pg on 2016/12/22.
//  Copyright © 2016年 DZHFCompany. All rights reserved.
//

#import "RotationViewController.h"
#import "ZJRotationView.h"

@interface RotationViewController ()
@property (strong,nonatomic)ZJRotationView *rotationView;

@end

@implementation RotationViewController

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
}

-(void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSArray *titlesArr = @[@"查试题",@"应用汇",@"微视频",@"做训练",@"看试卷",@"爱问答"];
    NSArray *imagesArr = @[@"index_shiti",@"index_yingyong",@"index_pvideo",@"index_xunlian",@"index_shijuan",@"index_discussion"];
    CGFloat viewW = [UIScreen mainScreen].bounds.size.width-80;
    _rotationView = [[ZJRotationView alloc]initWithFrame:CGRectMake(0, 0, viewW, viewW) titles:titlesArr images:imagesArr clickBlock:^(NSInteger buttonIndex) {
        NSLog(@"当前点击的按钮===%zd",buttonIndex);
    }];
    _rotationView.center = self.view.center;
    [self.view addSubview:_rotationView];

}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.navigationController popViewControllerAnimated:YES];
}
@end
