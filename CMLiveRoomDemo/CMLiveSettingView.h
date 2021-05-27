//
//  CMLiveSettingView.h
//  CMLiveRoomDemo
//
//  Created by jfdreamyang on 2020/3/9.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LinkV/LinkV.h>

NS_ASSUME_NONNULL_BEGIN


@class CMLiveSettingView;

@protocol CMLiveSettingViewDelegate <NSObject>

-(void)didSelect:(NSIndexPath *)indexPath title:(NSString *)title isOn:(BOOL)isOn;

-(void)settingView:(CMLiveSettingView *)settingView dismiss:(BOOL)dismiss;

-(void)didChangeAVConfig:(LVAVConfig *)config;

@end


@interface CMLiveSettingView : UIView

@property (nonatomic,weak)id <CMLiveSettingViewDelegate> delegate;

@property (nonatomic,strong)NSArray *dataSource;

-(void)reloadData;

-(void)dismiss;

@end

NS_ASSUME_NONNULL_END
