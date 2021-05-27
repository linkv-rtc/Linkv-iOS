//
//  CMEasyDemoViewController.m
//  CMLiveRoomDemo
//
//  Created by jfdreamyang on 2020/3/6.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import "CMEasyDemoViewController.h"
#import "Masonry.h"
#import <LinkV/LinkV.h>

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

@interface LVRTCEngine (Ext)
+ (void)setDevMode:(bool)isDevMode;

+ (void)setDebugMode:(bool)isDebugMode;

@end


@interface CMEasyDemoViewController ()<LVRTCEngineDelegate>

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

// sdk api
@property (nonatomic, strong) LVRTCEngine *           cmApi;
@property (nonatomic, strong) LVRTCDisplayView *    localView;

/// 渲染视图列表
@property (atomic, strong) NSMutableDictionary <NSString *, LVRTCDisplayView *> * renders;

@end

@implementation CMEasyDemoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [LVRTCEngine initSdk];
    
    self.roomIdText.text = [NSString stringWithFormat:@"%ld",((NSInteger)NSDate.date.timeIntervalSince1970 - 1583000000)];
    
    int64_t datatime = [[[NSDate alloc] init] timeIntervalSince1970] * 1000;
    self.userId             = [NSString stringWithFormat:@"U_%lld", datatime];
    self.status             = kRoomStatus_IDLE;
    self.isShowKeyboard     = false;
    self.frame              = self.view.frame;
    self.cmApi              = [LVRTCEngine sharedInstance];
    self.localView          = nil;
    self.renders            = [NSMutableDictionary new];
    
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
    
    [self.cmApi startCapture];
    
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
        NSString *appId = USE_TEST ? TEST_ENVIR : PRODUCT;
        NSString *sk = USE_TEST ? TEST_ENVIR_SIGN : PRODUCT_SIGN;
        
        // 设置params
        __weak typeof(self) weakSelf = self;
        [self.cmApi auth:appId
                             skStr:sk
                            userId:self.userId
                        completion:^(LVErrorCode code) {
            __strong typeof(weakSelf) strong_self = weakSelf;
            if (strong_self) {
                if (code == LVErrorCodeSuccess) {
                    NSLog(@"[CMSDK-Demo] Succeed to auth.");
                    
                    [strong_self.cmApi loginRoom:strong_self.userId
                                          roomId:room_id
                                          isHost:self.isHost
                                     isOnlyAudio:false
                                        delegate:strong_self];
                } else {
                    NSLog(@"[CMSDK-Demo] Failed to auth.");
                }
            }
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
        [self _startPublish];
    }
}

- (IBAction)onStopBeamClick:(id)sender {
    if (self.isHost) {
        return;
    }
    
    NSLog(@"Click stop beam : %@", self.roomIdText.text);
    if (self.status == kRoomStatus_BEAM && !self.isHost) {
        self.status = kRoomStatus_JOINED;
        
        [self.cmApi stopCapture];
        [self.cmApi stopPublishing];
        [self _removeLocalView];
    }
}

- (IBAction)onExitClick:(id)sender {
    NSLog(@"Click exit room : %@", self.roomIdText.text);
    [self _reset];
    [self.cmApi stopCapture];
    [self.cmApi logoutRoom:^(LVErrorCode code) {
        
    }];
}
- (IBAction)mixAudioButtonClick:(id)sender {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"audio" ofType:@"mp3"];
    [[LVRTCEngine sharedInstance] startAudioMixing:path replace:YES loop:10];
}


#pragma mark -
#pragma mark - CMRoomDelegate
- (void)OnEnterRoomComplete:(LVErrorCode)result users:(nullable NSArray<LVUser *> *)users {
    if (result != LVErrorCodeSuccess) {
        NSLog(@"CMSDK- Error to enter room : %d", (int)result);
        [self _reset];
        return;
    }
    
    if (self.status == kRoomStatus_JOINED) {
        if (self.isHost) {
            self.status = kRoomStatus_BEAM;
            [self _startPublish];
        } else {
            for (LVUser * user in users) {
                // 如果是自己, 记录 pull url. 用 streamid(!!!), 兼容 zego
                if (![self.userId isEqualToString:user.userId]) {
                    [self.cmApi startPlayingStream:user.userId];
                    [self createRenderView:user.userId];
                }
            }
        }
    }
}

- (void)OnExitRoomComplete {
    
}

- (void)OnAddRemoter:(nonnull NSArray<LVUser *> *)users {
    for (LVUser * user in users) {
        // 如果是自己, 记录 pull url. 用 streamid(!!!), 兼容 zego
        if (![self.userId isEqualToString:user.userId]) {
            [self.cmApi startPlayingStream:user.userId];
            [self createRenderView:user.userId];
        }
    }
}

- (void)OnDeleteRemoter:(nonnull NSString *)uid {
    [self.cmApi stopPlayingStream:uid];
    dispatch_async(dispatch_get_main_queue(), ^{
        LVRTCDisplayView *displayView = [self.renders objectForKey:uid];
        [displayView removeFromSuperview];
        [LVRTCEngine.sharedInstance removeDisplayView:displayView];
        [self.renders removeObjectForKey:uid];
    });
}

- (void)OnAudioData:(nonnull NSString *)uid audio_data:(nonnull const void *)audio_data bits_per_sample:(int)bits_per_sample sample_rate:(int)sample_rate number_of_channels:(size_t)number_of_channels number_of_frames:(size_t)number_of_frames {
    
}

- (void)OnAudioMixStream:(nonnull const int16_t *)data samples:(int)samples nchannel:(int)nchannel flag:(LVAudioRecordType)flag {
    
}

- (void)OnMixComplete:(LVErrorCode)code {
    
}

- (void)OnPlayQualityUpate:(nonnull LVVideoStatistic *)quality userId:(nonnull NSString *)userId {
    
}

- (void)OnPlayStateUpdate:(LVErrorCode)code userId:(nonnull NSString *)userId {
    
}

- (void)OnPublishQualityUpdate:(nonnull LVVideoStatistic *)quality {
    
}

- (void)OnPublishStateUpdate:(LVErrorCode)code {
    
}

- (void)OnRoomDisconnect:(LVErrorCode)code {
    
}

- (void)OnRoomReconnected {
    
}

- (void)OnSoundLevelUpdate:(nonnull NSArray<LVAudioVolume *> *)soundLevels {
    
}


#pragma mark -
#pragma mark - Private API
- (void)_startPublish {
    [self.cmApi startPublishing];
}

- (void)_initLocalView {
    self.localView = [[LVRTCDisplayView alloc] initWithFrame:self.view.bounds];
    [self.view insertSubview:self.localView atIndex:0];
    [[LVRTCEngine sharedInstance] addDisplayView:self.localView];
}

- (void)createRenderView:(NSString*)uid {
    dispatch_async(dispatch_get_main_queue(), ^{
        LVRTCDisplayView *renderView = [self.renders objectForKey:uid];
        if (!renderView) {
            NSInteger count = self.renders.allValues.count;
            renderView = [[LVRTCDisplayView alloc] initWithFrame:CGRectMake(10 + count%3 * (144 + 10), 30 + count/3 * (192 + 20), 144, 192)];
            [self.view insertSubview:renderView atIndex:1];
            renderView.uid = uid;
            self.renders[uid] = renderView;
            [self.cmApi addDisplayView:renderView];
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
            LVRTCDisplayView *displayView = [self.renders objectForKey:key];
            [displayView removeFromSuperview];
            [LVRTCEngine.sharedInstance removeDisplayView:displayView];
        }
        [self.renders removeAllObjects];
    });
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
