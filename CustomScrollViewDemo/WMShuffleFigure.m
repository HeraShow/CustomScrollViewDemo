//
//  WMShuffleFigure.m
//  Wemart
//
//  Created by 冯文秀 on 16/7/18.
//  Copyright © 2016年 冯文秀. All rights reserved.
//

#import "WMShuffleFigure.h"
#define DEFAULTTIME 5
#define HORMARGIN 10
#define VERMARGIN 5
@interface WMShuffleFigure()<UIScrollViewDelegate>
// 图片数组
@property (nonatomic, strong) NSMutableArray *images;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIImageView *currImageView;
// 滚动显示的imageView
@property (nonatomic, strong) UIImageView *otherImageView;
// 当前显示图片的索引
@property (nonatomic, assign) NSInteger currIndex;
// 将要显示图片的索引
@property (nonatomic, assign) NSInteger nextIndex;
// pageControl图片大小
@property (nonatomic, assign) CGSize pageImageSize;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation WMShuffleFigure
#pragma mark --- 由代码创建 ---
- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initSubView];
    }
    return self;
}

#pragma mark --- 由nib创建 ---
- (void)awakeFromNib {
    [self initSubView];
}

#pragma mark --- 初始化控件 ---
- (void)initSubView {
    [self addSubview:self.scrollView];
    [self addSubview:self.pageControl];
}
#pragma mark --- 宽高 ---
- (CGFloat)height {
    return self.scrollView.frame.size.height;
}
- (CGFloat)width {
    return self.scrollView.frame.size.width;
}

#pragma mark --- 懒加载 滚动视图 ---
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.pagingEnabled = YES;
        _scrollView.bounces = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        //添加手势监听图片的点击
        [_scrollView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageClick)]];
        _currImageView = [[UIImageView alloc] init];
        _currImageView.clipsToBounds = YES;
        [_scrollView addSubview:_currImageView];
        _otherImageView = [[UIImageView alloc] init];
        _otherImageView.clipsToBounds = YES;
        [_scrollView addSubview:_otherImageView];
    }
    return _scrollView;
}

#pragma mark --- 图片点击事件 ---
- (void)imageClick {
    if ([_delegate respondsToSelector:@selector(shuffleView:clickImageAtIndex:)]){
        [_delegate shuffleView:self clickImageAtIndex:self.currIndex];
    }
}

#pragma mark --- 懒加载 分页视图 ---
- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.userInteractionEnabled = NO;
    }
    return _pageControl;
}


#pragma mark --- 图片的内容模式 ---
- (void)setContentMode:(UIViewContentMode)contentMode {
    _contentMode = contentMode;
    _currImageView.contentMode = contentMode;
    _otherImageView.contentMode = contentMode;
}

#pragma mark --- 图片数组 ---
- (void)setImageArray:(NSArray *)imageArray{
    if (!imageArray.count) return;
    _imageArray = imageArray;
    _images = [NSMutableArray array];
    for (int i = 0; i < imageArray.count; i++) {
        if ([imageArray[i] isKindOfClass:[UIImage class]]) {
            [_images addObject:imageArray[i]];
        }
    }
    //防止在滚动过程中重新给imageArray赋值时报错
    if (_currIndex >= _images.count)_currIndex = _images.count - 1;
    self.currImageView.image = _images[_currIndex];
    self.pageControl.numberOfPages = _images.count;
    [self layoutSubviews];
}

