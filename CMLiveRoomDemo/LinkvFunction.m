//
//  LinkvFunction.m
//  LinkV
//
//  Created by liveme on 2021/8/3.
//  Copyright © 2021 Liveme. All rights reserved.
//

#import "LinkvFunction.h"

// mini online
#define PRODUCT  @"XYWAhtXcWoApAUCXeTZjbcSvdrrunAhj"
#define PRODUCT_SIGN    @"09FAF2A1AC61DA50E6C8FBED654186DCAFF206FCFE4A932093728E209A4476CB5D2E725CE7261DE19DC9F28902F83725E84938C8CCC35670C647E6A2E8EE998DB1DA091197137A9473B096826062673BCB21829872BFE32FF12F20AE9AD58897570508D8A9508CBD7BF3AA5C0E46B1DE26E297BE4FDEF8D16100ADA107F5D7C3CD176308F29DC4332EC725F438B80FC24A2DBC0D484F93DDE894F52FD1F309FEA63E54FF04EA8BA22D04A26637E99FAAB1B81805B812C542B16EF498E076DB85"

// mini qa
#define TEST_ENVIR  @"WFYptoftuSpnGqxDuvUWtsHPqEXjlrNy"
#define TEST_ENVIR_SIGN    @"9A6A02308AF796DDFA9FA1DDF1C71811BDB5F2565FBE0000DDA625C0A195F8572CD8A62A207783402A9E262FE5E1206DE923AF6471F6501D665CEC0E8027406B5B0DB802DED9C9D668AAF581FF631CE805D3BD33AADC8F7993E03896908B75FAEA9CBE255A14F612AE473DC7604CB521"

typedef void(^LinkvAuthCompletion)(BOOL success, NSString *uuid);

typedef void(^LinkvJoinCompletion)(NSString* _Nonnull channel, NSUInteger uid, NSInteger elapsed);


typedef enum : NSUInteger {
    LinkvRoomStateIdle,
    LinkvRoomStateDisconnect,
    LinkvRoomStateConnected,
} LinkvRoomState;


@interface LVRTCEngine (Private)
-(void)handleVideoFrame:(CMSampleBufferRef)cameraBuffer rotation:(LVVideoRotation)rotation isFaceCamera:(BOOL)isFaceCamera;
@end


@implementation HinowView

@end

@interface LinkvFunction ()<LVRTCEngineDelegate>
@property (nonatomic,weak)id<IRtcEventManager> delegate;
@property (nonatomic,weak)id<AudioFrameObserver> observer;
@property (nonatomic,weak)id<AgoraVideoSourceProtocol> source;
@end



@implementation LinkvFunction
{
    int _clientRole;
    int _clientProfile;
    int _currentUserId;
    NSString *_channelId;
    AgoraChannelStats *_lastStats;
    LVRTCDisplayView *_remoteDisplayView;
    bool _firstFrameReported;
    bool _firstFramePublishReported;
    BOOL _isAuthSucceed;
    BOOL _isJoining;
    LinkvRoomState _roomState;
    NSMutableArray *_viewModels;
    int64_t _startTime;
    LinkvJoinCompletion _completion;
}

+(instancetype)sharedFunction{
    static LinkvFunction *_function = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _function = [[self alloc]init];
    });
    return _function;
}

-(id<AgoraFunction>)create:(NSString *)appId handler:(id<IRtcEventManager>)handler{
    self.delegate = handler;
    _viewModels = [NSMutableArray new];
    return self;
}

