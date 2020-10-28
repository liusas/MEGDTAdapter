//
//  MEGDTAdapter.m
//  MobiAdSDK
//
//  Created by 刘峰 on 2020/9/25.
//

#import "MEGDTAdapter.h"
#import <GDTMobSDK/GDTSDKConfig.h>

#if __has_include("MobiPub.h")
#import "MPLogging.h"
#import "MobiRewardedVideoError.h"
#import "MobiRewardedVideoReward.h"
#endif

// Initialization configuration keys
NSString * const kGDTAppID = @"appid";

// Errors
static NSString * const kAdapterErrorDomain = @"com.mobipub.mobipub-ios-sdk.mobipub-gdt-adapter";

typedef NS_ENUM(NSInteger, GDTAdapterErrorCode) {
    GDTAdapterErrorCodeMissingAppId,
};

@implementation MEGDTAdapter

#pragma mark - Caching

+ (void)updateInitializationParameters:(NSDictionary *)parameters {
    // These should correspond to the required parameters checked in
    // `initializeNetworkWithConfiguration:complete:`
    NSString * appId = parameters[kGDTAppID];
    
    if (appId != nil) {
        NSDictionary * configuration = @{ kGDTAppID: appId };
        [MEGDTAdapter setCachedInitializationParameters:configuration];
    }
}

#pragma mark - MPAdapterConfiguration

- (NSString *)adapterVersion {
    return @"1.0.7";
}

- (NSString *)biddingToken {
    return nil;
}

- (NSString *)mobiNetworkName {
    return @"gdt";
}

- (NSString *)networkSdkVersion {
    return [GDTSDKConfig sdkVersion];
}

#pragma mark - MobiPub ad type
- (Class)getSplashCustomEvent {
    return NSClassFromString(@"MobiGDTSplashCustomEvent");
}

- (Class)getBannerCustomEvent {
    return NSClassFromString(@"MobiGDTBannerCustomEvent");
}

- (Class)getFeedCustomEvent {
    return NSClassFromString(@"MobiGDTFeedCustomEvent");
}

- (Class)getInterstitialCustomEvent {
    return NSClassFromString(@"MobiGDTInterstitialCustomEvent");
}

- (Class)getRewardedVideoCustomEvent {
    return NSClassFromString(@"MobiGDTRewardedVideoCustomEvent");
}

- (Class)getFullscreenCustomEvent {
    return NSClassFromString(@"MobiGDTFullscreenCustomEvent");
}

- (void)initializeNetworkWithConfiguration:(NSDictionary<NSString *,id> *)configuration complete:(void (^)(NSError * _Nullable))complete {

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSString *appid = configuration[kGDTAppID];
        BOOL result = [GDTSDKConfig registerAppId:kGDTAppID];
        if (result) {
            if (complete != nil) {
                complete(nil);
            }
        } else {
            NSError *error = [NSError
                              errorWithDomain:MobiRewardedVideoAdsSDKDomain
                              code:MobiRewardedVideoAdErrorNoAdReady
                              userInfo:@{NSLocalizedDescriptionKey : @"Rewarded ad is not ready to be presented."}];
            
            if (complete != nil) {
                complete(error);
            }
        }
    });
}

// MoPub collects GDPR consent on behalf of Google
+ (NSString *)npaString
{
//    return !MobiPub.sharedInstance.canCollectPersonalInfo ? @"1" : @"";
    return @"";
}

/// 获取顶层VC
+ (UIViewController *)topVC {
    UIWindow *rootWindow = [UIApplication sharedApplication].keyWindow;
    if (![[UIApplication sharedApplication].windows containsObject:rootWindow]
        && [UIApplication sharedApplication].windows.count > 0) {
        rootWindow = [UIApplication sharedApplication].windows[0];
    }
    UIViewController *topVC = rootWindow.rootViewController;
    // 未读到keyWindow的rootViewController，则读UIApplicationDelegate的window，但该window不一定存在
    if (nil == topVC && [[UIApplication sharedApplication].delegate respondsToSelector:@selector(window)]) {
        topVC = [UIApplication sharedApplication].delegate.window.rootViewController;
    }
    while (topVC.presentedViewController) {
        topVC = topVC.presentedViewController;
    }
    return topVC;
}

@end