#pragma mark --- scrollView的contentSize ---
- (void)setScrollViewContentSize {
    if (_images.count > 1) {
        self.scrollView.contentSize = CGSizeMake(self.width * 5, 0);
        self.scrollView.contentOffset = CGPointMake(self.width * 2, 0);
        self.currImageView.frame = CGRectMake(self.width * 2, 0, self.width, self.height);
        if (_changeMode == ChangeModeFade) {
            //淡入淡出模式，两个imageView都在同一位置，改变透明度就可以了
            _currImageView.frame = CGRectMake(0, 0, self.width, self.height);
            _otherImageView.frame = self.currImageView.frame;
            _otherImageView.alpha = 0;
            [self insertSubview:self.currImageView atIndex:0];
            [self insertSubview:self.otherImageView atIndex:1];
        }

        [self startTimer];
    }
    else {
        //只要一张图片时，scrollview不可滚动，且关闭定时器
        self.scrollView.contentSize = CGSizeZero;
        self.scrollView.contentOffset = CGPointZero;
        self.currImageView.frame = CGRectMake(0, 0, self.width, self.height);
        [self stopTimer];
    }
}

#pragma mark --- pageControl的指示器图片 ---
- (void)setPageImage:(UIImage *)image andCurrentPageImage:(UIImage *)currentImage {
    if (!image || !currentImage) return;
    self.pageImageSize = image.size;
    [self.pageControl setValue:currentImage forKey:@"_currentPageImage"];
    [self.pageControl setValue:image forKey:@"_pageImage"];
}

#pragma mark --- pageControl的指示器颜色 ---
- (void)setPageColor:(UIColor *)color andCurrentPageColor:(UIColor *)currentColor {
    _pageControl.pageIndicatorTintColor = color;
    _pageControl.currentPageIndicatorTintColor = currentColor;
}

#pragma mark --- pageControl的位置 ---
- (void)setPagePosition:(PageControlPosition)pagePosition {
    _pagePosition = pagePosition;
    _pageControl.hidden = (_pagePosition == PositionHide) || (_imageArray.count == 1);
    if (_pageControl.hidden) return;
    
    CGSize size;
    if (!_pageImageSize.width) {//没有设置图片，系统原有样式
        size = [_pageControl sizeForNumberOfPages:_pageControl.numberOfPages];
        size.height = 8;
    }
    else {//设置图片了
        size = CGSizeMake(10 * (_pageControl.numberOfPages * 2 - 1), 10);
    }
    _pageControl.frame = CGRectMake(0, 0, size.width, size.height);

    CGFloat centerY = self.height - size.height * 0.5 - VERMARGIN;
    CGFloat pointY = self.height - size.height - VERMARGIN;
    
    if (_pagePosition == PositionDefault || _pagePosition == PositionBottomCenter)
        _pageControl.center = CGPointMake(self.width * 0.5, centerY);
    else if (_pagePosition == PositionTopCenter)
        _pageControl.center = CGPointMake(self.width * 0.5, size.height * 0.5 + VERMARGIN);
    else if (_pagePosition == PositionBottomLeft)
        _pageControl.frame = CGRectMake(HORMARGIN, pointY, size.width, size.height);
    else
        _pageControl.frame = CGRectMake(self.width - HORMARGIN - size.width, pointY, size.width, size.height);
}

#pragma mark --- 定时器时间 ---
- (void)setTime:(NSTimeInterval)time {
    _time = time;
    [self startTimer];
}

