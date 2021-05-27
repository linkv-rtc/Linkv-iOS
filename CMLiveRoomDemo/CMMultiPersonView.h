//
//  CMMultiPersonView.h
//  CMLiveRoomDemo
//
//  Created by jfdreamyang on 2020/3/10.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LinkV/LinkV.h>

NS_ASSUME_NONNULL_BEGIN

/// 多人连麦视图
@interface CMMultiPersonView : UIView

-(void)reloadData:(NSArray *)dataSource;

@end

NS_ASSUME_NONNULL_END
