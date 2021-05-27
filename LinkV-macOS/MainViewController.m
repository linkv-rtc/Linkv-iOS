//
//  ViewController.m
//  LinkV-macOS
//
//  Created by jfdreamyang on 2020/4/7.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import "MainViewController.h"
#import <LinkV/LinkV.h>
#import <CoreMedia/CoreMedia.h>
#import <CoreVideo/CoreVideo.h>
#import "RTCNetworkManager.h"
#import "CMLiveViewController.h"
#import "CMPresentationAnimator.h"
#import "CMTableCellView.h"
#import "CMMLiveSettingView.h"
#import "CMSettingController.h"
#import "Masonry.h"
#import "MBProgressHUD.h"


#if __has_feature(objc_arc)
#define MB_AUTORELEASE(exp) exp
#define MB_RELEASE(exp) exp
#define MB_RETAIN(exp) exp
#else
#define MB_AUTORELEASE(exp) [exp autorelease]
#define MB_RELEASE(exp) [exp release]
#define MB_RETAIN(exp) [exp retain]
#endif

NSString * const kCMDRTCLocalView    = @"cm_rtc_local_view";

@interface MainViewController ()<NSTableViewDelegate,NSTableViewDataSource,CMTableCellViewDelegate>
{
    CMSettingController *settingView;
}
@property (nonatomic,strong)LVAVConfig *configOC;
@property (nonatomic,strong)LVRTCDisplayView *displayView;

@property (weak) IBOutlet NSView *controlView;
@property (weak) IBOutlet NSTableView *tableView;
@property (nonatomic,strong)NSArray *dataSource;
@property (weak) IBOutlet NSTextField *marketLab;
@property (weak) IBOutlet NSTextField *roomIdTextField;
@property (weak) IBOutlet NSTextField *toastLabel;

@property (nonatomic,assign)BOOL showListView;
@property (nonatomic,assign)NSInteger tryTimes;
@end

@implementation MainViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.view.layer.backgroundColor = [NSColor lightGrayColor].CGColor;
    self.controlView.wantsLayer = YES;
    self.controlView.layer.cornerRadius = 10;
    self.controlView.layer.masksToBounds = YES;
    self.controlView.layer.backgroundColor = [NSColor whiteColor].CGColor;
    // Do any additional setup after loading the view.
    [LVRTCEngine initSdk];
    [LVRTCEngine setLogLevel:(kLVLoggingSeverityInfo)];
    [RTCNetworkManager sharedManager].authCode = LVErrorCodeUnknownError;
    
    BOOL hasSet = NO;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"RTCAppType"]) {
        RTCAppType appType = [[NSUserDefaults standardUserDefaults] integerForKey:@"RTCAppType"];
        
        if ([[NSUserDefaults standardUserDefaults] objectForKey:@"RTCAppEnvironment"]) {
            RTCEnvironment environment = [[NSUserDefaults standardUserDefaults] integerForKey:@"RTCAppEnvironment"];
            [[RTCNetworkManager sharedManager] fixEnvironment:environment];
            hasSet = YES;
        }
        [[RTCNetworkManager sharedManager] setAppType:appType];
    }
    if (!hasSet && [[NSUserDefaults standardUserDefaults] objectForKey:@"RTCAppEnvironment"]) {
        RTCEnvironment environment = [[NSUserDefaults standardUserDefaults] integerForKey:@"RTCAppEnvironment"];
        [[RTCNetworkManager sharedManager] setEnvironment:environment];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadLanguage) name:@"kCMAppReloadLanguage" object:nil];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView registerNib:[[NSNib alloc]initWithNibNamed:@"CMTableCellView" bundle:[NSBundle mainBundle]] forIdentifier:@"CMTableCellView"];
    self.tableView.superview.superview.hidden = YES;
    
    NSString *market = NSLocalizedString(@"Marketing Cooperation", nil);
    NSMutableAttributedString *string = [[NSMutableAttributedString alloc]initWithString:[NSString stringWithFormat:@"%@: cloud@liveme.com",market]];
    [string addAttributes:@{NSForegroundColorAttributeName:[NSColor lightGrayColor]} range:NSMakeRange(0, market.length+1)];
    self.marketLab.attributedStringValue = string;
    self.toastLabel.stringValue = @"";
    self.toastLabel.hidden = YES;
    
}
- (IBAction)settingButtonClick:(id)sender {
    
    NSArray *views;
    [[NSBundle mainBundle] loadNibNamed:@"CMSettingController" owner:self topLevelObjects:&views];
    for (id obj in views) {
        if ([obj isKindOfClass:CMSettingController.class]) {
            settingView = obj;
            settingView.wantsLayer = YES;
            settingView.layer.backgroundColor = [NSColor colorWithRed:241/255.0 green:241/255.0 blue:246/255. alpha:1.f].CGColor;
            [settingView configure];
            settingView.alphaValue = 0;
            [self.view addSubview:settingView];
            [settingView mas_makeConstraints:^(MASConstraintMaker *make) {
                make.right.equalTo(self.view);
                make.top.equalTo(self.view);
                make.width.equalTo(@(300));
                make.height.equalTo(self.view);
            }];
            
            [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
               
                context.duration = 0.4;
                settingView.animator.alphaValue = 1;
                
            } completionHandler:^{
                settingView.alphaValue = 1;
            }];
            
            break;
        }
    }
}

