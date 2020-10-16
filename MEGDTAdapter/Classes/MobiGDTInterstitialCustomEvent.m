//
//  MobiGDTInterstitialCustomEvent.m
//  MobiAdSDK
//
//  Created by 刘峰 on 2020/9/27.
//

#import "MobiGDTInterstitialCustomEvent.h"
#import <GDTMobSDK/GDTUnifiedInterstitialAd.h>

#if __has_include("MobiPub.h")
#import "MPLogging.h"
#import "MobiInterstitialError.h"
#endif

@interface MobiGDTInterstitialCustomEvent ()<GDTUnifiedInterstitialAdDelegate>

/// 插屏广告管理
@property (nonatomic, strong) GDTUnifiedInterstitialAd *interstitial;

/// 用来弹出广告的 viewcontroller
@property (nonatomic, strong) UIViewController *rootVC;

@end

@implementation MobiGDTInterstitialCustomEvent

- (void)requestInterstitialWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    NSString *adUnitId = [info objectForKey:@"adunit"];
    if (adUnitId == nil) {
        NSError *error =
        [NSError errorWithDomain:MobiInterstitialAdsSDKDomain
                            code:MobiInterstitialAdErrorInvalidPosid
                        userInfo:@{NSLocalizedDescriptionKey : @"Ad Unit ID cannot be nil."}];
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }
    
    self.interstitial = [[GDTUnifiedInterstitialAd alloc] initWithPlacementId:adUnitId];
    self.interstitial.delegate = self;
    self.interstitial.videoMuted = YES; // 设置视频是否Mute静音
    self.interstitial.videoAutoPlayOnWWAN = NO; // 设置视频是否在非 WiFi 网络自动播放
    [self.interstitial loadAd];
}

/**
 * Called when the interstitial should be displayed.
 *
 * This message is sent sometime after an interstitial has been successfully loaded, as a result
 * of your code calling `-[MPInterstitialAdController showFromViewController:]`. Your implementation
 * of this method should present the interstitial ad from the specified view controller.
 *
 * If you decide to [opt out of automatic impression tracking](enableAutomaticImpressionAndClickTracking), you should place your
 * manual calls to [-trackImpression]([MPInterstitialCustomEventDelegate trackImpression]) in this method to ensure correct metrics.
 *
 * @param rootViewController The controller to use to present the interstitial modally.
 *
 */
- (void)showInterstitialFromRootViewController:(UIViewController *)rootViewController {
    if (rootViewController != nil) {
        self.rootVC = rootViewController;
    }
    
    if (self.interstitial.isAdValid) {
        [self.interstitial presentAdFromRootViewController:rootViewController];
        return;
    }
    
    NSError *error =
    [NSError errorWithDomain:MobiInterstitialAdsSDKDomain
                        code:MobiInterstitialAdErrorNoAdsAvailable
                    userInfo:@{NSLocalizedDescriptionKey : @"Cannot present intersitial ads. Cause interstitial ad is invalid"}];
    [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
}

- (BOOL)hasAdAvailable
{
    return self.interstitial.isAdValid;
}

/** @name Impression and Click Tracking */

/**
 * Override to opt out of automatic impression and click tracking.
 *
 * By default, the  MPInterstitialCustomEventDelegate will automatically record impressions and clicks in
 * response to the appropriate callbacks. You may override this behavior by implementing this method
 * to return `NO`.
 *
 * @warning **Important**: If you do this, you are responsible for calling the `[-trackImpression]([MPInterstitialCustomEventDelegate trackImpression])` and
 * `[-trackClick]([MPInterstitialCustomEventDelegate trackClick])` methods on the custom event delegate. Additionally, you should make sure that these
 * methods are only called **once** per ad.
 */
- (BOOL)enableAutomaticImpressionAndClickTracking {
    return YES;
}

// MARK: - GDTUnifiedInterstitialAdDelegate
/**
 *  插屏2.0广告预加载成功回调
 *  当接收服务器返回的广告数据成功后调用该函数
 */
- (void)unifiedInterstitialSuccessToLoadAd:(GDTUnifiedInterstitialAd *)unifiedInterstitial
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialCustomEvent:didLoadAd:)]) {
        [self.delegate interstitialCustomEvent:self didLoadAd:nil];
    }
}

/**
 *  插屏2.0广告预加载失败回调
 *  当接收服务器返回的广告数据失败后调用该函数
 */
- (void)unifiedInterstitialFailToLoadAd:(GDTUnifiedInterstitialAd *)unifiedInterstitial error:(NSError *)error {
    self.rootVC = nil;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialCustomEvent:didFailToLoadAdWithError:)]) {
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    }
}

/**
 *  插屏2.0广告将要展示回调
 *  插屏2.0广告即将展示回调该函数
 */
- (void)unifiedInterstitialWillPresentScreen:(GDTUnifiedInterstitialAd *)unifiedInterstitial {
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialCustomEventWillAppear:)]) {
        [self.delegate interstitialCustomEventWillAppear:self];
    }
}

/**
 *  插屏2.0广告视图展示成功回调
 *  插屏2.0广告展示成功回调该函数
 */
- (void)unifiedInterstitialDidPresentScreen:(GDTUnifiedInterstitialAd *)unifiedInterstitial {
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialCustomEventDidAppear:)]) {
        [self.delegate interstitialCustomEventDidAppear:self];
    }
}

/**
 *  插屏2.0广告展示结束回调
 *  插屏2.0广告展示结束回调该函数
 */
- (void)unifiedInterstitialDidDismissScreen:(GDTUnifiedInterstitialAd *)unifiedInterstitial {
    self.rootVC = nil;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialCustomEventWillDisappear:)]) {
        [self.delegate interstitialCustomEventWillDisappear:self];
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialCustomEventDidDisappear:)]) {
        [self.delegate interstitialCustomEventDidDisappear:self];
    }
}

- (void)unifiedInterstitialFailToPresent:(GDTUnifiedInterstitialAd *)unifiedInterstitial error:(NSError *)error {
    self.rootVC = nil;
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialCustomEvent:didFailToLoadAdWithError:)]) {
        [self.delegate interstitialCustomEvent:self didFailToLoadAdWithError:error];
    }
}

/**
 *  插屏2.0广告点击回调
 */
- (void)unifiedInterstitialClicked:(GDTUnifiedInterstitialAd *)unifiedInterstitial
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialCustomEventDidReceiveTapEvent:)]) {
        [self.delegate interstitialCustomEventDidReceiveTapEvent:self];
    }
}

/**
 *  全屏广告页将要关闭
 */
- (void)unifiedInterstitialAdWillDismissFullScreenModal:(GDTUnifiedInterstitialAd *)unifiedInterstitial
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialCustomEventDidDismissModal:)]) {
        [self.delegate interstitialCustomEventDidDismissModal:self];
    }
}

/**
 *  当点击下载应用时会调用系统程序打开其它App或者Appstore时回调
 */
- (void)unifiedInterstitialWillLeaveApplication:(GDTUnifiedInterstitialAd *)unifiedInterstitial {
    if (self.delegate && [self.delegate respondsToSelector:@selector(interstitialCustomEventWillLeaveApplication:)]) {
        [self.delegate interstitialCustomEventWillLeaveApplication:self];
    }
}

@end
