//
//  LVRTCEngineDefines.h
//  LVRTCEngineDefines
//
//  Copyright © 2021年 LinkV. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreGraphics/CoreGraphics.h>
#if TARGET_OS_IOS
#import <UIKit/UIKit.h>
#else
#import <AppKit/AppKit.h>
#endif


NS_ASSUME_NONNULL_BEGIN

#define LV_EXPORT_CLASS __attribute__((visibility("default")))

/**
 日志打印级别信息
 */
typedef NS_ENUM(NSInteger, LVLoggingSeverity) {
    /**
        打印所有级别的日志信息
     */
    kLVLoggingSeverityVerbose,
    /**
        打印包含 sdk 其他数据信息日志
     */
    kLVLoggingSeverityInfo,
    /**
        只打印警告以上级别日志
     */
    kLVLoggingSeverityWarning,
    /**
        只打印错误日志
     */
    kLVLoggingSeverityError,
    /**
        不打印日志
     */
    kLVLoggingSeverityNone
};

/**
 RTC 错误码汇总
 */
typedef NS_ENUM(NSUInteger, LVErrorCode) {
    
    /**
        SDK 业务操作成功
     */
    LVErrorCodeSuccess = 0,
    
    /**
        参数错误
     */
    LVErrorCodeParamError = 1000,
    
    /**
        没有初始化错误
     */
    LVErrorCodeNotInitError = 1001,
    
    /**
        SDK 没有授权，请先授权再使用
     */
    LVErrorCodeNotAuthError = 1002,
    
    /**
        房间实例初始化错误
     */
    LVErrorCodeInitError = 1003,
    
    /**
       不支持的音视频格式
    */
    LVErrorCodeUnsupportFormat = 1004,
    
    /**
        SDK 授权错误
     */
    LVErrorCodeAuthError = 2000,
    
    /**
        音视频信令服务断开连接错误
     */
    LVErrorCodeDisconnectSignaling = 3000,
    
    /**
        媒体服务断开连接错误
     */
    LVErrorCodeDisconnectMedia = 3001,
    
    /**
        获取不到有效的音视频信令服务
     */
    LVErrorCodeNoEdgeError = 4000,
    
    /**
        网络请求错误（含网络不可达，网络请求超时、40x 系列错误）
     */
    LVErrorCodeNetworkReqError = 4001,
    
    /**
       网络响应错误，无响应内容
    */
    LVErrorCodeNoResponse = 40002,
    
    /**
        网络响应错误（返回数据非法、50x 系列错误）
     */
    LVErrorCodeNetworkRspError = 4003,
    
    /**
        未知错误
     */
    LVErrorCodeUnknownError = 10000
};

/**
 音频数据回调类型（声音数据录制模式）
 */
typedef NS_ENUM(NSInteger, LVAudioRecordType) {
    /**
        不需要回掉音频数据
     */
    LVAudioRecordTypeNone         = 0,
    /**
        只回掉远端用户数据
     */
    LVAudioRecordTypePlayBack     = 0x01,
    /**
        只回掉本地 mic 采集的数据
     */
    LVAudioRecordTypeMicrophone   = 0x02,
    /**
        回掉混音之后的音频数据
     */
    LVAudioRecordTypeMix          = 0x04,
};

/**
 外层视频旋转方向，注意不是视频采集方向
 */
typedef NS_ENUM(NSInteger, LVVideoRotation) {
    /**
        对视频数据进行 0 度旋转
     */
    LVVideoRotation_0          = 0,
    /**
       对视频数据进行 90 度旋转
    */
    LVVideoRotation_90         = 90,
    /**
       对视频数据进行 180 度旋转
    */
    LVVideoRotation_180        = 180,
    /**
       对视频数据进行 270 度旋转
    */
    LVVideoRotation_270        = 270,
};

/**
 前后摄像头枚举
 */
typedef NS_OPTIONS(NSUInteger, LVRTCCameraPosition) {
    /**
        前置摄像头
     */
    LVRTCCameraPositionFront,
    /**
        后置摄像头
     */
    LVRTCCameraPositionBack,
};

/**
 本地预览视频视图的模式
 */
typedef NS_OPTIONS(NSUInteger, LVViewContentMode) {
    /**
     等比缩放，可能有黑边（或白边）
     */
    LVViewContentModeScaleAspectFit     = 0,
    /**
     等比缩放填充整View，可能有部分被裁减
     */
    LVViewContentModeScaleAspectFill    = 1,
    /**
     填充整个View
     */
    LVViewContentModeScaleToFill        = 2,
};

/**
 视频编码参数
 */
