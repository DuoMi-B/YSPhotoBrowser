//
//  YSPhotoItem.m
//  YSPhotoBrowser
//
//  Created by Joe on 2018/4/9.
//  Copyright © 2018年 Joe. All rights reserved.
//

#import "YSPhotoItem.h"

@interface YSPhotoItem ()

@property (nonatomic, strong, readwrite) UIView *sourceView;
@property (nonatomic, strong, readwrite) UIImage *thumbImage;
@property (nonatomic, strong, readwrite) UIImage *image;
@property (nonatomic, strong, readwrite) NSURL *imageUrl;

@end

@implementation YSPhotoItem

- (instancetype)initWithSourceView:(UIView *__nullable)view
                        thumbImage:(UIImage *)image
                          imageUrl:(NSURL *)url {
    self = [super init];
    if (self) {
        
        if (view) {
            
            _sourceView = view;
        }else{
            UIImageView *imageview=[[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 0.01, 0.01)];
            imageview.center = CGPointMake([UIScreen mainScreen].bounds.size.width * 0.5, [UIScreen mainScreen].bounds.size.height * 0.5);
            [[[UIApplication sharedApplication] keyWindow] addSubview:imageview];
            _sourceView = imageview;
        }
        _thumbImage = image;
        _imageUrl = url;
    }
    return self;
}

- (instancetype)initWithSourceView:(UIImageView *__nullable)view
                          imageUrl:(NSURL *)url
{
    return [self initWithSourceView:view
                         thumbImage:view.image
                           imageUrl:url];
}

- (instancetype)initWithSourceView:(UIImageView *__nullable)view
                             image:(UIImage *)image {
    self = [super init];
    if (self) {
        _sourceView = view;
        _thumbImage = image;
        _imageUrl = nil;
        _image = image;
    }
    return self;
}

+ (instancetype)itemWithSourceView:(UIView *__nullable)view
                        thumbImage:(UIImage *)image
                          imageUrl:(NSURL *)url
{
    return [[YSPhotoItem alloc] initWithSourceView:view
                                        thumbImage:image
                                          imageUrl:url];
}

+ (instancetype)itemWithSourceView:(UIImageView *__nullable)view
                          imageUrl:(NSURL *)url
{
    return [[YSPhotoItem alloc] initWithSourceView:view
                                          imageUrl:url];
}

+ (instancetype)itemWithSourceView:(UIImageView *__nullable)view
                             image:(UIImage *)image
{
    return [[YSPhotoItem alloc] initWithSourceView:view
                                             image:image];
}

@end
