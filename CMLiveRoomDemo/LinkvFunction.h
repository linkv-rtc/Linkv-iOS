//
//  LinkvFunction.h
//  LinkV
//
//  Created by liveme on 2021/8/3.
//  Copyright © 2021 Liveme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AgoraFunction.h"
#import <LinkV/LinkV.h>

NS_ASSUME_NONNULL_BEGIN


typedef enum : NSUInteger {
    LinkvErrorCode_RoomDisconnected = 12010,
    LinkvErrorCode_OnKickOff = 12011,
} LinkvErrorCode;

@interface LinkvAudioFrame : NSObject
@property(assign, nonatomic) NSInteger samplesPerChannel;
@property(assign, nonatomic) NSInteger bytesPerSample;
@property(assign, nonatomic) NSInteger channels;
@property(assign, nonatomic) NSInteger samplesPerSec;
@property(strong, nonatomic) NSData* _Nullable buffer;
@property(assign, nonatomic) int64_t renderTimeMs;
@property(assign, nonatomic) NSInteger avSyncType;
@end

@interface HinowView : NSObject
@property (nonatomic,strong)AgoraRtcVideoCanvas *agora;
@property (nonatomic,strong)LVRTCDisplayView *linkv;
@end


@interface LinkvFunction : NSObject <AgoraFunction, AgoraVideoFrameConsumer>

+(instancetype)sharedFunction;

@end

NS_ASSUME_NONNULL_END
