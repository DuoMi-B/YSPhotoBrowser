//
//  YSPhotoScrollView.m
//  YSPhotoBrowser
//
//  Created by Joe on 2018/4/9.
//  Copyright © 2018年 Joe. All rights reserved.
//

#import "YSPhotoScrollView.h"
#import "YSPhotoItem.h"
#import "YSImageLoaderManager.h"

@interface YSProgressView ()<CAAnimationDelegate>

@property (nonatomic, assign) BOOL isSpinning;

@end

@implementation YSProgressView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        self.frame = frame;
        self.cornerRadius = 20;
        self.fillColor = [UIColor clearColor].CGColor;
        self.strokeColor = [UIColor whiteColor].CGColor;
        self.lineWidth = 4;
        self.lineCap = kCALineCapRound;
        self.strokeStart = 0;
        self.strokeEnd = 0.01;
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5].CGColor;
        
        UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(self.bounds, 2, 2) cornerRadius:20-2];
        self.path = path.CGPath;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification {
    if (self.isSpinning) {
        [self startSpin];
    }
}

- (void)startSpin {
    self.isSpinning = YES;
    [self spinWithAngle:M_PI];
}

- (void)spinWithAngle:(CGFloat)angle {
    self.strokeEnd = 0.33;
    CABasicAnimation *rotationAnimation;
    rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.toValue = @(M_PI-0.5);
    rotationAnimation.duration = 0.4;
    rotationAnimation.cumulative = YES;
    rotationAnimation.repeatCount = HUGE;
    [self addAnimation:rotationAnimation forKey:nil];
}

- (void)stopSpin {
    self.isSpinning = NO;
    [self removeAllAnimations];
}

@end

const CGFloat kBLPhotoViewPadding = 10;
const CGFloat kBLPhotoViewMaxScale = 3;
@interface YSPhotoScrollView ()<UIScrollViewDelegate,UIGestureRecognizerDelegate>

@property (nonatomic, strong, readwrite) FLAnimatedImageView *imageView;
@property (nonatomic, strong, readwrite) YSProgressView *progressView;
@property (nonatomic, strong, readwrite) YSPhotoItem *item;
@property (nonatomic, strong) id<YSImageLoaderManagerDelegate> imageLoaderManagerDelegate;

@end

@implementation YSPhotoScrollView

- (instancetype)initWithFrame:(CGRect)frame imageManagerDelegate:(id<YSImageLoaderManagerDelegate>)imageLoaderManagerDelegate {
    self = [super initWithFrame:frame];
    if (self) {
        self.bouncesZoom = YES;
        self.maximumZoomScale = kBLPhotoViewMaxScale;
        self.multipleTouchEnabled = YES;
        self.showsHorizontalScrollIndicator = YES;
        self.showsVerticalScrollIndicator = YES;
        self.delegate = self;
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        _imageView = [[FLAnimatedImageView alloc] init];
        _imageView.clipsToBounds = YES;
        [self addSubview:_imageView];
        [self resizeImageView];
        
        _progressView = [[YSProgressView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        _progressView.position = CGPointMake(frame.size.width/2, frame.size.height/2);
        _progressView.hidden = YES;
        [self.layer addSublayer:_progressView];
        
        _imageLoaderManagerDelegate = imageLoaderManagerDelegate;
    }
    return self;
}

- (void)setItem:(YSPhotoItem *)item determinate:(BOOL)determinate {
    _item = item;
    [_imageLoaderManagerDelegate cancelImageRequestForImageView:_imageView];
    if (item) {
        if (item.image) {
            _imageView.image = item.image;
            _item.finished = YES;
            [_progressView stopSpin];
            _progressView.hidden = YES;
            [self resizeImageView];
            return;
        }
        __weak typeof(self) wself = self;
        ProgressBlock progressBlock = nil;
        if (determinate) {
            progressBlock = ^(NSInteger receivedSize, NSInteger expectedSize) {
                __strong typeof(wself) sself = wself;
                double progress = (double)receivedSize / expectedSize;
                sself.progressView.hidden = NO;
                sself.progressView.strokeEnd = MAX(progress, 0.01);
            };
        } else {
            [_progressView startSpin];
        }
        _progressView.hidden = NO;
        
        _imageView.image = item.thumbImage;
        [_imageLoaderManagerDelegate setImageForImageView:_imageView withURL:item.imageUrl placeholder:item.thumbImage progress:progressBlock completion:^(UIImage *image, NSURL *url, BOOL finished, NSError *error) {
                    __strong typeof(wself) sself = wself;
                    if (finished) {
                        [sself resizeImageView];
                    }
                    [sself.progressView stopSpin];
                    sself.progressView.hidden = YES;
                    sself.item.finished = YES;
                }];
   

    } else {
        [_progressView stopSpin];
        _progressView.hidden = YES;
        _imageView.image = nil;
    }
    [self resizeImageView];
}

- (void)resizeImageView {
    if (_imageView.image) {
        CGSize imageSize = _imageView.image.size;
        CGFloat width = _imageView.frame.size.width;
        CGFloat height = width * (imageSize.height / imageSize.width);
        CGRect rect = CGRectMake(0, 0, width, height);
        _imageView.frame = rect;
        _imageView.contentMode = _item.sourceView.contentMode;
        // 如果图片过长
        if (height <= self.bounds.size.height) {
            _imageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
        } else {
            _imageView.center = CGPointMake(self.bounds.size.width/2, height/2);
        }
        
        // 如果图片过宽
        if (width / height > 2) {
            self.maximumZoomScale = self.bounds.size.height / height;
        }
    } else {
        CGFloat width = self.frame.size.width - 2 * kBLPhotoViewPadding;
        _imageView.frame = CGRectMake(0, 0, width, width * 2.0 / 3);
        _imageView.center = CGPointMake(self.bounds.size.width/2, self.bounds.size.height/2);
    }
    self.contentSize = _imageView.frame.size;
}

- (void)cancelCurrentImageLoad {
    [_imageLoaderManagerDelegate cancelImageRequestForImageView:_imageView];
    [_progressView stopSpin];
}

- (BOOL)isScrollViewOnTopOrBottom {
    CGPoint translation = [self.panGestureRecognizer translationInView:self];
    if (translation.y > 0 && self.contentOffset.y <= 0) {
        return YES;
    }
    CGFloat maxOffsetY = floor(self.contentSize.height - self.bounds.size.height);
    if (translation.y < 0 && self.contentOffset.y >= maxOffsetY) {
        return YES;
    }
    return NO;
}

#pragma mark - ScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return _imageView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width)?
    (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0.0;
    
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height)?
    (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0.0;
    
    _imageView.center = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX,
                                    scrollView.contentSize.height * 0.5 + offsetY);
}

#pragma mark - GestureRecognizerDelegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.panGestureRecognizer) {
        if (gestureRecognizer.state == UIGestureRecognizerStatePossible) {
            if ([self isScrollViewOnTopOrBottom]) {
                return NO;
            }
        }
    }
    return YES;
}

@end
