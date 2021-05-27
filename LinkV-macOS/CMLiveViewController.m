//
//  CMLiveViewController.m
//  LinkV-macOS
//
//  Created by jfdreamyang on 2020/4/9.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import "CMLiveViewController.h"
#import "Masonry.h"
#import "RTCNetworkManager.h"
#import "CMScrollView.h"
#import "CMMLiveSettingView.h"
#import "CMUserListView.h"
#import "CMMacStatisticsView.h"
#import "CMAudioControlView.h"
#import <LinkV/LinkV.h>

@interface CMLiveViewController ()<LVRTCEngineDelegate,CMUserListViewDelegate,CMMLiveSettingViewDelegate>
{
    RTCRoomStatus _roomStatus;
    NSMutableSet *_userIdList;
    BOOL cameraSelected;
    BOOL microphoneSelected;
    BOOL isMixing;
    // 嘉宾有效
    BOOL _isPublishing;
    BOOL _isFirstPublishing;
    NSInteger joinedRoom;
}
@property (nonatomic,strong)LVRTCDisplayView *mainPreview;
@property (nonatomic,strong)LVAVConfig *avConfig;
@property (weak) IBOutlet NSView *controlView;
@property (weak) IBOutlet NSButton *lianmaiButton;
@property (weak) IBOutlet NSButton *speakerButton;
@property (weak) IBOutlet NSButton *userlistButton;
@property (weak) IBOutlet NSButton *cameraButton;
@property (weak) IBOutlet NSButton *settingButton;
@property (weak) IBOutlet NSButton *hangupButton;
@property (nonatomic, strong) NSTimer *keepaliveTimer;
@property (weak) IBOutlet NSTextFieldCell *roomIdLab;
@property (weak) IBOutlet NSTextField *userIdLab;
@property (nonatomic,strong)NSMutableDictionary *renders;
@property (weak) IBOutlet NSScrollView *rightScrollView;
@property (weak) IBOutlet NSView *documentView;
@property (nonatomic,strong)CMMacStatisticsView *statisticsView;

@property (weak) IBOutlet NSTextField *toastLabel;

@property (nonatomic)NSInteger currentNumber;
@end

@implementation CMLiveViewController

-(void)dealloc{
    NSLog(@"%s",__func__);
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do view setup here.
    self.renders = [NSMutableDictionary new];
    self.view.wantsLayer = YES;
    self.view.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    _avConfig = [[LVAVConfig alloc]initWithVideoProfile:LVRTCVideoProfile_720P];
    [[LVRTCEngine sharedInstance] setAVConfig:_avConfig];
    
    [LVRTCEngine setPublishQualityMonitorCycle:1];
    [LVRTCEngine setPlayQualityMonitorCycle:1];
    
    self.rightScrollView.wantsLayer = YES;
    self.rightScrollView.layer.backgroundColor = [NSColor clearColor].CGColor;
    self.rightScrollView.contentView.backgroundColor = [NSColor clearColor];
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowBlurRadius = 2;
    shadow.shadowColor = [NSColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.3];
    shadow.shadowOffset =CGSizeMake(0,0);
    
    NSString *roomId = [RTCNetworkManager sharedManager].roomId;
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:roomId attributes: @{NSFontAttributeName: [NSFont systemFontOfSize: 16],NSForegroundColorAttributeName: [NSColor blackColor], NSShadowAttributeName: shadow}];
    [string setAlignment:NSTextAlignmentCenter range:NSMakeRange(0, roomId.length)];
    self.roomIdLab.attributedStringValue = string;
    
    NSString *userId = [RTCNetworkManager sharedManager].userId;
    NSString *userIdLocal = NSLocalizedString(@"user_id", nil);
    NSMutableAttributedString *userIdString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",userIdLocal,userId] attributes: @{NSFontAttributeName: [NSFont systemFontOfSize: 11],NSForegroundColorAttributeName: [NSColor colorWithRed:0x99/255.0 green:0x99/255.0 blue:0x99/255.0 alpha:1.0]}];
    [userIdString setAlignment:NSTextAlignmentCenter range:NSMakeRange(0, userIdLocal.length)];
    self.userIdLab.attributedStringValue = userIdString;
    
    _userIdList = [NSMutableSet new];
    
    
    self.keepaliveTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(roomKeepAlive) userInfo:nil repeats:YES];
    
    self.controlView.wantsLayer = YES;
    self.controlView.layer.cornerRadius = 20;
    self.controlView.layer.masksToBounds = YES;
    self.controlView.layer.backgroundColor = [NSColor colorWithRed:0x25/255.f green:0x29/255.f blue:0x2E/255.f alpha:0.8f].CGColor;
    
    [self.controlView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-40);
        make.width.equalTo(@360);
        make.height.equalTo(@44);
    }];
    
    CGFloat totolWidth = 360 - 60;
    CGFloat space = 25;
    CGFloat width = (totolWidth-(5*space))/6;
    
    for (NSInteger i=0; i<6; i++) {
        NSView *view = [self.controlView viewWithTag:1001+i];
        view.frame = CGRectMake(30 + width * i + space*i, (44-width)/2 + width + 2, width, width);
    }
    
    if ([RTCNetworkManager sharedManager].isHost) {
        [self.view addSubview:self.mainPreview positioned:NSWindowBelow relativeTo:self.rightScrollView];
        [[LVRTCEngine sharedInstance] addDisplayView:self.mainPreview];
        [[LVRTCEngine sharedInstance] setAVConfig:_avConfig];
        [[LVRTCEngine sharedInstance] startCapture];
    }
    
    [self startLiving];
    cameraSelected = YES;
    microphoneSelected = YES;
    _isFirstPublishing = YES;
    self.toastLabel.hidden = YES;
}

