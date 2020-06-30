//
//  YSPhotoBrowser.m
//  YSPhotoBrowser
//
//  Created by Joe on 2018/4/9.
//  Copyright © 2018年 Joe. All rights reserved.
//

#import "YSPhotoBrowser.h"
#import "YSPhotoScrollView.h"
#import "YSImageLoaderManager.h"
#import "YSImageAlertSheetView.h"

#define PAGE_INDEX_COLOR(args) [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:args]
static const NSTimeInterval kAnimationDuration = 0.3;
static Class imageLoaderManagerDelegateClass = nil;

@interface YSPhotoBrowser () <UIScrollViewDelegate, UIViewControllerTransitioningDelegate, CAAnimationDelegate> {
    CGPoint _startLocation;
}
/** scrollView  */
@property (nonatomic, strong) UIScrollView *scrollView;
/** photoItem数组  */
@property (nonatomic, strong) NSMutableArray *photoItems;
/** 复用Item数组  */
@property (nonatomic, strong) NSMutableSet *reusableItemViews;
/** 可视Item数组  */
@property (nonatomic, strong) NSMutableArray *visibleItemViews;
/** 当前索引  */
@property (nonatomic, assign) NSUInteger currentPage;
/** 背景view  */
@property (nonatomic, strong) UIImageView *backgroundView;
/** pageControl  */
@property (nonatomic, strong) UIPageControl *pageControl;
/** 图片索引lab  */
@property (nonatomic, strong) UILabel *pageLabel;
@property (nonatomic, assign) BOOL presented;
/** 图片加载代理  */
@property (nonatomic, strong) id<YSImageLoaderManagerDelegate> imageLoaderManagerDelegate;
/** YSImageAlertSheetView的标题数组  */
@property (nonatomic, strong) NSArray<NSString *> *imageLongPressStyleTitles;
/** YSImageAlertSheetView的回调  */
@property (nonatomic, copy) YSPhotoBrowserAlertSheetBlock browserAlertSheetBlock;

@end

@implementation YSPhotoBrowser

#pragma mark - 生命周期
- (instancetype)init {
    NSAssert(NO, @"用 initWithMediaItems: 代替");
    return nil;
}
+ (instancetype)showBrowserWithPhotoItems:(NSArray<YSPhotoItem *> *)photoItems selectedIndex:(NSUInteger)selectedIndex  imageLongPressStyleTitles:(NSArray <NSString *>*)imageLongPressStyleTitles browserAlertSheetBlock:(YSPhotoBrowserAlertSheetBlock)browserAlertSheetBlock{
    YSPhotoBrowser *browser = [[YSPhotoBrowser alloc] initWithPhotoItems:photoItems selectedIndex:selectedIndex imageLongPressStyleTitles:imageLongPressStyleTitles  browserAlertSheetBlock:browserAlertSheetBlock];
    [browser showFromViewController];
    return browser;
}

