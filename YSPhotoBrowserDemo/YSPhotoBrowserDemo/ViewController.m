//
//  ViewController.m
//  YSPhotoBrowserDemo
//
//  Created by YS on 2020/6/30.
//  Copyright © 2020 DuoMi-B. All rights reserved.
//

#import "ViewController.h"
#import "YSPhotoBrowser.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/FLAnimatedImageView+WebCache.h>

@interface ViewController ()
@property (nonatomic, strong) UIImageView *demo1;
@property (nonatomic, strong) UIImageView *demo2;
@property (nonatomic, strong) UIImageView *demo3;
@property (nonatomic, strong) FLAnimatedImageView *demo4;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIImageView *demo1 = [[UIImageView alloc] init];
    demo1.tag = 1;
    demo1.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 150);
    demo1.image = [UIImage imageNamed:@"car1"];
    demo1.userInteractionEnabled = YES;
    [self.view addSubview:demo1];
    self.demo1 = demo1;
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] init];
    [tap1 addTarget:self action:@selector(tap:)];
    [demo1 addGestureRecognizer:tap1];
    
    
    UIImageView *demo2 = [[UIImageView alloc] init];
    demo2.tag = 2;
    demo2.frame = CGRectMake(0, 160, [UIScreen mainScreen].bounds.size.width, 150);
    demo2.image = [UIImage imageNamed:@"car2"];
    demo2.userInteractionEnabled = YES;
    [self.view addSubview:demo2];
    self.demo2 = demo2;
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] init];
    [tap2 addTarget:self action:@selector(tap:)];
    [demo2 addGestureRecognizer:tap2];
    
    UIImageView *demo3 = [[UIImageView alloc] init];
    demo3.tag = 3;
    demo3.frame = CGRectMake(0, 320, [UIScreen mainScreen].bounds.size.width, 150);
    [demo3 sd_setImageWithURL:[NSURL URLWithString:@"http://pic1.win4000.com/wallpaper/2017-11-17/5a0e8fc38dcc3.jpg"] completed:nil];
    demo3.userInteractionEnabled = YES;
    [self.view addSubview:demo3];
    self.demo3 = demo3;
    UITapGestureRecognizer *tap3 = [[UITapGestureRecognizer alloc] init];
    [tap3 addTarget:self action:@selector(tap:)];
    [demo3 addGestureRecognizer:tap3];
    
    
    FLAnimatedImageView *demo4 = [[FLAnimatedImageView alloc] init];
    demo4.tag = 4;
    demo4.frame = CGRectMake(0, 480, [UIScreen mainScreen].bounds.size.width, 150);
    [demo4 sd_setImageWithURL:[NSURL URLWithString:@"http://b-ssl.duitang.com/uploads/item/201702/18/20170218161710_wiVcE.gif"] completed:nil];
    demo4.userInteractionEnabled = YES;
    [self.view addSubview:demo4];
    self.demo4 = demo4;
    UITapGestureRecognizer *tap4 = [[UITapGestureRecognizer alloc] init];
    [tap4 addTarget:self action:@selector(tap:)];
    [demo4 addGestureRecognizer:tap4];
    
}

- (void)tap:(UITapGestureRecognizer *)tap{
    YSPhotoItem *item1 = [[YSPhotoItem alloc] initWithSourceView:self.demo1 image:self.demo1.image];
    YSPhotoItem *item2 = [[YSPhotoItem alloc] initWithSourceView:self.demo2 image:self.demo2.image];
    YSPhotoItem *item3 = [[YSPhotoItem alloc] initWithSourceView:self.demo3 imageUrl:[NSURL URLWithString:@"http://pic1.win4000.com/wallpaper/2017-11-17/5a0e8fc38dcc3.jpg"]];
    
      YSPhotoItem *item4 = [[YSPhotoItem alloc] initWithSourceView:self.demo4 imageUrl:[NSURL URLWithString:@"http://b-ssl.duitang.com/uploads/item/201702/18/20170218161710_wiVcE.gif"]];
    
    [YSPhotoBrowser showBrowserWithPhotoItems:@[item1,item2,item3,item4] selectedIndex:tap.view.tag - 1 imageLongPressStyleTitles:@[@"保存图片",@"转发图片",@"取消"] browserAlertSheetBlock:^(NSInteger imagePageIndex, NSInteger alertSheetType, UIImage * _Nullable image, NSString * _Nullable imageUrl) {
          if (alertSheetType == 0) {
              NSLog(@"保存图片");
          }else if (alertSheetType == 1){
              NSLog(@"转发图片");
          }else{
              NSLog(@"取消");
          }
      }];
}

@end