#pragma mark --- 定时器 ---
- (void)startTimer {
    //如果只有一张图片，则直接返回，不开启定时器
    if (_images.count <= 1) return;
    //如果定时器已开启，先停止再重新开启
    if (self.timer) [self stopTimer];
    self.timer = [NSTimer timerWithTimeInterval:_time < 2? DEFAULTTIME: _time target:self selector:@selector(nextPage) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}
#pragma mark --- 关闭定时器 并置空 ---
- (void)stopTimer {
    [self.timer invalidate];
    self.timer = nil; // 销毁定时器
}
#pragma mark --- 开启定时器 ---
- (void)nextPage {
    if (_changeMode == ChangeModeFade) {
        //淡入淡出模式，不需要修改scrollview偏移量，改变两张图片的透明度即可
        self.nextIndex = (self.currIndex + 1) % _images.count;
        self.otherImageView.image = _images[_nextIndex];
        
        [UIView animateWithDuration:1.2 animations:^{
            self.currImageView.alpha = 0;
            self.otherImageView.alpha = 1;
            self.pageControl.currentPage = _nextIndex;
        } completion:^(BOOL finished) {
            [self changeToNext];
        }];
    }
    else{
        [self.scrollView setContentOffset:CGPointMake(self.width * 3, 0) animated:YES];
    }
}

#pragma mark --- 布局子控件 ---
- (void)layoutSubviews {
    [super layoutSubviews];
    //有导航控制器时，会默认在scrollview上方添加64的内边距，这里强制设置为0
    _scrollView.contentInset = UIEdgeInsetsZero;
    _scrollView.frame = self.bounds;
    //重新计算pageControl的位置
    self.pagePosition = self.pagePosition;
    [self setScrollViewContentSize];
}


#pragma mark --- 图片滚动过半时就修改当前页码 ---
- (void)changeCurrentPageWithOffset:(CGFloat)offsetX {
    if (offsetX < self.width * 1.5) {
        NSInteger index = self.currIndex - 1;
        if (index < 0) index = self.images.count - 1;
        _pageControl.currentPage = index;
    } else if (offsetX > self.width * 2.5){
        _pageControl.currentPage = (self.currIndex + 1) % self.images.count;
    } else {
        _pageControl.currentPage = self.currIndex;
    }
}

#pragma mark --- UIScrollViewDelegate ---
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (CGSizeEqualToSize(CGSizeZero, scrollView.contentSize)) return;
    CGFloat offsetX = scrollView.contentOffset.x;
    //滚动过程中改变pageControl的当前页码
    [self changeCurrentPageWithOffset:offsetX];
    //向右滚动
    if (offsetX < self.width * 2) {
        if (_changeMode == ChangeModeFade) {
            self.currImageView.alpha = offsetX / self.width - 1;
            self.otherImageView.alpha = 2 - offsetX / self.width;
        }
        else{
            self.otherImageView.frame = CGRectMake(self.width, 0, self.width, self.height);
        }
        self.nextIndex = self.currIndex - 1;
        if (self.nextIndex < 0) self.nextIndex = _images.count - 1;
        self.otherImageView.image = self.images[self.nextIndex];
        if (offsetX <= self.width) [self changeToNext];
        //向左滚动
    }
    else if (offsetX > self.width * 2){
        if (_changeMode == ChangeModeFade) {
            self.otherImageView.alpha = offsetX / self.width - 2;
            self.currImageView.alpha = 3 - offsetX / self.width;
        }
        else {
        self.otherImageView.frame = CGRectMake(CGRectGetMaxX(_currImageView.frame), 0, self.width, self.height);
        }
        self.nextIndex = (self.currIndex + 1) % _images.count;
        self.otherImageView.image = self.images[self.nextIndex];
        if (offsetX >= self.width * 3) [self changeToNext];
    }
}
#pragma mark --- 切换到下一张图片 ---
- (void)changeToNext {
    if (_changeMode == ChangeModeFade) {
        self.currImageView.alpha = 1;
        self.otherImageView.alpha = 0;
    }
    self.currImageView.image = self.otherImageView.image;
    self.scrollView.contentOffset = CGPointMake(self.width * 2, 0);
    [self.scrollView layoutSubviews];
    self.currIndex = self.nextIndex;
    self.pageControl.currentPage = self.currIndex;
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopTimer];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    [self startTimer];
}

#pragma mark --- 修复滚动过快导致分页异常的bug ---
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    CGPoint pointInSelf = [_scrollView convertPoint:_otherImageView.frame.origin toView:self];
    if (ABS(pointInSelf.x) != self.width) {
        CGFloat offsetX = _scrollView.contentOffset.x + pointInSelf.x;
        [self.scrollView setContentOffset:CGPointMake(offsetX, 0) animated:YES];
    }
}
@end
