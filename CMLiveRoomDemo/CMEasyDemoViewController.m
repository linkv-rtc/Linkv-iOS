//
//  CMEasyDemoViewController.m
//  CMLiveRoomDemo
//
//  Created by jfdreamyang on 2020/3/6.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import "CMEasyDemoViewController.h"
#import "Masonry.h"
#import "LinkvFunction.h"
#import "LVRTCFileCapturer.h"
#import "LinkvVideoSource.h"

#define USE_TEST true

// mini
#define PRODUCT  @""
#define TEST_ENVIR  @""
#define PRODUCT_SIGN    @""
#define TEST_ENVIR_SIGN    @""


#define RGBAColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:a]

//const int64_t kInternalNanosecondsPerSecond = 1000000000;

typedef NS_ENUM(NSInteger, RoomStatus) {
    kRoomStatus_IDLE    = 0,
    kRoomStatus_JOINED  = 1,
    kRoomStatus_BEAM    = 2
};

@interface CMEasyDemoViewController ()<IRtcEventManager, AudioFrameObserver, AgoraRtcEngineDelegate>{
    AgoraVideoEncoderConfiguration *_currentConfig;
    LinkvVideoSource *_videoSource;
    AgoraRtcEngineKit *engine;
}
@property (weak, nonatomic) IBOutlet UITextField *          roomIdText;
@property (weak, nonatomic) IBOutlet UISegmentedControl *   hostSegmented;
@property (weak, nonatomic) IBOutlet UIButton *             startBtn;
@property (weak, nonatomic) IBOutlet UIButton *             startBeamBtn;
@property (weak, nonatomic) IBOutlet UIButton *             stopBeamBtn;
@property (weak, nonatomic) IBOutlet UIButton *             exitBtn;

@property (assign, nonatomic) RoomStatus    status;
@property (assign, nonatomic) bool          isHost;
@property (assign, nonatomic) bool          isShowKeyboard;

@property (assign, nonatomic) CGRect        frame;

@property (strong, nonatomic) NSString*     userId;
@property (nonatomic, strong) LVRTCDisplayView *    localView;

/// 渲染视图列表
@property (atomic, strong) NSMutableDictionary <NSString *, HinowView *> * renders;

@end

@implementation CMEasyDemoViewController

-(void)dealloc{
    [_videoSource stop];
}


-(BOOL)onRecordAudioFrame:(id)frame{
    return YES;
}

-(BOOL)onPlaybackAudioFrame:(id)frame{
    return YES;
}

- (void)rtcEngine:(AgoraRtcEngineKit* _Nonnull)engine lastmileProbeTestResult:(AgoraLastmileProbeResult* _Nonnull)result{
    
    NSLog(@"%@", result);
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    
    int room = ((long long)NSDate.date.timeIntervalSince1970) % 10000;
    self.roomIdText.text = [NSString stringWithFormat:@"%d",room];
    
    self.userId             = [NSString stringWithFormat:@"%d", room + 1];
    self.status             = kRoomStatus_IDLE;
    self.isShowKeyboard     = false;
    self.frame              = self.view.frame;
    self.localView          = nil;
    self.renders            = [NSMutableDictionary new];
    
    
    AgoraRtcEngineConfig *config = [AgoraRtcEngineConfig new];
    config.appId = @"3afa993e38084d7c863381884e06e283";
    config.areaCode = AgoraAreaCodeGLOB;
    engine = [AgoraRtcEngineKit sharedEngineWithConfig:config delegate:self];
    
    AgoraLastmileProbeConfig *config1 = [AgoraLastmileProbeConfig new];
    config1.probeDownlink = YES;
    config1.probeUplink = YES;
    config1.expectedUplinkBitrate = 1000 * 1000;
    config1.expectedDownlinkBitrate = 1000 * 1000;
    [engine startLastmileProbeTest:config1];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//
//        [engine stopLastmileProbeTest];
//
//    });
    
    
    [[LinkvFunction sharedFunction] create:@"" handler:self probeCompletion:^(LVNetworkProbeContent * _Nonnull content) {
        
    }];
    
    _currentConfig = [[AgoraVideoEncoderConfiguration alloc]initWithWidth:720 height:1280 frameRate:15 bitrate:1800 orientationMode:(AgoraVideoOutputOrientationModeAdaptative)];
    [[LinkvFunction sharedFunction] setVideoEncoderConfiguration:_currentConfig];
    
    _videoSource = [[LinkvVideoSource alloc]init];
    [[LinkvFunction sharedFunction] setVideoSource:_videoSource];
    
    
    // 设置手势事件取消键盘
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                           action:@selector(hidKeyboard:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    // 监听键盘事件
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onKeyboardHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    [self _initLocalView];
    [_videoSource start];
}
- (IBAction)backButtonClick:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLayoutSubviews {
    if (self.localView) {
        self.localView.frame = self.view.bounds;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [[LinkvFunction sharedFunction] leaveChannel:^(AgoraChannelStats * _Nonnull stat) {
            
    }];
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark - Keyboard Event
- (void)onKeyboardShow:(NSNotification *)note {
    if (![self.roomIdText isFirstResponder]) {
        return;
    }
    
    self.isShowKeyboard = true;

    CGRect keyBoardRect = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat deltaY = keyBoardRect.size.height - 80;
    
    [UIView animateWithDuration:0.1 animations:^{
        [self.roomIdText mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-126 - deltaY);
            } else {
                // Fallback on earlier versions
                make.bottom.equalTo(self.view).offset(-126 - deltaY);
            }
            
        }];
        [self.view layoutIfNeeded];
    }];
    
    
}