typedef NS_ENUM(NSInteger, LVRTCVideoProfile) {
    /**
        320x180   15   300
     */
    LVRTCVideoProfile_180P = 0,
    /**
        480x270   15   500
     */
    LVRTCVideoProfile_270P = 1,
    /**
        640x360   15   800
     */
    LVRTCVideoProfile_360P = 2,
    /**
        640x480   15   1000
     */
    LVRTCVideoProfile_480P = 3,
    /**
        960x540    15   1200
     */
    LVRTCVideoProfile_540P = 4,
    /**
        1280x720  15   1800
     */
    LVRTCVideoProfile_720P = 5,
    /**
        1920x1080  15   2400， 手机端暂不支持 1080P 视频走 RTC，请不要支持使用
     */
    LVRTCVideoProfile_1080P = 6
};

/**
 视频图像翻转操作枚举
 */
typedef enum : NSUInteger {
    /**
        不旋转
     */
    LVImageOrientationNone = 0,
    /**
        画面旋转 90 度
     */
    LVImageOrientationRotate90,
    /**
        向左旋转
     */
    LVImageOrientationRotateLeft = LVImageOrientationRotate90,
    /**
        旋转 180 度
     */
    LVImageOrientationRotate180,
    /**
        画面选择 270 度
     */
    LVImageOrientationRotate270,
    /**
        向右旋转
     */
    LVImageOrientationRotateRight = LVImageOrientationRotate270,
    /**
        竖直翻转
     */
    LVImageOrientationFlipVertical,
    /**
        水平翻转
     */
    LVImageOrientationFlipHorizonal,
    /**
        向左旋转并同时水平翻转
     */
    LVImageOrientationRotateLeftHorizonal,
    /**
        向右旋转并同时水平翻转
     */
    LVImageOrientationRotateRightHorizonal,
    /**
        由程序内部控制旋转方向
     */
    LVImageOrientationAuto
} LVImageOrientation;


typedef enum : NSUInteger {
    /**
        设置 SDK 3A 模式，回声消除、降噪、自动增益
     */
    LVAudio3AModeDisable,
    /**
        使用硬件 3A
     */
    LVAudio3AModeHardware,
    /**
        使用软件 3A
     */
    LVAudio3AModeSoftware,
} LVAudio3AMode;


/**
 外置视频数据类型
 */
typedef enum : NSUInteger {
    /**
        摄像头视频内容
     */
    LVSampleBufferType_Camera,
    /**
        文件视频内容
     */
    LVSampleBufferType_VideoFile,
    /**
        屏幕共享视频内容
     */
    LVSampleBufferType_ScreenShare,
} LVSampleBufferType;

/**
 视频网络自适应j降级策略
 */
typedef enum : NSUInteger {
    /**
        码率自适应，带宽不足时，只会模糊，不降帧率分辨率
    */
    LVVideoDegradationPreference_DISABLED = 0,
    /**
        维持帧率不变，网络糟糕时自动降低分辨率，保持帧率不变
     */
    LVVideoDegradationPreference_MAINTAIN_FRAMERATE = 1,
    
    /**
        维持分辨率不变，也就网络糟糕的时候会降低视频帧率，保持视频分辨率不变
     */
    LVVideoDegradationPreference_MAINTAIN_RESOLUTION = 2,
    
    /**
        根据网络状态自动降低分辨率和帧率（测试功能，请勿使用）
     */
    LVVideoDegradationPreference_BALANCE = 3
    
} LVVideoDegradationPreference;

/**
 音频混音模式
 */
typedef enum : NSUInteger {
    /**
     * 伴奏音乐只用于发送，本地听不到伴奏音乐，远端可听到
     */
    LVAudioMixingMode_SEND_ONLY = (1 << 1),
    /**
     * 伴奏音乐只用于本地播放，远端听不到伴奏音乐
     */
    LVAudioMixingMode_PLAYOUT_ONLY = (1 << 2),
    /**
     * 伴奏音乐本地和远端都可听到
     */
    LVAudioMixingMode_SEND_AND_PLAYOUT = (LVAudioMixingMode_SEND_ONLY | LVAudioMixingMode_PLAYOUT_ONLY),
    /**
     * 替换microphone采集声音，本地和远端都只播放伴奏音乐
     */
    LVAudioMixingMode_REPLACE_MIC = (1 << 0 | LVAudioMixingMode_SEND_AND_PLAYOUT),
    /**
     * 伴奏替换microphone采集声音，同时伴奏声音只用于发送
     */
    LVAudioMixingMode_REPLACE_MIC_AND_SEND_ONLY = (1 << 0 | LVAudioMixingMode_SEND_ONLY)

} LVAudioMixingMode;

/**
 音视频录制支持模式
 */
typedef enum : NSUInteger {
    /**
        仅录制音频
     */
    LVRecorderType_AUDIO = 0,
    /**
        仅录制视频
     */
    LVRecorderType_VIDEO,
    /**
        音频和视频同时录制
     */
    LVRecorderType_AUDIO_AND_VIDEO,
    
} LVRecorderType;



