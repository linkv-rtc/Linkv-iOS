//
//  AgoraFunction.h
//  LinkV
//
//  Created by liveme on 2021/8/3.
//  Copyright © 2021 Liveme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "IRtcEventManager.h"
#import <AgoraRtcKit/AgoraRtcEngineKit.h>

NS_ASSUME_NONNULL_BEGIN


@class HinowView;

typedef void(^LinkvNetworkProbeCompletion)(LVNetworkProbeContent *content);

@protocol AudioFrameObserver <NSObject>

- (BOOL)onRecordAudioFrame:(id)frame;

- (BOOL)onPlaybackAudioFrame:(id)frame;

@end



@protocol AgoraFunction <NSObject>

-(id<AgoraFunction>)create:(NSString *)appId handler:(id<IRtcEventManager>)handler probeCompletion:(LinkvNetworkProbeCompletion)probeCompletion;

-(void)setLogFilter:(int)filter;

-(void)fileSizeInKBytes:(int)fileSizeInKBytes;

-(int)setVideoEncoderConfiguration:(AgoraVideoEncoderConfiguration *)config;

-(void)enableVideo;

-(int)setChannelProfile:(int)profile;

-(int)setPlaybackAudioFrameParametersWithSampleRate:(int)sampleRate channel:(int)channel mode:(AgoraAudioRawFrameOperationMode)mode samplesPerCall:(int)samplesPerCall;

-(int)setClientRole:(int)role;

-(int)setVideoSource:(id<AgoraVideoSourceProtocol>)source;

-(int)joinChannelByToken:(NSString* _Nullable)token channelId:(NSString* _Nonnull)channelId info:(NSString* _Nullable)info uid:(NSUInteger)uid joinSuccess:(void (^_Nullable)(NSString* _Nonnull channel, NSUInteger uid, NSInteger elapsed))joinSuccessBlock;

-(int)leaveChannel:(void (^_Nullable)(AgoraChannelStats* _Nonnull stat))leaveChannelBlock;

-(int)muteLocalAudioStream:(bool)muted;

-(int)enableLocalAudio:(BOOL)enabled;

-(int)registerAudioFrameObserver:(id<AudioFrameObserver>)observer;

-(int)muteRemoteAudioStream:(int)uid mute:(bool)mute;

-(int)setupRemoteVideo:(HinowView *)surfaceView;

-(int)setRemoteVideoStreamType:(int)uid streamType:(int)streamType;

-(int)setParameters:(NSString* _Nonnull)options;

-(int)startPreview;

-(int)stopPreview;

-(int)switchCamera;

-(int)setEnableSpeakerphone:(BOOL)enableSpeaker;

/// 开始视频录制（请以.mkv 目录结尾， 例如：/User/linkv/Desktop/video-1213232.mkv）
/// @param userId 要录制视频的用户 ID
/// @param path 视频录制地址
-(int)startRecorder:(int)userId path:(NSString *)path;

/// 停止视频录制
/// @param userId 视频对应用户 ID
-(int)stopRecorder:(int)userId;

@end

NS_ASSUME_NONNULL_END
