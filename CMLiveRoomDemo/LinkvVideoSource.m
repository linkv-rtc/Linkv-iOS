//
//  LinkvVideoSource.m
//  LinkV
//
//  Created by liveme on 2021/8/4.
//  Copyright © 2021 Liveme. All rights reserved.
//

#import "LinkvVideoSource.h"
#import "LVRTCFileCapturer.h"


@interface LinkvVideoSource ()<LVRTCFileCapturerDelegate>

@end

@implementation LinkvVideoSource
{
    LVRTCFileCapturer *_fileCapturer;
}


-(void)start{
    _fileCapturer = [[LVRTCFileCapturer alloc]init];
    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"mp4"];
    _fileCapturer.delegate = self;
    [_fileCapturer startCapturingFromFilePath:videoPath onError:^(NSError * _Nullable code) {
        NSLog(@"%@",code);
    }];
}

-(void)stop{
    [_fileCapturer stopCapture];
    _fileCapturer = nil;
}

- (void)didOutputSampleBuffer:(CMSampleBufferRef _Nullable)sampleBuffer{
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CMTime currentTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    [self.consumer consumePixelBuffer:pixelBuffer withTimestamp:currentTime rotation:(AgoraVideoRotationNone)];
    CFRelease(sampleBuffer);
    
}

- (void)didReadCompleted{
    
}

@end