- (instancetype)initWithPhotoItems:(NSArray<YSPhotoItem *> *)photoItems selectedIndex:(NSUInteger)selectedIndex  imageLongPressStyleTitles:(NSArray <NSString *>*)imageLongPressStyleTitles browserAlertSheetBlock:(YSPhotoBrowserAlertSheetBlock)browserAlertSheetBlock {
    self = [super init];
    if (self) {
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        
        _photoItems = [NSMutableArray arrayWithArray:photoItems];
        _currentPage = selectedIndex;
        //如果构造时没有制定样式，默认为以下样式
        _dismissalStyle = YSPhotoBrowserDismissalStyleScale;
        _pageindicatorStyle = YSPhotoBrowserPageIndicatorStyleText;
        _loadingStyle = YSPhotoBrowserImageLoadingStyleDeterminate;
        _imageLongPressStyleTitles = imageLongPressStyleTitles;
        _browserAlertSheetBlock = browserAlertSheetBlock;
        
        _reusableItemViews = [[NSMutableSet alloc] init];
        _visibleItemViews = [[NSMutableArray alloc] init];
        
        if (imageLoaderManagerDelegateClass == nil) {
            imageLoaderManagerDelegateClass = [BLSDImageLoader class];
        }
        _imageLoaderManagerDelegate = [[imageLoaderManagerDelegateClass alloc] init];
        //用于处理YSImageAlertSheetView删除等操作的后diamiss
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showDismissalAnimation) name:@"YSPhotoBrowserDismissalAnimationNotification" object:nil];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor blackColor];
    
    _backgroundView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    _backgroundView.alpha = 0;
    [self.view addSubview:_backgroundView];
    
    CGRect rect = self.view.bounds;
    rect.origin.x -= kBLPhotoViewPadding;
    rect.size.width += 2 * kBLPhotoViewPadding;
    _scrollView = [[UIScrollView alloc] initWithFrame:rect];
    _scrollView.pagingEnabled = YES;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.delegate = self;
    [self.view addSubview:_scrollView];
    
    if (_photoItems.count > 1) {
        if (_pageindicatorStyle == YSPhotoBrowserPageIndicatorStyleDot) {
                _pageControl = [[UIPageControl alloc] initWithFrame:CGRectMake(0, self.view.bounds.size.height-40, self.view.bounds.size.width, 20)];
                _pageControl.numberOfPages = _photoItems.count;
                _pageControl.currentPage = _currentPage;
                [self.view addSubview:_pageControl];
        } else {
            _pageLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetHeight([UIApplication sharedApplication].statusBarFrame) + 3, self.view.bounds.size.width, 20)];
            _pageLabel.textColor = PAGE_INDEX_COLOR(1);
            _pageLabel.font = [UIFont systemFontOfSize:20];
            _pageLabel.textAlignment = NSTextAlignmentCenter;
            [self configPageLabelWithPage:_currentPage];
            [self.view addSubview:_pageLabel];
        }
    }
    
    CGSize contentSize = CGSizeMake(rect.size.width * _photoItems.count, rect.size.height);
    _scrollView.contentSize = contentSize;
    
    [self addGestureRecognizer];
    
    CGPoint contentOffset = CGPointMake(_scrollView.frame.size.width*_currentPage, 0);
    [_scrollView setContentOffset:contentOffset animated:NO];
    if (contentOffset.x == 0) {
        [self scrollViewDidScroll:_scrollView];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self startAnimation];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
#pragma mark - 公有方法

/**
 显示photoBrowser
 */
- (void)showFromViewController{
    if (_photoItems.count <= _currentPage) {
        return;
    }
    UIViewController *topController = [[UIApplication  sharedApplication] keyWindow].rootViewController;
    while (topController.presentedViewController) {
        topController = topController.presentedViewController;
    }
    [topController presentViewController:self animated:NO completion:nil];
}


/**
 设置图片加载代理的class

 @param cls 图片加载代理的class
 */
+ (void)setImageLoaderManagerClass:(Class<YSImageLoaderManagerDelegate>)cls {
    imageLoaderManagerDelegateClass = cls;
}

#pragma mark - 私有方法

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskPortrait;
}

- (YSPhotoScrollView *)photoScrollViewForPage:(NSUInteger)page {
    for (YSPhotoScrollView *photoScrollView in _visibleItemViews) {
        if (photoScrollView.tag == page) {
            return photoScrollView;
        }
    }
    return nil;
}

- (YSPhotoScrollView *)dequeueReusableItemView {
    YSPhotoScrollView *photoScrollView = [_reusableItemViews anyObject];
    if (photoScrollView == nil) {
        photoScrollView = [[YSPhotoScrollView alloc] initWithFrame:_scrollView.bounds imageManagerDelegate:_imageLoaderManagerDelegate];
    } else {
        [_reusableItemViews removeObject:photoScrollView];
    }
    photoScrollView.tag = -1;
    return photoScrollView;
}

- (void)updateReusableItemViews {
    NSMutableArray *itemsForRemove = @[].mutableCopy;
    for (YSPhotoScrollView *photoScrollView in _visibleItemViews) {
        if (photoScrollView.frame.origin.x + photoScrollView.frame.size.width < _scrollView.contentOffset.x - _scrollView.frame.size.width ||
            photoScrollView.frame.origin.x > _scrollView.contentOffset.x + 2 * _scrollView.frame.size.width) {
            [photoScrollView removeFromSuperview];
            [self configPhotoScrollView:photoScrollView withItem:nil];
            [itemsForRemove addObject:photoScrollView];
            [_reusableItemViews addObject:photoScrollView];
        }
    }
    [_visibleItemViews removeObjectsInArray:itemsForRemove];
}

