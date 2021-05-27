//
//  CMLiveUserListView.h
//  CMLiveRoomDemo
//
//  Created by jfdreamyang on 2020/3/16.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class CMLiveUserListView;

@protocol CMLiveUserListViewDelegate <NSObject>

-(void)listView:(CMLiveUserListView *)listView didSelected:(NSString *)userId;

@end

@interface CMLiveUserListView : UIView

@property (nonatomic,weak)id <CMLiveUserListViewDelegate> delegate;

-(void)reloadData:(NSArray *)userIdList;

@end

NS_ASSUME_NONNULL_END
