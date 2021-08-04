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
    LinkvErrorCode_RoomDisconnected,
    LinkvErrorCode_OnKickOff,
} LinkvErrorCode;


@interface HinowView : NSObject
@property (nonatomic,strong)AgoraRtcVideoCanvas *agora;
@property (nonatomic,strong)LVRTCDisplayView *linkv;
@end


@interface LinkvFunction : NSObject <AgoraFunction, AgoraVideoFrameConsumer>

+(instancetype)sharedFunction;

@end

NS_ASSUME_NONNULL_END
