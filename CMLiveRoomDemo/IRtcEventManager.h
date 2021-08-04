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

@protocol IRtcEventManager <NSObject>

-(void)onJoinChannelSuccess:(NSString *)channel uid:(int)uid elapsed:(int)elapsed;

-(void)onUserOffline:(int)uid reason:(int)reason;

-(void)onUserJoined:(int)uid elapsed:(int)elapsed;

-(void)onUserMuteAudio:(int)uid muted:(bool)muted;

-(void)onFirstRemoteVideoDecoded:(int)uid width:(int)width height:(int)height elapsed:(int)elapsed;

-(void)onRemoteVideoStateChanged:(int)uid state:(int)state reason:(int)reason elapsed:(int)elapsed;

-(void)onAudioVolumeIndication:(NSArray <AgoraRtcAudioVolumeInfo *> *)speakers totalVolume:(int)totalVolume;

-(void)onRtcStats:(AgoraChannelStats *)stats;

-(void)onError:(int)err;

-(void)onLeaveChannel:(AgoraChannelStats *)stats;
@end

NS_ASSUME_NONNULL_END
