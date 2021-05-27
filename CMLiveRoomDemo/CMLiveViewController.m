//
//  CMLiveViewController.m
//  CMLiveRoomDemo
//
//  Created by jfdreamyang on 2020/3/5.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import "CMLiveViewController.h"
#import <LinkV/LinkV.h>
#import "Masonry.h"
#import "UIImage+Ext.h"
#import "UIColor+Ext.h"
#import "RTCNetworkManager.h"
#import "CMLiveSettingView.h"
#import "UIView+Toast.h"
#import "CMLiveSettingCell.h"
#import "CMMultiPersonView.h"
#import "CMDemoAudioDecoder.h"
#import "CMVolumeControlView.h"
#import "CMLiveUserListView.h"
#import "CMVideoProfileHelper.h"
#import "CMBeautyControlView.h"
#import "CMStatisticsView.h"
#import "LVRTCFileCapturer.h"
#import <AVFoundation/AVFoundation.h>

//#define kCMUseFileCapturer          true

// 下面功能在 ToB 的 SDK 中不再开放，demo 可以通过该方式临时使用
@interface LVRTCEngine ()
- (void)beautyEnable:(bool)enable;

- (bool)enableVideoAutoResolution:(BOOL)enable;

- (void)setFlexfecEnable:(BOOL)enable;

- (void)enableDataReport:(BOOL)enable;
@end

typedef enum : NSUInteger {
    CMSettingModeNormal,
    CMSettingModeResolution,
    CMSettingModeAngle,
} CMSettingMode;

@interface LVAVConfig (DemoPrivate)
/// 当前视频采集参数
@property (nonatomic,assign)LVRTCVideoProfile capturerProfile;

/// 当前视频编码参数
@property (nonatomic,assign)LVRTCVideoProfile encoderProfile;
@end

static LVRTCCameraPosition _cameraPosition = LVRTCCameraPositionFront;

@interface CMLiveViewController ()<LVRTCEngineDelegate,CMLiveSettingViewDelegate,CMDemoAudioDecoderDelegate,CMLiveUserListViewDelegate,CMBeautyControlViewDelegate,LVRTCFileCapturerDelegate,RTCNetworkManagerDelegate>
{
    RTCRoomStatus _roomStatus;
    BOOL joinedRoom;
    CMSettingMode _settingMode;
    BOOL _externalAudioInput;
    NSMutableSet *_userIdList;
    BOOL _videoResolutionAdapter;
    
    LVRTCFileCapturer *_fileCapturer;

    NSFileHandle *_fileHandler;
    
    long long VideoStart;
    BOOL recorderRemoteVideo;
    NSFileHandle *_videoFileHandle;
    dispatch_queue_t _videoQueue;
    
    NSMutableArray *_statistics;
    
    int last_keyframe_size;
    int last_delta_size;
    
    
    NSMutableArray *_recvStats;
    
    NSString *hostUserId;
    
}

/// 主预览视图，如果是主播，则主播视图作为主预览视图
/// 如果是观众，随机取其中一个作为主预览视图
/// 超过 3 个人互动视频的话全部转换为 9 宫格视图

@property (nonatomic, strong) LVRTCDisplayView *mainPreview;

@property (nonatomic, strong) UILabel *roomIdLab;
@property (nonatomic, strong) UILabel *userIdLab;
@property (nonatomic, strong) UIButton *lianmai;
@property (nonatomic, strong) UIButton *switchCamera;
@property (nonatomic, strong) UIButton *muteMicphone;
@property (nonatomic, strong) UIButton *settingButton;
@property (nonatomic, strong) UIButton *duorenlianmai;
@property (nonatomic, strong) UIButton *startLivingButton;
@property (nonatomic, strong) UIButton *beautyButton;
@property (nonatomic, strong) LVRTCEngine *cmApi;
@property (nonatomic, strong) NSMutableDictionary *renders;
@property (nonatomic, strong) NSTimer *keepaliveTimer;
@property (nonatomic, strong) CMLiveSettingView *settingView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) CMMultiPersonView *multiPersionView;
@property (nonatomic, strong) CMDemoAudioDecoder *audioDecoder;
@property (nonatomic, assign) BOOL sendSei;
@property (nonatomic, assign) NSInteger currentNumber;
@property (nonatomic, strong) CMVolumeControlView *controlView;
@property (nonatomic, strong) CMBeautyControlView *beautyControlView;

@property (nonatomic, strong) CMLiveUserListView *userIdListView;
@property (nonatomic, strong) NSMutableDictionary <NSString *,NSValue *>*resolutionMap;
@property (nonatomic, strong) LVAVConfig *currentConfig;
@property (nonatomic, strong) CMStatisticsView *statisticsView;

@property (nonatomic, strong) NSMutableDictionary *writter;

@property (nonatomic, strong) NSLock *locker;
@property (nonatomic, strong) UIButton *recordLocalButton;
@property (nonatomic, strong) UIButton *recordRemoteButton;
@property (atomic)BOOL startRecordVideo;
@property (nonatomic)BOOL stopWriter;

@property (nonatomic, strong) UITextField *room2TextField;
@property (nonatomic, strong) UITextField *room3TextField;
@property (nonatomic, strong) UITextField *room4TextField;

@property (nonatomic, strong) UIButton *roomPkGoButton;
@property (nonatomic, strong) UIButton *roomPkLeaveButton;

@property (nonatomic, strong) UIButton *mix1;
@property (nonatomic, strong) UIButton *mix2;
@property (nonatomic, strong) UIButton *mix3;
@property (nonatomic, strong) UIButton *mix4;
@property (nonatomic, strong) UIButton *mix5;

@property (nonatomic, strong) NSMutableSet *roomIdSets;

@end

@implementation CMLiveViewController

