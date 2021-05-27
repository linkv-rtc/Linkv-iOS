//
//  CMDemoAudioDecoder.h
//  CMLiveRoomDemo
//
//  Created by jfdreamyang on 2020/3/12.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CMDemoAudioDecoderDelegate <NSObject>

-(void)didCaptureAudio:(int16_t *)buffer length:(NSInteger)length;

@end

@interface CMDemoAudioDecoder : NSObject
-(instancetype)initWithAudioPath:(NSString *)audioPath;
@property (nonatomic,weak)id <CMDemoAudioDecoderDelegate> delegate;
-(void)start;
-(void)stop;
-(void)pause;
@end

NS_ASSUME_NONNULL_END