-(void)roomKeepAlive{
    if (_roomStatus == RTCRoomStatusLive) {
        [[RTCNetworkManager sharedManager] update:2];
    }
}

-(void)startLiving{
    NSString *roomId = RTCNetworkManager.sharedManager.roomId;
    [[LVRTCEngine sharedInstance] loginRoom:RTCNetworkManager.sharedManager.userId roomId:roomId isHost:RTCNetworkManager.sharedManager.isHost isOnlyAudio:NO delegate:self];
    if (RTCNetworkManager.sharedManager.isHost) {
        _mainPreview.uid = RTCNetworkManager.sharedManager.userId;
    }
}

-(void)viewDidLayout{
    [super viewDidLayout];
    CGRect frame = self.view.bounds;
    frame.size.height = frame.size.height - 44 - 30;
    self.mainPreview.frame = frame;
    self.rightScrollView.frame = CGRectMake(frame.size.width - 240, 0, 240, frame.size.height);
}

- (IBAction)lianmaiButtonClick:(id)sender {
    if([RTCNetworkManager sharedManager].isHost) return;
    
    if (!joinedRoom) {
        [self makeToast:@"正在加入中，请稍后" duration:1.0];
        return;
    }
    _isPublishing = !_isPublishing;
    if (_isPublishing) {
        if (_isFirstPublishing) {
            [self.view addSubview:self.mainPreview positioned:NSWindowBelow relativeTo:self.rightScrollView];
            [[LVRTCEngine sharedInstance] addDisplayView:self.mainPreview];
            [[LVRTCEngine sharedInstance] setAVConfig:_avConfig];
        }
        [[LVRTCEngine sharedInstance] startCapture];
        [[LVRTCEngine sharedInstance] startPublishing];
        _isFirstPublishing = NO;
    }
    else{
        [[LVRTCEngine sharedInstance] stopCapture];
        [[LVRTCEngine sharedInstance] stopPublishing];
        
    }
}
- (IBAction)speakerButtonClick:(NSButton *)sender {
    microphoneSelected = !microphoneSelected;
    if (microphoneSelected) {
        sender.image = [NSImage imageNamed:@"main_speaker"];
    }
    else{
        sender.image = [NSImage imageNamed:@"microphone_close_ico"];
    }
    [[LVRTCEngine sharedInstance] enableMic:microphoneSelected];
}

