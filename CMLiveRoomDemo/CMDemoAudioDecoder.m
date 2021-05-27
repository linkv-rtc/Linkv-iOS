//
//  CMDemoAudioDecoder.m
//  CMLiveRoomDemo
//
//  Created by jfdreamyang on 2020/3/12.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import "CMDemoAudioDecoder.h"
#import <AudioToolbox/AudioToolbox.h>


typedef struct ExtAudioConverterSettings {
    AudioStreamBasicDescription   outputFormat;
    ExtAudioFileRef               inputFile;
    AudioStreamPacketDescription *inputPacketDescriptions;
} ExtAudioConverterSettings;

typedef NS_ENUM(UInt32, ExtAudioConverterStatus) {
    ExtAudioConverterStatusOK = 0,
    ExtAudioConverterStatusFailed
};

static ExtAudioConverterStatus CheckStatus(OSStatus status, const char *operation) {
    if (status == noErr) return ExtAudioConverterStatusOK;
    char statusString[20];
    // See if it appears to be a 4-char-code
    *(UInt32 *)(statusString + 1) = CFSwapInt32HostToBig(status);
    if (isprint(statusString[1]) && isprint(statusString[2]) &&
        isprint(statusString[3]) && isprint(statusString[4])) {
        statusString[0] = statusString[5] = '\'';
        statusString[6] = '\0';
    } else {
        // No, format it as an integer
        sprintf(statusString, "%d", (int)status);
    }
    fprintf(stderr, "Error: %s (%s)\n", operation, statusString);
    return ExtAudioConverterStatusFailed;
}







@interface CMDemoAudioDecoder ()
{
    NSString *_audioPath;
    AudioStreamBasicDescription   outputFormat;
    BOOL stop;
    dispatch_queue_t _decodeQueue;
    dispatch_queue_t _timerQueue;
    dispatch_source_t _timer;
    ExtAudioConverterSettings settings;
    
    UInt32 sizePerBuffer;
    UInt32 framesPerBuffer;
    SInt16 *outputBuffer;
}
@end

@implementation CMDemoAudioDecoder

- (instancetype)initWithAudioPath:(NSString *)audioPath{
    self = [super init];
    if (self) {
        _audioPath = audioPath;
        
        framesPerBuffer = 1024;
        sizePerBuffer = 1024 * 2;
           // allocate destination buffer
        outputBuffer = (SInt16 *)malloc(sizePerBuffer);
        
        outputFormat.mSampleRate = 48000;
        int samples10ms = outputFormat.mSampleRate/100;
        
        outputFormat.mChannelsPerFrame = 1;
        outputFormat.mFormatID = kAudioFormatLinearPCM;
        outputFormat.mBytesPerFrame = 2;
        outputFormat.mBitsPerChannel = 16;
        outputFormat.mBytesPerPacket = 2;
        outputFormat.mFramesPerPacket = 1;
        outputFormat.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
        settings.outputFormat = outputFormat;
        
        _decodeQueue = dispatch_queue_create("com.liveme.sdk.audio.decode", 0);
           
        NSURL *sourceURL = [NSURL fileURLWithPath:_audioPath];
        ExtAudioConverterStatus status = CheckStatus(ExtAudioFileOpenURL((__bridge CFURLRef)sourceURL,&settings.inputFile),"ExtAudioFileOpenURL failed");
        if (status != ExtAudioConverterStatusOK) {
            return nil;
        }
        status = CheckStatus(ExtAudioFileSetProperty(settings.inputFile,kExtAudioFileProperty_ClientDataFormat, sizeof(settings.outputFormat),&settings.outputFormat),
                             "Setting client data format of input file failed");
        if (status != ExtAudioConverterStatusOK) {
            return nil;
        }
        
        _timerQueue = dispatch_queue_create("com.jfdream.signal.timer", DISPATCH_QUEUE_SERIAL);
        _timer =  dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, _timerQueue);
        
        float interval = ((framesPerBuffer * 10 * 1.0)/ samples10ms)/1000.0;
        
        dispatch_source_set_timer(_timer, dispatch_time(DISPATCH_TIME_NOW, 0),( long long)(NSEC_PER_SEC * interval), 0);
        dispatch_source_set_event_handler(_timer, ^{
            [self decode];
        });
    }
    return self;
}

-(void)start{
    dispatch_resume(_timer);
}

-(void)pause{
    dispatch_suspend(_timer);
}

-(void)stop{
    dispatch_cancel(_timer);
}

-(void)decode{
    
    ExtAudioConverterStatus status;
    AudioBufferList outputBufferList;
    outputBufferList.mNumberBuffers              = 1;
    outputBufferList.mBuffers[0].mNumberChannels = settings.outputFormat.mChannelsPerFrame;
    outputBufferList.mBuffers[0].mDataByteSize   = sizePerBuffer;
    outputBufferList.mBuffers[0].mData           = outputBuffer;
    UInt32 framesCount = framesPerBuffer;
    status = CheckStatus(ExtAudioFileRead(settings.inputFile,
                                          &framesCount,
                                          &outputBufferList),
                         "ExtAudioFileRead failed");
    if (status != ExtAudioConverterStatusOK) {
        NSLog(@"audio converter error");
        return;
    }
    if (framesCount==0) return;
    [self.delegate didCaptureAudio:outputBuffer length:framesPerBuffer];
}


@end
