//
//  CMLiveSettingCell.h
//  CMLiveRoomDemo
//
//  Created by jfdreamyang on 2020/3/9.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef enum : NSUInteger {
    CMCellTypeNone,
    CMCellTypeSwitch,
    CMCellTypeCustom
} CMCellType;


@protocol CMLiveSettingCellDelegate <NSObject>

-(void)didSelect:(NSIndexPath *)indexPath title:(NSString *)title isOn:(BOOL)isOn;

@end


@interface CMLiveSettingCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLab;

@property (weak, nonatomic) IBOutlet UISwitch *actionSwitch;

@property (nonatomic,strong)NSDictionary *item;
@property (nonatomic,strong)NSIndexPath *indexPath;
@property (nonatomic,weak)id <CMLiveSettingCellDelegate>delegate;
@end

NS_ASSUME_NONNULL_END
