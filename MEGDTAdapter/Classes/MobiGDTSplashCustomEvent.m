//
//  MobiGDTSplashCustomEvent.m
//  MobiAdSDK
//
//  Created by 刘峰 on 2020/9/27.
//

#import "MobiGDTSplashCustomEvent.h"
#import <GDTMobSDK/GDTSplashAd.h>

#if __has_include("MobiPub.h")
#import "MPLogging.h"
#import "MobiSplashError.h"
#endif

@interface MobiGDTSplashCustomEvent ()<GDTSplashAdDelegate>

@property (strong, nonatomic) GDTSplashAd *splash;

@property (nonatomic, strong) UIView *bottomView;

/// 用来弹出广告的 viewcontroller
@property (nonatomic, strong) UIViewController *rootVC;

@property (nonatomic, copy) NSString *adUnitId;

@end

@implementation MobiGDTSplashCustomEvent

- (void)requestSplashWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    NSString *adUnitId = [info objectForKey:@"adunit"];
    UIView *bottomView = [info objectForKey:@"bottomView"];
    NSTimeInterval delay = [[info objectForKey:@"delay"] floatValue];
    UIImageView *backImageView = [info objectForKey:@"backImageView"];
    
    if (adUnitId == nil) {
        NSError *error = [NSError splashErrorWithCode:MobiSplashAdErrorNoAdsAvailable localizedDescription:@"posid cannot be nil"];
        if ([self.delegate respondsToSelector:@selector(splashAdFailToPresentForCustomEvent:withError:)]) {
            [self.delegate splashAdFailToPresentForCustomEvent:self withError:error];
        }
        return;
    }
    
    self.adUnitId = adUnitId;
    
    if (bottomView) {
        self.bottomView = bottomView;
    }
    
    GDTSplashAd *splash = [[GDTSplashAd alloc] initWithPlacementId:adUnitId];
    splash.delegate = self;
    splash.fetchDelay = delay != 0 ? delay : 3;
    [splash loadAd];
    self.splash = splash;
}

- (void)presentSplashFromWindow:(UIWindow *)window {
    if (![self hasAdAvailable]) {
        NSError *error = [NSError splashErrorWithCode:MobiSplashAdErrorNoAdsAvailable localizedDescription:@"splash ad is not avaliable"];
        if ([self.delegate respondsToSelector:@selector(splashAdFailToPresentForCustomEvent:withError:)]) {
            [self.delegate splashAdFailToPresentForCustomEvent:self withError:error];
        }
        return;
    }
    
    [self.splash showAdInWindow:window withBottomView:self.bottomView skipView:nil];
}

- (BOOL)hasAdAvailable
{
    return self.splash.isAdValid;
}

- (void)handleAdPlayedForCustomEventNetwork
{
    if (!self.splash.isAdValid) {
        [self.delegate splashAdDidExpireForCustomEvent:self];
    }
}

- (void)handleCustomEventInvalidated
{
}

// MARK: - GDTSplashAdDelegate
/**
 *  开屏广告成功展示
 */
- (void)splashAdSuccessPresentScreen:(GDTSplashAd *)splashAd {
    if (self.delegate && [self.delegate respondsToSelector:@selector(splashAdSuccessPresentScreenForCustomEvent:)]) {
        [self.delegate splashAdSuccessPresentScreenForCustomEvent:self];
    }
    
    [GDTSplashAd preloadSplashOrderWithPlacementId:self.adUnitId];
}

/**
 *  开屏广告素材加载成功
 */
- (void)splashAdDidLoad:(GDTSplashAd *)splashAd {
    if (self.delegate && [self.delegate respondsToSelector:@selector(splashAdDidLoadForCustomEvent:)]) {
        [self.delegate splashAdDidLoadForCustomEvent:self];
    }
}

/**
 *  开屏广告展示失败
 */