- (void)onKeyboardHide:(NSNotification *)note {

    [UIView animateWithDuration:0.1 animations:^{
        [self.roomIdText mas_remakeConstraints:^(MASConstraintMaker *make) {
            
            if (@available(iOS 11.0, *)) {
                make.bottom.equalTo(self.view.mas_safeAreaLayoutGuideBottom).offset(-126);
            } else {
                // Fallback on earlier versions
                make.bottom.equalTo(self.view).offset(-126);
            }
            
        }];
        [self.view layoutIfNeeded];
    }];
    
}

- (void)hidKeyboard {
    if (self.isShowKeyboard) {
        self.isShowKeyboard = false;
    }
}

- (void)hidKeyboard:(UITapGestureRecognizer*)tap {
    if (self.isShowKeyboard) {
        self.isShowKeyboard = false;
        [self.roomIdText resignFirstResponder];
    }
}


#pragma mark -
#pragma mark - IBAction
- (IBAction)onStartClick:(id)sender {
    self.isHost = (self.hostSegmented.selectedSegmentIndex == 0);
    NSLog(@"Click join room : %@, %d", self.roomIdText.text, self.isHost);
    
    if (self.status == kRoomStatus_IDLE) {
        self.isHost = (self.hostSegmented.selectedSegmentIndex == 0);
        self.roomIdText.enabled = NO;
        self.status = kRoomStatus_JOINED;
        NSString* room_id = self.roomIdText.text;
        [[LinkvFunction sharedFunction] joinChannelByToken:@"" channelId:room_id info:nil uid:self.userId.intValue joinSuccess:^(NSString * _Nonnull channel, NSUInteger uid, NSInteger elapsed) {
            
        }];
    }
}

- (IBAction)onStartBeamClick:(id)sender {
    if (self.isHost) {
        return;
    }
    NSLog(@"Click start beam : %@", self.roomIdText.text);
    if (self.status == kRoomStatus_JOINED && !self.isHost) {
        self.status = kRoomStatus_BEAM;
//        [self _startPublish];
    }
}

- (IBAction)onStopBeamClick:(id)sender {
    static BOOL mute = NO;
    mute = !mute;
    [[LinkvFunction sharedFunction] muteLocalAudioStream:mute];
    
    NSLog(@"Click stop beam : %@", self.roomIdText.text);
//    if (self.status == kRoomStatus_BEAM && !self.isHost) {
//        self.status = kRoomStatus_JOINED;
//        [self _removeLocalView];
//    }
}

- (IBAction)onExitClick:(id)sender {
    NSLog(@"Click exit room : %@", self.roomIdText.text);
    [self _reset];
    [[LinkvFunction sharedFunction] leaveChannel:^(AgoraChannelStats * _Nonnull stat) {
        
    }];
}
- (IBAction)mixAudioButtonClick:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"audio" ofType:@"mp3"];
    [[LVRTCEngine sharedInstance] startAudioMixing:path replace:YES loop:10];
}

