//
//  CMSettingSliderCell.h
//  CMLiveRoomDemo
//
//  Created by jfdreamyang on 2020/3/20.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LinkV/LinkV.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CMSettingSliderCellDelegate <NSObject>

-(void)didChangeAVConfig:(LVAVConfig *)config;

@end

@interface CMSettingSliderCell : UITableViewCell
@property (nonatomic,strong)NSDictionary *item;
@property (nonatomic,weak)id <CMSettingSliderCellDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
