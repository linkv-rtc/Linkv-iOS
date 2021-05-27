//
//  CMRoomListView.h
//  CMRTCDemo
//
//  Created by jfdreamyang on 2019/12/5.
//  Copyright © 2019 jfdreamyang. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


@protocol CMRoomListViewDelegate <NSObject>

-(void)didSelectIndexPath:(NSIndexPath *)indexPath;

@end

@interface CMRoomListView : UIView
@property (nonatomic,strong,readonly)NSArray *dataSource;
@property (nonatomic,weak)id <CMRoomListViewDelegate> delegate;
-(void)reloadData:(NSArray *)dataSource;
@end

NS_ASSUME_NONNULL_END
