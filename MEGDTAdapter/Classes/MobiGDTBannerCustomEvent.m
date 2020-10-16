//
//  MobiGDTBannerCustomEvent.m
//  MobiAdSDK
//
//  Created by 刘峰 on 2020/9/28.
//

#import "MobiGDTBannerCustomEvent.h"
#import <GDTMobSDK/GDTUnifiedBannerView.h>

#if __has_include("MobiPub.h")
#import "MPLogging.h"
#import "MobiBannerError.h"
#endif

@interface MobiGDTBannerCustomEvent ()<GDTUnifiedBannerViewDelegate>

// banner
@property (nonatomic, strong) GDTUnifiedBannerView *bannerView;

@end

@implementation MobiGDTBannerCustomEvent

- (void)requestAdWithSize:(CGSize)size customEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    NSString *adUnitId = [info objectForKey:@"adunit"];
    CGFloat whRatio = [[info objectForKey:@"whRatio"] floatValue];
    NSTimeInterval interval = [[info objectForKey:@"interval"] floatValue];
    UIViewController *rootVC = [info objectForKey:@"rootVC"];
    
    
    if (adUnitId == nil) {
        NSError *error =
        [NSError errorWithDomain:MobiBannerAdsSDKDomain
                            code:MobiBannerAdErrorInvalidPosid
                        userInfo:@{NSLocalizedDescriptionKey : @"Ad Unit ID cannot be nil."}];
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
        return;
    }
    
    
    if (!self.bannerView) {
        CGRect rect = {CGPointZero, size};
        self.bannerView = [[GDTUnifiedBannerView alloc] initWithFrame:rect placementId:adUnitId viewController:rootVC];
        self.bannerView.accessibilityIdentifier = @"banner_ad";
        self.bannerView.autoSwitchInterval = interval;
        self.bannerView.delegate = self;
    }
    
    [self.bannerView loadAdAndShow];
}

- (BOOL)enableAutomaticImpressionAndClickTracking
{
    return YES;
}

// MARK: - GDTUnifiedBannerViewDelegate
/**
 *  请求广告条数据成功后调用
 *  当接收服务器返回的广告数据成功后调用该函数
 */
- (void)unifiedBannerViewDidLoad:(GDTUnifiedBannerView *)unifiedBannerView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(bannerCustomEvent:didLoadAd:)]) {
        [self.delegate bannerCustomEvent:self didLoadAd:self.bannerView];
    }
}

/**
 *  请求广告条数据失败后调用
 *  当接收服务器返回的广告数据失败后调用该函数
 */

- (void)unifiedBannerViewFailedToLoad:(GDTUnifiedBannerView *)unifiedBannerView error:(NSError *)error
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(bannerCustomEvent:didFailToLoadAdWithError:)]) {
        [self.delegate bannerCustomEvent:self didFailToLoadAdWithError:error];
    }
}

/**
 *  banner2.0曝光回调
 */
- (void)unifiedBannerViewWillExpose:(nonnull GDTUnifiedBannerView *)unifiedBannerView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(bannerCustomEvent:willVisible:)]) {
        [self.delegate bannerCustomEvent:self willVisible:unifiedBannerView];
    }
}

/**
 *  banner2.0点击回调
 */
- (void)unifiedBannerViewClicked:(GDTUnifiedBannerView *)unifiedBannerView
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(bannerCustomEvent:didClick:)]) {
        [self.delegate bannerCustomEvent:self didClick:unifiedBannerView];
    }
}

- (void)unifiedBannerViewWillLeaveApplication:(GDTUnifiedBannerView *)unifiedBannerView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(bannerCustomEventWillLeaveApplication:)]) {
        [self.delegate bannerCustomEventWillLeaveApplication:self];
    }
}

/**
 *  banner2.0被用户关闭时调用
 */
- (void)unifiedBannerViewWillClose:(nonnull GDTUnifiedBannerView *)unifiedBannerView {
    if (self.delegate && [self.delegate respondsToSelector:@selector(bannerCustomEvent:willClose:)]) {
        [self.delegate bannerCustomEvent:self willClose:unifiedBannerView];
    }
    
    [UIView animateWithDuration:0.25 animations:^{
        unifiedBannerView.alpha = 0;
    } completion:^(BOOL finished) {
        [unifiedBannerView removeFromSuperview];
        if (self.bannerView == unifiedBannerView) {
            self.bannerView = nil;
        }
    }];
}

@end
