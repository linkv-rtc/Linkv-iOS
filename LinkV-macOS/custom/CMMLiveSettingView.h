//
//  CMLiveSettingView.h
//  LinkV-macOS
//
//  Created by jfdreamyang on 2020/4/10.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@class LVAVConfig;

@protocol CMMLiveSettingViewDelegate <NSObject>

-(void)openStatisticsView:(BOOL)open;
-(void)didSetAVConfig:(LVAVConfig *)config;
-(void)mixButtonClick:(BOOL)on;

@end

@interface CMMLiveSettingView : NSView
-(void)configure;
@property (nonatomic)NSInteger tag;
@property (nonatomic,weak)id <CMMLiveSettingViewDelegate> delegate;
- (void)closeButtonClick;

-(void)setAVConfig:(LVAVConfig *)config;

@property (nonatomic)BOOL isMixing;

@end

NS_ASSUME_NONNULL_END
