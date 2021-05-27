//
//  CMListTableViewCell.h
//  CMLiveRoomDemo
//
//  Created by jfdreamyang on 2020/3/6.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CMListTableViewCellDelegate <NSObject>

-(void)didSelectedIndex:(NSIndexPath *)indexPath;

@end


@interface CMListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *roomIdLab;
@property (nonatomic,weak)id <CMListTableViewCellDelegate> delegate;
@property (nonatomic,strong)NSIndexPath *indexPath;
@end

NS_ASSUME_NONNULL_END
