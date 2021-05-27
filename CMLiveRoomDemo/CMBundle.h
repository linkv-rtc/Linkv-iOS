//
//  CMBundle.h
//  CMLiveRoomDemo
//
//  Created by jfdreamyang on 2020/3/24.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSBundle (Ext)
+ (BOOL)isChineseLanguage;

+ (NSString *)currentLanguage;
@end

@interface CMBundle : NSBundle

@end

NS_ASSUME_NONNULL_END