-(void)auth:(LinkvAuthCompletion)completion{
    NSString *uuid = [NSUUID UUID].UUIDString;
    if (_isAuthSucceed) {
        completion(YES, uuid);
    }
    else{
        bool isTest = true;
        [LVRTCEngine setUseTestEnv:isTest];
        NSString *appId = isTest ? TEST_ENVIR : PRODUCT;
        NSString *skStr = isTest ? TEST_ENVIR_SIGN : PRODUCT_SIGN;
        LV_LOGI(@"auth: %@", uuid);
        
        // 设置推流质量监控回调间隔
        [LVRTCEngine setPublishQualityMonitorCycle:1];
        [[LVRTCEngine sharedInstance] auth:appId skStr:skStr userId:uuid completion:^(LVErrorCode code) {
            _isAuthSucceed = (code == LVErrorCodeSuccess);
            completion(_isAuthSucceed, uuid);
        }];
    }
}

-(void)setLogFilter:(int)filter{
    switch (filter) {
        case AgoraLogFilterOff:
            [LVRTCEngine setLogLevel:(kLVLoggingSeverityNone)];
            break;
        case AgoraLogFilterDebug:
            [LVRTCEngine setLogLevel:(kLVLoggingSeverityVerbose)];
            break;
        case AgoraLogFilterInfo:
            [LVRTCEngine setLogLevel:(kLVLoggingSeverityInfo)];
            break;
        case AgoraLogFilterWarning:
            [LVRTCEngine setLogLevel:(kLVLoggingSeverityWarning)];
            break;
        case AgoraLogFilterError:
            [LVRTCEngine setLogLevel:(kLVLoggingSeverityError)];
            break;
        case AgoraLogFilterCritical:
            [LVRTCEngine setLogLevel:(kLVLoggingSeverityInfo)];
            break;
        default:
            break;
    }
}

-(void)fileSizeInKBytes:(int)fileSizeInKBytes{
    // SDK 内部默认日志保存大小为 3M，最多保存 15 个文件，日志获取成功后自动删除
    LV_LOGI(@"fileSizeInKBytes:%d", fileSizeInKBytes);
}

-(int)setVideoEncoderConfiguration:(AgoraVideoEncoderConfiguration *)config{
    // 以 720P 进行视频采集，以用户自定义分辨率进行编码
    LVAVConfig *avConfig = [[LVAVConfig alloc]initWithVideoProfile:(LVRTCVideoProfile_720P)];
    avConfig.videoEncodeResolution = config.dimensions;
    avConfig.bitrate = (int)config.bitrate * 1000;
    avConfig.min_bitrate = (int)config.minBitrate * 1000;
    avConfig.fps = (int)config.frameRate;
    switch (config.degradationPreference) {
        case AgoraDegradationMaintainFramerate:{
            avConfig.videoDegradationPreference = LVVideoDegradationPreference_MAINTAIN_FRAMERATE;
        }
            break;
            
        case AgoraDegradationBalanced:{
            avConfig.videoDegradationPreference = LVVideoDegradationPreference_BALANCE;
        }
            break;
            
        default:
            avConfig.videoDegradationPreference = LVVideoDegradationPreference_MAINTAIN_RESOLUTION;
            break;
    }
    [[LVRTCEngine sharedInstance] setAVConfig:avConfig];
    return 0;
}

-(void)enableVideo{
    // SDK 内部默认视频是打开的，此处不需要调用该功能
}

-(int)setChannelProfile:(int)profile{
    _clientProfile = profile;
    return 0;
}

-(int)setPlaybackAudioFrameParameters:(int)sampleRate channel:(int)channel mode:(int)mode samplesPerCall:(int)samplesPerCall{
    return 0;
}

-(int)setClientRole:(int)role{
    _clientRole = role;
    return 0;
}

-(int)setVideoSource:(id<AgoraVideoSourceProtocol>)source{
    source.consumer = self;
    if (_roomState == LinkvRoomStateConnected) {
        [[LVRTCEngine sharedInstance] startPublishing];
    }
    self.source = source;
    return 0;
}

