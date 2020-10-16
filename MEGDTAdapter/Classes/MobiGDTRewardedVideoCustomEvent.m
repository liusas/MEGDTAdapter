//
//  MobiGDTRewardedVideoCustomEvent.m
//  MobiAdSDK
//
//  Created by 刘峰 on 2020/9/27.
//

#import "MobiGDTRewardedVideoCustomEvent.h"
#import <GDTMobSDK/GDTRewardVideoAd.h>

#if __has_include("MobiPub.h")
#import "MPLogging.h"
#import "MobiRewardedVideoError.h"
#import "MobiRewardedVideoReward.h"
#endif

@interface MobiGDTRewardedVideoCustomEvent ()<GDTRewardedVideoAdDelegate>

@property(nonatomic, copy) NSString *posid;
//激励视频广告
@property (nonatomic, strong) GDTRewardVideoAd *rewardVideoAd;
/// 用来弹出广告的 viewcontroller
@property (nonatomic, strong) UIViewController *rootVC;

@end

@implementation MobiGDTRewardedVideoCustomEvent

- (void)requestRewardedVideoWithCustomEventInfo:(NSDictionary *)info adMarkup:(NSString *)adMarkup {
    NSString *adUnitId = [info objectForKey:@"adunit"];
    
    if (adUnitId == nil) {
        NSError *error =
        [NSError errorWithDomain:MobiRewardedVideoAdsSDKDomain
                            code:MobiRewardedVideoAdErrorInvalidPosid
                        userInfo:@{NSLocalizedDescriptionKey : @"Ad Unit ID cannot be nil."}];
        [self.delegate rewardedVideoDidFailToLoadAdForCustomEvent:self error:error];
        return;
    }
    
    self.rewardVideoAd = [[GDTRewardVideoAd alloc] initWithPlacementId:adUnitId];
    self.rewardVideoAd.delegate = self;
    [self.rewardVideoAd loadAd];
}

/// 上层调用`presentRewardedVideoFromViewController`展示广告之前,
/// 需要判断这个广告是否还有效,需要在此处返回广告有效性(是否可以直接展示)
- (BOOL)hasAdAvailable {
    if (self.rewardVideoAd.expiredTimestamp <= [[NSDate date] timeIntervalSince1970]) {
        return NO;
    }
    if (!self.rewardVideoAd.isAdValid) {
        return NO;
    }
    
    return YES;
}

/// 展示激励视频广告
/// 一般在广告加载成功后调用,需要重写这个类,实现弹出激励视频广告
/// 注意,如果重写的`enableAutomaticImpressionAndClickTracking`方法返回NO,
/// 那么需要自行实现`trackImpression`方法进行数据上报,否则不用处理,交由上层的adapter处理即可
/// @param viewController 弹出激励视频广告的类
- (void)presentRewardedVideoFromViewController:(UIViewController *)viewController {
    if (viewController != nil) {
        self.rootVC = viewController;
    }
    
    if (self.rewardVideoAd.isAdValid == YES) {
        [self.rewardVideoAd showAdFromRootViewController:viewController];
        return;
    }
    
    // We will send the error if the rewarded ad has already been presented.
    NSError *error = [NSError
                      errorWithDomain:MobiRewardedVideoAdsSDKDomain
                      code:MobiRewardedVideoAdErrorNoAdReady
                      userInfo:@{NSLocalizedDescriptionKey : @"Rewarded ad is not ready to be presented."}];
    [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
}

/// 子类重写次方法,决定由谁处理展现和点击上报
/// 默认return YES;由上层adapter处理展现和点击上报,
/// 若return NO;则由子类实现trackImpression和trackClick方法,实现上报,但要保证每个广告只上报一次
- (BOOL)enableAutomaticImpressionAndClickTracking {
    return YES;
}

 /** MoPub's API includes this method because it's technically possible for two MoPub custom events or
  adapters to wrap the same SDK and therefore both claim ownership of the same cached ad. The
  method will be called if 1) this custom event has already invoked
  rewardedVideoDidLoadAdForCustomEvent: on the delegate, and 2) some other custom event plays a
  rewarded video ad. It's a way of forcing this custom event to double-check that its ad is
  definitely still available and is not the one that just played. If the ad is still available, no
  action is necessary. If it's not, this custom event should call
  rewardedVideoDidExpireForCustomEvent: to let the MoPub SDK know that it's no longer ready to play
  and needs to load another ad. That event will be passed on to the publisher app, which can then
  trigger another load.
  */
- (void)handleAdPlayedForCustomEventNetwork {
    if (!self.rewardVideoAd.adValid) {
        [self.delegate rewardedVideoDidExpireForCustomEvent:self];
    }
}

/// 在激励视频系统不再需要这个custom event类时,会调用这个方法,目的是让custom event能够成功释放掉,如果能保证custom event不会造成内存泄漏,则这个方法不用重写
- (void)handleCustomEventInvalidated {
    
}

// MARK: - GDTRewardedVideoAdDelegate

- (void)gdt_rewardVideoAdDidLoad:(GDTRewardVideoAd *)rewardedVideoAd {
//    NSLog(@"eCPM:%ld eCPMLevel:%@", [rewardedVideoAd eCPM], [rewardedVideoAd eCPMLevel]);
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardedVideoDidLoadAdForCustomEvent:)]) {
        [self.delegate rewardedVideoDidLoadAdForCustomEvent:self];
    }
}

