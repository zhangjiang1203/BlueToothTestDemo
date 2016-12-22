//
//  ZJRotationView.m
//  BlueToothTestDemo
//
//  Created by pg on 2016/12/22.
//  Copyright © 2016年 DZHFCompany. All rights reserved.
//

#import "ZJRotationView.h"
#import <UIKit/UIGestureRecognizerSubclass.h>
#define KImagePercentage 0.7
#define KButtonW 80
@implementation ZJCustomButton

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.imageView.contentMode = UIViewContentModeScaleAspectFit;
        self.titleLabel.textAlignment = NSTextAlignmentCenter;
    }
    return self;
}


-(CGRect)imageRectForContentRect:(CGRect)contentRect{
    CGFloat imageH = contentRect.size.height*KImagePercentage;
    CGFloat imageW = contentRect.size.width;
    return CGRectMake(0, 0, imageW, imageH);
}


-(CGRect)titleRectForContentRect:(CGRect)contentRect{
    CGFloat titleY = contentRect.size.height*KImagePercentage+5;
    CGFloat titleH = contentRect.size.height *(1-KImagePercentage)-5;
    CGFloat titleW = contentRect.size.width;
    return CGRectMake(0, titleY, titleW, titleH);
    
}

@end

#pragma mark -手势

@implementation ZJCustomGesture

-(void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if ([self state] == UIGestureRecognizerStatePossible    ){
        [self setState:UIGestureRecognizerStateBegan];
    }else{
        [self setState:UIGestureRecognizerStateChanged];
    }
    //记录位置
    UITouch *touch = [touches anyObject];
    //获取触摸的view
    UIView *view = [self view];
    CGPoint center = CGPointMake(CGRectGetMidX([view bounds]), CGRectGetMidY([view bounds]));
    CGPoint currentPoint = [touch locationInView:view];
    CGPoint previousPoint = [touch previousLocationInView:view];
    //根据反正切函数计算角度
    CGFloat angle = atan2f(currentPoint.y - center.y, currentPoint.x - center.x) - atan2f(previousPoint.y - center.y, previousPoint.x - center.x);
    //给属性赋值，记录每次移动的时候偏转的角度 通过角度的累加实现旋转效果
    self.rotation = angle;
}

-(void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    if ([self state] == UIGestureRecognizerStateChanged) {
        [self setState:UIGestureRecognizerStateEnded];
    }else{
        [self setState:UIGestureRecognizerStateFailed];
    }
}

-(void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self setState:UIGestureRecognizerStateFailed];
}
@end


@interface ZJRotationView ()
@property (strong,nonatomic)NSArray *imagesArr;
@property (strong,nonatomic)NSArray *titlesArr;
@property (strong,nonatomic)NSMutableArray *buttonsArr;
@property (copy,nonatomic)RotationBlock rotationBlock;
@property (nonatomic,assign) CGFloat rotationAngle;//旋转的弧度

@end

@implementation ZJRotationView

-(instancetype)initWithFrame:(CGRect)frame titles:(NSArray *)titlesArr images:(NSArray *)imagesArr clickBlock:(RotationBlock)rotaionBlock{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = YES;
        self.layer.contents = (__bridge id)[UIImage imageNamed:@"home_center_bg"].CGImage;
        self.buttonsArr = [NSMutableArray array];
        self.layer.masksToBounds = YES;
        self.layer.cornerRadius = frame.size.width/2.0;
        self.imagesArr = imagesArr;
        self.titlesArr = titlesArr;
        self.rotationBlock = rotaionBlock;
        [self setMyRotationButtons];

        [self addGestureRecognizer:[[ZJCustomGesture alloc]initWithTarget:self action:@selector(changeButtonTransform:)]];
    }
    return self;
}

-(void)setMyRotationButtons{
    //每个按钮的偏移角度
    NSInteger count = _imagesArr.count;
    CGFloat corner = -M_PI * 2.0 / count;
    //旋转半径
    CGFloat r = (self.frame.size.width -10 - KButtonW)/2.0;
    CGFloat x = (self.frame.size.width-10)/2.0;
    CGFloat y = (self.frame.size.width-10)/2.0;
    
    for (int i = 0; i < count; i++) {
        ZJCustomButton *cusButton = [[ZJCustomButton alloc] init];
        cusButton.bounds = CGRectMake(0, 0, KButtonW, KButtonW);
        cusButton.layer.masksToBounds = YES;
        cusButton.layer.cornerRadius = KButtonW/2;
        CGFloat num = (i + 0.5) * 1.0;
        cusButton.center = CGPointMake(x + r *cos(corner*num)+3, y + r * sin(corner*num)+3);
        cusButton.tag = i+1;
        cusButton.titleLabel.font = [UIFont systemFontOfSize:self.fontSize];
        [cusButton setTitle:_titlesArr[i] forState:UIControlStateNormal];
        [cusButton setImage:[UIImage imageNamed:_imagesArr[i]] forState:UIControlStateNormal];
        [cusButton addTarget:self action:@selector(rotationViewClickAction:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:cusButton];
        [self.buttonsArr addObject:cusButton];
    }
}

#pragma mark -
-(void)changeButtonTransform:(ZJCustomGesture*)reco{
    switch (reco.state) {
        case UIGestureRecognizerStateBegan:
            break;
        case UIGestureRecognizerStateChanged:
        {
            self.rotationAngle += reco.rotation;
            [UIView animateWithDuration:.25 animations:^{
                self.transform = CGAffineTransformMakeRotation(self.rotationAngle+reco.rotation);
                for (UIButton *btn in _buttonsArr) {
                    btn.transform = CGAffineTransformMakeRotation(-(self.rotationAngle+reco.rotation));
                }
            }];
        }
            break;
        case UIGestureRecognizerStateEnded:
        {
            int num = self.rotationAngle/(M_PI/3);
            int last = ((int)(self.rotationAngle*(180/M_PI)))%(60);
            if (abs(last) >= 30) {
                [UIView animateWithDuration:.25 animations:^{
                    self.transform = CGAffineTransformMakeRotation(M_PI/3*(last>0?(num+1):(num-1)));
                    for (UIButton *btn in _buttonsArr) {
                        btn.transform = CGAffineTransformMakeRotation(-(M_PI/3*(last>0?(num+1):(num-1))));
                    }
                    self.rotationAngle = (M_PI/3*(last>0?(num+1):(num-1)));
                    NSLog(@"当前旋转的角度==%.4f",self.rotationAngle*(180/M_PI));
                }];
            }else{
                [UIView animateWithDuration:.25 animations:^{
                    self.transform = CGAffineTransformMakeRotation(M_PI/3*num);
                    for (UIButton *btn in _buttonsArr) {
                        btn.transform = CGAffineTransformMakeRotation(-(M_PI/3)*num);
                    }
                }];
                //保存偏转角度
                self.rotationAngle = M_PI/3*num;
            }
        }
            break;
        default:
            break;
    }
}
#pragma mark - 按钮触发事件
-(void)rotationViewClickAction:(UIButton*)sender{
    self.rotationBlock ? self.rotationBlock(sender.tag):nil;
}

-(NSInteger)fontSize{
    if (_fontSize == 0) {
        _fontSize = 13;
    }
    return _fontSize;
}
@end