-(void)mouseDown:(NSEvent *)event{
    
    CGPoint point = [event locationInWindow];
    point = [self.view convertPoint:point fromView:self.view];
    
    CGRect frame = self.statisticsView.frame;
    if (!CGRectContainsPoint(frame, point)) {
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
             self.statisticsView.animator.alphaValue = 0;
        } completionHandler:^{
            [self.statisticsView removeFromSuperview];
            self.statisticsView.alphaValue = 1;
        }];
    }
    
}

-(void)didClickRow:(NSString *)userId{
    if (self.renders[userId] || [[RTCNetworkManager sharedManager].userId isEqualToString:userId]) {
        return;
    }
    [self createRenderView:userId];
    [[LVRTCEngine sharedInstance] startPlayingStream:userId];
}

- (IBAction)userlistButtonClick:(id)sender {
    NSArray *views;
    if ([self.view viewWithTag:8888]) return;
    [[NSBundle mainBundle] loadNibNamed:@"CMUserListView" owner:self topLevelObjects:&views];
    for (id obj in views) {
        if ([obj isKindOfClass:CMUserListView.class]) {
            CMUserListView *_userListView = obj;
            _userListView.tag = 8888;
            [_userListView configure];
            _userListView.wantsLayer = YES;
            _userListView.layer.backgroundColor = [NSColor colorWithRed:0x25/255.f green:0x29/255.0 blue:0x2E/255.f alpha:0.8].CGColor;
            _userListView.layer.cornerRadius = 10;
            _userListView.layer.masksToBounds = YES;
            _userListView.delegate = self;
            [self.view addSubview:_userListView];
            [_userListView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.center.equalTo(self.view);
                make.width.equalTo(@250);
                make.height.equalTo(@300);
            }];
            [_userListView reloadView:_userIdList.allObjects];
            break;
        }
    }
}
- (IBAction)cameraButtonClick:(NSButton *)sender {
    cameraSelected = !cameraSelected;
    if (cameraSelected) {
        sender.image = [NSImage imageNamed:@"main_live_camera"];
    }
    else{
        sender.image = [NSImage imageNamed:@"camera_disable_ico"];
    }
    if (cameraSelected) {
        [[LVRTCEngine sharedInstance] setAVConfig:_avConfig];
        [[LVRTCEngine sharedInstance] startCapture];
        self.mainPreview.hidden = NO;
    }
    else{
        [[LVRTCEngine sharedInstance] stopCapture];
        self.mainPreview.hidden = YES;
    }
}
- (IBAction)settingButtonClick:(id)sender {
    
    if ([self.view viewWithTag:9999]) return;
    
    NSArray *views;
    [[NSBundle mainBundle] loadNibNamed:@"CMLiveSettingView" owner:self topLevelObjects:&views];
    for (id obj in views) {
        if ([obj isKindOfClass:CMMLiveSettingView.class]) {
            CMMLiveSettingView *settingView = obj;
            settingView.tag = 9999;
            settingView.delegate = self;
            settingView.isMixing = isMixing;
            [settingView configure];
            settingView.wantsLayer = YES;
            settingView.layer.backgroundColor = [NSColor colorWithRed:0x25/255.f green:0x29/255.0 blue:0x2E/255.f alpha:0.8].CGColor;
            settingView.layer.cornerRadius = 10;
            settingView.layer.masksToBounds = YES;
            [self.view addSubview:settingView];
            [settingView setAVConfig:_avConfig];
            [settingView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerX.equalTo(self.view);
                make.centerY.equalTo(self.view).offset(-60);
                make.width.equalTo(@250);
                make.height.equalTo(@380);
            }];
            break;
        }
    }
}

