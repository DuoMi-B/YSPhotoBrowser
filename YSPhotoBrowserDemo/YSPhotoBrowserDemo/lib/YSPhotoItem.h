//
//  YSPhotoItem.h
//  YSPhotoBrowser
//
//  Created by Joe on 2018/4/9.
//  Copyright © 2018年 Joe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSPhotoItem : NSObject

@property (nonatomic, strong, readonly) UIView *sourceView;
@property (nonatomic, strong, readonly) UIImage *thumbImage;
@property (nonatomic, strong, readonly) UIImage *image;
@property (nonatomic, strong, readonly) NSURL *imageUrl;
@property (nonatomic, assign) BOOL finished;


/**
 带有原图片、缩略图image、网络图片url的类方法

 @param view 图片原试图
 @param image 缩略图image
 @param url 网络图片url
 @return YSPhotoItem
 */
- (instancetype)initWithSourceView:(UIView *__nullable)view
                        thumbImage:(UIImage *)image
                          imageUrl:(NSURL *)url;
/**
 带有原图片、网络图片url的对象方法
 
 @param view 图片原试图
 @param url 网络图片url
 @return YSPhotoItem
 */
- (instancetype)initWithSourceView:(UIImageView *__nullable)view
                          imageUrl:(NSURL *)url;
/**
 带有原图片、缩略图image的对象方法
 
 @param view 图片原试图
 @param image 缩略图image
 @return YSPhotoItem
 */
- (instancetype)initWithSourceView:(UIImageView *__nullable)view
                             image:(UIImage *)image;

/**
 带有原图片、缩略图image、网络图片url的类方法
 
 @param view 图片原试图
 @param image 缩略图image
 @param url 网络图片url
 @return YSPhotoItem
 */
+ (instancetype)itemWithSourceView:(UIView *__nullable)view
                        thumbImage:(UIImage *)image
                          imageUrl:(NSURL *)url;

/**
 带有原图片、网络图片url的类方法
 
 @param view 图片原试图
 @param url 网络图片url
 @return YSPhotoItem
 */
+ (instancetype)itemWithSourceView:(UIImageView *__nullable)view
                          imageUrl:(NSURL *)url;

/**
 带有原图片、缩略图image的类方法
 
 @param view 图片原试图
 @param image 缩略图image
 @return YSPhotoItem
 */
+ (instancetype)itemWithSourceView:(UIImageView *__nullable)view
                             image:(UIImage *)image;

@end

NS_ASSUME_NONNULL_END
