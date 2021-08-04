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

@protocol AudioFrameObserver <NSObject>

-(bool)onPlaybackFrame:(int8_t *)samples numOfSamples:(int)numOfSamples bytesPerSample:(int)bytesPerSample channels:(int)channels samplesPerSec:(int)samplesPerSec;

-(bool)onRecordFrame:(int8_t *)samples numOfSamples:(int)numOfSamples bytesPerSample:(int)bytesPerSample channels:(int)channels samplesPerSec:(int)samplesPerSec;

@end



@protocol AgoraFunction <NSObject>

-(id<AgoraFunction>)create:(NSString *)appId handler:(id<IRtcEventManager>)handler;

-(void)setLogFilter:(int)filter;

-(void)fileSizeInKBytes:(int)fileSizeInKBytes;

-(int)setVideoEncoderConfiguration:(AgoraVideoEncoderConfiguration *)config;

-(void)enableVideo;

-(int)setChannelProfile:(int)profile;

-(int)setPlaybackAudioFrameParameters:(int)sampleRate channel:(int)channel mode:(int)mode samplesPerCall:(int)samplesPerCall;

-(int)setClientRole:(int)role;

-(int)setVideoSource:(id<AgoraVideoSourceProtocol>)source;

-(int)joinChannel:(NSString *)token channelName:(NSString *)channelName optionalInfo:(nullable NSString *)optionalInfo optionalUid:(int)optionalUid;

-(int)leaveChannel;

-(int)muteLocalAudioStream:(bool)muted;

-(int)registerAudioFrameObserver:(id<AudioFrameObserver>)observer;

-(int)muteRemoteAudioStream:(int)uid muted:(bool)muted;

-(int)setupRemoteVideo:(HinowView *)surfaceView;

-(int)setRemoteVideoStreamType:(int)uid streamType:(int)streamType;

-(int)setParameters:(NSString* _Nonnull)options;

-(int)startPreview;

-(int)stopPreview;

-(int)switchCamera;

@end

NS_ASSUME_NONNULL_END
