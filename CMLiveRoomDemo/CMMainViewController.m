//
//  ViewController.m
//  CMLiveRoomDemo
//
//  Created by MikePro on 2020/1/22.
//  Copyright © 2020 Liveme. All rights reserved.
//

//treat_warnings_as_errors=false
//生成 release Xcode 工程更新
//gn gen out/ios_debug --args='target_os="ios" is_debug=false target_cpu="arm64" additional_target_cpus=["arm"]' --ide=xcode
//生成 debug Xcode 工程更新
//gn gen out/ios_debug --args='target_os="ios" target_cpu="arm64" additional_target_cpus=["arm"]' --ide=xcode

//生成 macOS 项目
//gn gen out/macOS --args='target_os="mac" is_debug=false' --ide=xcode


#import "CMMainViewController.h"
#import "CMSettingViewController.h"
#import <Foundation/Foundation.h>
#import <LinkV/LinkV.h>
#import "Masonry.h"
#import "CMLiveViewController.h"
#import "CMListViewController.h"
#import "CMEasyDemoViewController.h"
#import "UITransitionStyle.h"
#import "RTCNetworkManager.h"
#import "UIView+Toast.h"
#import "UIImage+Ext.h"
#import "UIColor+Ext.h"
#import "GCDWebServer.h"
#import "GCDWebDAVServer.h"
#import "UWConfig.h"

#define RGBAColor(r, g, b, a) [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:a]

const int64_t kInternalNanosecondsPerSecond = 1000000000;

typedef NS_ENUM(NSInteger, RoomStatus) {
    kRoomStatus_IDLE    = 0,
    kRoomStatus_JOINED  = 1,
    kRoomStatus_BEAM    = 2
};


@interface CMMainViewController ()<UIViewControllerTransitioningDelegate>{
    GCDWebServer *_davServer;
}
@property (nonatomic,strong)UIButton *loginButton;

@property (nonatomic,strong)UIButton *lookButton;

@property (nonatomic,assign)LVErrorCode authCode;

@property (nonatomic,assign)NSInteger tryTimes;

@property (nonatomic)dispatch_queue_t searialQueue;
@property (weak, nonatomic) IBOutlet UITextField *roomTextField;

@end

@implementation CMMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"%@", LVRTCEngine.buildVersion);
    
    _davServer = [[GCDWebServer alloc] init];
    [_davServer addGETHandlerForBasePath:@"/" directoryPath:NSHomeDirectory() indexFilename:nil cacheAge:3600 allowRangeRequests:YES];
    [_davServer startWithPort:8088 bonjourName:nil];
    
    [LVRTCEngine initSdk];
    [LVRTCEngine setLogLevel:(kLVLoggingSeverityInfo)];
    [RTCNetworkManager sharedManager].authCode = LVErrorCodeUnknownError;
    
    [self.view addSubview:self.loginButton];
    
    [self.view addSubview:self.lookButton];
    
    [self.lookButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(327));
        make.height.equalTo(@(57));
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.view).offset(-110);
    }];
    
    [self.loginButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@(327));
        make.height.equalTo(@(57));
        make.centerX.equalTo(self.view);
        make.bottom.equalTo(self.lookButton.mas_top).offset(-30);
    }];
    
    UITapGestureRecognizer *tapGestureClick = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(easyDemoClick)];
    tapGestureClick.numberOfTapsRequired = 5;
    [self.view addGestureRecognizer:tapGestureClick];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadLanguage) name:@"kCMAppReloadLanguage" object:nil];
    [LVRTCEngine setUseInternationalEnv:YES];
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"RTCAppType"]) {
        RTCAppType appType = [[NSUserDefaults standardUserDefaults] integerForKey:@"RTCAppType"];
        [[RTCNetworkManager sharedManager] setAppType:appType];
    }
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"RTCAppEnvironment"]) {
        RTCEnvironment environment = [[NSUserDefaults standardUserDefaults] integerForKey:@"RTCAppEnvironment"];
        [[RTCNetworkManager sharedManager] setEnvironment:environment];
    }
    else{
        [[RTCNetworkManager sharedManager] setEnvironment:RTCEnvironmentProduction];
    }
    
    UITapGestureRecognizer *hideKeyboard = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hideKeyboardClick)];
    [self.view addGestureRecognizer:hideKeyboard];
    
    [[RTCNetworkManager sharedManager] clearAllRoom];
    
}

