//
//  WMShuffleFigure.h
//  Wemart
//
//  Created by 冯文秀 on 16/7/18.
//  Copyright © 2016年 冯文秀. All rights reserved.
//

#import <UIKit/UIKit.h>
@class WMShuffleFigure;
typedef enum {
    PositionDefault,           // 默认值 == PositionBottomCenter
    PositionHide,
    PositionTopCenter,
    PositionBottomLeft,
    PositionBottomCenter,
    PositionBottomRight
} PageControlPosition;
//图片切换的方式
typedef enum {
    ChangeModeDefault,  //轮播滚动
    ChangeModeFade      //淡入淡出
} ChangeMode;


@protocol WMShuffleFigureDelegate <NSObject>

// 该方法用来处理图片的点击，返回图片在数组中的索引
- (void)shuffleView:(WMShuffleFigure *)shuffleView clickImageAtIndex:(NSInteger)index;
@end

@interface WMShuffleFigure : UIView<UIScrollViewDelegate>
// 设置图片的切换模式，默认为ChangeModeDefault
@property (nonatomic, assign) ChangeMode changeMode;

// 设置图片的内容模式，默认为UIViewContentModeScaleToFill
@property (nonatomic, assign) UIViewContentMode contentMode;

// 默认为PositionBottomCenter 只有一张图片时，pageControl隐藏
@property (nonatomic, assign) PageControlPosition pagePosition;

// 轮播的图片数组，可以是本地图片（UIImage，不能是图片名称）/网络路径 (支持网络gif图片，本地gif需做处理后传入)
@property (nonatomic, strong) NSArray *imageArray;

// 图片描述的字符串数组，应与图片顺序对应 默认是隐藏的
// 设置该属性，控件会显示;设置为nil或空数组，控件会隐藏
@property (nonatomic, strong) NSArray *describeArray;

// 每一页停留时间，默认为5s，最少2s 当设置的值小于2s时，则为默认值
@property (nonatomic, assign) NSTimeInterval time;

@property (nonatomic, weak) id<WMShuffleFigureDelegate> delegate;

// 开启定时器 默认已开启，调用该方法会重新开启
- (void)startTimer;

// 停止定时器  停止后，如果手动滚动图片，定时器会重新开启
- (void)stopTimer;


/**
 *  设置分页控件指示器的图片
 *  两个图片必须同时设置，否则设置无效
 *  不设置则为系统默认
 *
 *  @param pageImage    其他页码的图片
 *  @param currentImage 当前页码的图片
 */
- (void)setPageImage:(UIImage *)image andCurrentPageImage:(UIImage *)currentImage;

/**
 *  设置分页控件指示器的颜色
 *  不设置则为系统默认
 *
 *  @param color        其他页码的颜色
 *  @param currentColor 当前页码的颜色
 */
- (void)setPageColor:(UIColor *)color andCurrentPageColor:(UIColor *)currentColor;

@end