-(void)mixButtonClick:(BOOL)isOn{
    
    if (!self.renders[[RTCNetworkManager sharedManager].userId] && ![RTCNetworkManager sharedManager].isHost) {
        NSString *accompaniment_demo_mention = NSLocalizedString(@"accompaniment_demo_mention", nil);
//        [self.view makeToast:accompaniment_demo_mention duration:2.0 position:@"center"];
        return;
    }
//    NSMutableDictionary *item = [self.dataSource[indexPath.row] mutableCopy];
//    item[@"default"] = @(isOn);
//    self.dataSource[indexPath.row] = [item copy];
    isMixing = isOn;
    if (isOn) {
        NSString *audioPath = [[NSBundle mainBundle] pathForResource:@"audio" ofType:@"mp3"];
        [[LVRTCEngine sharedInstance] startAudioMixing:audioPath replace:NO loop:-1];
        CMAudioControlView *controlView = [self.view viewWithTag:3344];
        controlView.pause = NO;
        if (!controlView) {
            NSArray *items;
            [[NSBundle mainBundle] loadNibNamed:@"CMAudioControlView" owner:self topLevelObjects:&items];
            for (id item in items) {
                if ([item isKindOfClass:CMAudioControlView.class]) {
                    controlView = item;
                    break;;
                }
            }
            if (controlView) {
                controlView.tag = 3344;
                [self.view addSubview:controlView];
                controlView.wantsLayer = YES;
                controlView.layer.cornerRadius = 20;
                controlView.layer.masksToBounds = YES;
                controlView.layer.backgroundColor = [NSColor colorWithWhite:0 alpha:0.5].CGColor;
                [controlView mas_makeConstraints:^(MASConstraintMaker *make) {
                    make.width.equalTo(@480);
                    make.height.equalTo(@100);
                    make.centerX.equalTo(self.view);
                    make.top.equalTo(self.view).offset(64);
                }];
            }
        }
        [controlView show];
    }
    else{
        [[LVRTCEngine sharedInstance] stopAudioMixing];
        CMAudioControlView *controlView = [self.view viewWithTag:3344];
        [controlView removeFromSuperview];
    }
}

-(void)reloadListView{
    CMUserListView *listView = [self.view viewWithTag:8888];
    if (listView) {
        [listView reloadView:_userIdList.allObjects];
    }
}

- (IBAction)hangupButtonClick:(id)sender {
    [[LVRTCEngine sharedInstance] stopCapture];
    [[LVRTCEngine sharedInstance] removeDisplayView:self.mainPreview];
    [self.mainPreview removeFromSuperview];
    [self.renders enumerateKeysAndObjectsUsingBlock:^(NSString  *userId, LVRTCDisplayView *obj, BOOL * _Nonnull stop) {
        [[LVRTCEngine sharedInstance] removeDisplayView:obj];
    }];
    [self.renders removeAllObjects];
    [self.presentingViewController dismissViewController:self];
    if ([RTCNetworkManager sharedManager].isHost) {
        [[RTCNetworkManager sharedManager] update:RTCRoomStatusStop];
    }
    [[LVRTCEngine sharedInstance] logoutRoom:^(LVErrorCode code) {
        
    }];
    [self.keepaliveTimer invalidate];
    self.keepaliveTimer = nil;
    [_userIdList removeAllObjects];
}

#pragma mark -  LVRTCEngineDelegate
- (void)OnRoomReconnected{
    
}

- (void)OnEnterRoomComplete:(LVErrorCode)code users:(nullable NSArray<LVUser*>*)users{
    if (code == LVErrorCodeSuccess) {
        joinedRoom = YES;
        if (RTCNetworkManager.sharedManager.isHost) {
            [[LVRTCEngine sharedInstance] startPublishing];
        }
        _roomStatus = RTCRoomStatusLive;
        [self roomKeepAlive];
        dispatch_async(dispatch_get_main_queue(), ^{
            for (LVUser * user in users) {
                NSString *userId = RTCNetworkManager.sharedManager.userId;
                // 如果是自己, 记录 pull url. 用 streamid(!!!), 兼容 zego
                if (![userId isEqualToString:user.userId]) {
                    [LVRTCEngine.sharedInstance startPlayingStream:user.userId];
                    [self createRenderView:user.userId];
                }
                [_userIdList addObject:user.userId];
            }
            [self reloadListView];
        });
    }
}

- (void)OnExitRoomComplete{
    
}

- (void)OnRoomDisconnected:(LVErrorCode)code{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self hangupButtonClick:nil];
    });
}

