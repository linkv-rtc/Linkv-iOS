//
//  CMVideoProfileHelper.m
//  CMLiveRoomDemo
//
//  Created by jfdreamyang on 2020/3/20.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import "CMVideoProfileHelper.h"

@implementation CMVideoProfileHelper
+(NSInteger)bitRate:(LVRTCVideoProfile)videoProfile{
    return [[self configure:videoProfile].firstObject integerValue];
}

+(NSInteger)frame:(LVRTCVideoProfile)videoProfile{
    return [[self configure:videoProfile][1] integerValue];
}

+(NSString *)resolution:(LVRTCVideoProfile)videoProfile{
    return [self configure:videoProfile][2];
}
+(CGSize)resolutionSize:(LVRTCVideoProfile)videoProfile{
    NSString *size = [self resolution:videoProfile];
    NSArray *res = [size componentsSeparatedByString:@"x"];
    return CGSizeMake([res[0] floatValue], [res[1] floatValue]);
}

+(NSArray *)configure:(LVRTCVideoProfile)videoProfile{
    NSInteger bitRate = 0, frame = 0;
    NSString * resolution = @"";
    switch (videoProfile) {
        case LVRTCVideoProfile_180P:{
            resolution = @"320x180";
            frame = 15;
            bitRate = 300;
        }
            break;
        case LVRTCVideoProfile_270P:{
            resolution = @"480x270";
            frame = 15;
            bitRate = 500;
        }
            break;
        case LVRTCVideoProfile_360P:{
            resolution = @"640x360";
            frame = 15;
            bitRate = 800;
        }
            break;
            //        case LVRTCVideoProfile_368P:{
            //            resolution = @"640x368";
            //            frame = 15;
            //            bitRate = 410;
            //        }
            //            break;
        case LVRTCVideoProfile_480P:{
            resolution = @"640x480";
            frame = 15;
            bitRate = 1000;
        }
            break;
        case LVRTCVideoProfile_540P:{
            resolution = @"960x540";
            frame = 15;
            bitRate = 1200;
        }
            break;
            
        case LVRTCVideoProfile_720P:{
            resolution = @"1280x720";
            frame = 15;
            bitRate = 1800;
        }
            break;
        default:{
            resolution = @"960x540";
            frame = 15;
            bitRate = 1200;
        }
            break;
    }
    return @[@(bitRate),@(frame),resolution];
}

@end
