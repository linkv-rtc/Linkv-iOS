//
//  CMParameterView.h
//  LinkV
//
//  Created by jfdreamyang on 2020/5/26.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CMParameterViewDelegate <NSObject>

-(void)cancel;
-(void)confirm;

@end

@interface CMParameterView : UIView
-(void)reloadData;
@property (nonatomic,weak)id <CMParameterViewDelegate> delegate;
@end

NS_ASSUME_NONNULL_END