- (int)joinChannelByToken:(NSString* _Nullable)token channelId:(NSString* _Nonnull)channelId info:(NSString* _Nullable)info uid:(NSUInteger)uid joinSuccess:(void (^_Nullable)(NSString* _Nonnull channel, NSUInteger uid, NSInteger elapsed))joinSuccessBlock{
    
    NSString *userId = [NSString stringWithFormat:@"%d", (int)uid];
    bool isHost = false;
    _channelId = channelId;
    if (_clientRole == AgoraClientRoleBroadcaster) {
        isHost = true;
    }
    _lastStats = [[AgoraChannelStats alloc]init];
    // 增加正在加入中的熟悉，由于首次调用存在鉴权，故需要等鉴权完成之后调用加入房间接口，用户如果未等鉴权成功就离开，则不需要调用加入房间流程
    _roomState = LinkvRoomStateIdle;
    _currentUserId = (int)uid;
    _completion = joinSuccessBlock;
    _isJoining = YES;
    // SDK 仅鉴权一次
    [self auth:^(BOOL success, NSString *uuid) {
        if (success && _isJoining) {
            [[LVRTCEngine sharedInstance] loginRoom:userId roomId:channelId isHost:isHost isOnlyAudio:false delegate:self];
        }
        else{
            LV_LOGE(@"auth result:%@, uuid:%@ joining:%@", @(success == YES), uuid, @(_isJoining));
        }
    }];
    return 0;
}

- (int)leaveChannel:(void (^_Nullable)(AgoraChannelStats* _Nonnull stat))leaveChannelBlock{
    _completion = nil;
    // 如果用户未加入房间，则直接退出即可
    _firstFrameReported = false;
    _firstFramePublishReported = false;
    _roomState = LinkvRoomStateIdle;
    @synchronized (self) {
        for (HinowView *model in _viewModels) {
            [[LVRTCEngine sharedInstance] removeDisplayView:model.linkv];
        }
        [_viewModels removeAllObjects];
    }
    if (!_isJoining) return 0;
    _isJoining = NO;
    leaveChannelBlock(_lastStats);
    [[LVRTCEngine sharedInstance] logoutRoom:^(LVErrorCode code) {
        LV_LOGI(@"logoutRoom:%ld", (long)code);
    }];
    return 0;
}

-(int)enableLocalAudio:(BOOL)enabled{
    [[LVRTCEngine sharedInstance] enableMic:enabled];
    return 0;
}

-(int)muteLocalAudioStream:(bool)muted{
    [[LVRTCEngine sharedInstance] enableMic:!muted];
    return 0;
}

-(int)setEnableSpeakerphone:(BOOL)enableSpeaker{
    [[LVRTCEngine sharedInstance] enableSpeakerphone:enableSpeaker];
    return 0;
}

-(int)registerAudioFrameObserver:(id<AudioFrameObserver>)observer{
    self.observer = observer;
    [[LVRTCEngine sharedInstance] setAudioRecordFlag:(LVAudioRecordTypePlayBack | LVAudioRecordTypeMicrophone)];
    return 0;
}

-(int)muteRemoteAudioStream:(int)uid mute:(bool)muted{
    NSString *userId = [NSString stringWithFormat:@"%d", uid];
    int volume = muted ? 0 : 100;
    [[LVRTCEngine sharedInstance] setPlayVolume:volume userId:userId];
    return 0;
}

-(int)setupRemoteVideo:(HinowView *)surfaceView{
    if (!surfaceView.linkv || !surfaceView.linkv.uid) {
        LV_LOGI(@"Invalid surfaceView, linkv is nil or uid is nil");
        return -1;
    }
    @synchronized (self) {
        [_viewModels addObject:surfaceView];
    }
    LV_LOGI(@"setupRemoteVideo:%@", surfaceView.linkv.uid);
    [[LVRTCEngine sharedInstance] addDisplayView:surfaceView.linkv];
    if (_roomState == LinkvRoomStateConnected) {
        [[LVRTCEngine sharedInstance] startPlayingStream:surfaceView.linkv.uid];
    }
    return 0;
}

-(int)setRemoteVideoStreamType:(int)uid streamType:(int)streamType{
    return 0;
}

