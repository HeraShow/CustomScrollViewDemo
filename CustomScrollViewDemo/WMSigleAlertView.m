//
//  WMCartAlertView.m
//  Wemart
//
//  Created by 冯文秀 on 16/8/26.
//  Copyright © 2016年 冯文秀. All rights reserved.
//

#import "WMSigleAlertView.h"
#define WMLightFont(FontSize) [UIFont fontWithName:@"PingFangSC-Light" size:FontSize]
#define WMMediumFont(FontSize) [UIFont fontWithName:@"PingFangSC-Medium" size:FontSize]
#define ColorRGB(a,b,c,d) [UIColor colorWithRed:a/255.0 green:b/255.0 blue:c/255.0 alpha:d]


@interface WMSigleAlertView()
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, strong) UILabel * titleLabel;

@end

@implementation WMSigleAlertView

- (void)showAlertViewTitle:(NSString *)title bgView:(UIView *)bgView
{
    CGRect bounds = [title boundingRectWithSize:CGSizeMake(1000, 28) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObject:WMMediumFont(13.f) forKey:NSFontAttributeName] context:nil];
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, bounds.size.width + 30, 26)];
    self.titleLabel.center = bgView.center;
    self.titleLabel.backgroundColor = ColorRGB(0, 0, 0, 0.8);
    self.titleLabel.layer.cornerRadius = 5;
    self.titleLabel.clipsToBounds = YES;
    self.titleLabel.font = WMLightFont(14.f);
    self.titleLabel.textColor = [UIColor whiteColor];
    self.titleLabel.text = title;
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    [bgView addSubview:_titleLabel];
    
    [self shakeUpShow:_titleLabel];
    [self openTimeByRuntime];
}

#pragma mark --- 添加动画 ---
- (void)shakeUpShow:(UIView *)shakeView
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    NSMutableArray *mutableArray = [NSMutableArray array];
    NSValue *value1 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.1, 0.1, 1.0)];
    NSValue *value2 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.2, 1.2, 1.0)];
    NSValue *value3 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(0.9, 0.9, 1.0)];
    NSValue *value4 = [NSValue valueWithCATransform3D:CATransform3DMakeScale(1.0, 1.0, 1.0)];
    [mutableArray addObject:value1];
    [mutableArray addObject:value2];
    [mutableArray addObject:value3];
    [mutableArray addObject:value4];
    animation.duration = 0.5;
    animation.values = [mutableArray copy];
    [shakeView.layer addAnimation:animation forKey:nil];
}

#pragma mark --- 开启计时器 ---
- (void)openTimeByRuntime
{
    self.timer = [NSTimer timerWithTimeInterval:1.2 target:self selector:@selector(dismissViewAction) userInfo:nil repeats:NO];
    if (self.timer != nil) {
        [[NSRunLoop currentRunLoop] addTimer:_timer forMode:NSDefaultRunLoopMode];
    }
}

- (void)dismissViewAction
{
    if (_timer != nil) {
        [self.timer invalidate];
        self.timer = nil;
    }
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
    [UIView setAnimationDuration:1.4];
    [UIView setAnimationDelegate:self];
    self.titleLabel.hidden = YES;
    [self.titleLabel removeFromSuperview];
    [UIView commitAnimations];
}

@end