-(void)dealloc{
    NSLog(@"%s",__func__);
    [UIApplication sharedApplication].idleTimerDisabled = NO;
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [_fileCapturer stopCapture];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor lightGrayColor];
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    self.recordLocalButton.hidden = YES;
    self.recordRemoteButton.hidden = YES;
    if([[LVRTCEngine sharedInstance] respondsToSelector:@selector(enableDataReport:)]){
        [[LVRTCEngine sharedInstance] enableDataReport:NO];
    }
    RTCNetworkManager.sharedManager.delegate = self;
    
    self.roomIdSets = [NSMutableSet new];
    _videoQueue = dispatch_queue_create("com.linkv.video.queue", DISPATCH_QUEUE_SERIAL);
    

    self.writter = [NSMutableDictionary new];
    self.stopWriter = YES;
    
    [LVRTCEngine setPublishQualityMonitorCycle:1];
    [LVRTCEngine setPlayQualityMonitorCycle:1];
    
    self.locker = [[NSLock alloc]init];
    
    _currentConfig = [[LVAVConfig alloc]initWithVideoProfile:LVRTCVideoProfile_720P];
    if ([[RTCNetworkManager sharedManager].roomId hasPrefix:@"M"]) {
        _currentConfig = [[LVAVConfig alloc]initWithVideoProfile:LVRTCVideoProfile_360P];
    }
    _videoResolutionAdapter = NO;
    
    self.cmApi = [LVRTCEngine sharedInstance];
    self.renders = [NSMutableDictionary new];
    self.dataSource = [[NSMutableArray alloc]init];
    
    _settingMode = CMSettingModeNormal;
    _externalAudioInput = NO;
    _resolutionMap = [NSMutableDictionary new];
    
    _userIdList = [[NSMutableSet alloc]init];
    
    UIButton *back = [UIButton buttonWithType:UIButtonTypeCustom];
    [back setImage:[UIImage imageNamed:@"barbuttonicon_back"] forState:UIControlStateNormal];
    [back addTarget:self action:@selector(backButtonClick) forControlEvents:UIControlEventTouchUpInside];
    back.tintColor = [UIColor lightGrayColor];
    [self.view addSubview:back];
    
    [back mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@8);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(4);
        } else {
            // Fallback on earlier versions
            make.top.equalTo(self.view).offset(4);
        }
        make.width.equalTo(@40);
        make.height.equalTo(@40);
    }];
    
    [self.view addSubview:self.roomIdLab];
    [self.view addSubview:self.userIdLab];
    
    [self.roomIdLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        if (@available(iOS 11.0, *)) {
            make.top.equalTo(self.view.mas_safeAreaLayoutGuideTop).offset(5);
        } else {
            // Fallback on earlier versions
            make.top.equalTo(self.view).offset(5);
        }
        make.width.equalTo(@300);
        make.height.equalTo(@40);
    }];
    
    
    [self.userIdLab mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.top.equalTo(self.roomIdLab.mas_bottom);
        make.width.equalTo(@300);
        make.height.equalTo(@20);
    }];
    
    [self.view insertSubview:self.multiPersionView belowSubview:back];
    
    if ([RTCNetworkManager sharedManager].type == RTCLiveTypeNormal) {
        self.multiPersionView.hidden = YES;
    }
    
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowBlurRadius = 2;
    shadow.shadowColor = [UIColor colorWithRed:0/255.0 green:0/255.0 blue:0/255.0 alpha:0.3];
    shadow.shadowOffset =CGSizeMake(0,0);
    
    NSString *roomId = [RTCNetworkManager sharedManager].roomId;
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:roomId attributes: @{NSFontAttributeName: [UIFont systemFontOfSize: 16],NSForegroundColorAttributeName: [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0], NSShadowAttributeName: shadow}];
    
    self.roomIdLab.attributedText = string;
    
    NSString *userId = [RTCNetworkManager sharedManager].userId;
    NSString *userIdLocal = NSLocalizedString(@"user_id", nil);
    NSMutableAttributedString *userIdString = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@%@",userIdLocal,userId] attributes: @{NSFontAttributeName: [UIFont systemFontOfSize: 14],NSForegroundColorAttributeName: [UIColor colorWithRed:255/255.0 green:255/255.0 blue:255/255.0 alpha:1.0], NSShadowAttributeName: shadow}];
    self.userIdLab.attributedText = userIdString;
    
    
    [self.view addSubview:self.startLivingButton];
    
    [self.startLivingButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@23);
        make.right.equalTo(self.view).offset(-23);
        make.height.equalTo(@45);
        if (@available(iOS 11.0, *)) {
            make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-80);
        } else {
            // Fallback on earlier versions
            make.bottom.equalTo(self.view).offset(-80);
        }
    }];
    
    [self.view addSubview:self.lianmai];
    [self.view addSubview:self.switchCamera];
    [self.view addSubview:self.muteMicphone];
    [self.view addSubview:self.settingButton];
    [self.view addSubview:self.duorenlianmai];
    [self.view addSubview:self.beautyButton];
    
    CGFloat width = 30;
    CGFloat height = 30;
    CGFloat _eyebrow = 0;
    if (@available(iOS 11.0, *)) {
        _eyebrow = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    } else {
        _eyebrow = 0;
    }
    if (RTCNetworkManager.sharedManager.isHost) {
        CGFloat originY = self.view.frame.size.height - height - 20 - _eyebrow;
        CGFloat space = (self.view.frame.size.width - 4*width)/4;
        CGFloat delta = self.view.frame.size.width/4;
        
        CGFloat duorenlianmaiY = _eyebrow + 22;
        self.duorenlianmai.frame = CGRectMake(self.view.frame.size.width - width - 10, duorenlianmaiY, width, height);
        
        self.beautyButton.frame = CGRectMake(space/2, originY, width, height);
        self.switchCamera.frame = CGRectMake(space/2 + delta, originY, width, height);
        self.muteMicphone.frame = CGRectMake(space/2 + 2 * delta, originY, width, height);
        self.settingButton.frame = CGRectMake(space/2 + 3 * delta, originY, width, height);
        
        [self.view insertSubview:self.mainPreview atIndex:0];
        if ([RTCNetworkManager sharedManager].type != RTCLiveTypeAudioMode) {
#if kCMUseFileCapturer
            _fileCapturer = [[LVRTCFileCapturer alloc]init];
            NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"mp4"];
            _fileCapturer.delegate = self;
            [_fileCapturer startCapturingFromFilePath:videoPath onError:^(NSError * _Nullable code) {
                NSLog(@"%@",code);
            }];
            [[LVRTCEngine sharedInstance] setAVConfig:_currentConfig];
#else
            [[LVRTCEngine sharedInstance] setAVConfig:_currentConfig];
            [[LVRTCEngine sharedInstance] startCapture];
#endif
        }
        [[LVRTCEngine sharedInstance] addDisplayView:self.mainPreview];
        [self updateMainPreviewLab:_currentConfig];
    }
    else{
        CGFloat originY = self.view.frame.size.height - height - 20 - _eyebrow;
        CGFloat space = (self.view.frame.size.width - 5*width)/5;
        CGFloat delta = self.view.frame.size.width/5;
        
        CGFloat duorenlianmaiY = _eyebrow + 22;
        self.duorenlianmai.frame = CGRectMake(self.view.frame.size.width - width - 10, duorenlianmaiY, width, height);
        
        self.lianmai.frame = CGRectMake(space/2, originY, width, height);
        self.beautyButton.frame = CGRectMake(space/2 + 1 * delta, originY, width, height);
        self.switchCamera.frame = CGRectMake(space/2 + 2 * delta, originY, width, height);
        self.muteMicphone.frame = CGRectMake(space/2 + 3 * delta, originY, width, height);
        self.settingButton.frame = CGRectMake(space/2 + 4 * delta, originY, width, height);
        
        [self startLiving];
        self.startLivingButton.hidden = YES;
    }
    self.keepaliveTimer = [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(roomKeepAlive) userInfo:nil repeats:YES];
    [[LVRTCEngine sharedInstance] enableVideoAutoRotation:NO];
    [self reloadViews];
    
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGestureClick:)];
    gesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:gesture];
    
    
    [self.view addSubview:self.recordLocalButton];
    [self.view addSubview:self.recordRemoteButton];
    
    [self.recordRemoteButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(@(-160));
        make.centerX.equalTo(self.view);
        make.width.equalTo(@120);
        make.height.equalTo(@25);
    }];
    
    [self.recordLocalButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self.recordRemoteButton.mas_top).offset(-60);
        make.centerX.equalTo(self.view);
        make.width.equalTo(@120);
        make.height.equalTo(@25);
    }];
    
    _statistics = [NSMutableArray new];
    _recvStats = [NSMutableArray new];
    
    
    self.room2TextField = [[UITextField alloc]init];
    self.room2TextField.placeholder = @"请输入房间 1 ID";
    self.room2TextField.borderStyle = UITextBorderStyleRoundedRect;
    self.room2TextField.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:self.room2TextField];
    [self.room2TextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@22);
        make.right.equalTo(self.view).offset(-22);
        make.height.equalTo(@40);
        make.top.equalTo(self.userIdLab.mas_bottom).offset(30);
    }];
    
    
    self.room3TextField = [[UITextField alloc]init];
    self.room3TextField.placeholder = @"请输入房间 2 ID";
    self.room3TextField.borderStyle = UITextBorderStyleRoundedRect;
    self.room3TextField.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:self.room3TextField];
    [self.room3TextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@22);
        make.right.equalTo(self.view).offset(-22);
        make.height.equalTo(@40);
        make.top.equalTo(self.room2TextField.mas_bottom).offset(20);
    }];

    
    self.room4TextField = [[UITextField alloc]init];
    self.room4TextField.placeholder = @"请输入房间 3 ID";
    self.room4TextField.borderStyle = UITextBorderStyleRoundedRect;
    self.room4TextField.font = [UIFont systemFontOfSize:17];
    [self.view addSubview:self.room4TextField];
    [self.room4TextField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(@22);
        make.right.equalTo(self.view).offset(-22);
        make.height.equalTo(@40);
        make.top.equalTo(self.room3TextField.mas_bottom).offset(20);
    }];
    
    self.roomPkGoButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.roomPkGoButton setTitle:@"开始PK" forState:UIControlStateNormal];
    [self.roomPkGoButton addTarget:self action:@selector(linkRoomButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.roomPkGoButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.view addSubview:self.roomPkGoButton];
    
    [self.roomPkGoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(@80);
        make.height.equalTo(@40);
        make.top.equalTo(self.room4TextField.mas_bottom).offset(40);
    }];
    
    self.roomPkLeaveButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.roomPkLeaveButton setTitle:@"结束PK" forState:UIControlStateNormal];
    [self.roomPkLeaveButton addTarget:self action:@selector(unlinkRoomButtonClick) forControlEvents:UIControlEventTouchUpInside];
    self.roomPkLeaveButton.titleLabel.font = [UIFont boldSystemFontOfSize:18];
    [self.view addSubview:self.roomPkLeaveButton];
    
    [self.roomPkLeaveButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.width.equalTo(@80);
        make.height.equalTo(@40);
        make.top.equalTo(self.roomPkGoButton.mas_bottom).offset(20);
    }];
    
    self.mix1 = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.mix1 setTitle:@"仅发送" forState:UIControlStateNormal];
//    self.mix1.tag = LVAudioMixingMode_SEND_ONLY + 50;
    self.mix1.frame = CGRectMake(0, 200, self.view.frame.size.width/5, 40);
    [self.mix1 addTarget:self action:@selector(mixButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.mix1];
    
    self.mix2 = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.mix2 setTitle:@"仅播放" forState:UIControlStateNormal];
//    self.mix2.tag = LVAudioMixingMode_PLAYOUT_ONLY + 50;
    self.mix2.frame = CGRectMake(self.view.frame.size.width/5, 200, self.view.frame.size.width/5, 40);
    [self.mix2 addTarget:self action:@selector(mixButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.mix2];
    
    self.mix3 = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.mix3 setTitle:@"发送播放" forState:UIControlStateNormal];
    self.mix3.frame = CGRectMake(self.view.frame.size.width/5*2, 200, self.view.frame.size.width/5, 40);