- (void)splashAdFailToPresent:(GDTSplashAd *)splashAd withError:(NSError *)error {
    self.splash = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(splashAdFailToPresentForCustomEvent:withError:)]) {
        [self.delegate splashAdFailToPresentForCustomEvent:self withError:error];
    }
}

/**
 *  应用进入后台时回调
 *  详解: 当点击下载应用时会调用系统程序打开，应用切换到后台
 */
- (void)splashAdApplicationWillEnterBackground:(GDTSplashAd *)splashAd {
    if (self.delegate && [self.delegate respondsToSelector:@selector(splashAdApplicationWillEnterBackgroundForCustomEvent:)]) {
        [self.delegate splashAdApplicationWillEnterBackgroundForCustomEvent:self];
    }
}

/**
 *  开屏广告曝光回调
 */
- (void)splashAdExposured:(GDTSplashAd *)splashAd {
    if (self.delegate && [self.delegate respondsToSelector:@selector(splashAdExposuredForCustomEvent:)]) {
        [self.delegate splashAdExposuredForCustomEvent:self];
    }
}

/**
 *  开屏广告点击回调
 */
- (void)splashAdClicked:(GDTSplashAd *)splashAd {
    if (self.delegate && [self.delegate respondsToSelector:@selector(splashAdClickedForCustomEvent:)]) {
        [self.delegate splashAdClickedForCustomEvent:self];
    }
}

/**
 *  开屏广告将要关闭回调
 */
- (void)splashAdWillClosed:(GDTSplashAd *)splashAd {
    if (self.delegate && [self.delegate respondsToSelector:@selector(splashAdWillClosedForCustomEvent:)]) {
        [self.delegate splashAdWillClosedForCustomEvent:self];
    }
}

/**
 *  开屏广告关闭回调
 */
- (void)splashAdClosed:(GDTSplashAd *)splashAd {
    if (self.delegate && [self.delegate respondsToSelector:@selector(splashAdClosedForCustomEvent:)]) {
        [self.delegate splashAdClosedForCustomEvent:self];
    }
}

/**
 *  开屏广告点击以后即将弹出全屏广告页
 */
- (void)splashAdWillPresentFullScreenModal:(GDTSplashAd *)splashAd {
    if (self.delegate && [self.delegate respondsToSelector:@selector(splashAdWillPresentFullScreenModalForCustomEvent:)]) {
        [self.delegate splashAdWillPresentFullScreenModalForCustomEvent:self];
    }
}

/**
 *  开屏广告点击以后弹出全屏广告页
 */
- (void)splashAdDidPresentFullScreenModal:(GDTSplashAd *)splashAd {
    if (self.delegate && [self.delegate respondsToSelector:@selector(splashAdDidPresentFullScreenModalForCustomEvent:)]) {
        [self.delegate splashAdDidPresentFullScreenModalForCustomEvent:self];
    }
}

/**
 *  点击以后全屏广告页将要关闭
 */
- (void)splashAdWillDismissFullScreenModal:(GDTSplashAd *)splashAd {
    if (self.delegate && [self.delegate respondsToSelector:@selector(splashAdWillDismissFullScreenModalForCustomEvent:)]) {
        [self.delegate splashAdWillDismissFullScreenModalForCustomEvent:self];
    }
}

/**
 *  点击以后全屏广告页已经关闭
 */
- (void)splashAdDidDismissFullScreenModal:(GDTSplashAd *)splashAd {
    if (self.delegate && [self.delegate respondsToSelector:@selector(splashAdDidDismissFullScreenModalForCustomEvent:)]) {
        [self.delegate splashAdDidDismissFullScreenModalForCustomEvent:self];
    }
}

/**
 * 开屏广告剩余时间回调
 */
- (void)splashAdLifeTime:(NSUInteger)time {
    if (self.delegate && [self.delegate respondsToSelector:@selector(splashAdLifeTime:)]) {
        [self.delegate splashAdLifeTime:time];
    }
}

@end
