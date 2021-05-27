//
//  CMTableCellView.h
//  LinkV-macOS
//
//  Created by jfdreamyang on 2020/4/10.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import <Cocoa/Cocoa.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CMTableCellViewDelegate <NSObject>

-(void)didSelectRow:(NSInteger)row;

@end

@interface CMTableCellView : NSTableCellView
@property (weak) IBOutlet NSTextField *roomLab;
@property (nonatomic)NSInteger row;
@property (nonatomic,weak)id <CMTableCellViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
