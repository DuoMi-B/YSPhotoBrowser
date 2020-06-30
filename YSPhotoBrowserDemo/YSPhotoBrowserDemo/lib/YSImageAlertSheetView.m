//
//  YSImageAlertSheetView.m
//
//  Created by YS on 2018/5/9.
//  Copyright © 2018年  All rights reserved.
//

#import "YSImageAlertSheetView.h"

#define BtnHeight 46 //每个按钮的高度
#define CancleMargin 8 //取消按钮上面的间隔
#define AlertSheetColor(r, g, b) [UIColor colorWithRed:(r/255.0) green:(g/255.0) blue:(b/255.0) alpha:1.0]
#define BGColor AlertSheetColor(237,240,242) //背景色
#define SeparatorColor AlertSheetColor(226, 226, 226) //分割线颜色
#define normalImage [self imageWithColor:AlertSheetColor(255,255,255)] //普通下的图片
#define highImage [self imageWithColor:AlertSheetColor(242,242,242)] //高亮的图片
#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define HeitiLight(f) [UIFont fontWithName:@"STHeitiSC-Light" size:f]

@interface YSImageAlertSheetView()
{
    int _tag;
}
@property (nonatomic, weak) YSImageAlertSheetView *alertSheetView;
@property (nonatomic, weak) UIView *sheetView;
@property (nonatomic, weak) UIImage *image;
@property (nonatomic, copy) AlertSheetBlock alertSheetBlock;
@property (nonatomic, strong) NSArray <NSString *> *alertSheetTitles;
@end
@implementation YSImageAlertSheetView
+ (instancetype)imageAlertSheetViewWithImage:(UIImage *)image andAlertSheetTitles:(NSArray <NSString *>*)alertSheetTitles alertSheetBlock:(AlertSheetBlock)alertSheetBlock{
    return [[YSImageAlertSheetView alloc] initWithImage:image andAlertSheetTitles:alertSheetTitles alertSheetBlock:alertSheetBlock];
}
- (instancetype)initWithImage:(UIImage *)image andAlertSheetTitles:(NSArray <NSString *>*)alertSheetTitles alertSheetBlock:(AlertSheetBlock)alertSheetBlock{
    YSImageAlertSheetView *alertSheetView = [self init];
    alertSheetView.alertSheetView = alertSheetView;
    alertSheetView.alertSheetBlock = alertSheetBlock;
    alertSheetView.alertSheetTitles = alertSheetTitles;
    alertSheetView.image = image;
    //黑色遮盖
    alertSheetView.frame = [UIScreen mainScreen].bounds;
    alertSheetView.backgroundColor = [UIColor blackColor];
    [[[UIApplication sharedApplication] keyWindow] addSubview:alertSheetView];
    alertSheetView.alpha = 0.0;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissAlertSheetView)];
    [alertSheetView addGestureRecognizer:tap];
    
    // sheet
    UIView *sheetView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0)];
    sheetView.backgroundColor = BGColor;
    sheetView.alpha = 0.9;
    [[[UIApplication sharedApplication] keyWindow] addSubview:sheetView];
    alertSheetView.sheetView = sheetView;
    sheetView.hidden = YES;
    
    _tag = 1;
    for (NSString *alertSheetTitle in alertSheetTitles) {
        if ([alertSheetTitle isEqual:alertSheetTitles.lastObject]) {
            break;
        }
        [self setupBtnWithTitle:alertSheetTitle];
    }
    
    CGRect sheetViewF = sheetView.frame;
    sheetViewF.size.height = BtnHeight * _tag + CancleMargin+HomeIndicatorHeight;
    sheetView.frame = sheetViewF;
    
    // 取消按钮
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, sheetView.frame.size.height - BtnHeight-HomeIndicatorHeight, ScreenWidth, BtnHeight)];
    [btn setBackgroundImage:normalImage forState:UIControlStateNormal];
    [btn setBackgroundImage:highImage forState:UIControlStateHighlighted];
    [btn setTitle:alertSheetTitles.lastObject forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleLabel.font = HeitiLight(17);
    btn.tag = alertSheetTitles.count - 1;
    [btn addTarget:self action:@selector(sheetBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [alertSheetView.sheetView addSubview:btn];
    
    return alertSheetView;
}

- (void)showAlertSheetView{
    self.sheetView.hidden = NO;
    
    CGRect sheetViewF = self.sheetView.frame;
    sheetViewF.origin.y = ScreenHeight;
    self.sheetView.frame = sheetViewF;
    
    CGRect newSheetViewF = self.sheetView.frame;
    newSheetViewF.origin.y = ScreenHeight - self.sheetView.frame.size.height;
    
    [UIView animateWithDuration:0.3 animations:^{
        self.sheetView.frame = newSheetViewF;
        self.alertSheetView.alpha = 0.3;
    }];
}

- (void)dismissAlertSheetView{
    CGRect sheetViewF = self.sheetView.frame;
    sheetViewF.origin.y = ScreenHeight;
    
    [UIView animateWithDuration:0.2 animations:^{
        self.sheetView.frame = sheetViewF;
        self.alertSheetView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self.alertSheetView removeFromSuperview];
        [self.sheetView removeFromSuperview];
        self.alertSheetBlock = nil;
    }];
}


/**
 创建每个选项
 
 @param title 选项展示名
 */
- (void)setupBtnWithTitle:(NSString *)title{
    // 创建按钮
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, BtnHeight * (_tag - 1) , ScreenWidth, BtnHeight)];
    [btn setBackgroundImage:normalImage forState:UIControlStateNormal];
    [btn setBackgroundImage:highImage forState:UIControlStateHighlighted];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    btn.titleLabel.font = HeitiLight(17);
    btn.tag = _tag - 1;
    [btn addTarget:self action:@selector(sheetBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.sheetView addSubview:btn];
    
    // 最上面画分割线
    UIView *line = [[UIView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 0.5)];
    line.backgroundColor = SeparatorColor;
    [btn addSubview:line];
    
    _tag ++;
}


- (void)sheetBtnClick:(UIButton *)btn{
    [self dismissAlertSheetView];
//    if (btn.tag == self.alertSheetTitles.count - 1) {
//        return;
//    }
    if (self.alertSheetBlock) {
        self.alertSheetBlock(btn.tag,self.alertSheetTitles[btn.tag],self.image);
    }
}


/**
 根据颜色生成图片

 @param color 颜色

 @return 图片
 */

-(UIImage *)imageWithColor:(UIColor *)color{
    
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
