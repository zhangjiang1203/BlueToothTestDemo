//
//  ZJRotationView.h
//  BlueToothTestDemo
//
//  Created by pg on 2016/12/22.
//  Copyright © 2016年 DZHFCompany. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^RotationBlock)(NSInteger buttonIndex);

#pragma mark -设置按钮
@interface ZJCustomButton : UIButton

@end

#pragma mark -设置手势
@interface ZJCustomGesture : UIGestureRecognizer

//记录手势最后一个改变的旋转角度
@property (nonatomic,assign) CGFloat rotation;

@end



#pragma mark -旋转视图
@interface ZJRotationView : UIView

/**
 按钮背景图
 */
@property (nonatomic,strong)UIColor *buttonBackColor;

/**
 按钮字号
 */
@property (nonatomic,assign)NSInteger fontSize;

/**
 按钮文字颜色
 */
@property (nonatomic,strong)UIColor *titleColor;


-(instancetype)initWithFrame:(CGRect)frame titles:(NSArray*)titlesArr images:(NSArray*)imagesArr clickBlock:(RotationBlock)rotaionBlock;
@end
