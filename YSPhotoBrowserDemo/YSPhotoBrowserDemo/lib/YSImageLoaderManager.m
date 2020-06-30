//
//  YSImageLoaderManager.m
//  YSPhotoBrowser
//
//  Created by YS on 2018/5/9.
//  Copyright © 2018年 Joe. All rights reserved.
//

#import "YSImageLoaderManager.h"
#import <SDWebImage/UIView+WebCache.h>


@implementation YSImageLoaderManager

@end

/**
 SDWebImage
 */
@implementation BLSDImageLoader

- (void)setImageForImageView:(UIImageView *)imageView
                     withURL:(NSURL *)imageURL
                 placeholder:(UIImage *)placeholder
                    progress:(ProgressBlock)progress
                  completion:(CompletionBlock)completion
{

    SDWebImageOptions options = 1;
    
    [imageView sd_setImageWithURL:imageURL placeholderImage:placeholder options:options progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        if (progress) {
            progress(receivedSize, expectedSize);
        }
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        if (completion) {
            completion(image, imageURL, !error, error);
        }
    }];
}

- (void)cancelImageRequestForImageView:(UIImageView *)imageView {
    [imageView sd_cancelCurrentImageLoad];
}

- (UIImage *)imageFromMemoryForURL:(NSURL *)url {
    SDWebImageManager *manager = [SDWebImageManager sharedManager];
    NSString *key = [manager cacheKeyForURL:url];
    return [(SDImageCache *)manager.imageCache imageFromMemoryCacheForKey:key];
}

@end

