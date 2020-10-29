//
//  MobiGDTFeedCustomEvent.m
//  MobiAdSDK
//
//  Created by 刘峰 on 2020/9/27.
//

#import "MobiGDTFeedCustomEvent.h"
#import <GDTNativeExpressAd.h>
#import <GDTNativeExpressAdView.h>
#import "MEGDTAdapter.h"

#if __has_include("MobiPub.h")
#import "MPLogging.h"
#import "MobiFeedError.h"
#endif

@interface MobiGDTFeedCustomEvent ()<GDTNativeExpressAdDelegete>

/// 原生模板广告
@property (strong, nonatomic) NSMutableArray *expressAdViews;

/// 信息流模板广告
@property (nonatomic, strong) GDTNativeExpressAd *nativeExpressAd;

@end

@implementation MobiGDTFeedCustomEvent

- (void)requestFeedWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    NSString *adUnitId = [info objectForKey:@"adunit"];
    CGFloat width = [[info objectForKey:@"width"] floatValue];
    NSInteger count = [[info objectForKey:@"count"] intValue];
    
    if (adUnitId == nil) {
        NSError *error =
        [NSError errorWithDomain:MobiFeedAdsSDKDomain
                            code:MobiFeedAdErrorInvalidPosid
                        userInfo:@{NSLocalizedDescriptionKey : @"Ad Unit ID cannot be nil."}];
        [self.delegate nativeExpressAdFailToLoadForCustomEvent:self error:error];
        return;
    }
    
    self.expressAdViews = [NSMutableArray array];
    
    self.nativeExpressAd = [[GDTNativeExpressAd alloc] initWithPlacementId:adUnitId adSize:CGSizeMake(width, 0)];
    self.nativeExpressAd.delegate = self;
    [self.nativeExpressAd loadAd:count];
}

/// 在回传信息流广告之前,
/// 需要判断这个广告是否还有效,需要在此处返回广告有效性(是否可以直接展示)
- (BOOL)hasAdAvailable {
    return YES;
}

/// 子类重写次方法,决定由谁处理展现和点击上报
/// 默认return YES;由上层adapter处理展现和点击上报,
/// 若return NO;则由子类实现trackImpression和trackClick方法,实现上报,但要保证每个广告只上报一次
- (BOOL)enableAutomaticImpressionAndClickTracking {
    return YES;
}

/// 这个方法存在的意义是聚合广告,因为聚合广告可能会出现两个广告单元用同一个广告平台加载广告
/// 在出现多个广告单元调用同一个广告平台展示广告时,我们要通知custom event类,它们的广告已经失效,当前已经有正在播放的广告
/// 当然广告失效后需要回调`[-rewardedVideoDidExpireForCustomEvent:]([MPRewardedVideoCustomEventDelegate rewardedVideoDidExpireForCustomEvent:])`方法告诉用户这个广告已不再有效
/// 并且我们要重写这个方法,让这个Custom event类能释放掉
/// 默认这个方法不会做任何事情
- (void)handleAdPlayedForCustomEventNetwork {
    [self.delegate nativeExpressAdDidExpireForCustomEvent:self];
}

/// 在激励视频系统不再需要这个custom event类时,会调用这个方法,目的是让custom event能够成功释放掉,如果能保证custom event不会造成内存泄漏,则这个方法不用重写
- (void)handleCustomEventInvalidated {
    
}

// MARK: - GDTNativeExpressAdDelegete
/**
 * 拉取广告成功的回调
 */
- (void)nativeExpressAdSuccessToLoad:(GDTNativeExpressAd *)nativeExpressAd views:(NSArray<__kindof GDTNativeExpressAdView *> *)views {
    [self.expressAdViews removeAllObjects];//【重要】不能保存太多view，需要在合适的时机手动释放不用的，否则内存会过大
    
    [self.expressAdViews addObjectsFromArray:views];
    [views enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GDTNativeExpressAdView *expressView = (GDTNativeExpressAdView *)obj;
        expressView.controller = [MEGDTAdapter topVC];
        [expressView render];
    }];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeExpressAdSuccessToLoadForCustomEvent:views:)]) {
        [self.delegate nativeExpressAdSuccessToLoadForCustomEvent:self views:self.expressAdViews];
    }
}

/**
 * 拉取广告失败的回调
 */
- (void)nativeExpressAdRenderFail:(GDTNativeExpressAdView *)nativeExpressAdView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeExpressAdViewRenderFailForCustomEvent:)]) {
        [self.delegate nativeExpressAdViewRenderFailForCustomEvent:nativeExpressAdView];
    }
}

/**
 * 拉取原生模板广告失败
 */
- (void)nativeExpressAdFailToLoad:(GDTNativeExpressAd *)nativeExpressAd error:(NSError *)error {
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeExpressAdSuccessToLoadForCustomEvent:views:)]) {
        [self.delegate nativeExpressAdFailToLoadForCustomEvent:self error:error];
    }
}