//    self.mix3.tag = LVAudioMixingMode_SEND_AND_PLAYOUT + 50;
    [self.mix3 addTarget:self action:@selector(mixButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.mix3];
    
    self.mix4 = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.mix4 setTitle:@"替MIC" forState:UIControlStateNormal];
    self.mix4.frame = CGRectMake(self.view.frame.size.width/5*3, 200, self.view.frame.size.width/5, 40);
//    self.mix4.tag = LVAudioMixingMode_REPLACE_MIC + 50;
    [self.mix4 addTarget:self action:@selector(mixButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.mix4];
    
    self.mix5 = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.mix5 setTitle:@"替MIC发送" forState:UIControlStateNormal];
    self.mix5.frame = CGRectMake(self.view.frame.size.width/5*4, 200, self.view.frame.size.width/5, 40);
//    self.mix5.tag = LVAudioMixingMode_REPLACE_MIC_AND_SEND_ONLY + 50;
    [self.mix5 addTarget:self action:@selector(mixButtonClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.mix5];
    
    self.roomPkGoButton.hidden = YES;
    self.roomPkLeaveButton.hidden = YES;
    self.room2TextField.hidden = YES;
    self.room3TextField.hidden = YES;
    self.room4TextField.hidden = YES;
    
    self.mix1.hidden = YES;
    self.mix2.hidden = YES;
    self.mix3.hidden = YES;
    self.mix4.hidden = YES;
    self.mix5.hidden = YES;
}

-(void)mixButtonClick:(UIButton *)mix{
//    [[LVRTCEngine sharedInstance] setAudioMixingMode:mix.tag - 50];
}

-(void)linkRoomButtonClick{
    if (self.room2TextField.text.length > 2 && [self.room2TextField.text hasPrefix:@"L"]) {
        if (![self.roomIdSets containsObject:self.room2TextField.text]) {
            [[LVRTCEngine sharedInstance] linkRoom:self.room2TextField.text];
            [self.roomIdSets addObject:self.room2TextField.text];
        }
    }
    if (self.room3TextField.text.length > 2 && [self.room3TextField.text hasPrefix:@"L"]) {
        if (![self.roomIdSets containsObject:self.room3TextField.text]) {
            [[LVRTCEngine sharedInstance] linkRoom:self.room3TextField.text];
            [self.roomIdSets addObject:self.room3TextField.text];
        }
    }
    if (self.room4TextField.text.length > 2 && [self.room4TextField.text hasPrefix:@"L"]) {
        if (![self.roomIdSets containsObject:self.room4TextField.text]) {
            [[LVRTCEngine sharedInstance] linkRoom:self.room4TextField.text];
            [self.roomIdSets addObject:self.room4TextField.text];
        }
    }
}

-(void)unlinkRoomButtonClick{
    for (NSString *roomId in self.roomIdSets) {
        [[LVRTCEngine sharedInstance] unlinkRoom:roomId];
    }
    [self.roomIdSets removeAllObjects];
}

-(void)handleTapGestureClick:(UITapGestureRecognizer *)gesture{
    
    [self.room2TextField resignFirstResponder];
    [self.room3TextField resignFirstResponder];
    [self.room4TextField resignFirstResponder];
    
    return;
    [self.locker lock];
    self.stopWriter = !self.stopWriter;
    [self.writter enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:AVAssetWriter.class]) {
            AVAssetWriter *writer = obj;
            [writer finishWritingWithCompletionHandler:^{
            }];
        }
        else if ([obj isKindOfClass:AVAssetWriterInput.class]){
            AVAssetWriterInput *input = obj;
            [input markAsFinished];
        }
    }];
    if (!self.stopWriter) {
        [self.view makeToast:@"视频录制已开启" duration:2 position:@"center"];
    }
    else{
        [self.view makeToast:@"视频录制已关闭" duration:2 position:@"center"];
    }
    [self.writter removeAllObjects];
    [self.locker unlock];
}

-(void)roomKeepAlive{
    if (_roomStatus == RTCRoomStatusLive) {
        [[RTCNetworkManager sharedManager] update:2];
    }
}

-(void)backButtonClick{
    [self dismissViewControllerAnimated:YES completion:nil];
    [[LVRTCEngine sharedInstance] stopCapture];
    [[LVRTCEngine sharedInstance] removeDisplayView:self.mainPreview];
    [[LVRTCEngine sharedInstance] logoutRoom:^(LVErrorCode code) {
        NSLog(@"logoutRoom:%ld",code);
    }];
    [self.keepaliveTimer invalidate];
    [self clearAllRenders];
    if ([RTCNetworkManager sharedManager].isHost) {
        [[RTCNetworkManager sharedManager] update:RTCRoomStatusStop];
    }
    [self.audioDecoder stop];

    NSArray *st = _statistics.copy;
    NSArray *play = _recvStats.copy;
    NSData *json = [NSJSONSerialization dataWithJSONObject:st options:NSJSONWritingPrettyPrinted error:nil];
    NSData *json2 = [NSJSONSerialization dataWithJSONObject:play options:NSJSONWritingPrettyPrinted error:nil];

    NSString *filePath = [NSString stringWithFormat:@"%@/Documents/videotoolbox_%ld.txt",NSHomeDirectory(),(long)NSDate.date.timeIntervalSince1970];
    NSString *playPath = [NSString stringWithFormat:@"%@/Documents/videotoolbox_play_%ld.txt",NSHomeDirectory(),(long)NSDate.date.timeIntervalSince1970];
    
    [json writeToFile:filePath atomically:YES];
    [json2 writeToFile:playPath atomically:YES];
}

-(void)clearAllRenders{
    NSArray *allValues = self.renders.allValues;
    for (LVRTCDisplayView *displayView in allValues) {
        [[LVRTCEngine sharedInstance] removeDisplayView:displayView];
    }
    [self.renders removeAllObjects];
}

#pragma mark -
#pragma mark - CMRoomDelegate
- (void)OnEnterRoomComplete:(LVErrorCode)result users:(nullable NSArray<LVUser *> *)users {
    if (result != LVErrorCodeSuccess) {
        NSLog(@"CMSDK- Error to enter room : %d", (int)result);
        return;
    }
    joinedRoom = YES;
    if (result == LVErrorCodeSuccess) {
        if (RTCNetworkManager.sharedManager.isHost) {
            [[LVRTCEngine sharedInstance] startPublishing];
            dispatch_async(dispatch_get_main_queue(), ^{
                [[LVRTCEngine sharedInstance] enableMic:!self.muteMicphone.selected];
            });
            _roomStatus = RTCRoomStatusLive;
            [self roomKeepAlive];
            dispatch_async(dispatch_get_main_queue(), ^{
                [UIView animateWithDuration:0.2 animations:^{
                    self.startLivingButton.alpha = 0;
                } completion:^(BOOL finished) {
                    self.startLivingButton.hidden = YES;
                }];
            });
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            for (LVUser * user in users) {
                NSString *userId = RTCNetworkManager.sharedManager.userId;
                if ([user.roomId isEqualToString:RTCNetworkManager.sharedManager.roomId] && [user.userId hasPrefix:@"H"]) {
                    hostUserId = user.userId;
                }
                // 如果是自己, 记录 pull url. 用 streamid(!!!), 兼容 zego
                if (![userId isEqualToString:user.userId]) {
                    [self.cmApi startPlayingStream:user.userId];
                    // 此时没有主预览视图，需要先确定主预览视图
                    if (!_mainPreview && ([user.userId hasPrefix:@"H"] || kEnableAutoTest)) {
                        [self.view insertSubview:self.mainPreview atIndex:0];
                        self.mainPreview.uid = user.userId;
                        [[LVRTCEngine sharedInstance] addDisplayView:self.mainPreview];
                        [self reloadViews];
                    }
                    else{
                        [self createRenderView:user.userId];
                    }
                }
                [_userIdList addObject:user.userId];
            }
        });
    }
}

- (void)OnExitRoomComplete {
    joinedRoom = NO;
}

- (void)OnAddRemoter:(nonnull LVUser *)user {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSString *userId = [RTCNetworkManager sharedManager].userId;
//        if ([user.roomId isEqualToString:RTCNetworkManager.sharedManager.roomId]) {
//            hostUserId = user.userId;
//        }
        [_userIdList addObject:user.userId];
        if (_userIdList.count > 4 && [RTCNetworkManager sharedManager].type == RTCLiveTypeNormal) {
            NSString *memtion = NSLocalizedString(@"person_surpass", nil);
            [self.view makeToast:memtion duration:2.0 position:@"center"];
            return;
        }
        if (![userId isEqualToString:user.userId]) {
            [self.cmApi startPlayingStream:user.userId];
            [self createRenderView:user.userId];
        }
        [self.userIdListView reloadData:_userIdList.allObjects];
    });
}