- (void)rtcEngine:(id<AgoraFunction>)engine didJoinChannel:(NSString *)channel withUid:(NSUInteger)uid elapsed:(NSInteger)elapsed{
    
    [[LinkvFunction sharedFunction] registerAudioFrameObserver:(self)];
    
}

- (void)rtcEngine:(id<AgoraFunction>)engine didOfflineOfUid:(NSUInteger)uid reason:(AgoraUserOfflineReason)reason{
    NSString *userId = [NSString stringWithFormat:@"%@", @(uid)];
    HinowView *view = [self.renders objectForKey:userId];
    [view.linkv removeFromSuperview];
}

- (void)rtcEngine:(id<AgoraFunction>)engine didJoinedOfUid:(NSUInteger)uid elapsed:(NSInteger)elapsed{
    NSString *userId = [NSString stringWithFormat:@"%d", uid];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self createRenderView:userId];
    });
}

- (void)rtcEngine:(id<AgoraFunction>)engine didAudioMuted:(BOOL)muted byUid:(NSUInteger)uid{
    
}

- (void)rtcEngine:(id<AgoraFunction>)engine firstRemoteVideoDecodedOfUid:(NSUInteger)uid size:(CGSize)size elapsed:(NSInteger)elapsed{
    
}

- (void)rtcEngine:(id<AgoraFunction>)engine reportAudioVolumeIndicationOfSpeakers:(NSArray<AgoraRtcAudioVolumeInfo*>* _Nonnull)speakers totalVolume:(NSInteger)totalVolume{
    
}

- (void)rtcEngine:(id<AgoraFunction>)engine didOccurError:(AgoraErrorCode)errorCode{
    
}

- (void)rtcEngine:(id<AgoraFunction>)engine didLeaveChannelWithStats:(AgoraChannelStats* _Nonnull)stats{
    
}

- (void)_initLocalView {
    self.localView = [[LVRTCDisplayView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:self.localView atIndex:0];
    [[LVRTCEngine sharedInstance] addDisplayView:self.localView];
}

- (void)createRenderView:(NSString*)uid {
    dispatch_async(dispatch_get_main_queue(), ^{
        HinowView *view = [self.renders objectForKey:uid];
        if (!view) {
            NSInteger count = self.renders.allValues.count;
            HinowView *view = [[HinowView alloc]init];
            LVRTCDisplayView *renderView = [[LVRTCDisplayView alloc] initWithFrame:CGRectMake(10 + count%3 * (144 + 10), 30 + count/3 * (192 + 20), 144, 192)];
            [self.view insertSubview:renderView atIndex:1];
            renderView.uid = uid;
            view.linkv = renderView;
            self.renders[uid] = view;
            [[LinkvFunction sharedFunction] setupRemoteVideo:view];
            NSLog(@"CMSDK- Create render view : %@", uid);
        }
    });
}

- (void)_reset {
    self.status = kRoomStatus_IDLE;
    dispatch_async(dispatch_get_main_queue(), ^{
        self.roomIdText.enabled = YES;
    });
    [self hidKeyboard];
    [self _removeLocalView];
    [self _removeRenderView];
}

- (void)_removeLocalView {
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.localView) {
            [self.renders removeObjectForKey:self.userId];
            [self.localView removeFromSuperview];
            self.localView = nil;
        }
    });
}

- (void)_removeRenderView {
    dispatch_async(dispatch_get_main_queue(), ^{
        for (NSString *key in self.renders) {
            HinowView *displayView = [self.renders objectForKey:key];
            [displayView.linkv removeFromSuperview];
            [LVRTCEngine.sharedInstance removeDisplayView:displayView.linkv];
        }
        [self.renders removeAllObjects];
    });
}


-(bool)onPlaybackFrame:(int8_t *)samples numOfSamples:(int)numOfSamples bytesPerSample:(int)bytesPerSample channels:(int)channels samplesPerSec:(int)samplesPerSec{
    return true;
}

-(bool)onRecordFrame:(int8_t *)samples numOfSamples:(int)numOfSamples bytesPerSample:(int)bytesPerSample channels:(int)channels samplesPerSec:(int)samplesPerSec{
    return true;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