- (void)nativeExpressAdViewRenderSuccess:(GDTNativeExpressAdView *)nativeExpressAdView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeExpressAdViewRenderSuccessForCustomEvent:)]) {
        [self.delegate nativeExpressAdViewRenderSuccessForCustomEvent:nativeExpressAdView];
    }
}

/**
 * 原生模板广告曝光回调
 */
- (void)nativeExpressAdViewExposure:(GDTNativeExpressAdView *)nativeExpressAdView {
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeExpressAdViewExposureForCustomEvent:)]) {
        [self.delegate nativeExpressAdViewExposureForCustomEvent:nativeExpressAdView];
    }
}

- (void)nativeExpressAdViewClicked:(GDTNativeExpressAdView *)nativeExpressAdView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeExpressAdViewClickedForCustomEvent:)]) {
        [self.delegate nativeExpressAdViewClickedForCustomEvent:nativeExpressAdView];
    }
}

- (void)nativeExpressAdViewClosed:(GDTNativeExpressAdView *)nativeExpressAdView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeExpressAdViewClosedForCustomEvent:)]) {
        [self.delegate nativeExpressAdViewClosedForCustomEvent:nativeExpressAdView];
    }
}

/**
 * 点击原生模板广告以后即将弹出全屏广告页
 */
- (void)nativeExpressAdViewWillPresentScreen:(GDTNativeExpressAdView *)nativeExpressAdView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeExpressAdViewWillPresentScreenForCustomEvent:)]) {
        [self.delegate nativeExpressAdViewWillPresentScreenForCustomEvent:nativeExpressAdView];
    }
}

/**
 * 点击原生模板广告以后弹出全屏广告页
 */
- (void)nativeExpressAdViewDidPresentScreen:(GDTNativeExpressAdView *)nativeExpressAdView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeExpressAdViewDidPresentScreenForCustomEvent:)]) {
        [self.delegate nativeExpressAdViewDidPresentScreenForCustomEvent:nativeExpressAdView];
    }
}

/**
 * 全屏广告页将要关闭
 */
- (void)nativeExpressAdViewWillDismissScreen:(GDTNativeExpressAdView *)nativeExpressAdView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeExpressAdViewWillDissmissScreenForCustomEvent:)]) {
        [self.delegate nativeExpressAdViewWillDissmissScreenForCustomEvent:nativeExpressAdView];
    }
}

/**
 * 全屏广告页将要关闭
 */
- (void)nativeExpressAdViewDidDismissScreen:(GDTNativeExpressAdView *)nativeExpressAdView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeExpressAdViewDidDissmissScreenForCustomEvent:)]) {
        [self.delegate nativeExpressAdViewDidDissmissScreenForCustomEvent:nativeExpressAdView];
    }
}

/**
 * 详解:当点击应用下载或者广告调用系统程序打开时调用
 */
- (void)nativeExpressAdViewApplicationWillEnterBackground:(GDTNativeExpressAdView *)nativeExpressAdView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeExpressAdViewApplicationWillEnterBackgroundForCustomEvent:)]) {
        [self.delegate nativeExpressAdViewApplicationWillEnterBackgroundForCustomEvent:nativeExpressAdView];
    }
}

/**
 * 原生模板视频广告 player 播放状态更新回调
 */
- (void)nativeExpressAdView:(GDTNativeExpressAdView *)nativeExpressAdView playerStatusChanged:(GDTMediaPlayerStatus)status {
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeExpressAdViewForCustomEvent:playerStatusChanged:)]) {
        [self.delegate nativeExpressAdViewForCustomEvent:nativeExpressAdView playerStatusChanged:status];
    }
}

/**
 * 原生视频模板详情页 WillPresent 回调
 */
- (void)nativeExpressAdViewWillPresentVideoVC:(GDTNativeExpressAdView *)nativeExpressAdView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeExpressAdViewWillPresentVideoVCForCustomEvent:)]) {
        [self.delegate nativeExpressAdViewWillPresentVideoVCForCustomEvent:nativeExpressAdView];
    }
}

/**
 * 原生视频模板详情页 DidPresent 回调
 */
- (void)nativeExpressAdViewDidPresentVideoVC:(GDTNativeExpressAdView *)nativeExpressAdView {
}

/**
 * 原生视频模板详情页 WillDismiss 回调
 */
- (void)nativeExpressAdViewWillDismissVideoVC:(GDTNativeExpressAdView *)nativeExpressAdView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeExpressAdViewWillDismissVideoVCForCustomEvent:)]) {
        [self.delegate nativeExpressAdViewWillDismissVideoVCForCustomEvent:nativeExpressAdView];
    }
}

/**
 * 原生视频模板详情页 DidDismiss 回调
 */
- (void)nativeExpressAdViewDidDismissVideoVC:(GDTNativeExpressAdView *)nativeExpressAdView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(nativeExpressAdViewDidDismissVideoVCForCustomEvent:)]) {
        [self.delegate nativeExpressAdViewDidDismissVideoVCForCustomEvent:nativeExpressAdView];
    }
}

@end
