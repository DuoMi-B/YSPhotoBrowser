//
//  YSImageLoaderManager.h
//  YSPhotoBrowser
//
//  Created by Joe on 2018/4/9.
//  Copyright © 2018年 Joe. All rights reserved.
//

#import <UIKit/UIKit.h>

#if __has_include(<SDWebImage/SDWebImageManager.h>)
#import <SDWebImage/UIImageView+WebCache.h>
#import <SDWebImage/SDWebImageManager.h>
#import <SDWebImage/FLAnimatedImageView+WebCache.h>
#import <SDWebImage/UIView+WebCache.h>
#else
#import "UIImageView+WebCache.h"
#import "SDWebImageManager.h"
#import "FLAnimatedImageView+WebCache.h"
#import "UIView+WebCache.h"
#endif

typedef void (^ProgressBlock)(NSInteger receivedSize, NSInteger expectedSize);
typedef void (^CompletionBlock)(UIImage * _Nullable image, NSURL * _Nullable url, BOOL success, NSError * _Nullable error);

@protocol YSImageLoaderManagerDelegate <NSObject>

- (void)setImageForImageView:(nullable UIImageView *)imageView
                     withURL:(nullable NSURL *)imageURL
                 placeholder:(nullable UIImage *)placeholder
                    progress:(nullable ProgressBlock)progress
                  completion:(nullable CompletionBlock)completion;

- (void)cancelImageRequestForImageView:(nullable UIImageView *)imageView;

- (UIImage *_Nullable)imageFromMemoryForURL:(nullable NSURL *)url;

@end

@interface YSImageLoaderManager:NSObject

@end


@interface BLSDImageLoader : NSObject<YSImageLoaderManagerDelegate>

@end
