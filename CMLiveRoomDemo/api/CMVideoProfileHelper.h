//
//  CMVideoProfileHelper.h
//  CMLiveRoomDemo
//
//  Created by jfdreamyang on 2020/3/20.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <LinkV/LinkV.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMVideoProfileHelper : NSObject

+ (NSInteger)frame:(LVRTCVideoProfile)videoProfile;
+ (NSInteger)bitRate:(LVRTCVideoProfile)videoProfile;

/// 通过 videoProfile 获取分辨率大小
/// @param videoProfile 分辨率大小
+ (CGSize)resolutionSize:(LVRTCVideoProfile)videoProfile;
@end

NS_ASSUME_NONNULL_END
