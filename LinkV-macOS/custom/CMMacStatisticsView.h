//
//  CMMacStatisticsView.h
//  LinkV-macOS
//
//  Created by jfdreamyang on 2020/4/13.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <LinkV/LinkV.h>

NS_ASSUME_NONNULL_BEGIN

@interface CMMacStatisticsView : NSView

-(void)configure;

-(void)reloadView:(LVVideoStatistic *)videoStatistic userId:(NSString *)userId;

-(void)remove:(NSString *)userId;
@end

NS_ASSUME_NONNULL_END
