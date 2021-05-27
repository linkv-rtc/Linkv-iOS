//
//  CMSettingSliderCell.m
//  CMLiveRoomDemo
//
//  Created by jfdreamyang on 2020/3/20.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import "CMSettingSliderCell.h"
#import "CMVideoProfileHelper.h"

NSInteger const kCMMaxVideoFramerate  =  30;
NSInteger const kCMMaxBitrate   = 3000000;


@interface LVAVConfig (DemoPrivate)
/// 当前视频采集参数
@property (nonatomic,assign)LVRTCVideoProfile capturerProfile;

/// 当前视频编码参数
@property (nonatomic,assign)LVRTCVideoProfile encoderProfile;
@end


@interface CMSettingSliderCell ()
@property (weak, nonatomic) IBOutlet UISlider *resolutionSlider;
@property (weak, nonatomic) IBOutlet UISlider *fpsSlider;
@property (weak, nonatomic) IBOutlet UISlider *bitrateSlider;
@property (weak, nonatomic) IBOutlet UILabel *resolutionLab;
@property (weak, nonatomic) IBOutlet UILabel *fpsLab;
@property (weak, nonatomic) IBOutlet UILabel *bitrateLab;

@property (nonatomic,assign)BOOL modification;
@property (nonatomic,assign)LVRTCVideoProfile selectedProfile;
@property (nonatomic,assign)int selectedFps;
@property (nonatomic,assign)int selectedBitrate;

@end


@implementation CMSettingSliderCell
- (IBAction)resolutionSliderChanged:(UISlider *)sender {
    // 180, 270, 360, 480, 540, 720
    float space = 1/5.0;
    LVRTCVideoProfile profile = LVRTCVideoProfile_180P;
    if (sender.value < space/2.0) {
        sender.value = 0;
        profile = LVRTCVideoProfile_180P;
    }
    else if (sender.value > space/2.0 && sender.value < 1.5*space){
        sender.value = space;
        profile = LVRTCVideoProfile_270P;
    }
    else if (sender.value > space*1.5 && sender.value < 2.5*space){
        sender.value = 2*space;
        profile = LVRTCVideoProfile_360P;
    }
    else if (sender.value > space*2.5 && sender.value < 3.5*space){
        sender.value = 3*space;
        profile = LVRTCVideoProfile_480P;
    }
    else if (sender.value > space*3.5 && sender.value < 4.5*space){
        sender.value = 4*space;
        profile = LVRTCVideoProfile_540P;
    }
    else{
        sender.value = 1;
        profile = LVRTCVideoProfile_720P;
    }
    CGSize size = [CMVideoProfileHelper resolutionSize:profile];
    
    LVAVConfig *config = [[LVAVConfig alloc]initWithVideoProfile:profile];
    
    self.resolutionLab.text = [NSString stringWithFormat:@"%.0fx%.0f",size.width,size.height];
    self.selectedProfile = profile;
    self.modification = YES;
    
    int currentBitrate = config.bitrate;
    self.bitrateLab.text = [NSString stringWithFormat:@"%d",currentBitrate];
    self.selectedBitrate = currentBitrate;
    self.bitrateSlider.value = currentBitrate*1.0/kCMMaxBitrate;
    
    int currentFrame = config.fps;
    self.fpsLab.text = [NSString stringWithFormat:@"%d",currentFrame];
    self.selectedFps = currentFrame;
    self.fpsSlider.value = currentFrame*1.0/kCMMaxVideoFramerate;
    
}
- (IBAction)fpsSliderChanged:(UISlider *)sender {
    int currentFrame = (int)(sender.value * kCMMaxVideoFramerate);
    self.fpsLab.text = [NSString stringWithFormat:@"%d",currentFrame];
    self.selectedFps = currentFrame;
    self.modification = YES;
}
- (IBAction)bitrateSliderChanged:(UISlider *)sender {
    int currentBitrate = (int)(sender.value * kCMMaxBitrate);
    self.bitrateLab.text = [NSString stringWithFormat:@"%d",currentBitrate];
    self.selectedBitrate = currentBitrate;
    self.modification = YES;
}
-(void)setItem:(NSDictionary *)item{
    _item = item;
    LVAVConfig *config = item[@"config"];
    self.resolutionLab.text = [NSString stringWithFormat:@"%.0fx%.0f",config.videoEncodeResolution.width,config.videoEncodeResolution.height];
    self.fpsLab.text = [NSString stringWithFormat:@"%d",config.fps];
    self.bitrateLab.text = [NSString stringWithFormat:@"%d",config.bitrate];
    
    self.selectedProfile = config.capturerProfile;
    self.selectedBitrate = config.bitrate;
    self.selectedFps = config.fps;
    
    self.bitrateSlider.value = config.bitrate * 1.0 / kCMMaxBitrate;
    self.fpsSlider.value = config.fps * 1.0 / kCMMaxVideoFramerate;
    
//     180, 270, 360, 480, 540, 720
    if (config.encoderProfile == LVRTCVideoProfile_180P) {
        self.resolutionSlider.value = 0;
    }
    else if (config.encoderProfile == LVRTCVideoProfile_270P){
        self.resolutionSlider.value = 1/5.0;
    }
    else if (config.encoderProfile == LVRTCVideoProfile_360P){
        self.resolutionSlider.value = 2/5.0;
    }
    else if (config.encoderProfile == LVRTCVideoProfile_480P){
        self.resolutionSlider.value = 3/5.0;
    }
    else if (config.encoderProfile == LVRTCVideoProfile_540P){
        self.resolutionSlider.value = 4/5.0;
    }
    else if (config.encoderProfile == LVRTCVideoProfile_720P){
        self.resolutionSlider.value = 1.0;
    }
}


- (IBAction)confirmButtonClick:(id)sender {
    
    if (!self.modification)return;
    self.modification = NO;
    LVAVConfig *config = [[LVAVConfig alloc] initWithVideoProfile:self.selectedProfile];
    config.bitrate = self.selectedBitrate;
    config.fps = self.selectedFps;
    config.min_bitrate = config.bitrate/3.0;
    [self.delegate didChangeAVConfig:config];
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.backgroundColor = [UIColor clearColor];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
