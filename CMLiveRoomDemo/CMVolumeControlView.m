//
//  CMVolumeControlView.m
//  CMLiveRoomDemo
//
//  Created by jfdreamyang on 2020/3/16.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import "CMVolumeControlView.h"
#import <LinkV/LinkV.h>

@interface CMVolumeControlView ()
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (nonatomic)BOOL pause;
@end


@implementation CMVolumeControlView
- (IBAction)volumeChanged:(UISlider *)sender {
    int volume = (sender.value * 160);
//    [[LVRTCEngine sharedInstance] adjustAudioMixingVolume:volume];
    [[LVRTCEngine sharedInstance] setAudioMixingPosition:volume * 1000];
}
- (IBAction)pauseButtonClick:(id)sender {
    self.pause = !self.pause;
    if (self.pause) {
        NSString *volume_control_play = NSLocalizedString(@"volume_control_play", nil);
        [[LVRTCEngine sharedInstance] pauseAudioMixing];
        [self.pauseButton setTitle:volume_control_play forState:UIControlStateNormal];
    }
    else{
        [[LVRTCEngine sharedInstance] resumeAudioMixing];
        NSString *volume_control_pause = NSLocalizedString(@"volume_control_pause", nil);
        [self.pauseButton setTitle:volume_control_pause forState:UIControlStateNormal];
    }
    
}
- (IBAction)closeButtonClick:(id)sender {
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
