//
//  AppDelegate.m
//  LinkV-macOS
//
//  Created by jfdreamyang on 2020/4/7.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // Insert code here to initialize your application
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willCloseWindow) name:NSWindowWillCloseNotification object:nil];
}

-(void)willCloseWindow{
    [NSApp terminate:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


@end