-(int)setParameters:(NSString* _Nonnull)options{
    return 0;
}
-(int)startPreview{
    return 0;
}

-(int)stopPreview{
    return 0;
}

-(int)switchCamera{
    return 0;
}


#pragma mark - AgoraVideoFrameConsumer
- (void)consumePixelBuffer:(CVPixelBufferRef _Nonnull)pixelBuffer withTimestamp:(CMTime)timestamp rotation:(AgoraVideoRotation)rotation{
    CMTime currentTime = timestamp;
    CMTime decodeTime = timestamp;
    CMTime duration = kCMTimeInvalid;
    CMVideoFormatDescriptionRef videoInfo = NULL;
    CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &videoInfo);
    if (!videoInfo) {
        LV_LOGE(@"Invalid video info");
        return;
    }
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    CMSampleTimingInfo timing = {duration, currentTime, decodeTime};
    CMSampleBufferRef processedSampleBuffer = NULL;
    CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault, pixelBuffer, YES, NULL, NULL, videoInfo, &timing, &processedSampleBuffer);
    CFRelease(videoInfo);
    CVPixelBufferUnlockBaseAddress(pixelBuffer, 0);
    if (!processedSampleBuffer) {
        LV_LOGE(@"Invalid processedSampleBuffer");
        return;
    }
    LVVideoRotation lvRotation;
    switch (rotation) {
        case AgoraVideoRotationNone:
            lvRotation = LVVideoRotation_0;
            break;
        case AgoraVideoRotation90:
            lvRotation = LVVideoRotation_90;
            break;
        case AgoraVideoRotation180:
            lvRotation = LVVideoRotation_180;
            break;
        case AgoraVideoRotation270:
            lvRotation = LVVideoRotation_270;
            break;
        default:
            break;
    }
    [[LVRTCEngine sharedInstance] handleVideoFrame:processedSampleBuffer rotation:lvRotation isFaceCamera:NO];
    CFRelease(processedSampleBuffer);
}

- (void)consumeRawData:(void* _Nonnull)rawData withTimestamp:(CMTime)timestamp format:(AgoraVideoPixelFormat)format size:(CGSize)size rotation:(AgoraVideoRotation)rotation{}


#pragma mark - LVRTCEngineDelegate
- (void)OnRoomReconnected{
    LV_LOGI(@"%s", __func__);
    if ([self.delegate respondsToSelector:@selector(rtcEngine:connectionChangedToState:reason:)]) {
        [self.delegate rtcEngine:self connectionChangedToState:AgoraConnectionStateConnected reason:0];
    }
}

- (void)OnEnterRoomComplete:(LVErrorCode)code users:(nullable NSArray<LVUser*>*)users{
    if (_completion) {
        _completion(_channelId, _currentUserId, 0);
    }
    _completion = nil;
    if ([self.delegate respondsToSelector:@selector(rtcEngine:didJoinChannel:withUid:elapsed:)]) {
        [self.delegate rtcEngine:self didJoinChannel:_channelId withUid:_currentUserId elapsed:0];
    }
    
    for (LVUser *user in users) {
        int uid = [user.userId intValue];
        if (uid == _currentUserId) {
            continue;
        }
        if ([self.delegate respondsToSelector:@selector(rtcEngine:didJoinedOfUid:elapsed:)]) {
            [self.delegate rtcEngine:self didJoinedOfUid:uid elapsed:0];
        }
        @synchronized (self) {
            for (HinowView *view in _viewModels) {
                if (view.linkv.uid.intValue == uid) {
                    [[LVRTCEngine sharedInstance] startPlayingStream:view.linkv.uid];
                    break;
                }
            }
        }
    }
    _startTime = (long long)(NSDate.date.timeIntervalSince1970 * 1000);
    _roomState = LinkvRoomStateConnected;
    if (self.source) {
        [[LVRTCEngine sharedInstance] startPublishing];
    }
}

