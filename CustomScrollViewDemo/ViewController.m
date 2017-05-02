//
//  ViewController.m
//  CustomScrollViewDemo
//
//  Created by 冯文秀 on 16/11/22.
//  Copyright © 2016年 冯文秀. All rights reserved.
//

#import "ViewController.h"
#import "WMShuffleFigure.h"
// 屏宽
#define KScreenWidth [UIScreen mainScreen].bounds.size.width
// 屏高
#define KScreenHeight [UIScreen mainScreen].bounds.size.height

@interface ViewController ()<WMShuffleFigureDelegate>

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    NSArray *imageArray = @[[UIImage imageNamed:@"dun"], [UIImage imageNamed:@"haqi"], [UIImage imageNamed:@"mom"]];
    WMShuffleFigure *shuffleView = [[WMShuffleFigure alloc]initWithFrame:CGRectMake(0, 0, KScreenWidth, 220)];
    shuffleView.imageArray = imageArray;
    shuffleView.delegate = self;
    shuffleView.time = 2;
    [shuffleView setPageImage:[UIImage imageNamed:@"wemart_shuffle_solid"] andCurrentPageImage:[UIImage imageNamed:@"wemart_shuffle_hollow"]];
    [self.view addSubview:shuffleView];

}

# pragma mark ---- 滚动视图 的代理方法 ----
- (void)shuffleView:(WMShuffleFigure *)shuffleView clickImageAtIndex:(NSInteger)index
{
    NSLog(@"滚动视图 图片数组 ---- %@", shuffleView.imageArray);
    NSLog(@"图片数组 下表 ---- %ld", index);

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
