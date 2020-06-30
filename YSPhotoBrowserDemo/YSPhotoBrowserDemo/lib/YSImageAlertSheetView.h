//
//  YSImageAlertSheetView.h
//
//  Created by YS on 2018/5/9.
//  Copyright © 2018年  All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDevice_Is_iPhoneX \
({BOOL isPhoneX = NO;\
if (@available(iOS 11.0, *)) {\
isPhoneX = [[UIApplication sharedApplication] keyWindow].safeAreaInsets.bottom > 0.0;\
}\
(isPhoneX);})

#define HomeIndicatorHeight (kDevice_Is_iPhoneX?34:0)

@class YSImageAlertSheetView;
typedef void(^AlertSheetBlock)(NSInteger alertSheetType ,NSString *alertSheetTitle ,UIImage *image);

@interface YSImageAlertSheetView : UIView

- (instancetype)initWithImage:(UIImage *)image andAlertSheetTitles:(NSArray <NSString *>*)alertSheetTitles alertSheetBlock:(AlertSheetBlock)alertSheetBlock;
+ (instancetype)imageAlertSheetViewWithImage:(UIImage *)image andAlertSheetTitles:(NSArray <NSString *>*)alertSheetTitles alertSheetBlock:(AlertSheetBlock)alertSheetBlock;

/**
 展示
 */
- (void)showAlertSheetView;
/**
 取消
 */
- (void)dismissAlertSheetView;
@end
