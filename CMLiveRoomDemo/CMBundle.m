//
//  CMBundle.m
//  CMLiveRoomDemo
//
//  Created by jfdreamyang on 2020/3/24.
//  Copyright © 2020 Liveme. All rights reserved.
//

#import "CMBundle.h"
#import "UWConfig.h"
#import <objc/runtime.h>

@implementation NSBundle(Ext)

+ (BOOL)isChineseLanguage
{
    NSString *currentLanguage = [self currentLanguage];
    if ([currentLanguage hasPrefix:@"zh-Hans"]) {
        return YES;
    } else {
        return NO;
    }
}

/*
 *  设置默认语言类型
 */
+ (NSString *)currentLanguage
{
//    return [UWConfig userLanguage] ? : [NSLocale preferredLanguages].firstObject;
    return [UWConfig userLanguage] ? : @"zh-Hans";
}

+ (void)load
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        //动态继承、交换，方法类似KVO，通过修改[NSBundle mainBundle]对象的isa指针，使其指向它的子类UWBundle，这样便可以调用子类的方法；其实这里也可以使用method_swizzling来交换mainBundle的实现，来动态判断，可以同样实现。
        object_setClass([NSBundle mainBundle], [CMBundle class]);
    });
}


@end


@implementation CMBundle
- (NSString *)localizedStringForKey:(NSString *)key value:(NSString *)value table:(NSString *)tableName
{
    if ([CMBundle uw_mainBundle]) {
        return [[CMBundle uw_mainBundle] localizedStringForKey:key value:value table:tableName];
    } else {
        return [super localizedStringForKey:key value:value table:tableName];
    }
}

+ (NSBundle *)uw_mainBundle
{
    if ([NSBundle currentLanguage].length) {
        NSString *path = [[NSBundle mainBundle] pathForResource:[NSBundle currentLanguage] ofType:@"lproj"];
        if (path.length) {
            return [NSBundle bundleWithPath:path];
        }
    }
    return nil;
}

@end