- (void)OnExitRoomComplete{
    if ([self.delegate respondsToSelector:@selector(rtcEngine:didLeaveChannelWithStats:)]) {
        [self.delegate rtcEngine:self didLeaveChannelWithStats:_lastStats];
    }
}

- (void)OnRoomDisconnected:(LVErrorCode)code{
    LV_LOGE(@"OnRoomDisconnected:%d", (int)code);
    if ([self.delegate respondsToSelector:@selector(rtcEngineConnectionDidLost:)]) {
        [self.delegate rtcEngineConnectionDidLost:self];
    }
    
    if ([self.delegate respondsToSelector:@selector(rtcEngine:connectionChangedToState:reason:)]) {
        [self.delegate rtcEngine:self connectionChangedToState:AgoraConnectionStateFailed reason:0];
    }
    
    if ([self.delegate respondsToSelector:@selector(rtcEngine:didOccurError:)]) {
        [self.delegate rtcEngine:self didOccurError:(AgoraErrorCode)LinkvErrorCode_RoomDisconnected];
    }
    _roomState = LinkvRoomStateDisconnect;
}

- (void)OnAddRemoter:(LVUser *)user{
    int uid = [user.userId intValue];
    if ([self.delegate respondsToSelector:@selector(rtcEngine:didJoinedOfUid:elapsed:)]) {
        [self.delegate rtcEngine:self didJoinedOfUid:uid elapsed:0];
    }
    @synchronized (self) {
        for (HinowView *view in _viewModels) {
            if (view.linkv.uid.intValue == uid) {
                [[LVRTCEngine sharedInstance] startPlayingStream:view.linkv.uid];
                break;
            }
        }
    }
}

- (void)OnDeleteRemoter:(NSString*)userId{
    if ([self.delegate respondsToSelector:@selector(rtcEngine:didOfflineOfUid:reason:)]) {
        int uid = [userId intValue];
        [self.delegate rtcEngine:self didOfflineOfUid:uid reason:0];
    }
}

- (void)OnMixComplete:(LVErrorCode)code{
    LV_LOGI(@"%s", __func__);
}

- (void)OnAudioData:(NSString *)userId
         audio_data:(const void*)audio_data
    bits_per_sample:(int)bits_per_sample
        sample_rate:(int)sample_rate
 number_of_channels:(size_t)number_of_channels
   number_of_frames:(size_t)number_of_frames{
    [self.observer onPlaybackFrame:(int8_t *)audio_data numOfSamples:(int)number_of_frames bytesPerSample:bits_per_sample channels:(int)number_of_channels samplesPerSec:sample_rate];
}

- (void)OnAudioMixStream:(const int16_t *)data samples:(int)samples nchannel:(int)nchannel samplesPerChannel:(int)samplesPerChannel flag:(LVAudioRecordType)flag{
    [self.observer onRecordFrame:(int8_t *)data numOfSamples:samplesPerChannel * 2 bytesPerSample:2 channels:nchannel samplesPerSec:samples];
}

- (void)OnPublishQualityUpdate:(LVVideoStatistic *)quality{
    _lastStats.gatewayRtt = quality.audioRtt > quality.videoRtt ? quality.videoRtt : quality.audioRtt;
    _lastStats.cpuTotalUsage = quality.cpuusage * 100;
    _lastStats.memoryAppUsageRatio = quality.memoryusage;
    _lastStats.duration = ((NSDate.date.timeIntervalSince1970 * 1000) - _startTime)/1000;
    _lastStats.txBytes += quality.videosentKbytes * 1000;
    _lastStats.txVideoBytes += quality.videosentKbytes * 1000;
    _lastStats.txPacketLossRate = quality.videoLostPercent;
    _lastStats.userCount = 2;
}

