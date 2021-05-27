//
//  CMLiveSettingView.m
//  LinkV-macOS
//
//  Created by jfdreamyang on 2020/4/10.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import "CMMLiveSettingView.h"
#import <LinkV/LinkV.h>
#import "CMVideoProfileHelper.h"

@interface LVAVConfig ()
/// 当前视频采集参数
@property (nonatomic,assign)LVRTCVideoProfile capturerProfile;

/// 当前视频编码参数
@property (nonatomic,assign)LVRTCVideoProfile encoderProfile;

@end

@interface CMMLiveSettingView ()
@property (weak) IBOutlet NSPopUpButton *framerateButton;
@property (weak) IBOutlet NSPopUpButton *resolutionButton;
@property (weak) IBOutlet NSPopUpButton *bitrateRate;
@property (weak) IBOutlet NSPopUpButton *videoDevice;
@property (weak) IBOutlet NSPopUpButton *audioDevice;
@property (weak) IBOutlet NSButton *checkboxButton;
@property (weak) IBOutlet NSButton *mixCheckboxButton;


@property (nonatomic)BOOL modification;
@property (nonatomic)LVRTCVideoProfile selectedProfile;
@property (nonatomic,strong)LVAVConfig *avConfig;
@end


@implementation CMMLiveSettingView

@synthesize tag = _tag;

-(void)configure{
    
    NSString *close = NSLocalizedString(@"Live close", nil);
    NSString *_default = NSLocalizedString(@"Live default", nil);
    NSString *open = NSLocalizedString(@"Live open", nil);
    
    NSMutableAttributedString *s = [[NSMutableAttributedString alloc]initWithString:close];
    
    [s addAttributes:@{NSForegroundColorAttributeName:[NSColor whiteColor]} range:NSMakeRange(0, close.length)];
    self.checkboxButton.attributedTitle = s;
    
    if (!self.isMixing) {
        s = [[NSMutableAttributedString alloc]initWithString:close];
        [s addAttributes:@{NSForegroundColorAttributeName:[NSColor whiteColor]} range:NSMakeRange(0, close.length)];
    }
    else{
        s = [[NSMutableAttributedString alloc]initWithString:open];
        self.mixCheckboxButton.state = NSControlStateValueOn;
        [s addAttributes:@{NSForegroundColorAttributeName:[NSColor whiteColor]} range:NSMakeRange(0, open.length)];
    }
    self.mixCheckboxButton.attributedTitle = s;
    NSMenu *menu = [[NSMenu alloc]initWithTitle:@"1280x720"];
    self.resolutionButton.menu = menu;
    
    menu = [[NSMenu alloc]initWithTitle:@"15"];
    self.framerateButton.menu = menu;
    
    menu = [[NSMenu alloc]initWithTitle:@"1130"];
    self.bitrateRate.menu = menu;
    
    menu = [[NSMenu alloc]initWithTitle:_default];
    self.videoDevice.menu = menu;
    
    menu = [[NSMenu alloc]initWithTitle:_default];
    self.audioDevice.menu = menu;

    [self.resolutionButton addItemsWithTitles:@[@"320x180",@"320x240",@"640x360",@"640x480",@"960x540",@"1280x720"]];
    [self.framerateButton addItemsWithTitles:@[@"1",@"5",@"9",@"10",@"15",@"20",@"25",@"30"]];
    [self.bitrateRate addItemsWithTitles:@[@"140",@"200",@"400",@"500",@"800",@"900",@"1000",@"1130",@"1300",@"1500",@"1800"]];
    
    [self.videoDevice addItemsWithTitles:@[_default]];
    [self.audioDevice addItemsWithTitles:@[_default]];
    
    
//    [self.resolutionButton selectItem:[self.resolutionButton.menu itemAtIndex:5]];
//    [self.framerateButton selectItem:[self.framerateButton.menu itemAtIndex:4]];
//    [self.bitrateRate selectItem:[self.bitrateRate.menu itemAtIndex:5]];
}
- (IBAction)openStatisticsView:(NSButton *)sender {
    NSString *close = NSLocalizedString(@"Live close", nil);
    NSString *open = NSLocalizedString(@"Live open", nil);
    if (sender.state == NSControlStateValueOn) {
        NSMutableAttributedString *s = [[NSMutableAttributedString alloc]initWithString:open];
        [s addAttributes:@{NSForegroundColorAttributeName:[NSColor whiteColor]} range:NSMakeRange(0, open.length)];
        self.checkboxButton.attributedTitle = s;
        [self.delegate openStatisticsView:YES];
    }
    else{
        NSMutableAttributedString *s = [[NSMutableAttributedString alloc]initWithString:close];
        [s addAttributes:@{NSForegroundColorAttributeName:[NSColor whiteColor]} range:NSMakeRange(0, close.length)];
        self.checkboxButton.attributedTitle = s;
        [self.delegate openStatisticsView:NO];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    
    
    // Drawing code here.
}
- (IBAction)closeButtonClick:(id)sender {
    [self closeButtonClick];
}
- (IBAction)mixButtonClick:(NSButton *)sender {
    [self.delegate mixButtonClick:sender.state == NSControlStateValueOn];
    NSString *close = NSLocalizedString(@"Live close", nil);
    NSString *open = NSLocalizedString(@"Live open", nil);
    if (sender.state == NSControlStateValueOn) {
        NSMutableAttributedString *s = [[NSMutableAttributedString alloc]initWithString:open];
        [s addAttributes:@{NSForegroundColorAttributeName:[NSColor whiteColor]} range:NSMakeRange(0, open.length)];
        self.mixCheckboxButton.attributedTitle = s;
    }
    else{
        NSMutableAttributedString *s = [[NSMutableAttributedString alloc]initWithString:close];
        [s addAttributes:@{NSForegroundColorAttributeName:[NSColor whiteColor]} range:NSMakeRange(0, close.length)];
        self.mixCheckboxButton.attributedTitle = s;
    }
}
- (void)closeButtonClick{
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
        context.duration = .5;
        self.animator.alphaValue = 0;
    } completionHandler:^{
        [self removeFromSuperview];
    }];
}

