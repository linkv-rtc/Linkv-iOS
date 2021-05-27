//
//  CMSettingCell.h
//  CMLiveRoomDemo
//
//  Created by jfdreamyang on 2020/3/20.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef enum : NSUInteger {
    CMSettingTypeNormal,
    CMSettingTypeArrow
} CMSettingType;

@interface CMSettingCell : UITableViewCell
-(void)reloadView:(NSDictionary *)info;
@end

NS_ASSUME_NONNULL_END