-(void)hideKeyboardClick{
    [self.roomTextField resignFirstResponder];
}

-(void)easyDemoClick{
    CMEasyDemoViewController *easy = [[CMEasyDemoViewController alloc]initWithNibName:@"CMEasyDemoViewController" bundle:[NSBundle mainBundle]];
    easy.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:easy animated:YES completion:nil];
}


- (UIButton *)loginButton
{
    if (!_loginButton) {
        UIButton *button = [[UIButton alloc] init];
        [button.layer setMasksToBounds:YES];
        [button.layer setCornerRadius:4.0f];
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
        [button setBackgroundColor:[UIColor colorWithRed:17/255.0 green:205/255.0 blue:168/255.0 alpha:1.0]];
        [button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:10/255.0 green:180/255.0 blue:160/255.0 alpha:1.0]] forState:UIControlStateHighlighted];
        NSString *title = NSLocalizedString(@"start_streaming",nil);
        NSMutableAttributedString * loginAttr = [[NSMutableAttributedString alloc]initWithString:title];
        [loginAttr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18],NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(0, title.length)];
        [button setAttributedTitle:loginAttr forState:UIControlStateNormal];
        
        loginAttr = [[NSMutableAttributedString alloc]initWithString:title];
        [loginAttr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18],NSForegroundColorAttributeName:[UIColor lightGrayColor]} range:NSMakeRange(0, title.length)];
         [button setAttributedTitle:loginAttr forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(chooseLiveType) forControlEvents:UIControlEventTouchUpInside];
        _loginButton = button;
    }
    return _loginButton;
}


-(void)chooseLiveType{
    
    NSString *title = NSLocalizedString(@"streaming_type", nil);
    NSString *metion = NSLocalizedString(@"mention",nil);
    NSString *normal_streaming = NSLocalizedString(@"normal_streaming", nil);
    NSString *conference = NSLocalizedString(@"conference", nil);
    NSString *audio_mode = NSLocalizedString(@"audio_mode", nil);
    NSString *cancel = NSLocalizedString(@"cancel", nil);
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:title message:metion preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *action = [UIAlertAction actionWithTitle:normal_streaming style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [RTCNetworkManager sharedManager].type = RTCLiveTypeNormal;
        [self live];
    }];
    [ac addAction:action];
    
    action = [UIAlertAction actionWithTitle:conference style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [RTCNetworkManager sharedManager].type = RTCLiveTypeConference;
        [self live];
    }];
    [ac addAction:action];
    
    action = [UIAlertAction actionWithTitle:audio_mode style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [RTCNetworkManager sharedManager].type = RTCLiveTypeAudioMode;
        [self live];
    }];
    [ac addAction:action];
    
    action = [UIAlertAction actionWithTitle:cancel style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [ac addAction:action];
    [self presentViewController:ac animated:YES completion:^{
        
    }];
}


