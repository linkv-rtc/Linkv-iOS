//
//  IRtcEventManager.h
//  LinkV
//
//  Created by liveme on 2021/8/3.
//  Copyright © 2021 Liveme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgoraRtcKit/AgoraRtcEngineKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol AgoraFunction;

@protocol IRtcEventManager <NSObject>

-(void)rtcEngine:(id<AgoraFunction>)engine firstLocalVideoFramePublished:(NSInteger)elapsed;

- (void)rtcEngine:(id<AgoraFunction>)engine didJoinChannel:(NSString *)channel withUid:(NSUInteger)uid elapsed:(NSInteger)elapsed;

- (void)rtcEngine:(id<AgoraFunction>)engine firstLocalVideoFrameWithSize:(CGSize)size elapsed:(NSInteger)elapsed;

- (void)rtcEngine:(id<AgoraFunction>)engine firstRemoteVideoDecodedOfUid:(NSUInteger)uid size:(CGSize)size elapsed:(NSInteger)elapsed;

- (void)rtcEngine:(id<AgoraFunction>)engine didAudioMuted:(BOOL)muted byUid:(NSUInteger)uid;

- (void)rtcEngine:(id<AgoraFunction>)engine didOccurError:(AgoraErrorCode)errorCode;

- (void)rtcEngine:(id<AgoraFunction>)engine tokenPrivilegeWillExpire:(NSString *_Nonnull)token;

- (void)rtcEngineRequestToken:(id<AgoraFunction>)engine;

- (void)rtcEngine:(id<AgoraFunction>)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason;

- (void)rtcEngine:(id<AgoraFunction>)engine connectionChangedToState:(AgoraConnectionStateType)state reason:(AgoraConnectionChangedReason)reason;

- (void)rtcEngineConnectionDidLost:(id<AgoraFunction>)engine;

- (void)rtcEngine:(id<AgoraFunction>)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed;

- (void)rtcEngine:(id<AgoraFunction>)engine didLeaveChannelWithStats:(AgoraChannelStats* _Nonnull)stats;

- (void)rtcEngine:(id<AgoraFunction>)engine reportAudioVolumeIndicationOfSpeakers:(NSArray<AgoraRtcAudioVolumeInfo*>* _Nonnull)speakers totalVolume:(NSInteger)totalVolume;
@end

NS_ASSUME_NONNULL_END