- (void)OnDeleteRemoter:(nonnull NSString *)uid {
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self.cmApi stopPlayingStream:uid];
    });
    dispatch_async(dispatch_get_main_queue(), ^{
        LVRTCDisplayView *displayView = [self.renders objectForKey:uid];
        if (!displayView) {
            if (![uid isEqualToString:_mainPreview.uid]) return;
            displayView = _mainPreview;
        }
        [UIView animateWithDuration:0.1 animations:^{
            displayView.alpha = 0;
        } completion:^(BOOL finished) {
            [displayView removeFromSuperview];
        }];
        [LVRTCEngine.sharedInstance removeDisplayView:displayView];
        [self.renders removeObjectForKey:uid];
        [self reloadViews];
        [_userIdList removeObject:uid];
        [self.resolutionMap removeObjectForKey:uid];
        [self.userIdListView reloadData:_userIdList.allObjects];
        [self.statisticsView remove:uid];
        if ([uid isEqualToString:hostUserId]) {
            if (![self.userIdLab.text containsString:@":H"]) {
                [self backButtonClick];
            }
        }
    });
}

- (void)OnAudioData:(nonnull NSString *)uid audio_data:(nonnull const void *)audio_data bits_per_sample:(int)bits_per_sample sample_rate:(int)sample_rate number_of_channels:(size_t)number_of_channels number_of_frames:(size_t)number_of_frames {
    
}

- (void)OnAudioMixStream:(nonnull const int16_t *)data samples:(int)samples nchannel:(int)nchannel flag:(LVAudioRecordType)flag {
    
}

- (void)OnMixComplete:(LVErrorCode)code {
    
}

- (void)OnPlayQualityUpate:(nonnull LVVideoStatistic *)quality userId:(nonnull NSString *)userId {
    NSDictionary *info = @{@"time":@([NSDate date].timeIntervalSince1970 * 1000), @"fps":@(quality.videoFps)};
     [_recvStats addObject:info];
    dispatch_async(dispatch_get_main_queue(), ^{
        LVRTCDisplayView *displayView = self.renders[userId];
        if (!displayView) {
            displayView = _mainPreview;
        }
        UILabel *resolutionLab = [displayView viewWithTag:10000];
        NSString *resolution = [resolutionLab.text componentsSeparatedByString:@" / "].firstObject;
        resolutionLab.text = [NSString stringWithFormat:@"%@ / %d",resolution,quality.videoFps];
        [self.statisticsView reloadView:quality userId:userId];
    });
}

-(void)keyframeSize:(int)keyframe_size deltaSize:(int)delta_size{
    last_keyframe_size = keyframe_size;
    last_delta_size = delta_size;
}

- (void)OnPublishQualityUpdate:(nonnull LVVideoStatistic *)quality {
    static int lastFps = 0;
    NSDictionary *info = @{@"cpu":@(quality.cpuusage),@"memory":@(quality.memoryusage),@"encode":@(quality.videoAvgEncodeCostMs),@"time":@([NSDate date].timeIntervalSince1970 * 1000), @"k":@(last_keyframe_size), @"d":@(last_delta_size),@"fps":@(quality.videoEncodeFrames - lastFps), @"vbps":@(quality.videoBitratebps)};
    [_statistics addObject:info];
    lastFps = quality.videoEncodeFrames;
//    NSLog(@"%@",info);
    dispatch_async(dispatch_get_main_queue(), ^{
        int fps = quality.videoFps;
        if (fps == 0 || quality.frameHeight == 0 || quality.frameWidth == 0) return;
         UILabel *resolutionLab;
        CGSize newSize = CGSizeMake(quality.frameWidth, quality.frameHeight);
         LVRTCDisplayView *displayView = self.renders[[RTCNetworkManager sharedManager].userId];
         if (displayView) {
             resolutionLab = [displayView viewWithTag:10000];
             resolutionLab.text = [NSString stringWithFormat:@"%.0fx%.0f / %d",newSize.width,newSize.height,fps];
         }
         else{
             resolutionLab = [_mainPreview viewWithTag:10000];
             resolutionLab.text = [NSString stringWithFormat:@"%.0fx%.0f / %d",newSize.width,newSize.height,fps];
         }
        [self.statisticsView reloadView:quality userId:RTCNetworkManager.sharedManager.userId];
    });
}

- (void)OnPlayStateUpdate:(LVErrorCode)code userId:(nonnull NSString *)userId {
    
}

- (void)OnPublishStateUpdate:(LVErrorCode)code {
    
}

- (void)OnRoomDisconnected:(LVErrorCode)code {
    joinedRoom = NO;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self backButtonClick];
    });
}

- (void)OnRoomReconnected {
    joinedRoom = YES;
}

- (void)OnSoundLevelUpdate:(nonnull NSArray<LVAudioVolume *> *)soundLevels {
    
}

-(void)OnKickOff:(NSInteger)reason roomId:(NSString *)roomId{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self backButtonClick];
    });
}

-(NSString *)OnMediaSideInfoInPublishVideoFrame:(NSUInteger)timestamp{
    long long datatime = [[[NSDate alloc] init] timeIntervalSince1970] * 1000;
    NSString *s = [NSString stringWithFormat:@"%lld",datatime];
    return  self.sendSei ? s : @"";
}

-(int64_t)OnDrawFrame:(CVPixelBufferRef)pixelBuffer uid:(NSString *)uid sei:(NSString *)sei{
    [self save:pixelBuffer userId:uid];
    int64_t sei_delay = 0;
    if (sei && sei.length > 0) {
        static NSInteger toast = 0;
        if (toast % 100 == 0) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.view makeToast:[NSString stringWithFormat:@"%@",sei] duration:1.0 position:@"center"];
            });
        }
        toast ++;
        sei_delay = [[NSString stringWithFormat:@"%@",sei] longLongValue];
    }
    size_t width = CVPixelBufferGetWidth(pixelBuffer);
    size_t height = CVPixelBufferGetHeight(pixelBuffer);
    NSValue *resolution = self.resolutionMap[uid];
    if (!resolution) {
        resolution = [NSValue valueWithCGSize:CGSizeMake(width, height)];
        [self resolutionDidChange:resolution.CGSizeValue uid:uid];
        self.resolutionMap[uid] = resolution;
    }
    else{
        CGSize point = resolution.CGSizeValue;
        if (fabs(point.width - width) > 0.1 || fabs(point.height - height) > 0.1) {
            resolution = [NSValue valueWithCGSize:CGSizeMake(width, height)];
            self.resolutionMap[uid] = resolution;
            [self resolutionDidChange:resolution.CGSizeValue uid:uid];
        }
    }
    return sei_delay;
}

#pragma mark - CMLiveViewController


-(void)resolutionDidChange:(CGSize)newSize uid:(NSString *)uid{
    dispatch_async(dispatch_get_main_queue(), ^{
        LVRTCDisplayView *displayView = self.renders[uid];
        if (!displayView && ![uid isEqualToString:[RTCNetworkManager sharedManager].userId]) {
            displayView = _mainPreview;
        }
        displayView.hidden = NO;
        UILabel *resolutionLab = [displayView viewWithTag:10000];
        NSArray *items = [resolutionLab.text componentsSeparatedByString:@" / "];
        if (items.count > 1) {
            NSString *fps = items.lastObject;
            resolutionLab.text = [NSString stringWithFormat:@"%.0fx%.0f / %@",newSize.width,newSize.height,fps];
        }
        else{
            resolutionLab.text = [NSString stringWithFormat:@"%.0fx%.0f",newSize.width,newSize.height];
        }
    });
}

- (void)viewDidLayoutSubviews {
    if (_mainPreview && [RTCNetworkManager sharedManager].type == RTCLiveTypeNormal) {
        _mainPreview.frame = self.view.bounds;
    }
}

