//
//  YSPhotoBrowser.h
//  YSPhotoBrowser
//
//  Created by Joe on 2018/4/9.
//  Copyright © 2018年 Joe. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YSPhotoItem.h"
//NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, YSPhotoBrowserDismissalStyle) {
    YSPhotoBrowserDismissalStyleRotation,
    YSPhotoBrowserDismissalStyleScale,
    YSPhotoBrowserDismissalStyleSlide,
    YSPhotoBrowserDismissalStyleNone
};

typedef NS_ENUM(NSUInteger, YSPhotoBrowserPageIndicatorStyle) {
    YSPhotoBrowserPageIndicatorStyleDot,
    YSPhotoBrowserPageIndicatorStyleText
};

typedef NS_ENUM(NSUInteger, YSPhotoBrowserImageLoadingStyle) {
    YSPhotoBrowserImageLoadingStyleIndeterminate,
    YSPhotoBrowserImageLoadingStyleDeterminate
};

typedef void(^YSPhotoBrowserAlertSheetBlock)(NSInteger imagePageIndex ,NSInteger alertSheetType,UIImage * image,NSString * imageUrl);
@protocol YSPhotoBrowserDelegate, YSImageLoaderManager;
@interface YSPhotoBrowser : UIViewController

/** diamiss方式 */
@property (nonatomic, assign) YSPhotoBrowserDismissalStyle dismissalStyle;

/** 分页显示；类型 */
@property (nonatomic, assign) YSPhotoBrowserPageIndicatorStyle pageindicatorStyle;

/** 图片加载样式 */
@property (nonatomic, assign) YSPhotoBrowserImageLoadingStyle loadingStyle;


/**
 图片浏览器的show方法

 @param photoItems 图片容器数组
 @param selectedIndex 当前图片的索引
 @param imageLongPressStyleTitles 点击图片选项的标题数组
 @param browserAlertSheetBlock 点击图片回调
 @return 图片浏览器
 */
+ (instancetype)showBrowserWithPhotoItems:(NSArray<YSPhotoItem *> *)photoItems selectedIndex:(NSUInteger)selectedIndex  imageLongPressStyleTitles:(NSArray <NSString *>*)imageLongPressStyleTitles browserAlertSheetBlock:(YSPhotoBrowserAlertSheetBlock)browserAlertSheetBlock;

/**
 创建图片浏览器的对象方法
 
 @param photoItems 图片容器数组
 @param selectedIndex 当前图片的索引
 @param imageLongPressStyleTitles 点击图片选项的标题数组
 @param browserAlertSheetBlock 点击图片回调
 @return 图片浏览器
 */
- (instancetype)initWithPhotoItems:(NSArray<YSPhotoItem *> *)photoItems selectedIndex:(NSUInteger)selectedIndex  imageLongPressStyleTitles:(NSArray <NSString *>*)imageLongPressStyleTitles browserAlertSheetBlock:(YSPhotoBrowserAlertSheetBlock)browserAlertSheetBlock;


/**
 设置网络图片加载器的类

 @param cls 图片加载代理的class
 */
+ (void)setImageLoaderManagerClass:(Class<YSImageLoaderManager>)cls;
@end

//NS_ASSUME_NONNULL_END