- (void)OnAddRemoter:(LVUser *)user{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (_userIdList.count > 4 && [RTCNetworkManager sharedManager].type == RTCLiveTypeNormal) {
            NSString *memtion = NSLocalizedString(@"person_surpass", nil);
            [self makeToast:memtion duration:2.0];
            return;
        }
        
        if (![user.userId isEqualToString:RTCNetworkManager.sharedManager.userId]) {
            [LVRTCEngine.sharedInstance startPlayingStream:user.userId];
            [self createRenderView:user.userId];
        }
        [_userIdList addObject:user.userId];
        [self reloadListView];
    });
}

- (void)OnDeleteRemoter:(NSString*)uid{
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([uid hasPrefix:@"H"]) {
            [self hangupButtonClick:nil];
            return;
        }
        
        [_userIdList removeObject:uid];
        [self reloadListView];
        LVRTCDisplayView *displayView = self.renders[uid];
        if (displayView) {
            [[LVRTCEngine sharedInstance] removeDisplayView:displayView];
            [[LVRTCEngine sharedInstance] stopPlayingStream:uid];
            [displayView removeFromSuperview];
            [self.renders removeObjectForKey:uid];
        }
        [self.statisticsView remove:uid];
        
    });
}

- (void)OnMixComplete:(LVErrorCode)code{
    
}

- (void)OnAudioData:(NSString *)uid
         audio_data:(const void*)audio_data
    bits_per_sample:(int)bits_per_sample
        sample_rate:(int)sample_rate
 number_of_channels:(size_t)number_of_channels
   number_of_frames:(size_t)number_of_frames{
    
}

- (void)OnAudioMixStream:(const int16_t *)data samples:(int)samples nchannel:(int)nchannel flag:(LVAudioRecordType)flag{
    
}

- (void)OnPublishQualityUpdate:(LVVideoStatistic *)quality{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.statisticsView reloadView:quality userId:RTCNetworkManager.sharedManager.userId];
    });
}

- (void)OnPlayQualityUpate:(LVVideoStatistic *)quality userId:(NSString*)userId{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.statisticsView reloadView:quality userId:userId];
    });
}

- (void)OnPublishStateUpdate:(LVErrorCode)code{
    
}

- (void)OnPlayStateUpdate:(LVErrorCode)code userId:(NSString*)userId{
    
}

- (void)OnAudioVolumeUpdate:(NSArray<LVAudioVolume *> *)soundLevels{
    
}


-(NSString *)OnMediaSideInfoInPublishVideoFrame:(NSUInteger)timestamp{
    return @"";
}

- (int64_t)OnDrawFrame:(CVPixelBufferRef)pixelBuffer
                   uid:(NSString *)uid
                   sei:(NSString *)sei{
    
    if (sei && sei.length > 0) {
        if (self.currentNumber % 150 == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSString *receive_sei = NSLocalizedString(@"receive_sei", nil);
                [self makeToast:[NSString stringWithFormat:@"%@%@",receive_sei,sei] duration:1.f];
            });
        }
        self.currentNumber ++;
    }
    return 0;
}

#pragma mark SELF
-(LVRTCDisplayView *)mainPreview{
    if (!_mainPreview) {
        _mainPreview = [[LVRTCDisplayView alloc]initWithFrame:self.view.bounds];
    }
    return _mainPreview;
}


