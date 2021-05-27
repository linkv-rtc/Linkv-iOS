//
//  CMUserListCell.h
//  LinkV-macOS
//
//  Created by jfdreamyang on 2020/4/13.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMUserListCell : NSTableCellView
-(void)reloadView:(NSString *)name;
@end

NS_ASSUME_NONNULL_END