- (void)configItemViews {
    NSInteger page = _scrollView.contentOffset.x / _scrollView.frame.size.width + 0.5;
    for (NSInteger i = page - 1; i <= page + 1; i++) {
        if (i < 0 || i >= _photoItems.count) {
            continue;
        }
        YSPhotoScrollView *photoScrollView = [self photoScrollViewForPage:i];
        if (photoScrollView == nil) {
            photoScrollView = [self dequeueReusableItemView];
            CGRect rect = _scrollView.bounds;
            rect.origin.x = i * _scrollView.bounds.size.width;
            photoScrollView.frame = rect;
            photoScrollView.tag = i;
            [_scrollView addSubview:photoScrollView];
            [_visibleItemViews addObject:photoScrollView];
        }
        if (photoScrollView.item == nil && _presented) {
            YSPhotoItem *item = [_photoItems objectAtIndex:i];
            [self configPhotoScrollView:photoScrollView withItem:item];
        }
    }
    
    if (page != _currentPage && _presented && (page >= 0 && page < _photoItems.count)) {
        _currentPage = page;
        if (_pageindicatorStyle == YSPhotoBrowserPageIndicatorStyleDot) {
            _pageControl.currentPage = page;
        } else {
            [self configPageLabelWithPage:_currentPage];
        }
    }
}

- (void)dismissAnimated{
    for (YSPhotoScrollView *photoScrollView in _visibleItemViews) {
        [photoScrollView cancelCurrentImageLoad];
    }
    YSPhotoItem *item = [_photoItems objectAtIndex:_currentPage];
    [UIView animateWithDuration:kAnimationDuration animations:^{
        item.sourceView.alpha = 1;
        self.presented = NO;
    }];
    [self dismissViewControllerAnimated:NO completion:nil];
}