-(void)mouseDown:(NSEvent *)event{
    
    CGPoint point = [event locationInWindow];
    CGRect frame = self.tableView.superview.superview.frame;
    BOOL contain = CGRectContainsPoint(frame, point);
    if (!contain) {
        CGRect frame = self.view.bounds;
        frame.origin.x = self.view.bounds.size.width;
        frame.size.width = 300;
        
        self.showListView = NO;
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            context.duration = 0.5;
            self.tableView.superview.superview.animator.frame = frame;
        } completionHandler:^{
            self.tableView.superview.superview.hidden = YES;
        }];
    }
    
    frame = settingView.frame;
    contain = CGRectContainsPoint(frame, point);
    
    if (!contain) {
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            context.duration = 0.3;
            settingView.animator.alphaValue = 0;
        } completionHandler:^{
            [settingView removeFromSuperview];
            settingView = nil;
        }];
    }
    [self.view.window makeFirstResponder:nil];
}

-(void)viewDidLayout{
    if (self.showListView) {
        CGRect frame = self.view.bounds;
        frame.origin.x = self.view.bounds.size.width - 300;
        frame.size.width = 300;
        self.tableView.superview.superview.frame = frame;
    }
}

-(void)refresh{
    [[RTCNetworkManager sharedManager] GET:@{@"app_id":[RTCNetworkManager sharedManager].mAppId} name:RTCApiNameRoomList completion:^(NSDictionary * _Nullable result, RTCErrorCode httpCode) {
        NSLog(@"room list:%@",result);
        dispatch_async(dispatch_get_main_queue(), ^{
            if (httpCode == RTCErrorCodeSuccess) {
                NSString *success = NSLocalizedString(@"get_room_success", nil);
                NSArray *dummy = result[@"data"];
                [self reloadData:dummy];
            }
            else{
                NSString *failure = NSLocalizedString(@"get_room_failure", nil);
            }
        });
    }];
}

-(void)reloadData:(NSArray *)list{
    self.dataSource = list;
    [self.tableView reloadData];
}


-(void)reloadLanguage{
    
}