-(LVRTCDisplayView *)mainPreview{
    if (!_mainPreview) {
        _mainPreview = [[LVRTCDisplayView alloc] init];
        _mainPreview.tag = 999;
        _mainPreview.viewContentMode = LVViewContentModeScaleAspectFit;
        _mainPreview.backgroundColor = [UIColor colorWithRed:50/255.f green:45/255.f blue:62/255.f alpha:1.f];;
        
        CGFloat eyebrow = 0;
        if (@available(iOS 11.0, *)) {
            eyebrow = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
        } else {
            eyebrow = 0;
        }
        if ([RTCNetworkManager sharedManager].type != RTCLiveTypeAudioMode) {
            UILabel *resolutionLab = [[UILabel alloc]initWithFrame:CGRectMake((self.view.frame.size.width - 100)/2, 70 + eyebrow, 100, 20)];
            resolutionLab.text = @"";
            resolutionLab.font = [UIFont systemFontOfSize:10];
            resolutionLab.textAlignment = NSTextAlignmentLeft;
            resolutionLab.textColor = [UIColor whiteColor];
            resolutionLab.tag = 10000;
            [_mainPreview addSubview:resolutionLab];
        }
        if ([RTCNetworkManager sharedManager].type != RTCLiveTypeNormal) {
            UIButton *close = [UIButton buttonWithType:UIButtonTypeCustom];
            [close addTarget:self action:@selector(closeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
            close.tag = _mainPreview.tag;
            [close setImage:[UIImage imageNamed:@"close_ico"] forState:UIControlStateNormal];
            close.frame = CGRectMake(122-26-5, 5, 26, 26);
            [_mainPreview addSubview:close];
        }
    }
    return _mainPreview;
}

-(void)updateMainPreviewLab:(LVAVConfig *)config{
    
    CGSize newSize = [CMVideoProfileHelper resolutionSize:config.capturerProfile];
    newSize = CGSizeMake(newSize.height, newSize.width);
    int fps = config.fps;
    UILabel *resolutionLab;
    LVRTCDisplayView *displayView = self.renders[[RTCNetworkManager sharedManager].userId];
    if (displayView) {
        resolutionLab = [displayView viewWithTag:10000];
        resolutionLab.text = [NSString stringWithFormat:@"%.0fx%.0f / %d",newSize.width,newSize.height,fps];
    }
    else{
        resolutionLab = [_mainPreview viewWithTag:10000];
        resolutionLab.text = [NSString stringWithFormat:@"%.0fx%.0f / %d",newSize.width,newSize.height,fps];
    }
    _currentConfig = config;
}

-(UILabel *)roomIdLab{
    if (!_roomIdLab) {
        _roomIdLab = [[UILabel alloc]init];
        _roomIdLab.textColor = [UIColor whiteColor];
        _roomIdLab.textAlignment = NSTextAlignmentCenter;
    }
    return _roomIdLab;
}

-(UILabel *)userIdLab{
    if (!_userIdLab) {
        _userIdLab = [[UILabel alloc]init];
        _userIdLab.textColor = [UIColor whiteColor];
        _userIdLab.textAlignment = NSTextAlignmentCenter;
    }
    return _userIdLab;
}

- (UIButton *)startLivingButton
{
    if (!_startLivingButton) {
        UIButton *button = [[UIButton alloc] init];
        [button.layer setMasksToBounds:YES];
        [button.layer setCornerRadius:4.0f];
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
        [button setBackgroundColor:[UIColor colorWithRed:17/255.0 green:205/255.0 blue:168/255.0 alpha:1.0]];
        
        NSString *title = NSLocalizedString(@"start_living", nil);

        NSMutableAttributedString * loginAttr = [[NSMutableAttributedString alloc]initWithString:title];
        [loginAttr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18],NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(0, title.length)];
        [button setAttributedTitle:loginAttr forState:UIControlStateNormal];
        
        [button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:10/255.0 green:180/255.0 blue:160/255.0 alpha:1.0]] forState:UIControlStateHighlighted];
        
        loginAttr = [[NSMutableAttributedString alloc]initWithString:title];
        [loginAttr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18],NSForegroundColorAttributeName:[UIColor lightGrayColor]} range:NSMakeRange(0, title.length)];
        [button setAttributedTitle:loginAttr forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(startLiving) forControlEvents:UIControlEventTouchUpInside];
        _startLivingButton = button;
    }
    return _startLivingButton;
}

-(void)startLiving{
    NSString *roomId = RTCNetworkManager.sharedManager.roomId;
    [[LVRTCEngine sharedInstance] loginRoom:RTCNetworkManager.sharedManager.userId roomId:roomId isHost:RTCNetworkManager.sharedManager.isHost isOnlyAudio:NO delegate:self];
    if (RTCNetworkManager.sharedManager.isHost) {
        _mainPreview.uid = RTCNetworkManager.sharedManager.userId;
    }
}