- (void)performRotationWithPan:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan translationInView:self.view];
    CGPoint location = [pan locationInView:self.view];
    CGPoint velocity = [pan velocityInView:self.view];
    YSPhotoScrollView *photoScrollView = [self photoScrollViewForPage:_currentPage];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            _startLocation = location;
            [self handlePanBegin];
            break;
        case UIGestureRecognizerStateChanged: {
            CGFloat angle = 0;
            if (_startLocation.x < self.view.frame.size.width/2) {
                angle = -(M_PI / 2) * (point.y / self.view.frame.size.height);
            } else {
                angle = (M_PI / 2) * (point.y / self.view.frame.size.height);
            }
            CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
            CGAffineTransform translation = CGAffineTransformMakeTranslation(0, point.y);
            CGAffineTransform transform = CGAffineTransformConcat(rotation, translation);
            photoScrollView.imageView.transform = transform;
            
            double percent = 1 - fabs(point.y)/(self.view.frame.size.height/2);
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:percent];
            _backgroundView.alpha = percent;
            _pageLabel.textColor = PAGE_INDEX_COLOR(percent);
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if (fabs(point.y) > 200 || fabs(velocity.y) > 500) {
                [self showRotationCompletionAnimationFromPoint:point];
            } else {
                [self showCancellationAnimation];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)performScaleWithPan:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan translationInView:self.view];
    CGPoint location = [pan locationInView:self.view];
    CGPoint velocity = [pan velocityInView:self.view];
    YSPhotoScrollView *photoScrollView = [self photoScrollViewForPage:_currentPage];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            _startLocation = location;
            [self handlePanBegin];
            break;
        case UIGestureRecognizerStateChanged: {
            double percent = 1 - fabs(point.y) / self.view.frame.size.height;
            percent = MAX(percent, 0);
            double s = MAX(percent, 0.5);
            CGAffineTransform translation = CGAffineTransformMakeTranslation(point.x/s, point.y/s);
            CGAffineTransform scale = CGAffineTransformMakeScale(s, s);
            photoScrollView.imageView.transform = CGAffineTransformConcat(translation, scale);
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:percent];
            _backgroundView.alpha = percent;
            _pageLabel.textColor = PAGE_INDEX_COLOR(percent);
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if (fabs(point.y) > 100 || fabs(velocity.y) > 500) {
                [self showDismissalAnimation];
            } else {
                [self showCancellationAnimation];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)performSlideWithPan:(UIPanGestureRecognizer *)pan {
    CGPoint point = [pan translationInView:self.view];
    CGPoint location = [pan locationInView:self.view];
    CGPoint velocity = [pan velocityInView:self.view];
    YSPhotoScrollView *photoScrollView = [self photoScrollViewForPage:_currentPage];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            _startLocation = location;
            [self handlePanBegin];
            break;
        case UIGestureRecognizerStateChanged: {
            photoScrollView.imageView.transform = CGAffineTransformMakeTranslation(0, point.y);
            double percent = 1 - fabs(point.y)/(self.view.frame.size.height/2);
            self.view.backgroundColor = [UIColor colorWithWhite:0 alpha:percent];
            _backgroundView.alpha = percent;
            _pageLabel.textColor = PAGE_INDEX_COLOR(percent);
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            if (fabs(point.y) > 200 || fabs(velocity.y) > 500) {
                [self showSlideCompletionAnimationFromPoint:point];
            } else {
                [self showCancellationAnimation];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)configPhotoScrollView:(YSPhotoScrollView *)photoScrollView withItem:(YSPhotoItem *)item {
    [photoScrollView setItem:item determinate:(_loadingStyle == YSPhotoBrowserImageLoadingStyleDeterminate)];
}

- (void)configPageLabelWithPage:(NSUInteger)page {
    _pageLabel.text = [NSString stringWithFormat:@"%lu / %lu",(unsigned long)page+1, (unsigned long)_photoItems.count];
}

- (void)handlePanBegin {
    YSPhotoScrollView *photoScrollView = [self photoScrollViewForPage:_currentPage];
    [photoScrollView cancelCurrentImageLoad];
    YSPhotoItem *item = [_photoItems objectAtIndex:_currentPage];
    [UIApplication sharedApplication].statusBarHidden = NO;
    photoScrollView.progressView.hidden = YES;
    item.sourceView.alpha = 1;
}


#pragma mark - 网络请求

#pragma mark - 手势

- (void)addGestureRecognizer {
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTap];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSingleTap:)];
    singleTap.numberOfTapsRequired = 1;
    [singleTap requireGestureRecognizerToFail:doubleTap];
    [self.view addGestureRecognizer:singleTap];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didLongPress:)];
    [self.view addGestureRecognizer:longPress];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didPan:)];
    [self.view addGestureRecognizer:pan];
}

- (void)didSingleTap:(UITapGestureRecognizer *)tap {
    [self showDismissalAnimation];
}

- (void)didDoubleTap:(UITapGestureRecognizer *)tap {
    YSPhotoScrollView *photoScrollView = [self photoScrollViewForPage:_currentPage];
    YSPhotoItem *item = [_photoItems objectAtIndex:_currentPage];
    if (!item.finished) {
        return;
    }
    if (photoScrollView.zoomScale > 1) {
        [photoScrollView setZoomScale:1 animated:YES];
    } else {
        CGPoint location = [tap locationInView:self.view];
        CGFloat maxZoomScale = photoScrollView.maximumZoomScale;
        CGFloat width = self.view.bounds.size.width / maxZoomScale;
        CGFloat height = self.view.bounds.size.height / maxZoomScale;
        [photoScrollView zoomToRect:CGRectMake(location.x - width/2, location.y - height/2, width, height) animated:YES];
    }
}

- (void)didLongPress:(UILongPressGestureRecognizer *)longPress {
    
    if (_imageLongPressStyleTitles.count == 0) return;
    if (longPress.state != UIGestureRecognizerStateBegan) return;
    YSPhotoScrollView *photoScrollView = [self photoScrollViewForPage:_currentPage];
    UIImage *image = photoScrollView.imageView.image;
    if (!image)return;
    YSImageAlertSheetView *sheet = [YSImageAlertSheetView imageAlertSheetViewWithImage:image andAlertSheetTitles:self.imageLongPressStyleTitles alertSheetBlock:^(NSInteger alertSheetType, NSString *alertSheetTitle, UIImage *image) {
        if (self.browserAlertSheetBlock) {
            YSPhotoScrollView *photoScrollView = [self photoScrollViewForPage:self.currentPage];
            self.browserAlertSheetBlock(self.currentPage,alertSheetType,photoScrollView.imageView.image,photoScrollView.item.imageUrl.absoluteString);
        }
    }];

    [sheet showAlertSheetView];

}