// 视频下载完成
- (void)gdt_rewardVideoAdVideoDidLoad:(GDTRewardVideoAd *)rewardedVideoAd {
    NSError *error = nil;
    if (self.rewardVideoAd.expiredTimestamp <= [[NSDate date] timeIntervalSince1970]) {
        error = [NSError errorWithDomain:@"广告已过期，请重新拉取" code:1 userInfo:@{@"广告平台":rewardedVideoAd.adNetworkName}];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(rewardedVideoDidExpireForCustomEvent:)]) {
            [self.delegate rewardedVideoDidExpireForCustomEvent:self];
        }
        
        return;
    }
    if (!self.rewardVideoAd.isAdValid) {
        error = [NSError errorWithDomain:@"广告失效，请重新拉取" code:1 userInfo:@{@"广告平台":rewardedVideoAd.adNetworkName}];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(rewardedVideoDidExpireForCustomEvent:)]) {
            [self.delegate rewardedVideoDidExpireForCustomEvent:self];
        }
        
        return;
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardedVideoAdVideoDidLoadForCustomEvent:)]) {
        [self.delegate rewardedVideoAdVideoDidLoadForCustomEvent:self];
    }
}


- (void)gdt_rewardVideoAdWillVisible:(GDTRewardVideoAd *)rewardedVideoAd {
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardedVideoWillAppearForCustomEvent:)]) {
        [self.delegate rewardedVideoWillAppearForCustomEvent:self];
    }
}

- (void)gdt_rewardVideoAdDidExposed:(GDTRewardVideoAd *)rewardedVideoAd {
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardedVideoDidAppearForCustomEvent:)]) {
        [self.delegate rewardedVideoDidAppearForCustomEvent:self];
    }
}

- (void)gdt_rewardVideoAdDidClose:(GDTRewardVideoAd *)rewardedVideoAd {
    self.rootVC = nil;
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardedVideoWillDisappearForCustomEvent:)]) {
        [self.delegate rewardedVideoWillDisappearForCustomEvent:self];
    }
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardedVideoDidDisappearForCustomEvent:)]) {
        [self.delegate rewardedVideoDidDisappearForCustomEvent:self];
    }
}


- (void)gdt_rewardVideoAdDidClicked:(GDTRewardVideoAd *)rewardedVideoAd {
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardedVideoDidReceiveTapEventForCustomEvent:)]) {
        [self.delegate rewardedVideoDidReceiveTapEventForCustomEvent:self];
    }
}

- (void)gdt_rewardVideoAd:(GDTRewardVideoAd *)rewardedVideoAd didFailWithError:(NSError *)error {
    self.rootVC = nil;
    
    NSString *errorLog = nil;
    
    if (error.code == 4014) {
        errorLog = @"请拉取到广告后再调用展示接口";
    } else if (error.code == 4016) {
        errorLog = @"应用方向与广告位支持方向不一致";
    } else if (error.code == 5012) {
        errorLog = @"广告已过期";
    } else if (error.code == 4015) {
        errorLog = @"广告已经播放过，请重新拉取";
    } else if (error.code == 5002) {
        errorLog = @"视频下载失败";
    } else if (error.code == 5003) {
        errorLog = @"视频播放失败";
    } else if (error.code == 5004) {
        errorLog = @"没有合适的广告";
    } else if (error.code == 5013) {
        errorLog = @"请求太频繁，请稍后再试";
    } else if (error.code == 3002) {
        errorLog = @"网络连接超时";
    } else if (error.code == 5027){
        errorLog = @"页面加载失败";
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardedVideoDidFailToPlayForCustomEvent:error:)]) {
        [self.delegate rewardedVideoDidFailToPlayForCustomEvent:self error:error];
    }
}

- (void)gdt_rewardVideoAdDidRewardEffective:(GDTRewardVideoAd *)rewardedVideoAd {
    
}

- (void)gdt_rewardVideoAdDidPlayFinish:(GDTRewardVideoAd *)rewardedVideoAd {
    if (self.delegate && [self.delegate respondsToSelector:@selector(rewardedVideoAdDidPlayFinishForCustomEvent:didFailWithError:)]) {
        [self.delegate rewardedVideoAdDidPlayFinishForCustomEvent:self didFailWithError:nil];
    }
}

@end
