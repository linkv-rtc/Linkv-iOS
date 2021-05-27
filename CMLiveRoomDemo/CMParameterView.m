//
//  CMParameterView.m
//  LinkV
//
//  Created by jfdreamyang on 2020/5/26.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import "CMParameterView.h"
#import "RTCNetworkManager.h"

@interface LVRTCEngine (Private)
+ (void)setDebugServerIp:(NSString *)ip;
+ (void)setDebugCenterIP:(NSString *)ip;
@end


static RTCEnvironment _lastEnvironment = RTCEnvironmentProduction;

@interface CMParameterView ()
@property (weak, nonatomic) IBOutlet UITextField *edgeTextField;
@property (weak, nonatomic) IBOutlet UITextField *roomTextField;
@property (weak, nonatomic) IBOutlet UITextField *userIdTextField;
@property (weak, nonatomic) IBOutlet UITextField *centerTextField;
@end

@implementation CMParameterView

-(void)reloadData{
    
    if (RTCNetworkManager.sharedManager.manualUserID) {
        self.userIdTextField.text = RTCNetworkManager.sharedManager.manualUserID;
    }
    if (RTCNetworkManager.sharedManager.manualRoomID) {
        self.roomTextField.text = RTCNetworkManager.sharedManager.manualRoomID;
    }
    if (RTCNetworkManager.sharedManager.manualEdgeURL) {
        self.edgeTextField.text = RTCNetworkManager.sharedManager.manualEdgeURL;
    }
    if (RTCNetworkManager.sharedManager.centerIP) {
        self.centerTextField.text = RTCNetworkManager.sharedManager.centerIP;
    }
}

- (IBAction)confirmButton:(id)sender {
    RTCNetworkManager.sharedManager.manualUserID = self.userIdTextField.text;
    RTCNetworkManager.sharedManager.manualRoomID = self.roomTextField.text;
    RTCNetworkManager.sharedManager.manualEdgeURL = self.edgeTextField.text;
    RTCNetworkManager.sharedManager.centerIP = self.centerTextField.text;
    [self.delegate confirm];

    if (RTCNetworkManager.sharedManager.manualEdgeURL.length > 0) {
        _lastEnvironment = [RTCNetworkManager sharedManager].environment;
        [[RTCNetworkManager sharedManager] setEnvironment:RTCEnvironmentTest];
        [LVRTCEngine setDebugServerIp:RTCNetworkManager.sharedManager.manualEdgeURL];
    }
    else{
        [[RTCNetworkManager sharedManager] setEnvironment:_lastEnvironment];
    }
}
- (IBAction)cancelButton:(id)sender {
    [self.delegate cancel];
}
- (IBAction)reset:(id)sender {
    RTCNetworkManager.sharedManager.manualUserID = @"";
    RTCNetworkManager.sharedManager.manualEdgeURL = @"";
    RTCNetworkManager.sharedManager.manualRoomID = @"";
    RTCNetworkManager.sharedManager.centerIP = @"";
    self.userIdTextField.text = @"";
    self.roomTextField.text = @"";
    self.edgeTextField.text = @"";
    self.centerTextField.text = @"";
    [LVRTCEngine setDebugCenterIP:@""];
    [LVRTCEngine setDebugServerIp:RTCNetworkManager.sharedManager.manualEdgeURL];
    [[RTCNetworkManager sharedManager] setEnvironment:_lastEnvironment];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