-(void)setAVConfig:(LVAVConfig *)config{
    self.avConfig = config;
    NSArray <NSString *>*framerates = @[@"1",@"5",@"9",@"10",@"15",@"20",@"25",@"30"];
    NSArray <NSString *>*items = @[@"140",@"200",@"400",@"500",@"800",@"900",@"1000",@"1130",@"1300",@"1500",@"1800"];
    NSArray <NSNumber *>*resolutions = @[@(LVRTCVideoProfile_180P),@(LVRTCVideoProfile_270P),@(LVRTCVideoProfile_360P),@(LVRTCVideoProfile_480P),@(LVRTCVideoProfile_540P),@(LVRTCVideoProfile_720P)];
    
    for (NSInteger i=0; i<framerates.count; i++) {
        int t = framerates[i].intValue;
        if (t == config.fps) {
            [self.framerateButton selectItem:[self.framerateButton.menu itemAtIndex:i]];
            break;
        }
    }
    for (NSInteger i=0; i<items.count; i++) {
        int t = items[i].intValue;
        if (t == config.bitrate/1000) {
            [self.bitrateRate selectItem:[self.bitrateRate.menu itemAtIndex:i]];
            break;
        }
    }
    for (NSInteger i=0; i<resolutions.count; i++) {
        LVRTCVideoProfile profile = (LVRTCVideoProfile)resolutions[i].integerValue;
        if (profile == config.capturerProfile) {
            [self.resolutionButton selectItem:[self.resolutionButton itemAtIndex:i]];
            break;
        }
    }
}

- (IBAction)videoDeviceChoose:(id)sender {
}
- (IBAction)audioDeviceClick:(id)sender {
}
- (IBAction)frameRateClick:(NSPopUpButton *)sender {
    [self update];
}
- (IBAction)resolutionClick:(NSPopUpButton *)sender {
    [self update];
}
- (IBAction)bitrateClick:(NSPopUpButton *)sender {
    [self update];
}


-(void)update{
    int selectedBitrate = 0;
    NSInteger index = [self.bitrateRate indexOfSelectedItem];
    NSArray <NSString *>*items = @[@"140",@"200",@"400",@"500",@"800",@"900",@"1000",@"1130",@"1300",@"1500",@"1800"];
    NSString *bps = items[index];
    selectedBitrate = bps.intValue;
    
    LVRTCVideoProfile profile = LVRTCVideoProfile_180P;
    index = [self.resolutionButton indexOfSelectedItem];
    if (index == 0) {
        profile = LVRTCVideoProfile_180P;
    }
    else if (index == 1){
        profile = LVRTCVideoProfile_270P;
    }
    else if (index == 2){
        profile = LVRTCVideoProfile_360P;
    }
    else if (index == 3){
        profile = LVRTCVideoProfile_480P;
    }
    else if (index == 4){
        profile = LVRTCVideoProfile_540P;
    }
    else{
        profile = LVRTCVideoProfile_720P;
    }
    LVAVConfig *config = [[LVAVConfig alloc]initWithVideoProfile:profile];
    items = @[@"1",@"5",@"9",@"10",@"15",@"20",@"25",@"30"];
    int fps = items[[self.framerateButton indexOfSelectedItem]].intValue;
    config.bitrate = selectedBitrate * 1000;
    config.fps = fps;
    [self.delegate didSetAVConfig:config];
    
}


-(void)mouseDown:(NSEvent *)event{
    
}

@end
