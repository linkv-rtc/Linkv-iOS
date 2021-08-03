//
//  RTCNetworkManager.h
//  CMLiveSDK
//
//  Created by jfdreamyang on 2019/12/5.
//  Copyright © 2019 jfdreamyang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LinkV/LinkV.h>

#define CM_WZ_DEBUG false
#define kEnableAutoTest false

#define CM_APP_STORE_VERSION false

NS_ASSUME_NONNULL_BEGIN


@interface LVRTCEngine (PrivateFunc)
-(NSString *)getAppID;
@end


typedef enum : NSUInteger {
    // 仅仅表示网络请求成功，返回参数没有校验
    RTCErrorCodeSuccess = 0,
    RTCErrorCodeParamIllegal = 40005,
    RTCErrorCodeRequestError = 40006,
    RTCErrorCodeResponseError = 40007,
    RTCErrorCodeResponseUnknown = 40008,
} RTCErrorCode;

typedef void(^RTCRequestCompletion)(NSDictionary * _Nullable result,RTCErrorCode httpCode);

typedef void(^RTCAuthCompletion)(BOOL success);

typedef enum : NSUInteger {
    RTCApiNameRoomList,
    RTCApiNameGenRoom,
    RTCApiNameRoomStatus,
    RTCApiNameUpdateRoom,
    RTCApiNameGetVendor
} RTCApiName;

typedef enum : NSUInteger {
    RTCEnvironmentTest,
    RTCEnvironmentProduction,
} RTCEnvironment;


typedef enum : NSUInteger {
    RTCAppTypeChina = 0,
    RTCAppTypeInternational,
} RTCAppType;

//state: ０:初始化, １:创建, ２:开始直播, 3:直播结束
typedef enum : NSUInteger {
    RTCRoomStatusInit = 0,
    RTCRoomStatusCreate,
    RTCRoomStatusLive,
    RTCRoomStatusStop
} RTCRoomStatus;

typedef enum : NSUInteger {
    RTCLiveTypeNormal,
    RTCLiveTypeConference,
    RTCLiveTypeAudioMode,
} RTCLiveType;


@protocol RTCNetworkManagerDelegate <NSObject>

-(void)keyframeSize:(int)keyframe_size deltaSize:(int)delta_size;

@end

@interface RTCNetworkManager : NSObject

@property (nonatomic,strong)NSString *roomId;
@property (nonatomic,strong)NSString *userId;
@property (nonatomic,copy,readonly)NSString *mAppId;
@property (nonatomic,copy,readonly)NSString *mAppSign;
@property (nonatomic,weak)id <RTCNetworkManagerDelegate> delegate;
@property (nonatomic,copy,readonly)NSString *appServerAppID;

@property (nonatomic,assign)BOOL isHost;
@property (nonatomic,copy,readonly)NSString *suffix;
@property (nonatomic,copy,readonly)NSString *roomSuffix;
@property (nonatomic,assign)RTCLiveType type;
@property (nonatomic,assign)LVErrorCode authCode;
@property (nonatomic,assign,readonly)RTCEnvironment environment;
@property (nonatomic,assign)RTCAppType appType;


@property (nonatomic,strong)NSString *manualRoomID;
@property (nonatomic,strong)NSString *manualUserID;
@property (nonatomic,strong)NSString *manualEdgeURL;
@property (nonatomic,strong)NSString *centerIP;

@property (nonatomic,assign,readonly)int *items;

-(NSString *)liveMeAppID;

-(void)fixEnvironment:(RTCEnvironment)environment;


/// 网络请求工具
+(RTCNetworkManager *)sharedManager;

/// 发送一个 post 请求
/// @param params 请求参数
/// @param completion 请求结果回调
-(void)POST:(NSDictionary *)params name:(RTCApiName)name completion:(RTCRequestCompletion)completion;


-(void)POST:(NSDictionary *)body api:(NSString *)api completion:(RTCRequestCompletion)completion;

/// 发送一个 GET 请求
/// @param params 请求参数
/// @param name  API 接口名称
/// @param completion 请求完成回掉
-(void)GET:(NSDictionary *)params name:(RTCApiName)name completion:(RTCRequestCompletion)completion;

/// 清空所有房间，测试时使用
-(void)clearAllRoom;

/// 更新房间状态
/// @param status 更新房间状态
-(void)update:(NSInteger)status;

/// 设置音视频环境
/// @param environment 环境
-(void)setEnvironment:(RTCEnvironment)environment;


/// 鉴权
/// @param completion 健全完成回掉
-(void)auth:(RTCAuthCompletion)completion;

@end

NS_ASSUME_NONNULL_END
