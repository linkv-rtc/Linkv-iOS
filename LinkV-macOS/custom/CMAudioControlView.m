//
//  CMAudioControlView.m
//  LinkV-macOS
//
//  Created by jfdreamyang on 2020/4/22.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import "CMAudioControlView.h"
#import <LinkV/LinkV.h>

@interface CMAudioControlView ()
@property (weak) IBOutlet NSButton *pauseButton;

@end

@implementation CMAudioControlView

@synthesize tag = _tag;

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
}
- (IBAction)sliderChanged:(NSSlider *)sender {
    int volume = (int)[sender.objectValue integerValue];;
    [[LVRTCEngine sharedInstance] adjustAudioMixingVolume:volume];
}
- (IBAction)pauseButtonClick:(NSButton *)sender {
    self.pause = !self.pause;
    if (self.pause) {
        [[LVRTCEngine sharedInstance] pauseAudioMixing];
    }
    else{
        [[LVRTCEngine sharedInstance] resumeAudioMixing];
    }
    NSString *pause = NSLocalizedString(@"volume_control_pause", nil);
    if (!self.pause) {
        pause = NSLocalizedString(@"volume_control_play",nil);
    }
    [self.pauseButton setTitle:pause];
}
- (IBAction)closeButtonClick:(id)sender {
    [self removeFromSuperview];
}

-(void)show{
    NSString *pause = NSLocalizedString(@"volume_control_pause", nil);
    if (!self.pause) {
        pause = NSLocalizedString(@"volume_control_play",nil);
    }
    [self.pauseButton setTitle:pause];
}

@end