/**
 点击手势

 @param pan 手势
 */
- (void)didPan:(UIPanGestureRecognizer *)pan {
//    YSPhotoScrollView *photoScrollView = [self photoScrollViewForPage:_currentPage];
//    if (photoScrollView.zoomScale > 1.1) {
//        return;
//    }
    
    switch (_dismissalStyle) {
        case YSPhotoBrowserDismissalStyleRotation:
            [self performRotationWithPan:pan];
            break;
        case YSPhotoBrowserDismissalStyleScale:
            [self performScaleWithPan:pan];
            break;
        case YSPhotoBrowserDismissalStyleSlide:
            [self performSlideWithPan:pan];
            break;
        default:
            break;
    }
}


#pragma mark - 动画


- (void)startAnimation{
    
    if (_presented) {
        return;
    }
    YSPhotoItem *item = [_photoItems objectAtIndex:_currentPage];
    item.sourceView .clipsToBounds = YES;
    YSPhotoScrollView *photoScrollView = [self photoScrollViewForPage:_currentPage];
    if ([_imageLoaderManagerDelegate imageFromMemoryForURL:item.imageUrl]) {
        //有缓存
        [self configPhotoScrollView:photoScrollView withItem:item];
    } else {
        //没有缓存
        photoScrollView.imageView.image = item.thumbImage;
        [photoScrollView resizeImageView];
    }
    
    CGRect endRect = photoScrollView.imageView.frame;
    CGRect sourceRect;
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersion >= 8.0 && systemVersion < 9.0) {
        sourceRect = [item.sourceView.superview convertRect:item.sourceView.frame toCoordinateSpace:photoScrollView];
    } else {
        sourceRect = [item.sourceView.superview convertRect:item.sourceView.frame toView:photoScrollView];
    }
    photoScrollView.imageView.frame =  sourceRect;
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        photoScrollView.imageView.frame = endRect;
        self.view.backgroundColor = [UIColor blackColor];
        self.backgroundView.alpha = 1;
        [self configPhotoScrollView:photoScrollView withItem:item];
    } completion:^(BOOL finished) {
        self.presented = YES;
        [UIApplication sharedApplication].statusBarHidden = YES;
    }];
}

- (void)showCancellationAnimation {
    YSPhotoScrollView *photoScrollView = [self photoScrollViewForPage:_currentPage];
    YSPhotoItem *item = [_photoItems objectAtIndex:_currentPage];
    item.sourceView.alpha = 1;
    if (!item.finished) {
        photoScrollView.progressView.hidden = NO;
    }

    [UIView animateWithDuration:kAnimationDuration animations:^{
        photoScrollView.imageView.transform = CGAffineTransformIdentity;
        self.view.backgroundColor = [UIColor blackColor];
        self.backgroundView.alpha = 1;
        self.pageLabel.textColor = PAGE_INDEX_COLOR(1);
        [self configPhotoScrollView:photoScrollView withItem:item];
    } completion:^(BOOL finished) {
        [UIApplication sharedApplication].statusBarHidden = YES;
    }];
}

