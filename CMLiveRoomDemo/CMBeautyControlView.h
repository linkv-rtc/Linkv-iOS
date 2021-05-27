//
//  CMBeautyControlView.h
//  CMLiveRoomDemo
//
//  Created by jfdreamyang on 2020/3/24.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CMBeautyControlViewDelegate <NSObject>

- (void)setBeautyLevel:(float)beautyLevel;

- (void)setBrightLevel:(float)brightLevel;

- (void)setToneLevel:(float)toneLevel;

- (void)hideBeautyControlView;

@end

@interface CMBeautyControlView : UIView
@property (nonatomic,weak)id <CMBeautyControlViewDelegate> delegate;
-(void)reset;
@end

NS_ASSUME_NONNULL_END
