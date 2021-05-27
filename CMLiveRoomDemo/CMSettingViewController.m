//
//  CMSettingViewController.m
//  CMLiveRoomDemo
//
//  Created by jfdreamyang on 2020/3/20.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import "CMSettingViewController.h"
#import "Masonry.h"
#import "RTCNetworkManager.h"
#import "CMSettingCell.h"
#import "UIView+Toast.h"
#import "CMParameterView.h"
#import "UWConfig.h"
#import <LinkV/LinkV.h>
#import <WebKit/WebKit.h>
#import <SafariServices/SafariServices.h>

@interface CMSettingViewController ()<UITableViewDelegate,UITableViewDataSource,CMParameterViewDelegate>
{
    UIView *bgView;
}
@property (nonatomic,strong)UITableView *tableView;
@property (nonatomic,strong)NSMutableArray *dataSource;
@end

@implementation CMSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"LinkV";
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc]initWithImage:[UIImage imageNamed:@"barbuttonicon_back"] style:UIBarButtonItemStylePlain target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = leftBarButton;
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *sdk_Version = [LVRTCEngine buildVersion];
    NSString *app_Name = @"LinkV";
    
//    [self.tableView registerClass:[CMSettingCell class] forCellReuseIdentifier:@"CMSettingCell"];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"CMSettingCell" bundle:[NSBundle mainBundle]] forCellReuseIdentifier:@"CMSettingCell"];
    
    NSString *version_str = NSLocalizedString(@"setting_version", nil);
    NSString *app_name_str = NSLocalizedString(@"app_name", nil);
    
    NSDictionary *version = @{@"title":version_str,@"items":@[@{@"App":app_Version,@"type":@(CMSettingTypeNormal)},@{app_name_str:app_Name,@"type":@(CMSettingTypeNormal)},@{@"SDK":sdk_Version,@"type":@(CMSettingTypeNormal)}]};
    
    NSString *environment_str = NSLocalizedString(@"setting_environment", nil);
    NSString *app_environment_str = NSLocalizedString(@"setting_app_environment", nil);
    NSString *app_type_str = NSLocalizedString(@"setting_app_type", nil);
    NSString *about_str = NSLocalizedString(@"setting_about", nil);
    
    NSString *production_str = NSLocalizedString(@"setting_prudtion", nil);
    NSString *test_str = NSLocalizedString(@"setting_test", nil);
    NSString *china_str = NSLocalizedString(@"setting_china", nil);
    NSString *international_str = NSLocalizedString(@"setting_international", nil);
    
    NSString *t = [RTCNetworkManager sharedManager].environment == RTCEnvironmentProduction ? production_str : test_str;
    NSString *t2 = [RTCNetworkManager sharedManager].appType == RTCAppTypeChina ? china_str : international_str;
    
    NSDictionary *environment = @{@"title":environment_str,@"items":@[@{app_environment_str:t,@"type":@(CMSettingTypeArrow)},@{app_type_str:t2,@"type":@(CMSettingTypeArrow)}]};
    
    NSDictionary *about = @{@"title":about_str,@"items":@[@{about_str:@"",@"type":@(CMSettingTypeArrow)}]};
    
    self.dataSource = [@[version,environment,about] mutableCopy];
    [self.view addSubview:self.tableView];
    
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showSetting)];
    tapGesture.numberOfTapsRequired = 5;
    [self.navigationController.navigationBar addGestureRecognizer:tapGesture];
    
    
    tapGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(enableDtls)];
    tapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:tapGesture];
    
}

-(void)enableDtls{
    static BOOL enable = false;
    enable = !enable;
//    [[LVRTCEngine sharedInstance] setDtlsEnable:enable];
    [self.view makeToast:[NSString stringWithFormat:@"DTLS 已 %@", enable ? @"打开":@"关闭"] duration:3 position:@"center"];
}

-(void)showSetting{
    bgView = [[UIView alloc]init];
    bgView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    [self.view.window addSubview:bgView];
    [bgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    CMParameterView *parameterView = [[NSBundle mainBundle] loadNibNamed:@"CMParameterView" owner:self options:nil].lastObject;
    [parameterView reloadData];
    parameterView.delegate = self;
    [bgView addSubview:parameterView];
    parameterView.layer.cornerRadius = 5;
    parameterView.layer.masksToBounds = YES;
    
    [parameterView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.width.equalTo(@300);
        make.height.equalTo(@360);
        make.centerX.equalTo(bgView);
        make.top.equalTo(@20);
    }];
}

-(void)cancel{
    [bgView removeFromSuperview];
}
-(void)confirm{
    [bgView removeFromSuperview];
}