- (void)showRotationCompletionAnimationFromPoint:(CGPoint)point {
    YSPhotoScrollView *photoScrollView = [self photoScrollViewForPage:_currentPage];
    BOOL startFromLeft = _startLocation.x < self.view.frame.size.width / 2;
    BOOL throwToTop = point.y < 0;
    CGFloat angle, toTranslationY;
    if (throwToTop) {
        angle = startFromLeft ? (M_PI / 2) : -(M_PI / 2);
        toTranslationY = -self.view.frame.size.height;
    } else {
        angle = startFromLeft ? -(M_PI / 2) : (M_PI / 2);
        toTranslationY = self.view.frame.size.height;
    }
    
    CGFloat angle0 = 0;
    if (_startLocation.x < self.view.frame.size.width/2) {
        angle0 = -(M_PI / 2) * (point.y / self.view.frame.size.height);
    } else {
        angle0 = (M_PI / 2) * (point.y / self.view.frame.size.height);
    }
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = @(angle0);
    rotationAnimation.toValue = @(angle);
    CABasicAnimation *translationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.translation.y"];
    translationAnimation.fromValue = @(point.y);
    translationAnimation.toValue = @(toTranslationY);
    CAAnimationGroup *throwAnimation = [CAAnimationGroup animation];
    throwAnimation.duration = kAnimationDuration;
    throwAnimation.delegate = self;
    throwAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    throwAnimation.animations = @[rotationAnimation, translationAnimation];
    [throwAnimation setValue:@"throwAnimation" forKey:@"id"];
    [photoScrollView.imageView.layer addAnimation:throwAnimation forKey:@"throwAnimation"];
    
    CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
    CGAffineTransform translation = CGAffineTransformMakeTranslation(0, toTranslationY);
    CGAffineTransform transform = CGAffineTransformConcat(rotation, translation);
    photoScrollView.imageView.transform = transform;
    
    [UIView animateWithDuration:kAnimationDuration animations:^{
        self.view.backgroundColor = [UIColor clearColor];
        self.backgroundView.alpha = 0;
        self.pageLabel.textColor = PAGE_INDEX_COLOR(0);
    } completion:nil];
}


- (void)showDismissalAnimation {
    YSPhotoItem *item = [_photoItems objectAtIndex:_currentPage];
    YSPhotoScrollView *photoScrollView = [self photoScrollViewForPage:_currentPage];
    [photoScrollView cancelCurrentImageLoad];
    [UIApplication sharedApplication].statusBarHidden = NO;
    
    if (item.sourceView == nil) {
        [UIView animateWithDuration:kAnimationDuration animations:^{
            self.view.alpha = 0;
        } completion:^(BOOL finished) {
            [self dismissAnimated];
        }];
        return;
    }
    
    photoScrollView.progressView.hidden = YES;
    item.sourceView.alpha = 1;
    CGRect sourceRect;
    float systemVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (systemVersion >= 8.0 && systemVersion < 9.0) {
        sourceRect = [item.sourceView.superview convertRect:item.sourceView.frame toCoordinateSpace:photoScrollView];
    } else {
        sourceRect = [item.sourceView.superview convertRect:item.sourceView.frame toView:photoScrollView];
    }
    
    photoScrollView.imageView.clipsToBounds = YES;
    [UIView animateWithDuration:kAnimationDuration animations:^{
        photoScrollView.imageView.frame = sourceRect;
        self.view.backgroundColor = [UIColor clearColor];
        self.backgroundView.alpha = 0;
        self.pageLabel.textColor = PAGE_INDEX_COLOR(0);
    } completion:^(BOOL finished) {
        [self dismissAnimated];
    }];
}

- (void)showSlideCompletionAnimationFromPoint:(CGPoint)point {
    YSPhotoScrollView *photoScrollView = [self photoScrollViewForPage:_currentPage];
    BOOL throwToTop = point.y < 0;
    CGFloat toTranslationY = 0;
    if (throwToTop) {
        toTranslationY = -self.view.frame.size.height;
    } else {
        toTranslationY = self.view.frame.size.height;
    }
    [UIView animateWithDuration:kAnimationDuration animations:^{
        photoScrollView.imageView.transform = CGAffineTransformMakeTranslation(0, toTranslationY);
        self.view.backgroundColor = [UIColor clearColor];
        self.backgroundView.alpha = 0;
        self.pageLabel.textColor = PAGE_INDEX_COLOR(0);
    } completion:^(BOOL finished) {
        [self dismissAnimated];
    }];
}

#pragma mark - 动画代理

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag {
    if ([[anim valueForKey:@"id"] isEqualToString:@"throwAnimation"]) {
        [self dismissAnimated];
    }
}

#pragma mark - UIScrollView代理

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self updateReusableItemViews];
    [self configItemViews];
}

@end