-(UIButton *)beautyButton{
    if (!_beautyButton) {
        _beautyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_beautyButton setImage:[UIImage imageNamed:@"beauty_ico"] forState:UIControlStateNormal];
        [_beautyButton setImage:[UIImage imageNamed:@"beauty_ico_selected"] forState:UIControlStateSelected];
        [_beautyButton addTarget:self action:@selector(beautyButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _beautyButton;
}

-(void)beautyButtonClick{
    _beautyButton.selected = !_beautyButton.selected;
    if (_beautyButton.selected) {
        [self.beautyControlView reset];
        [self.view addSubview:self.beautyControlView];
    }
    else{
        [self.beautyControlView removeFromSuperview];
    }
    if (!_beautyButton.selected) {
        [[[LVRTCEngine sharedInstance] getLVBeautyManager] setToneLevel:-1];
        [[[LVRTCEngine sharedInstance] getLVBeautyManager] setBeautyLevel:-1];
        [[[LVRTCEngine sharedInstance] getLVBeautyManager] setBrightLevel:-1];
    }
    else{
        [[[LVRTCEngine sharedInstance] getLVBeautyManager] setToneLevel:0.5];
        [[[LVRTCEngine sharedInstance] getLVBeautyManager] setBeautyLevel:0.5];
        [[[LVRTCEngine sharedInstance] getLVBeautyManager] setBrightLevel:0.5];
    }
}

-(void)hideBeautyControlView{
    [UIView animateWithDuration:0.2 animations:^{
        self.beautyControlView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.beautyControlView removeFromSuperview];
        self.beautyControlView.alpha = 1;
    }];
}

-(CMBeautyControlView *)beautyControlView{
    if (!_beautyControlView) {
        _beautyControlView = [[NSBundle mainBundle] loadNibNamed:@"CMBeautyControlView" owner:self options:nil].firstObject;
        _beautyControlView.delegate = self;
        CGFloat _eyebrow = 0;
         if (@available(iOS 11.0, *)) {
             _eyebrow = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
         } else {
             _eyebrow = 0;
         }
        _beautyControlView.frame = CGRectMake(12, self.view.frame.size.height - _eyebrow - 80 - 254, self.view.frame.size.width -  24, 254);
        _beautyControlView.layer.masksToBounds = YES;
        _beautyControlView.layer.cornerRadius = 10;
        _beautyControlView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
        
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *effect = [[UIVisualEffectView alloc]initWithEffect:blur];
        effect.frame = _beautyControlView.bounds;
        [_beautyControlView insertSubview:effect atIndex:0];
        
    }
    return _beautyControlView;
}

#pragma mark - CMBeautyControlViewDelegate
- (void)setBeautyLevel:(float)beautyLevel{
    [[[LVRTCEngine sharedInstance] getLVBeautyManager] setBeautyLevel:beautyLevel];
}

- (void)setBrightLevel:(float)brightLevel{
    [[[LVRTCEngine sharedInstance] getLVBeautyManager] setBrightLevel:brightLevel];
}

- (void)setToneLevel:(float)toneLevel{
    [[[LVRTCEngine sharedInstance] getLVBeautyManager] setToneLevel:toneLevel];
}



-(UIButton *)duorenlianmai{
    if (!_duorenlianmai) {
        _duorenlianmai = [UIButton buttonWithType:UIButtonTypeCustom];
        [_duorenlianmai setImage:[UIImage imageNamed:@"duorenlianmai_ico"] forState:UIControlStateNormal];
        [_duorenlianmai addTarget:self action:@selector(duorenlianmaiButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _duorenlianmai;
}
-(void)duorenlianmaiButtonClick{
    self.userIdListView.alpha = 0;
    [self.view addSubview:self.userIdListView];
    [self.userIdListView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    [UIView animateWithDuration:0.5 animations:^{
        self.userIdListView.alpha = 1.0;
    }];
    [self.userIdListView reloadData:_userIdList.allObjects];
}

-(UIButton *)lianmai{
    if (!_lianmai) {
        _lianmai = [UIButton buttonWithType:UIButtonTypeCustom];
        [_lianmai setImage:[UIImage imageNamed:@"lianmai"] forState:UIControlStateNormal];
        [_lianmai addTarget:self action:@selector(lianmaiButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _lianmai;
}

-(void)lianmaiButtonClick{
    if (joinedRoom) {
        self.beautyButton.selected = YES;
        [self beautyButtonClick];
        [self.cmApi setAVConfig:_currentConfig];
        [self.cmApi startPublishing];
        if ([RTCNetworkManager sharedManager].type != RTCLiveTypeAudioMode) {
            [self.cmApi startCapture];
        }
        // SDK 内部会自动将当前用户 ID 对应的视图和摄像头流进行绑定
        [self createRenderView:[RTCNetworkManager sharedManager].userId];
        [[LVRTCEngine sharedInstance] enableMic:!self.muteMicphone.selected];
        [self updateMainPreviewLab:_currentConfig];
    }
    else{
        [self.view makeToast:@"正在加入中，请稍后" duration:1.0 position:@"center"];
    }
}

-(UIButton *)switchCamera{
    if (!_switchCamera) {
        _switchCamera = [UIButton buttonWithType:UIButtonTypeCustom];
        [_switchCamera setImage:[UIImage imageNamed:@"reversed_ico"] forState:UIControlStateNormal];
        [_switchCamera addTarget:self action:@selector(switchCameraButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _switchCamera;
}

-(void)switchCameraButtonClick{
    if ([RTCNetworkManager sharedManager].type == RTCLiveTypeAudioMode) return;
    _cameraPosition = (LVRTCCameraPositionFront == _cameraPosition ? LVRTCCameraPositionBack:LVRTCCameraPositionFront);
    [[LVRTCEngine sharedInstance] switchCamera:_cameraPosition];
}

-(UIButton *)settingButton{
    if (!_settingButton) {
        _settingButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [_settingButton setImage:[UIImage imageNamed:@"setting_ico"] forState:UIControlStateNormal];
        [_settingButton addTarget:self action:@selector(settingButtonClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _settingButton;
}

-(void)settingButtonClick{

    if (self.dataSource.count == 0) {
        
        NSString *send_sei = NSLocalizedString(@"send_sei", nil);
        NSString *resolution_adaptation = NSLocalizedString(@"resolution_adaptation", nil);
        NSString *video_parameter = NSLocalizedString(@"video_parameter", nil);
        NSString *video_angle = NSLocalizedString(@"video_angle", nil);
        NSString *accompaniment_demo = NSLocalizedString(@"accompaniment_demo", nil);
        NSString *external_audio_input = NSLocalizedString(@"external_audio_input", nil);
        NSString *statistics = NSLocalizedString(@"statistics", nil);
        
        NSDictionary *sei = @{@"title":send_sei,@"type":@(CMCellTypeSwitch),@"default":@(0)};
        NSDictionary *resolutionAdapt = @{@"title":resolution_adaptation,@"type":@(CMCellTypeNone),@"default":@(0)};
        NSDictionary *resolution = @{@"title":video_parameter,@"type":@(CMCellTypeNone)};
        NSDictionary *outputAngle = @{@"title":video_angle,@"type":@(CMCellTypeNone)};
        NSDictionary *playMusic = @{@"title":accompaniment_demo,@"type":@(CMCellTypeSwitch),@"default":@(0)};
        NSDictionary *externalAudioInput = @{@"title":external_audio_input,@"type":@(CMCellTypeSwitch),@"default":@(0)};
        
        NSDictionary *statisticsInfo = @{@"title":statistics,@"type":@(CMCellTypeSwitch),@"default":@(0)};
        
        self.dataSource = [@[sei,resolutionAdapt,resolution,outputAngle,playMusic,externalAudioInput,statisticsInfo] mutableCopy];
    }
    self.settingView.dataSource = self.dataSource;
    [self.settingView reloadData];
    [self showSettingView];
}

-(void)showSettingView{
    CGRect frame = self.settingView.frame;
    frame.origin.y = 0;
    [self.view addSubview:self.settingView];
    [UIView animateWithDuration:0.2 animations:^{
        self.settingView.frame = frame;
    }];
}


-(void)settingView:(CMLiveSettingView *)settingView dismiss:(BOOL)dismiss{
    _settingMode = CMSettingModeNormal;
}

-(void)didChangeAVConfig:(LVAVConfig *)config{
    if (_videoResolutionAdapter) {
        config.videoDegradationPreference = LVVideoDegradationPreference_MAINTAIN_FRAMERATE;
    }
    else{
        config.videoDegradationPreference = LVVideoDegradationPreference_MAINTAIN_RESOLUTION;
    }
    [[LVRTCEngine sharedInstance] setAVConfig:config];
    [self updateMainPreviewLab:config];
}

-(void)didSelect:(NSIndexPath *)indexPath title:(NSString *)title isOn:(BOOL)isOn{
    
    NSString *send_sei = NSLocalizedString(@"send_sei", nil);
    NSString *resolution_adaptation = NSLocalizedString(@"resolution_adaptation", nil);
    NSString *video_parameter = NSLocalizedString(@"video_parameter", nil);
    NSString *video_angle = NSLocalizedString(@"video_angle", nil);
    NSString *accompaniment_demo = NSLocalizedString(@"accompaniment_demo", nil);
    NSString *external_audio_input = NSLocalizedString(@"external_audio_input", nil);
    NSString *statistics = NSLocalizedString(@"statistics", nil);
    
    if (_settingMode == CMSettingModeNormal) {
        if ([title isEqualToString:resolution_adaptation]) {
            NSString *_degrees0 = NSLocalizedString(@"CMVideoDegradationPreference_1", nil);
            NSString *_degrees90 = NSLocalizedString(@"CMVideoDegradationPreference_2", nil);
            NSString *_degrees180 = NSLocalizedString(@"CMVideoDegradationPreference_3", nil);
            
            NSDictionary *p0 = @{@"title":_degrees0,@"textAlignment":@(NSTextAlignmentCenter)};
            NSDictionary *p90 = @{@"title":_degrees90,@"textAlignment":@(NSTextAlignmentCenter)};
            NSDictionary *p180 = @{@"title":_degrees180,@"textAlignment":@(NSTextAlignmentCenter)};
            self.settingView.dataSource = @[p0,p90,p180];
            _settingMode = CMSettingModeResolution;
            [self.settingView reloadData];
            [self showSettingView];
        }
        else if ([title isEqualToString:video_parameter]){
            NSDictionary *item = @{@"type":@(CMCellTypeCustom),@"config":self.currentConfig};
            self.settingView.dataSource = @[item];
            [self.settingView reloadData];
            _settingMode = CMSettingModeResolution;
            [self.settingView reloadData];
            [self showSettingView];
        }
        else if ([title isEqualToString:send_sei]){
            NSMutableDictionary *item = [self.dataSource[indexPath.row] mutableCopy];
            item[@"default"] = @(isOn);
            self.dataSource[indexPath.row] = [item copy];
            self.sendSei = isOn;
        }
        else if ([title isEqualToString:video_angle]){
            
            NSString *_degrees0 = NSLocalizedString(@"0_degrees", nil);
            NSString *_degrees90 = NSLocalizedString(@"90_degrees", nil);
            NSString *_degrees180 = NSLocalizedString(@"180_degrees", nil);
            NSString *_degrees270 = NSLocalizedString(@"270_degrees", nil);
            
            NSDictionary *p0 = @{@"title":_degrees0,@"textAlignment":@(NSTextAlignmentCenter)};
            NSDictionary *p90 = @{@"title":_degrees90,@"textAlignment":@(NSTextAlignmentCenter)};
            NSDictionary *p180 = @{@"title":_degrees180,@"textAlignment":@(NSTextAlignmentCenter)};
            NSDictionary *p270 = @{@"title":_degrees270,@"textAlignment":@(NSTextAlignmentCenter)};
            self.settingView.dataSource = @[p0,p90,p180,p270];
            _settingMode = CMSettingModeAngle;
            [self.settingView reloadData];
            [self showSettingView];
        }
        else if ([title isEqualToString:accompaniment_demo]){
            
            if (!self.renders[[RTCNetworkManager sharedManager].userId] && ![RTCNetworkManager sharedManager].isHost) {
                NSString *accompaniment_demo_mention = NSLocalizedString(@"accompaniment_demo_mention", nil);
                [self.view makeToast:accompaniment_demo_mention duration:2.0 position:@"center"];
                return;
            }
            
            NSMutableDictionary *item = [self.dataSource[indexPath.row] mutableCopy];
            item[@"default"] = @(isOn);
            self.dataSource[indexPath.row] = [item copy];
            if (isOn) {
                NSString *audioPath = [[NSBundle mainBundle] pathForResource:@"audio" ofType:@"mp3"];
                [[LVRTCEngine sharedInstance] startAudioMixing:audioPath replace:NO loop:-1];
                [self showAudioControlerView];
            }
            else{
                [[LVRTCEngine sharedInstance] stopAudioMixing];
                [self hideAudioControlerView];
            }
        }
        else if ([title isEqualToString:external_audio_input]){
            if (joinedRoom && !_externalAudioInput) {
                NSString *join_room_setting = NSLocalizedString(@"join_room_setting", nil);
                [self.view makeToast:join_room_setting duration:1.0 position:@"center"];
                return;
            }
            NSMutableDictionary *item = [self.dataSource[indexPath.row] mutableCopy];
            item[@"default"] = @(isOn);
            self.dataSource[indexPath.row] = [item copy];
            if (!_externalAudioInput) {
                _externalAudioInput = YES;
                [[LVRTCEngine sharedInstance] enableExternalAudioInput:isOn];
            }
            if (!self.audioDecoder) {
                NSString *audioPath = [[NSBundle mainBundle] pathForResource:@"audio" ofType:@"mp3"];
                self.audioDecoder = [[CMDemoAudioDecoder alloc]initWithAudioPath:audioPath];
                self.audioDecoder.delegate = self;
            }
            if (isOn) {
                [self.audioDecoder start];
            }
            else{
                [self.audioDecoder pause];
            }
        }
        else if ([title isEqualToString:statistics]){
            NSMutableDictionary *item = [self.dataSource[indexPath.row] mutableCopy];
            item[@"default"] = @(isOn);
            self.dataSource[indexPath.row] = [item copy];
            if (isOn) {
                [self.view addSubview:self.statisticsView];
            }
            else{
                [self.statisticsView removeFromSuperview];
            }
            [self.settingView dismiss];
        }
    }
    else if (_settingMode == CMSettingModeAngle){
        [[LVRTCEngine sharedInstance] enableVideoAutoRotation:NO];
        
        NSString *_degrees0 = NSLocalizedString(@"0_degrees", nil);
        NSString *_degrees90 = NSLocalizedString(@"90_degrees", nil);
        NSString *_degrees180 = NSLocalizedString(@"180_degrees", nil);
        
        if ([title isEqualToString:_degrees0]) {
            [[LVRTCEngine sharedInstance] setOutputVideoRotation:LVVideoRotation_0];
        }
        else if ([title isEqualToString:_degrees90]){
            [[LVRTCEngine sharedInstance] setOutputVideoRotation:LVVideoRotation_90];
        }
        else if ([title isEqualToString:_degrees180]){
            [[LVRTCEngine sharedInstance] setOutputVideoRotation:LVVideoRotation_180];
        }
        else{
            [[LVRTCEngine sharedInstance] setOutputVideoRotation:LVVideoRotation_270];
        }
        [self.settingView dismiss];
        _settingMode = CMSettingModeNormal;
    }
    else if (_settingMode == CMSettingModeResolution){
        NSString *_degrees0 = NSLocalizedString(@"CMVideoDegradationPreference_1", nil);
        NSString *_degrees90 = NSLocalizedString(@"CMVideoDegradationPreference_2", nil);
        NSString *_degrees180 = NSLocalizedString(@"CMVideoDegradationPreference_3", nil);
        if ([title isEqualToString:_degrees0]) {
            _currentConfig.videoDegradationPreference = LVVideoDegradationPreference_MAINTAIN_FRAMERATE;
            [[LVRTCEngine sharedInstance] setAVConfig:_currentConfig];
        }
        else if ([title isEqualToString:_degrees90]){
            _currentConfig.videoDegradationPreference = LVVideoDegradationPreference_MAINTAIN_RESOLUTION;
            [[LVRTCEngine sharedInstance] setAVConfig:_currentConfig];
        }
        else if ([title isEqualToString:_degrees180]){
            _currentConfig.videoDegradationPreference = LVVideoDegradationPreference_DISABLED;
            [[LVRTCEngine sharedInstance] setAVConfig:_currentConfig];
        }
    }
}

#pragma mark - CMDemoAudioDecoderDelegate
-(void)didCaptureAudio:(int16_t *)buffer length:(NSInteger)length{
    [[LVRTCEngine sharedInstance] sendAudioFrame:buffer length:(int)length];
}

-(UIButton *)muteMicphone{
    if (!_muteMicphone) {
        _muteMicphone = [UIButton buttonWithType:UIButtonTypeCustom];
        [_muteMicphone addTarget:self action:@selector(muteButtonClick) forControlEvents:UIControlEventTouchUpInside];
        [_muteMicphone setImage:[UIImage imageNamed:@"mute_close_ico"] forState:UIControlStateNormal];
        [_muteMicphone setImage:[UIImage imageNamed:@"mute_open_ico"] forState:UIControlStateSelected];
    }
    return _muteMicphone;
}

-(void)muteButtonClick{
    [[LVRTCEngine sharedInstance] enableMic:self.muteMicphone.selected];
    self.muteMicphone.selected = !self.muteMicphone.selected;
}

-(CMLiveSettingView *)settingView{
    if (!_settingView) {
        _settingView = [[CMLiveSettingView alloc]initWithFrame:CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height)];
        _settingView.delegate = self;
    }
    return _settingView;
}

-(void)AudioMixerCurrentPlayingTime:(int)time_ms{
    NSLog(@"=============>%@",@(time_ms));
}


-(void)createRenderView:(NSString *)userId{
    LVRTCDisplayView *displayView = self.renders[userId];
    if (!displayView) {
        displayView = [[LVRTCDisplayView alloc]initWithFrame:CGRectMake(0, 0, 122, 218)];
        displayView.uid = userId;
        displayView.tag = self.renders.allValues.count + 1000;
        displayView.viewContentMode = LVViewContentModeScaleAspectFit;
        [self.view addSubview:displayView];
        [[LVRTCEngine sharedInstance] addDisplayView:displayView];
        
        UIButton *close = [UIButton buttonWithType:UIButtonTypeCustom];
        [close addTarget:self action:@selector(closeButtonClick:) forControlEvents:UIControlEventTouchUpInside];
        close.tag = displayView.tag;
        [close setImage:[UIImage imageNamed:@"close_ico"] forState:UIControlStateNormal];
        close.frame = CGRectMake(122-26-5, 5, 26, 26);
        [displayView addSubview:close];
        displayView.hidden = ![userId isEqualToString:[RTCNetworkManager sharedManager].userId];
        if ([RTCNetworkManager sharedManager].type == RTCLiveTypeAudioMode) {
            displayView.hidden = NO;
        }
        if ([RTCNetworkManager sharedManager].type != RTCLiveTypeAudioMode) {
            UILabel *resolutionLab = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, 100, 20)];
            resolutionLab.text = @"";
            resolutionLab.font = [UIFont systemFontOfSize:10];
            resolutionLab.textAlignment = NSTextAlignmentLeft;
            resolutionLab.textColor = [UIColor whiteColor];
            resolutionLab.tag = 10000;
            [displayView addSubview:resolutionLab];
        }
        self.renders[userId] = displayView;
    }
    [self reloadViews];
}


-(void)reloadViews{
    RTCLiveType type = [RTCNetworkManager sharedManager].type;
    if (type == RTCLiveTypeAudioMode || type == RTCLiveTypeConference) {
        if (_mainPreview && _mainPreview.alpha != 0) {
            UILabel *resolutionLab = [_mainPreview viewWithTag:10000];
            resolutionLab.frame = CGRectMake(5, 5, 100, 20);
            NSString *largeViewID = _mainPreview.uid ? _mainPreview.uid : [RTCNetworkManager sharedManager].userId;
            self.renders[largeViewID] = _mainPreview;
        }
        NSArray *views = self.renders.allValues;
        [self.multiPersionView reloadData:views];
        return;
    }
    NSArray *views = self.renders.allValues;
    CGFloat eyebrow = 0;
    if (@available(iOS 11.0, *)) {
        eyebrow = [UIApplication sharedApplication].keyWindow.safeAreaInsets.bottom;
    } else {
        eyebrow = 0;
    }
    CGFloat space = 5;
    CGFloat width = (self.view.frame.size.width - 20)/3;
    CGFloat height = width * 16 / 9.0;
    CGFloat screenWidth = self.view.frame.size.width;
    CGFloat screenHeight = self.view.frame.size.height;
    for (NSInteger i=0; i<views.count; i++) {
        LVRTCDisplayView *view = views[i];
        NSInteger index = i;
        view.frame = CGRectMake(screenWidth - width * (index + 1) - space * (index + 1), screenHeight - 218 - eyebrow - 20 - 30 - 20, width, height);
    }
}

-(void)closeButtonClick:(UIButton *)button{
    LVRTCDisplayView *displayView = [self.view viewWithTag:button.tag];
    NSString *uid = displayView.uid;
    if ([uid isEqualToString:[RTCNetworkManager sharedManager].userId] || !uid) {
        [self.cmApi stopPublishing];
        [self.cmApi stopCapture];
        if ([RTCNetworkManager sharedManager].isHost) {
            [self backButtonClick];
            return;
        }
    }
    else{
        [self.cmApi stopPlayingStream:uid];
    }
    if (!uid) uid = [RTCNetworkManager sharedManager].userId;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.resolutionMap removeObjectForKey:uid];
        LVRTCDisplayView *displayView = [self.renders objectForKey:uid];
        [UIView animateWithDuration:0.1 animations:^{
            displayView.alpha = 0;
        } completion:^(BOOL finished) {
            [displayView removeFromSuperview];
        }];
        if (displayView) {
            [LVRTCEngine.sharedInstance removeDisplayView:displayView];
        }
        [self.renders removeObjectForKey:uid];
    });
}

-(CMMultiPersonView *)multiPersionView{
    if (!_multiPersionView) {
        _multiPersionView = [[CMMultiPersonView alloc]initWithFrame:self.view.bounds];
        _multiPersionView.backgroundColor = [UIColor colorWithRed:27/255.0 green:20/255.0 blue:40/255.0 alpha:1.f];
    }
    return _multiPersionView;
}

-(CMVolumeControlView *)controlView{
    if (!_controlView) {
        _controlView = [[[NSBundle mainBundle] loadNibNamed:@"CMVolumeControlView" owner:self options:nil] firstObject];
        CGFloat space = 15;
        _controlView.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
        _controlView.layer.cornerRadius = 10;
        _controlView.layer.masksToBounds = YES;
        _controlView.frame = CGRectMake(space, 100, (self.view.frame.size.width - 30), 100);
        
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *effect = [[UIVisualEffectView alloc]initWithEffect:blur];
        effect.frame = _controlView.bounds;
        [_controlView insertSubview:effect atIndex:0];
        
    }
    return _controlView;
}

-(void)showAudioControlerView{
    self.controlView.alpha = 0;
    [self.view addSubview:self.controlView];
    [UIView animateWithDuration:0.1 animations:^{
        self.controlView.alpha = 1;
    }];
}

-(void)hideAudioControlerView{
    [UIView animateWithDuration:0.1 animations:^{
        self.controlView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.controlView removeFromSuperview];
    }];
}

-(CMLiveUserListView *)userIdListView{
    if (!_userIdListView) {
        _userIdListView = [[CMLiveUserListView alloc]init];
        _userIdListView.delegate = self;
        _userIdListView.layer.masksToBounds = YES;
        _userIdListView.layer.cornerRadius = 10;
    }
    return _userIdListView;
}

-(CMStatisticsView *)statisticsView{
    if (!_statisticsView) {
        
        CGFloat eyebrow = 0;
        if (@available(iOS 11.0, *)) {
            eyebrow = [UIApplication sharedApplication].keyWindow.safeAreaInsets.top;
        } else {
            eyebrow = 0;
        }
        _statisticsView = [[CMStatisticsView alloc]initWithFrame:CGRectMake(0, eyebrow + 90, self.view.frame.size.width, 200)];
        _statisticsView.backgroundColor = [UIColor clearColor];
    }
    return _statisticsView;;
}


-(void)listView:(CMLiveUserListView *)listView didSelected:(NSString *)userId{
    if ([userId isEqualToString:[RTCNetworkManager sharedManager].userId]) return;
    if (self.renders[userId] || ([_mainPreview.uid isEqualToString:userId] && _mainPreview.alpha == 1)) return;
    [self.resolutionMap removeObjectForKey:userId];
    [[LVRTCEngine sharedInstance] startPlayingStream:userId];
    if ([userId isEqualToString:_mainPreview.uid]) {
        [[LVRTCEngine sharedInstance] addDisplayView:_mainPreview];
        self.renders[_mainPreview.uid] = _mainPreview;
        _mainPreview.alpha = 1;
        [self reloadViews];
    }
    else{
        [self createRenderView:userId];
    }
}

-(void)save:(CVPixelBufferRef)pixelBuffer userId:(NSString *)userId{
    if (self.stopWriter) return;
    [self.locker lock];
    AVAssetWriter *writer = self.writter[userId];
    if (!writer) {
        OSType type = CVPixelBufferGetPixelFormatType(pixelBuffer);
        NSInteger videoWidth = CVPixelBufferGetWidth(pixelBuffer);
        NSInteger videoHeight = CVPixelBufferGetHeight(pixelBuffer);
        NSLog(@"videoWidth:%ld, videoHeight:%ld, type:%ld",videoWidth,videoHeight,type);
        NSDictionary *videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                         AVVideoCodecH264,AVVideoCodecKey,
                         [NSNumber numberWithInteger:videoWidth],AVVideoWidthKey,
                         [NSNumber numberWithInteger:videoHeight],AVVideoHeightKey,
                         nil];
        AVAssetWriterInput *input = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
        
       
        long long now = (long long)(CACurrentMediaTime() * 1000);
        
        NSString *dir = [NSString stringWithFormat:@"%@/Documents/VideoRecorder",NSHomeDirectory()];
        [[NSFileManager defaultManager] createDirectoryAtPath:dir withIntermediateDirectories:NO attributes:nil error:nil];
        NSString *path = [NSString stringWithFormat:@"%@/Documents/VideoRecorder/%lld-%u.mov",NSHomeDirectory(),now,arc4random()%10000];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        
        NSURL* url = [NSURL fileURLWithPath:path];
        //初始化写入媒体类型为MP4类型
        AVAssetWriter *writer = [AVAssetWriter assetWriterWithURL:url fileType:AVFileTypeQuickTimeMovie error:nil];
        //使其更适合在网络上播放
        writer.shouldOptimizeForNetworkUse = YES;
        
        if ([writer canAddInput:input]) {
            [writer addInput:input];
        }
        else{
            NSLog(@"input 添加失败");
        }
        NSDictionary* bufferAttributes = [NSDictionary
                                          dictionaryWithObjectsAndKeys:
                                          [NSNumber numberWithInt:type],
                                          kCVPixelBufferPixelFormatTypeKey,
                                          [NSNumber numberWithInt:(int)videoWidth], kCVPixelBufferWidthKey,
                                          [NSNumber numberWithInt:(int)videoHeight], kCVPixelBufferHeightKey,nil];
        
        AVAssetWriterInputPixelBufferAdaptor *avAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:input sourcePixelBufferAttributes:bufferAttributes];
        
        self.writter[[NSString stringWithFormat:@"%@-avAdaptor",userId]] = avAdaptor;
        self.writter[userId] = writer;
        self.writter[[NSString stringWithFormat:@"%@-start",userId]] = @(now);
        
        [writer startWriting];
        [writer startSessionAtSourceTime:kCMTimeZero];
        if (writer.status == AVAssetWriterStatusFailed) {
            NSLog(@"writer error %@",writer.error.localizedDescription);
        }
    }
    
    long long startedAt = [self.writter[[NSString stringWithFormat:@"%@-start",userId]] longLongValue];
    AVAssetWriterInputPixelBufferAdaptor *adapter = self.writter[[NSString stringWithFormat:@"%@-avAdaptor",userId]];
    
    if(!adapter.assetWriterInput.readyForMoreMediaData){
        NSLog(@"readyForMoreMediaData not ready");
        [self.locker unlock];
        return;
    }
    
    float millisElapsed = (long long)(CACurrentMediaTime() * 1000) - startedAt;
    CMTime time = CMTimeMake((int)millisElapsed, 1000);
    BOOL success = [adapter appendPixelBuffer:pixelBuffer withPresentationTime:time];
    static NSInteger counter = 0;
    if (!success && counter++ % 10 == 0) {
        NSInteger videoWidth = CVPixelBufferGetWidth(pixelBuffer);
        NSInteger videoHeight = CVPixelBufferGetHeight(pixelBuffer);
        OSType type = CVPixelBufferGetPixelFormatType(pixelBuffer);
        NSLog(@"Warning:  Unable to write buffer to video,videoWidth:%ld, videoHeight:%ld, type:%ld",videoWidth,videoHeight,type);
        [self.locker unlock];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleTapGestureClick:nil];
            [self.view makeToast:@"视频录制失败，请重试" duration:2 position:@"center"];
        });
        
        return;
    }
    [self.locker unlock];
}

-(void)OnCaptureVideoFrame:(CVPixelBufferRef)pixelBuffer{
    if (!self.startRecordVideo || recorderRemoteVideo == YES) {
        return;
    }
    CFRetain(pixelBuffer);
    dispatch_async(_videoQueue, ^{
//        NSData *bytes = [LVRTCEngine.sharedInstance convert:pixelBuffer];
        NSData *bytes;
        CFRelease(pixelBuffer);
        if (VideoStart == 0) {
            VideoStart = [NSDate date].timeIntervalSince1970 * 1000;
        }
        if (!_videoFileHandle) {
            NSString *videoPath = [NSString stringWithFormat:@"%@/Documents/local_video.yuv",NSHomeDirectory()];
            if ([[NSFileManager defaultManager] fileExistsAtPath:videoPath]) {
                [[NSFileManager defaultManager] removeItemAtPath:videoPath error:nil];
            }
            [[NSFileManager defaultManager] createFileAtPath:videoPath contents:nil attributes:nil];
            _videoFileHandle = [NSFileHandle fileHandleForWritingAtPath:videoPath];
        }
        long long now = [NSDate date].timeIntervalSince1970 * 1000;
        if ((now - VideoStart) < 10 * 1000 && self.startRecordVideo) {
            [_videoFileHandle writeData:bytes];
        }
        else{
            [_videoFileHandle closeFile];
            self.startRecordVideo = NO;
            VideoStart = 0;
            _videoFileHandle = nil;
        }
    });
}

- (void)didOutputSampleBuffer:(CMSampleBufferRef _Nullable)sampleBuffer{
    [[LVRTCEngine sharedInstance] sendVideoFrame:sampleBuffer];
    [self OnCaptureVideoFrame:CMSampleBufferGetImageBuffer(sampleBuffer)];
    CFRelease(sampleBuffer);
}

-(void)didReadCompleted{
    NSLog(@"%s",__func__);
}

-(UIButton *)recordLocalButton{
    
    if (!_recordLocalButton) {
        _recordLocalButton = [UIButton buttonWithType:UIButtonTypeSystem];
        [_recordLocalButton addTarget:self action:@selector(opevVideoRecorder:) forControlEvents:UIControlEventTouchUpInside];
        [_recordLocalButton setTitle:@"录制本地" forState:UIControlStateNormal];
    }
    return _recordLocalButton;
    
}
-(UIButton *)recordRemoteButton{
    if (!_recordRemoteButton) {
           _recordRemoteButton = [UIButton buttonWithType:UIButtonTypeSystem];
           [_recordRemoteButton addTarget:self action:@selector(openRemoteVideoRecorder:) forControlEvents:UIControlEventTouchUpInside];
           [_recordRemoteButton setTitle:@"录制远端" forState:UIControlStateNormal];
       }
       return _recordRemoteButton;
}

- (void)opevVideoRecorder:(id)sender {
    if (self.startRecordVideo) return;
    recorderRemoteVideo = NO;
    VideoStart = 0;
    self.startRecordVideo = YES;
}
- (void)openRemoteVideoRecorder:(id)sender {
    if (self.startRecordVideo) return;
    recorderRemoteVideo = YES;
    VideoStart = 0;
    self.startRecordVideo = YES;
}


@end
