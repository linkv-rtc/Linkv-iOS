//
//  CMListViewController.m
//  CMLiveRoomDemo
//
//  Created by jfdreamyang on 2020/3/6.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import "CMListViewController.h"
#import "CMRoomListView.h"
#import "RTCNetworkManager.h"
#import "UIView+Toast.h"
#import "CMLiveViewController.h"

@interface CMListViewController ()<CMRoomListViewDelegate>
{
    __weak CMLiveViewController *currentVc;
    NSInteger _currentIndex;
}
@property (nonatomic,strong)CMRoomListView *listView;
@property (nonatomic,strong)NSTimer *autoRefreshTimer;
@property (nonatomic,strong)NSTimer *autoTestTimer;
@end

@implementation CMListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.view addSubview:self.listView];
    _currentIndex = 0;
    NSString *title = NSLocalizedString(@"room_list", nil);
    self.title = title;
    
    [UIBarButtonItem appearance].tintColor = [UIColor lightGrayColor];
    
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"barbuttonicon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    NSString *refresh = NSLocalizedString(@"room_refresh", nil);
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithTitle:refresh style:UIBarButtonItemStylePlain target:self action:@selector(refresh)];
    if (kEnableAutoTest) {
        self.autoRefreshTimer = [NSTimer scheduledTimerWithTimeInterval:120 target:self selector:@selector(refreshLiveMe) userInfo:nil repeats:YES];
        
        self.autoTestTimer = [NSTimer scheduledTimerWithTimeInterval:4 target:self selector:@selector(stopAndStart) userInfo:nil repeats:YES];
        
        [self refreshLiveMe];
    }
    else{
        [self refresh];
    }
}

-(void)stopAndStart{
    if (currentVc) {
        [currentVc backButtonClick];
    }
    else{
        LV_LOGI(@"Invalid current Vc, skip");
    }
    if (self.listView.dataSource.count == 0) {
        return;
    }
    CMLiveViewController *lvc = [[CMLiveViewController alloc]init];
    [RTCNetworkManager sharedManager].roomId = [NSString stringWithFormat:@"%@",self.listView.dataSource[_currentIndex++%self.listView.dataSource.count]];
    
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
    if ([RTCNetworkManager sharedManager].manualUserID.length > 0) {
        [RTCNetworkManager sharedManager].userId = [RTCNetworkManager sharedManager].manualUserID;
    }
    else{
        [RTCNetworkManager sharedManager].userId = [NSString stringWithFormat:@"G%@", RTCNetworkManager.sharedManager.suffix];
    }
    lvc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:lvc animated:YES completion:nil];
    currentVc = lvc;
}

-(void)refreshLiveMe{
    [[RTCNetworkManager sharedManager] POST:@{@"timestamp":[NSString stringWithFormat:@"%lld",(long long)NSDate.date.timeIntervalSince1970], @"appid":@"1069348354",@"page":@"1",@"size":@"100",@"sesssssskip":@"1",@"sign":@"sign"} api:@"https://rtc-stream-global-center.linkv.fun/admin/v1/vids" completion:^(NSDictionary * _Nullable result, RTCErrorCode httpCode) {
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *dummy = result[@"data"][@"vids"];
            if ([dummy isKindOfClass:NSArray.class] && dummy.count > 0) {
                [self.listView reloadData:dummy];
                _currentIndex = arc4random();
                [self stopAndStart];
            }
            else{
                dummy = @[@"L12345678"];
            }
            if (httpCode == RTCErrorCodeSuccess) {
                NSString *success = NSLocalizedString(@"get_room_success", nil);
                [self.view makeToast:success duration:2 position:@"bottom"];
            }
            else{
                NSString *failure = NSLocalizedString(@"get_room_failure", nil);
                [self.view makeToast:failure duration:2 position:@"bottom"];
            }
        });
    }];
}

-(void)dealloc{
    [self.autoRefreshTimer invalidate];
}

-(void)refresh{
    NSDictionary *body = @{@"app_id":[RTCNetworkManager sharedManager].appServerAppID};
    [[RTCNetworkManager sharedManager] GET:body name:RTCApiNameRoomList completion:^(NSDictionary * _Nullable result, RTCErrorCode httpCode) {
        NSLog(@"room list:%@",result);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *dummy = result[@"data"];
            if ([dummy isKindOfClass:NSArray.class] && dummy.count > 0) {
                [self.listView reloadData:dummy];
            }
            else{
                dummy = @[@"L12345678"];
            }
            if (httpCode == RTCErrorCodeSuccess) {
                NSString *success = NSLocalizedString(@"get_room_success", nil);
                [self.view makeToast:success duration:2 position:@"bottom"];
            }
            else{
                NSString *failure = NSLocalizedString(@"get_room_failure", nil);
                [self.view makeToast:failure duration:2 position:@"bottom"];
            }
        });
    }];
}

-(void)didSelectIndexPath:(NSIndexPath *)indexPath{
    CMLiveViewController *lvc = [[CMLiveViewController alloc]init];
    [RTCNetworkManager sharedManager].roomId = [NSString stringWithFormat:@"%@",self.listView.dataSource[indexPath.row]];
    
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
    if ([RTCNetworkManager sharedManager].manualUserID.length > 0) {
        [RTCNetworkManager sharedManager].userId = [RTCNetworkManager sharedManager].manualUserID;
    }
    else{
        [RTCNetworkManager sharedManager].userId = [NSString stringWithFormat:@"G%@", RTCNetworkManager.sharedManager.suffix];
    }
    lvc.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:lvc animated:YES completion:nil];
}

-(CMRoomListView *)listView{
    if (!_listView) {
        _listView = [[CMRoomListView alloc]init];
        _listView.delegate = self;
    }
    return _listView;
}

-(void)viewDidLayoutSubviews{
    self.listView.frame = self.view.frame;
}

-(void)back{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