-(void)createRenderView:(NSString *)userId{
    LVRTCDisplayView *displayView = self.renders[userId];
    if (!displayView) {
        
        NSInteger number = self.renders.allValues.count;
        CGFloat originY = number*135;
        displayView = [[LVRTCDisplayView alloc]initWithFrame:CGRectMake(0, originY, 240, 135)];
        displayView.uid = userId;
        displayView.tag = 1000+number;
        displayView.wantsLayer = YES;
        displayView.layer.backgroundColor = [NSColor colorWithWhite:0 alpha:0.5].CGColor;
        displayView.layer.cornerRadius = 8;
        displayView.layer.masksToBounds = YES;
        displayView.viewContentMode = LVViewContentModeScaleAspectFit;
        [self.documentView addSubview:displayView];
        [[LVRTCEngine sharedInstance] addDisplayView:displayView];
        self.renders[userId] = displayView;
        
         // Fallback on earlier versions
        NSButton *closeButton = [[NSButton alloc]initWithFrame:CGRectMake(240 - 26- 10, 135 - 26 - 10, 26, 26)];
        closeButton.wantsLayer = YES;
        closeButton.layer.backgroundColor = [NSColor clearColor].CGColor;
        [closeButton setButtonType:NSButtonTypeMomentaryPushIn];
        [closeButton setBezelStyle:NSBezelStyleRegularSquare];
        [closeButton setImage:[NSImage imageNamed:@"close_ico"]];
        closeButton.tag = displayView.tag;
        closeButton.target = self;
        closeButton.action = @selector(closeButtonClick:);
        closeButton.imagePosition = NSImageOnly;
        closeButton.imageScaling = NSImageScaleProportionallyUpOrDown;
        closeButton.frame = CGRectMake(240 - 26- 10, 135 - 26 - 10, 26, 26);
        closeButton.bordered = NO;
        [displayView addSubview:closeButton];
    }
}

-(void)closeButtonClick:(NSButton *)button{
    LVRTCDisplayView *displayView = [self.documentView viewWithTag:button.tag];
    if (displayView) {
        [[LVRTCEngine sharedInstance] removeDisplayView:displayView];
        [[LVRTCEngine sharedInstance] stopPlayingStream:displayView.uid];
        [self.renders removeObjectForKey:displayView.uid];
        [displayView removeFromSuperview];
    }
}

-(CMMacStatisticsView *)statisticsView{
    if (!_statisticsView) {
        NSArray *views;
        [[NSBundle mainBundle] loadNibNamed:@"CMMacStatisticsView" owner:self topLevelObjects:&views];
        for (id obj in views) {
            if ([obj isKindOfClass:CMMacStatisticsView.class]) {
                _statisticsView = obj;
                _statisticsView.wantsLayer = YES;
                _statisticsView.layer.backgroundColor = [NSColor colorWithWhite:0 alpha:0.5].CGColor;
                _statisticsView.layer.masksToBounds = YES;
                _statisticsView.layer.cornerRadius = 10;
                [_statisticsView configure];
                break;
            }
        }
    }
    return _statisticsView;
}

#pragma mark - CMMLiveSettingViewDelegate
-(void)openStatisticsView:(BOOL)open{
    if (open) {
        if (self.statisticsView.superview) return;
        CMMLiveSettingView *settingView = [self.view viewWithTag:9999];
        [self.view addSubview:self.statisticsView positioned:(NSWindowBelow) relativeTo:settingView];
        [self.statisticsView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.view);
            make.width.equalTo(@375);
            make.height.equalTo(@200);
        }];
    }
    else{
        [self.statisticsView removeFromSuperview];
    }
}

-(void)didSetAVConfig:(LVAVConfig *)config{
    _avConfig = config;
    [[LVRTCEngine sharedInstance] setAVConfig:_avConfig];
    
}

-(void)makeToast:(NSString *)toast duration:(CGFloat)duration{
    
    self.toastLabel.alphaValue = 1;
    self.toastLabel.hidden = NO;
    
    self.toastLabel.stringValue = toast;
    self.toastLabel.wantsLayer = YES;
    self.toastLabel.textColor = NSColor.whiteColor;
    self.toastLabel.layer.backgroundColor = [NSColor colorWithWhite:0 alpha:0.7].CGColor;
    self.toastLabel.layer.masksToBounds = YES;
    self.toastLabel.layer.cornerRadius = 15;
    [self.toastLabel sizeToFit];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            self.toastLabel.animator.alphaValue = 0;
            self.toastLabel.hidden = YES;
        } completionHandler:^{
            
        }];
    });
}

-(void)OnKickOff:(NSInteger)reason roomId:(NSString *)roomId{
    NSLog(@"OnKickOff roomId:%@, reason:%ld",reason,roomId);
}

@end
