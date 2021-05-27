//
//  CMSettingController.m
//  LinkV-macOS
//
//  Created by jfdreamyang on 2020/4/10.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import "CMSettingController.h"
#import "RTCNetworkManager.h"
#import <LinkV/LinkV.h>
#import <SafariServices/SafariServices.h>


@interface CMSettingController ()
@property (weak) IBOutlet NSView *viewA;
@property (weak) IBOutlet NSView *viewB;
@property (weak) IBOutlet NSView *viewC;
@property (weak) IBOutlet NSTextField *versionApp;
@property (weak) IBOutlet NSTextField *versionSDK;
@property (weak) IBOutlet NSPopUpButton *appEnvironment;
@property (weak) IBOutlet NSPopUpButton *appType;
@end

@implementation CMSettingController

-(void)configure{
    self.viewA.wantsLayer = YES;
    self.viewA.layer.backgroundColor = [NSColor whiteColor].CGColor;
    self.viewB.wantsLayer = YES;
    self.viewB.layer.backgroundColor = [NSColor whiteColor].CGColor;
    self.viewC.wantsLayer = YES;
    self.viewC.layer.backgroundColor = [NSColor whiteColor].CGColor;
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *app_Version = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *sdk_Version = [LVRTCEngine buildVersion];
    
    self.versionApp.stringValue = app_Version;
    self.versionSDK.stringValue = sdk_Version;
    
    NSString *production_str = NSLocalizedString(@"setting_prudtion", nil);
    NSString *test_str = NSLocalizedString(@"setting_test", nil);
    NSString *china_str = NSLocalizedString(@"setting_china", nil);
    NSString *international_str = NSLocalizedString(@"setting_international", nil);

    NSMenu *menu = [[NSMenu alloc]initWithTitle:china_str];
    self.appType.menu = menu;
    
    menu = [[NSMenu alloc]initWithTitle:production_str];
    self.appEnvironment.menu = menu;
    
    NSInteger environmentI = 0;
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"RTCAppEnvironment"]) {
        RTCEnvironment environment = [[NSUserDefaults standardUserDefaults] integerForKey:@"RTCAppEnvironment"];
        if (environment == RTCEnvironmentTest) {
            environmentI = 1;
        }
    }
    NSInteger appTypeI = 0;
    if([[NSUserDefaults standardUserDefaults] objectForKey:@"RTCAppType"]) {
        RTCAppType environment = [[NSUserDefaults standardUserDefaults] integerForKey:@"RTCAppType"];
        if (environment == RTCAppTypeInternational) {
            appTypeI = 1;
        }
    }
    [self.appEnvironment addItemsWithTitles:@[production_str,test_str]];
    [self.appType addItemsWithTitles:@[china_str,international_str]];

    [self.appEnvironment selectItem:[self.appEnvironment.menu itemAtIndex:environmentI]];
    [self.appType selectItem:[self.appType.menu itemAtIndex:appTypeI]];
}

-(void)mouseDown:(NSEvent *)event{
    CGPoint point = [event locationInWindow];
    point = [self.superview convertPoint:point toView:self];
    CGRect frame = self.viewC.frame;
    BOOL contain = CGRectContainsPoint(frame, point);
    if (contain) {
        [[NSWorkspace sharedWorkspace] openURL:[NSURL URLWithString:@"http://www.linkv.io"]];
    }
}

- (IBAction)appEnvironmentClick:(NSPopUpButton *)sender {
    NSString *production_str = NSLocalizedString(@"setting_prudtion", nil);
    NSMenuItem *item = [sender selectedItem];
    if ([item.title isEqualToString:production_str]) {
        [[RTCNetworkManager sharedManager] setEnvironment:(RTCEnvironmentProduction)];
        [[NSUserDefaults standardUserDefaults] setInteger:RTCEnvironmentProduction forKey:@"RTCAppEnvironment"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else{
        [[RTCNetworkManager sharedManager] setEnvironment:(RTCEnvironmentTest)];
        [[NSUserDefaults standardUserDefaults] setInteger:RTCEnvironmentTest forKey:@"RTCAppEnvironment"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}
- (IBAction)appTypeClick:(NSPopUpButton *)sender {
    NSMenuItem *item = [sender selectedItem];
    NSString *china_str = NSLocalizedString(@"setting_china", nil);
    if ([item.title isEqualToString:china_str]) {
        [[RTCNetworkManager sharedManager] setAppType:(RTCAppTypeChina)];
        [[NSUserDefaults standardUserDefaults] setInteger:RTCAppTypeChina forKey:@"RTCAppType"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    else{
        [[RTCNetworkManager sharedManager] setAppType:(RTCAppTypeInternational)];
        [[NSUserDefaults standardUserDefaults] setInteger:RTCAppTypeInternational forKey:@"RTCAppType"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}

@end