-(void)back{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

-(UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc]initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
    }
    return _tableView;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return self.dataSource.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSDictionary *item = self.dataSource[section];
    NSArray *items = item[@"items"];
    return items.count;
}


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 20;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    NSDictionary *item = self.dataSource[section];
    return item[@"title"];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSDictionary *info = self.dataSource[indexPath.section];
    NSDictionary *item = info[@"items"][indexPath.row];
    CMSettingCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"CMSettingCell"];
    
    if ([item[@"type"] integerValue] == CMSettingTypeNormal) {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    else{
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    [cell reloadView:item];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSDictionary *info = self.dataSource[indexPath.section];
    NSDictionary *item = info[@"items"][indexPath.row];
    
    NSString *version_str = NSLocalizedString(@"setting_version", nil);
    
    NSString *environment_str = NSLocalizedString(@"setting_environment", nil);
    NSString *app_environment_str = NSLocalizedString(@"setting_app_environment", nil);
    NSString *app_type_str = NSLocalizedString(@"setting_app_type", nil);
    NSString *about_str = NSLocalizedString(@"setting_about", nil);
    
    NSString *production_str = NSLocalizedString(@"setting_prudtion", nil);
    NSString *test_str = NSLocalizedString(@"setting_test", nil);
    NSString *china_str = NSLocalizedString(@"setting_china", nil);
    NSString *international_str = NSLocalizedString(@"setting_international", nil);
    
    NSString *cancel_str = NSLocalizedString(@"cancel", nil);
    
    
    if([info[@"title"] isEqualToString:version_str]){
        NSString *value = item.allValues.firstObject;
        [UIPasteboard generalPasteboard].string = value;
        NSString *copy_to_clipboard = NSLocalizedString(@"copy_to_clipboard", nil);
        [self.view makeToast:copy_to_clipboard duration:2 position:@"center"];
    }
    else if ([info[@"title"] isEqualToString:about_str]) {
        SFSafariViewController *svc = [[SFSafariViewController alloc]initWithURL:[NSURL URLWithString:@"http://www.linkv.io"]];
        [self presentViewController:svc animated:YES completion:nil];
    }
    else if([info[@"title"] isEqualToString:environment_str]){
        
        NSString *key = @"";
        for (NSString *_key in item.allKeys) {
            if (![_key isEqualToString:@"type"]) {
                key = _key;
                break;
            }
        }
        if ([key isEqualToString:app_environment_str]) {
            
            if (CM_APP_STORE_VERSION) {
                return;
            }
            NSString *av_environment_setting = NSLocalizedString(@"av_environment_setting", nil);
            NSString *setting_default_environment = NSLocalizedString(@"setting_default_environment", nil);
            
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:av_environment_setting message:setting_default_environment preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *action = [UIAlertAction actionWithTitle:production_str style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[RTCNetworkManager sharedManager] setEnvironment:RTCEnvironmentProduction];
                [[NSUserDefaults standardUserDefaults] setInteger:RTCEnvironmentProduction forKey:@"RTCAppEnvironment"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                NSMutableDictionary *item = [self.dataSource[1] mutableCopy];
                
                NSMutableArray *items = [item[@"items"] mutableCopy];
                items[0] = @{app_environment_str:production_str,@"type":@(CMSettingTypeArrow)};
                item[@"items"] = items;
                
                self.dataSource[1] = [item copy];
                [self.tableView reloadData];
            }];
            [ac addAction:action];
            
            action = [UIAlertAction actionWithTitle:test_str style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                [[RTCNetworkManager sharedManager] setEnvironment:RTCEnvironmentTest];
                NSMutableDictionary *item = [self.dataSource[1] mutableCopy];
                
                [[NSUserDefaults standardUserDefaults] setInteger:RTCEnvironmentTest forKey:@"RTCAppEnvironment"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                NSMutableArray *items = [item[@"items"] mutableCopy];
                items[0] = @{app_environment_str:test_str,@"type":@(CMSettingTypeArrow)};
                item[@"items"] = items;
                
                self.dataSource[1] = [item copy];
                [self.tableView reloadData];
                
            }];
            [ac addAction:action];
            
            action = [UIAlertAction actionWithTitle:cancel_str style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [ac addAction:action];
            [self presentViewController:ac animated:YES completion:^{
                
            }];
            
        }
        else if ([key isEqualToString:app_type_str]){
            if (CM_APP_STORE_VERSION) {
                return;
            }
            NSString *av_environment_setting = NSLocalizedString(@"av_environment_setting", nil);
            NSString *setting_default_app_type = NSLocalizedString(@"setting_default_app_type", nil);
            UIAlertController *ac = [UIAlertController alertControllerWithTitle:av_environment_setting message:setting_default_app_type preferredStyle:UIAlertControllerStyleActionSheet];
            UIAlertAction *action = [UIAlertAction actionWithTitle:china_str style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UWConfig.userLanguage = @"zh-Hans";
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kCMAppReloadLanguage" object:nil];
                [[RTCNetworkManager sharedManager] setAppType:RTCAppTypeChina];
                [[NSUserDefaults standardUserDefaults] setInteger:RTCAppTypeChina forKey:@"RTCAppType"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                
                
                NSMutableDictionary *item = [self.dataSource[1] mutableCopy];
                NSMutableArray *items = [item[@"items"] mutableCopy];
                items[1] = @{app_type_str:china_str,@"type":@(CMSettingTypeArrow)};
                item[@"items"] = items;
                
                self.dataSource[1] = [item copy];
                [self.tableView reloadData];
                
                
                
            }];
            [ac addAction:action];
            
            action = [UIAlertAction actionWithTitle:international_str style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
                UWConfig.userLanguage = @"en";
                [[NSNotificationCenter defaultCenter] postNotificationName:@"kCMAppReloadLanguage" object:nil];
                [[RTCNetworkManager sharedManager] setAppType:RTCAppTypeInternational];
                [[NSUserDefaults standardUserDefaults] setInteger:RTCAppTypeInternational forKey:@"RTCAppType"];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                NSMutableDictionary *item = [self.dataSource[1] mutableCopy];
                NSMutableArray *items = [item[@"items"] mutableCopy];
                items[1] = @{app_type_str:international_str,@"type":@(CMSettingTypeArrow)};
                item[@"items"] = items;
                
                self.dataSource[1] = [item copy];
                [self.tableView reloadData];
                
            }];
            [ac addAction:action];
            
            action = [UIAlertAction actionWithTitle:cancel_str style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
                
            }];
            [ac addAction:action];
            [self presentViewController:ac animated:YES completion:^{
                
            }];
        }
    }
    
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
