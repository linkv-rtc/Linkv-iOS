//
//  LinkvVideoSource.h
//  LinkV
//
//  Created by liveme on 2021/8/4.
//  Copyright © 2021 Liveme. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LinkvFunction.h"

NS_ASSUME_NONNULL_BEGIN

@interface LinkvVideoSource : NSObject <AgoraVideoSourceProtocol>
@property(strong) id<AgoraVideoFrameConsumer> _Nullable consumer;
-(void)start;
-(void)stop;
@end

NS_ASSUME_NONNULL_END