- (void)OnPlayQualityUpate:(LVVideoStatistic *)quality userId:(NSString*)userId{
    _lastStats.rxBytes += quality.videoreceKbytes * 1000;
    _lastStats.rxVideoBytes += quality.videoreceKbytes * 1000;
    _lastStats.rxPacketLossRate = quality.videoLostPercent;
}

- (void)OnPublishStateUpdate:(LVErrorCode)code{
    LV_LOGI(@"OnPublishStateUpdate:%d", (int)code);
    if (!_firstFramePublishReported) {
        _firstFramePublishReported = YES;
        if ([self.delegate respondsToSelector:@selector(rtcEngine:firstLocalVideoFramePublished:)]) {
            [self.delegate rtcEngine:self firstLocalVideoFramePublished:0];
        }
    }
}

- (void)OnPlayStateUpdate:(LVErrorCode)code userId:(NSString*)userId{
    LV_LOGI(@"OnPlayStateUpdate:%d userId:%@", (int)code, userId);
}

- (void)OnAudioVolumeUpdate:(NSArray<LVAudioVolume *> *)soundLevels{
    NSMutableArray *levels = [[NSMutableArray alloc]init];
    int max = 0;
    for (LVAudioVolume *volume in soundLevels) {
        AgoraRtcAudioVolumeInfo *info = [[AgoraRtcAudioVolumeInfo alloc]init];
        info.uid = volume.userId.intValue;
        info.volume = volume.volume;
        info.channelId = _channelId;
        info.vad = 0;
        max = volume.volume > max ? volume.volume : max;
        [levels addObject:info];
    }
    if ([self.delegate respondsToSelector:@selector(rtcEngine:reportAudioVolumeIndicationOfSpeakers:totalVolume:)]) {
        [self.delegate rtcEngine:self reportAudioVolumeIndicationOfSpeakers:levels totalVolume:max];
    }
}

- (int64_t)OnDrawFrame:(CVPixelBufferRef)pixelBuffer
                   uid:(NSString *)userId
                   sei:(NSString *)sei{
    if (!_firstFrameReported) {
        _firstFrameReported = true;
        int width = (int)CVPixelBufferGetWidth(pixelBuffer);
        int height = (int)CVPixelBufferGetHeight(pixelBuffer);
        if ([self.delegate respondsToSelector:@selector(rtcEngine:firstRemoteVideoDecodedOfUid:size:elapsed:)]) {
            int uid = userId.intValue;
            [self.delegate rtcEngine:self firstRemoteVideoDecodedOfUid:uid size:CGSizeMake(width, height) elapsed:0];
        }
    }
    return 0;
}

- (void)OnKickOff:(NSInteger)reason roomId:(NSString *)roomId{
    LV_LOGI(@"OnKickOff: %@ reason:%d", roomId, (int)reason);
    if ([self.delegate respondsToSelector:@selector(rtcEngineConnectionDidLost:)]) {
        [self.delegate rtcEngineConnectionDidLost:self];
    }
    if ([self.delegate respondsToSelector:@selector(rtcEngine:didOccurError:)]) {
        [self.delegate rtcEngine:self didOccurError:(AgoraErrorCode)LinkvErrorCode_OnKickOff];
    }
}

- (void)OnMicphoneEnabled:(NSString *)userId enabled:(bool)enabled{
    if ([self.delegate respondsToSelector:@selector(rtcEngine:didAudioMuted:byUid:)]) {
        int uid = userId.intValue;
        [self.delegate rtcEngine:self didAudioMuted:!enabled byUid:uid];
    }
}

- (void)AudioMixerCurrentPlayingTime:(int)time_ms{
    
}

- (void)AudioMixerPlayerDidFinished{
    
}

- (void)OnReceivedFirstVideoFrame:(NSString *)userId streamId:(NSString *)streamId{
    
}

- (void)OnReceivedFirstAudioFrame:(NSString *)userId streamId:(NSString *)streamId{
    
}

- (void)OnReceiveRoomMessage:(NSString *)userId message:(NSString *)message{
    
}

@end
