//
//  YSPhotoScrollView.h
//  YSPhotoBrowser
//
//  Created by Joe on 2018/4/9.
//  Copyright © 2018年 Joe. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface YSProgressView : CAShapeLayer

- (instancetype)initWithFrame:(CGRect)frame;
- (void)startSpin;
- (void)stopSpin;

@end

extern const CGFloat kBLPhotoViewPadding;
@protocol YSImageLoaderManagerDelegate;
@class YSPhotoItem;
@interface YSPhotoScrollView : UIScrollView

@property (nonatomic, strong, readonly) UIImageView *imageView;
@property (nonatomic, strong, readonly) YSProgressView *progressView;
@property (nonatomic, strong, readonly) YSPhotoItem *item;

- (instancetype)initWithFrame:(CGRect)frame imageManagerDelegate:(id<YSImageLoaderManagerDelegate>)imageLoaderManagerDelegate;
- (void)setItem:(YSPhotoItem *)item determinate:(BOOL)determinate;
- (void)resizeImageView;
- (void)cancelCurrentImageLoad;

@end


NS_ASSUME_NONNULL_END