typedef enum : NSUInteger {
    
    /**
        使用默认音频编码器
     */
    LVAudioEncoderMode_DEFAULT = 0,
    
    /**
        音频编码器使用 VOIP 模式编码，通话和视频会议场景建议使用
     */
    LVAudioEncoderMode_VOIP,
    
    /**
        音频编码器使用 MUSIC 模式编码，音乐场景适用
     */
    LVAudioEncoderMode_MUSIC,
} LVAudioEncoderMode;


/// SDK 通用回到 block，code 表示当前操作的结果码
typedef void (^LVServiceCompletion)(LVErrorCode code);

#pragma mark -
#pragma mark - LVUser

LV_EXPORT_CLASS

/// 用户数据
@interface LVUser : NSObject

/// 用户标识
@property (nullable, nonatomic, copy)     NSString*   userId;

/// 用来标识该用户在哪一个房间
@property (nullable, nonatomic, copy)     NSString*   roomId;

/// 拉流 url 集合
@property (nullable, nonatomic, strong)   NSMutableArray<NSString*>* pullUrls;

@end


#pragma mark -
#pragma mark - LVAVConfig
LV_EXPORT_CLASS

/// 音视频参数配置
@interface LVAVConfig : NSObject

/// 视频编码输出分辨率
@property (assign) CGSize videoEncodeResolution;

/// 视频采集分辨率
@property (assign) CGSize videoCaptureResolution;

/// 视频帧率
@property (assign) int fps;

/// 视频最大码率， 单位 bps
@property (assign) int bitrate;

/// 视频最小码率 ，单位 bps
@property (assign) int min_bitrate;

/// 音频码率，单位 bps， 默认为 56kbps，音乐场景建议设置为 128 kbps / 256kbps
@property (assign) int audio_bitrate;

/// 音频编码器编码模式
@property (assign) LVAudioEncoderMode mode;

/// 视频降级策略，默认为维持分辨率大小不变（MAINTAIN_RESOLUTION）
@property (assign) LVVideoDegradationPreference videoDegradationPreference;

/// 使用 SDK 内置的分辨率、帧率和码率初始化 avConfig 对象
/// @param profile 内置视频编码和采集参数
-(instancetype)initWithVideoProfile:(LVRTCVideoProfile)profile;

@end

#pragma mark -
#pragma mark - LVRTCDisplayView

LV_EXPORT_CLASS

/// 视频数据显示类
#if TARGET_OS_IOS
@interface LVRTCDisplayView : UIView
#else
@interface LVRTCDisplayView : NSView

/// 视图 tag 设置
@property (nonatomic)NSInteger tag;
#endif

/// 用户 ID，不传时默认为本地视图，（注：uid  和登录房间时传的 uid 相同时也默认为本地视图）
@property (nonatomic,copy)NSString *uid;

/// 设置视图填充模式
@property (nonatomic)LVViewContentMode viewContentMode;

/// 是否是当前用户视图（加入房间之前可以通过该字段预览摄像头数据）
@property (nonatomic)BOOL isLocal;

/// 设置当前视图的旋转方向
/// @param orientation 旋转方向
-(void)setOrientation:(LVImageOrientation)orientation;

@end


#pragma mark -
#pragma mark - LVVideoStatistic

LV_EXPORT_CLASS

/// 音视频数据统计信息
@interface LVVideoStatistic : NSObject

/// 视频编码帧数量
@property (nonatomic, assign) int       videoEncodeFrames;

/// 视频总发送包数量
@property (nonatomic, assign) int       videoSentPackets;

/// 视频总发送字节数
@property (nonatomic, assign) long long videosentKbytes;

/// 视频发送总字节数
@property (nonatomic, assign) long long videoreceKbytes;

/// 视频输入、输出帧率（视频帧率）
@property (nonatomic, assign) int       videoFps;

/// 视频丢包总数
@property (nonatomic, assign) int       videoLostPackets;

/// 音频丢包总数
@property (nonatomic, assign) int       audioLostPackets;

/// 当前可用的发送带宽
@property (nonatomic, assign) int       availableSendBandwidth;

/// 视频码率
@property (nonatomic, assign) int       videoBitratebps;

/// 音频码率
@property (nonatomic, assign) int       audioBitratebps;

/// 视频编码耗时（单位毫米），仅对视频发送方有效
@property (nonatomic, assign) int       videoAvgEncodeCostMs;

/// 音频包 RTT，单位 ms
@property (nonatomic, assign) int       audioRtt;

/// 视频包 RTT，单位 ms
@property (nonatomic, assign) int       videoRtt;

/// 累计视频丢包百分比
@property (nonatomic, assign) int       videoLostPercent;

/// 累计音频丢包百分比
@property (nonatomic, assign) int       audioLostPercent;

