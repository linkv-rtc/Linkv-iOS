//
//  CMStatisticsViewCell.h
//  LinkV
//
//  Created by jfdreamyang on 2020/3/27.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LinkV/LinkV.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMStatisticsViewCell : UITableViewCell
-(void)reloadView:(LVVideoStatistic *)statistics userId:(NSString *)userId;
@end

NS_ASSUME_NONNULL_END