-(void)live{
    if ([RTCNetworkManager sharedManager].authCode != LVErrorCodeSuccess) {
        // 下面方法为避免第一次安装时网络权限没有获取到导致鉴权失败
        NSString *appId = [RTCNetworkManager sharedManager].mAppId;
        NSString *sk = [RTCNetworkManager sharedManager].mAppSign;
        [[LVRTCEngine sharedInstance] auth:appId
                             skStr:sk
                            userId:[RTCNetworkManager sharedManager].suffix
                        completion:^(LVErrorCode code) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"[CMSDK-Demo] auth:%ld",code);
                [RTCNetworkManager sharedManager].authCode = code;
                if (code != LVErrorCodeSuccess) {
                    if (self.tryTimes < 3) {
                        self.tryTimes++;
                        [self live];
                    }
                    else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSString *network_error = NSLocalizedString(@"network_error", nil);
                            [self.view makeToast:network_error duration:2 position:@"center"];
                        });
                    }
                }
                else{
                    [self live];
                }
            });
        }];
        return;
    }
    
    NSString *R = @"L";
    switch ([RTCNetworkManager sharedManager].type) {
        case RTCLiveTypeAudioMode:
            R = @"A";
            break;
        case RTCLiveTypeConference:
            R = @"M";
            break;
        default:
            R = @"L";
    }
    if ([RTCNetworkManager sharedManager].manualRoomID.length == 0) {
        NSString *roomId = self.roomTextField.text.length == 0 ? [RTCNetworkManager sharedManager].roomSuffix : self.roomTextField.text;
        [RTCNetworkManager sharedManager].roomId = [NSString stringWithFormat:@"%@%@",R ,roomId];
    }
    else{
        [RTCNetworkManager sharedManager].roomId = [RTCNetworkManager sharedManager].manualRoomID;
    }

    if ([RTCNetworkManager sharedManager].manualUserID.length == 0) {
        [RTCNetworkManager sharedManager].userId = [NSString stringWithFormat:@"H%@",RTCNetworkManager.sharedManager.suffix];
    }
    else{
        [RTCNetworkManager sharedManager].userId = [RTCNetworkManager sharedManager].manualUserID;
    }
    [RTCNetworkManager sharedManager].isHost = YES;
    CMLiveViewController *lvc = [[CMLiveViewController alloc]init];
    lvc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:lvc animated:YES completion:nil];
    
    [[RTCNetworkManager sharedManager] update:0];
    [[RTCNetworkManager sharedManager] update:1];
}

- (UIButton *)lookButton
{
    if (!_lookButton) {
        UIButton *button = [[UIButton alloc] init];
        [button.layer setMasksToBounds:YES];
        [button.layer setCornerRadius:4.0f];
        [button.titleLabel setFont:[UIFont boldSystemFontOfSize:18.0f]];
        [button setBackgroundColor:[UIColor colorWithRed:17/255.0 green:205/255.0 blue:168/255.0 alpha:1.0]];
        [button setBackgroundImage:[UIImage imageWithColor:[UIColor colorWithRed:10/255.0 green:180/255.0 blue:160/255.0 alpha:1.0]] forState:UIControlStateHighlighted];
        
        NSString *title = NSLocalizedString(@"look_streaming",nil);
        NSMutableAttributedString * loginAttr = [[NSMutableAttributedString alloc]initWithString:title];
        [loginAttr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18],NSForegroundColorAttributeName:[UIColor whiteColor]} range:NSMakeRange(0, title.length)];
        [button setAttributedTitle:loginAttr forState:UIControlStateNormal];
        
        loginAttr = [[NSMutableAttributedString alloc]initWithString:title];
        [loginAttr addAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:18],NSForegroundColorAttributeName:[UIColor lightGrayColor]} range:NSMakeRange(0, title.length)];
         [button setAttributedTitle:loginAttr forState:UIControlStateHighlighted];
        [button addTarget:self action:@selector(look) forControlEvents:UIControlEventTouchUpInside];
        _lookButton = button;
    }
    return _lookButton;
}

-(void)look{
    CMListViewController *lvc = [[CMListViewController alloc]init];
    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:lvc];
    nvc.modalPresentationStyle = UIModalPresentationFullScreen;
    nvc.transitioningDelegate = self;
    [self presentViewController:nvc animated:YES completion:nil];
}

#pragma Mark - UIViewControllerTransitioningDelegate
-(id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source{
    return [[UITransitionStyle alloc] init];
}
- (IBAction)chooseEnvironmentButtonClick:(id)sender {
    CMSettingViewController *setting = [[CMSettingViewController alloc]init];
    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:setting];
    nvc.modalPresentationStyle = UIModalPresentationFullScreen;
    nvc.transitioningDelegate = self;
    [self presentViewController:nvc animated:YES completion:nil];
}
- (IBAction)AutoTestButtonClick:(id)sender {
    
    
}


-(void)reloadLanguage{
    UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:[NSBundle mainBundle]];
    UIViewController *tbc = [storyBoard instantiateInitialViewController];
    dispatch_async(dispatch_get_main_queue(), ^{
        [UIApplication sharedApplication].keyWindow.rootViewController = tbc;
    });
}

@end