/// 推流：编码视频宽，拉流：输入视频帧宽
@property (nonatomic, assign) int       frameWidth;

/// 推流：编码视频高，拉流：输入视频帧高
@property (nonatomic, assign) int       frameHeight;

@property (nonatomic, assign) float      cpuusage;

@property (nonatomic, assign) float     memoryusage;


@end



#pragma mark -
#pragma mark - LVAudioVolume

LV_EXPORT_CLASS

/// 用户音量信息
@interface LVAudioVolume : NSObject

/// 用户标识
@property (nullable, nonatomic, copy)     NSString*   userId;

/// 音量
@property (nonatomic, assign) int       volume;

@end

#pragma mark -
#pragma mark - LVExternalAudioConfig

LV_EXPORT_CLASS

/// 外置音频采集参数配置
@interface LVExternalAudioConfig : NSObject

/// 外置音频采集输入采样率（默认 48000）
@property (nonatomic,assign)int sampleRate;

/// 外置音频采集输入频道数 （默认 1）
@property (nonatomic,assign)int channels;

/// 每个 buffer 输入的数据长度（该参数必须和 sendAudioBuffer 的接口传入的数据长度一致）
@property (nonatomic,assign)int framesPerBuffer;

@end

#pragma mark -
#pragma mark - LVMixStreamInput

LV_EXPORT_CLASS

/// 用户视频位置配置
@interface LVMixStreamInput : NSObject


/// 用户标识
@property (nullable, nonatomic, copy)     NSString*   userId;


/// 混流用户视频在画布中的位置
@property (nonatomic, assign)   CGRect      mixRect;

@end


#pragma mark -
#pragma mark - LVMixStreamConfig

LV_EXPORT_CLASS

/// 混流配置
@interface LVMixStreamConfig : NSObject

/// 输出帧率
@property (nonatomic, assign)   int outputFps;

/// 输出码率
@property (nonatomic, assign)   int outputBitrate;

/// 混流分辨率
@property (nonatomic, assign)   CGSize mixSize;

/// 输入流列表
@property (nullable, nonatomic, strong)   NSArray<NSString*>* pushUrls;

/// 输入流列表
@property (nullable, nonatomic, strong)   NSMutableArray<LVMixStreamInput*>* inputStreamList;

/// 混流背景颜色
@property (nullable, nonatomic, copy)     NSString* outputBackgroundColor;

/// 混流背景图
@property (nullable, nonatomic, copy)     NSString *outputBackgroundImage;

@end


#pragma mark -
#pragma mark - LVMixStreamConfig

LV_EXPORT_CLASS

/// 网络探测结果
@interface LVNetworkProbeContent : NSObject

/// 当前网络探测最优节点 RTT 平均值
@property (nonatomic)int rtt;
@end

#pragma mark -
#pragma mark - LVLogger

LV_EXPORT_CLASS

/// RTC 底层日志打印服务
@interface LVLogger : NSObject

/// 内部日志打印逻辑，推挤使用宏定义的方式使用
/// @param flag 日志类型
/// @param function 日志所在函数
/// @param format 格式
/// @param ... 字符串格式化
+(void)log:(LVLoggingSeverity)flag function:(const char *)function format:(NSString *)format, ... NS_FORMAT_FUNCTION(3,4);

@end

/// 基础美颜功能实现
@interface LVBeautyManager : NSObject

/// 设置滤镜美颜级别
/// @param beautyLevel 有效值范围[0.0f - 1.0f]，默认值为 -1，关闭设置
- (void)setBeautyLevel:(float)beautyLevel;

/// 设置滤镜明亮度
/// @param brightLevel 有效值范围[0.0f-1.0f]，默认值为-1，关闭设置
- (void)setBrightLevel:(float)brightLevel;

/// 设置滤镜饱和度
/// @param toneLevel 有效值范围[0.0f-1.0f]，默认值为-1，关闭设置
- (void)setToneLevel:(float)toneLevel;
@end


#define LV_LOGV(frmt, ...)    [LVLogger log:(kLVLoggingSeverityVerbose) function:__PRETTY_FUNCTION__ format:frmt,##__VA_ARGS__]

#define LV_LOGE(frmt, ...)      [LVLogger log:(kLVLoggingSeverityError) function:__PRETTY_FUNCTION__ format:frmt,##__VA_ARGS__]

#define LV_LOGW(frmt, ...)       [LVLogger log:(kLVLoggingSeverityWarning) function:__PRETTY_FUNCTION__ format:frmt,##__VA_ARGS__]

#define LV_LOGI(frmt, ...)       [LVLogger log:(kLVLoggingSeverityInfo) function:__PRETTY_FUNCTION__ format:frmt,##__VA_ARGS__]

NS_ASSUME_NONNULL_END
