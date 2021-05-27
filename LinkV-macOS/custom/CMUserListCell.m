//
//  CMUserListCell.m
//  LinkV-macOS
//
//  Created by jfdreamyang on 2020/4/13.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import "CMUserListCell.h"
#import "RTCNetworkManager.h"

@interface CMUserListCell ()
@property (weak) IBOutlet NSTextField *userIDLab;

@end

@implementation CMUserListCell

- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    // Drawing code here.
}
-(void)reloadView:(NSString *)userId{
    
    NSString *me = NSLocalizedString(@"Live Role Me", nil);
    NSString *host = NSLocalizedString(@"Live Role Host", nil);
    
    NSString *name = @"";
    if ([userId isEqualToString:[RTCNetworkManager sharedManager].userId]) {
        name = [NSString stringWithFormat:@"%@--%@",userId,me];
    }
    else if ([userId hasPrefix:@"H"]){
        name = [NSString stringWithFormat:@"%@--%@",userId,host];
    }
    else{
        name = [NSString stringWithFormat:@"%@",userId];
    }
    self.userIDLab.stringValue = name;
}


@end