- (IBAction)live:(id)sender {
    
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
                        [self live:nil];
                    }
                    else{
                        dispatch_async(dispatch_get_main_queue(), ^{
                            NSString *network_error = NSLocalizedString(@"network_error", nil);
                            [self makeToast:network_error duration:2];
                        });
                    }
                }
                else{
                    [self live:nil];
                }
            });
        }];
        return;
    }
    [RTCNetworkManager sharedManager].type = RTCLiveTypeNormal;
    [[RTCNetworkManager sharedManager] auth:^(BOOL success) {
        NSString *R = @"L";
        [RTCNetworkManager sharedManager].roomId = [NSString stringWithFormat:@"%@%@",R,[RTCNetworkManager sharedManager].roomSuffix];
        [RTCNetworkManager sharedManager].userId = [NSString stringWithFormat:@"H%@",RTCNetworkManager.sharedManager.suffix];
        [RTCNetworkManager sharedManager].isHost = YES;
        
        if (self.roomIdTextField.stringValue.length >= 6) {
            [RTCNetworkManager sharedManager].roomId = [NSString stringWithFormat:@"%@%@",R,self.roomIdTextField.stringValue];
        }
        CMPresentationAnimator *animator = [[CMPresentationAnimator alloc]init];
        CMLiveViewController *lvc = [[CMLiveViewController alloc]init];
        [self presentViewController:lvc animator:animator];
        
        [[RTCNetworkManager sharedManager] update:0];
        [[RTCNetworkManager sharedManager] update:1];
    }];
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
        }];
    });
}

- (IBAction)look:(id)sender {
    self.showListView = !self.showListView;
    if (self.showListView) {
        self.tableView.superview.superview.hidden = NO;
        CGRect frame = self.view.bounds;
        frame.origin.x = self.view.bounds.size.width - 300;
        frame.size.width = 300;
        [self refresh];
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            context.duration = 0.5;
            self.tableView.superview.superview.animator.frame = frame;
        } completionHandler:^{
            self.tableView.superview.superview.frame = frame;
        }];
    }
    else{
        CGRect frame = self.view.bounds;
        frame.origin.x = self.view.bounds.size.width;
        frame.size.width = 300;
        
        [NSAnimationContext runAnimationGroup:^(NSAnimationContext * _Nonnull context) {
            context.duration = 0.5;
            self.tableView.superview.superview.animator.frame = frame;
        } completionHandler:^{
            self.tableView.superview.superview.hidden = YES;
        }];
    }
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];

    // Update the view, if already loaded.
}

#pragma mark NSTableViewDelegate NSTableViewDataSource
-(NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return self.dataSource.count;
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    CMTableCellView *cellView = [tableView makeViewWithIdentifier:@"CMTableCellView" owner:self];
    cellView.roomLab.stringValue = [NSString stringWithFormat:@"%@",self.dataSource[row]];
    cellView.row = row;
    cellView.delegate = self;
    return cellView;
}

-(CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row{
    return 44;
}

-(CGFloat)tableView:(NSTableView *)tableView sizeToFitWidthOfColumn:(NSInteger)column{
    return 300;
}

-(void)didSelectRow:(NSInteger)row{
    
    [[RTCNetworkManager sharedManager] auth:^(BOOL success) {
        NSString *roomId = [NSString stringWithFormat:@"%@",self.dataSource[row]];
        CMLiveViewController *lvc = [[CMLiveViewController alloc]init];
        [RTCNetworkManager sharedManager].roomId = roomId;
        if ([[RTCNetworkManager sharedManager].roomId hasPrefix:@"A"]) {
            [RTCNetworkManager sharedManager].type = RTCLiveTypeAudioMode;
        }
        else if ([[RTCNetworkManager sharedManager].roomId hasPrefix:@"M"]){
            [RTCNetworkManager sharedManager].type = RTCLiveTypeConference;
        }
        else{
            [RTCNetworkManager sharedManager].type = RTCLiveTypeNormal;
        }
        [RTCNetworkManager sharedManager].isHost = NO;
        [RTCNetworkManager sharedManager].userId = [NSString stringWithFormat:@"G%@", RTCNetworkManager.sharedManager.suffix];
        CMPresentationAnimator *animator = [[CMPresentationAnimator alloc]init];
        [self presentViewController:lvc animator:animator];
    }];
}


@end
