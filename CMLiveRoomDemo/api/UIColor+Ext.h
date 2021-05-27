//
//  UIColor+Ext.h
//  CMLiveRoomDemo
//
//  Created by jfdreamyang on 2020/3/6.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import <UIKit/UIKit.h>

#define     RGBAColor(r, g, b, a)       [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:a]

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (Ext)
+(UIColor *)colorGreenLowerDefault;
@end

NS_ASSUME_NONNULL_END
