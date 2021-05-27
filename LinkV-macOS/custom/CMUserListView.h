//
//  CMUserListView.h
//  LinkV-macOS
//
//  Created by jfdreamyang on 2020/4/13.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CMUserListViewDelegate <NSObject>

-(void)didClickRow:(NSString *)userId;

@end

@interface CMUserListView : NSView
@property (nonatomic)NSInteger tag;
-(void)configure;
-(void)reloadView:(NSArray *)list;
@property (nonatomic,weak)id <CMUserListViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
