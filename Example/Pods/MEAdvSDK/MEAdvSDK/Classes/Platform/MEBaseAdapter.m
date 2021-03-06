//
//  MEBaseAdapter.m
//  MEAdvSDK
//
//  Created by 刘峰 on 2019/11/7.
//

#import "MEBaseAdapter.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation MEBaseAdapter

+ (instancetype)sharedInstance {
    static MEBaseAdapter *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[MEBaseAdapter alloc] init];
    });
    return sharedInstance;
}

/// 初始化相应广告平台
+ (void)launchAdPlatformWithAppid:(NSString *)appid {}
/// 返回对应平台的缩写,穿山甲-tt,广点通-gdt,快手-ks,谷歌-admob,valpub-gdt2
+ (NSString *)networkName {return nil;}

/// 获取顶层VC
- (UIViewController *)topVC {
    if (_topVC != nil) {
        return _topVC;
    }
    
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

- (NSMutableString *)stringMD5:(NSString *)string {
    const char *data = [string UTF8String];
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];

    CC_MD5(data, (CC_LONG)strlen(data), result);
    NSMutableString *mString = [NSMutableString string];
    for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
        //02:不足两位前面补0,   %02x:十六进制数
        [mString appendFormat:@"%02x",result[i]];
    }
    
    return mString;
}

// 设置广告平台参数
- (void)setAdParams:(NSDictionary *)dicParam {}

// MARK: - 信息流原生模板
/// 信息流预加载,并存入缓存
/// @param feedWidth 信息流宽度
/// @param posId 广告位id
- (void)saveFeedCacheWithWidth:(CGFloat)feedWidth
                         posId:(NSString *)posId {}

/// 显示信息流视图
/// @param feedWidth 广告位宽度
- (BOOL)showFeedViewWithWidth:(CGFloat)feedWidth
                        posId:(NSString *)posId
                        count:(NSInteger)count {return NO;}
                        
/// 显示信息流视图
/// @param feedWidth 广告位宽度
/// @param displayTime 展示时长
- (BOOL)showFeedViewWithWidth:(CGFloat)feedWidth
                        posId:(NSString *)posId
                        count:(NSInteger)count
              withDisplayTime:(NSTimeInterval)displayTime {return NO;}

/// 移除信息流视图
- (void)removeFeedViewWithPosid:(NSString *)posid {}

// MARK: - 信息流自渲染
/// 信息流预加载,并存入缓存
/// @param posId 广告位id
- (void)saveRenderFeedCacheWithPosId:(NSString *)posId {}

/// 显示自渲染的信息流视图
- (BOOL)showRenderFeedViewWithPosId:(NSString *)posId {return NO;}

/// 移除自渲染信息流视图
- (void)removeRenderFeedViewWithPosid:(NSString *)posid {}

// MARK: - 激励视频广告
- (BOOL)hasRewardedVideoAvailableWithPosid:(NSString *)posid {return YES;}
/// 加载激励视频
- (BOOL)loadRewardVideoWithPosid:(NSString *)posid {return NO;}
/// 展示激励视频
- (void)showRewardedVideoFromViewController:(UIViewController *)rootVC posid:(NSString *)posid {}
/// 关闭当前视频
- (void)stopCurrentVideoWithPosid:(NSString *)posid {}

// MARK: - 全屏视频广告
/// 全屏视频是否有效
- (BOOL)hasFullscreenVideoAvailableWithPosid:(NSString *)posid {return NO;}
/// 加载全屏视频
- (BOOL)loadFullscreenWithPosid:(NSString *)posid {return NO;}
/// 展示全屏视频
- (void)showFullscreenVideoFromViewController:(UIViewController *)rootVC posid:(NSString *)posid {}
/// 关闭当前视频
- (void)stopFullscreenVideoWithPosid:(NSString *)posid {}

// MARK: - 开屏广告
/// 预加载开屏广告
- (void)preloadSplashWithPosid:(NSString *)posid {}
/// 展示开屏页
- (BOOL)loadAndShowSplashWithPosid:(NSString *)posid {return NO;}
/// 展示带底部logo的开屏页
- (BOOL)loadAndShowSplashWithPosid:(NSString *)posid delay:(NSTimeInterval)delay bottomView:(UIView *)view {return NO;}
/// 停止开屏广告渲染,可能因为超时等原因
- (void)stopSplashRenderWithPosid:(NSString *)posid {}

// MARK: - 插屏广告
- (BOOL)hasInterstitialAvailableWithPosid:(NSString *)posid {return NO;}
/// 加载插屏页
- (BOOL)loadInterstitialWithPosid:(NSString *)posid {return NO;}
/// 展示插屏页
- (void)showInterstitialFromViewController:(UIViewController *)rootVC posid:(NSString *)posid {}
/// 停止插屏
- (void)stopInterstitialWithPosid:(NSString *)posid {}
@end
