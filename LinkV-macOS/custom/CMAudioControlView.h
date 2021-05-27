//
//  CMAudioControlView.h
//  LinkV-macOS
//
//  Created by jfdreamyang on 2020/4/22.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN


@interface CMAudioControlView : NSView
@property (nonatomic)NSInteger tag;
@property (nonatomic)BOOL pause;
-(void)show;
@end

NS_ASSUME_NONNULL_END
