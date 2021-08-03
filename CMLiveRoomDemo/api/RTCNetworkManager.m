//
//  RTCNetworkManager.m
//  CMLiveSDK
//
//  Created by jfdreamyang on 2019/12/5.
//  Copyright © 2019 jfdreamyang. All rights reserved.
//

#import "RTCNetworkManager.h"
#import <LinkV/LinkV.h>
#import <libCNamaSDK/FURenderer.h>
#import "authpack-ios-xx_2021-08-3-10-26.h"

//static NSString *const kTestApi = @"http://192.168.50.65:8080";
//static NSString *const kProductionApi = @"http://192.168.50.65:8080";

//static NSString *const kTestApi = @"https://qa-rtc-room.linkv.fun";
//static NSString *const kProductionApi = @"https://rtc-room.linkv.fun";

static NSString *const kTestApi = @"http://qa-rtc-backend-orion.ksmobile.net";
static NSString *const kProductionApi = @"http://rtc-backend-orion.ksmobile.net";


// 说明，该 demo 使用的 appid 为鉴权成功之后在控制台打印的 appid，可以先把从开发者平台上申请的 appid 和 secret 填到下面环境中，运行 app，日志会打印 appid 和 app sign，此时替换掉即可

#if CM_APP_STORE_VERSION


#define PRODUCT @""
#define PRODUCT_SIGN @""

#define TEST_ENVIR  @""
#define TEST_ENVIR_SIGN    @""

#else

// mini online
#define PRODUCT  @""
#define PRODUCT_SIGN    @""

// mini qa
#define TEST_ENVIR  @""
#define TEST_ENVIR_SIGN    @""

#endif



@interface RTCNetworkManager ()
{
    NSUInteger _transaction;
    int _items[3];
}
@property (nonatomic,assign,readonly)NSUInteger transaction;
@property (nonatomic,strong)NSURLSession *session;
@property (nonatomic,assign)RTCEnvironment environment;
@end

@implementation RTCNetworkManager
+(RTCNetworkManager *)sharedManager{
    static RTCNetworkManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc]init];
        [_manager configure];
    });
    return _manager;
}

-(int *)items{
    return _items;
}

- (void)loadFilter{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"face_beautification" ofType:@"bundle"];
    _items[1] = [FURenderer itemWithContentsOfFile:path];
}

-(NSUInteger)transaction{
    _transaction = _transaction + 1;
    return _transaction;
}


-(void)configure{
    int code = [[FURenderer shareRenderer] setupWithData:nil dataSize:0 ardata:nil authPackage:g_auth_package authSize:sizeof(g_auth_package)  shouldCreateContext:YES];
    _transaction = 100000;
    _environment = RTCEnvironmentProduction;
    memset(_items, 0, sizeof(int) * 3);
    _session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    uint64_t time = [NSDate date].timeIntervalSince1970 * 1000 * 1000 * 1000;
    _suffix = [[NSString stringWithFormat:@"%lld%d",time,arc4random()%100000] substringFromIndex:2];
    [self loadFilter];
}

-(NSString *)roomSuffix{
    uint64_t time = [NSDate date].timeIntervalSince1970 * 1000 * 1000 * 1000;
    NSString *f = [NSString stringWithFormat:@"%lld%d",time,arc4random()%100000];
    return [f substringFromIndex:2];
}

-(void)setEnvironment:(RTCEnvironment)environment{
    _environment = environment;
    if (!kEnableAutoTest) {
        [LVRTCEngine setUseTestEnv:_environment == RTCEnvironmentTest];
    }
    self.authCode = LVErrorCodeUnknownError;
    NSLog(@"%@",[self environmentDesc:_environment]);
    [[LVRTCEngine sharedInstance] auth:self.mAppId
                                 skStr:self.mAppSign
                                userId:self.suffix
                            completion:^(LVErrorCode code) {
        NSLog(@"[CMSDK-Demo] auth:%lu",(unsigned long)code);
        self.authCode = code;
    }];
}

-(NSString *)environmentDesc:(RTCEnvironment)environment{
    switch (environment) {
        case RTCEnvironmentTest:
            return @"RTCEnvironmentTest";
        default:
            return @"RTCEnvironmentProduction";
    }
}

-(void)fixEnvironment:(RTCEnvironment)environment{
    _environment = environment;
}

-(void)auth:(RTCAuthCompletion)completion{
    
    if (self.authCode != LVErrorCodeSuccess) {
        
        NSLog(@"%@",[self environmentDesc:_environment]);
        
        [[LVRTCEngine sharedInstance] auth:self.mAppId
                                     skStr:self.mAppSign
                                    userId:self.suffix
                                completion:^(LVErrorCode code) {
            NSLog(@"[CMSDK-Demo] auth:%lu",(unsigned long)code);
            self.authCode = code;
            dispatch_async(dispatch_get_main_queue(), ^{
                if (self.authCode != LVErrorCodeSuccess) {
                    completion(NO);
                }
                else{
                    completion(YES);
                }
            });
        }];
    }
    else{
        completion(YES);
    }
}


-(NSString *)liveMeAppID{
    return @"";
}

-(NSString *)liveMeAppSign{
    return @"";
}

-(NSString *)mAppId{
    if (kEnableAutoTest) {
        return [self liveMeAppID];
    }
    
//    return @"qOPBZYGqnqgCSJCobhLFRtvvJzeLLzDR";
    
    RTCEnvironment environment = [self environment];
    switch (environment) {
        case RTCEnvironmentProduction:
            return PRODUCT;
        
        case RTCEnvironmentTest:
            return TEST_ENVIR;
    }
}

-(NSString *)appServerAppID{
    if (kEnableAutoTest) {
        return [self liveMeAppID];
    }
    RTCEnvironment environment = [self environment];
    switch (environment) {
        case RTCEnvironmentProduction:
            return PRODUCT;
        
        case RTCEnvironmentTest:
            return TEST_ENVIR;
    }
}

-(NSString *)mAppSign{
    if (kEnableAutoTest) {
        return [self liveMeAppSign];
    }
    RTCEnvironment environment = [self environment];
    switch (environment) {
        case RTCEnvironmentProduction:
            return PRODUCT_SIGN;
        
        case RTCEnvironmentTest:
            return TEST_ENVIR_SIGN;
    }
}

-(NSString *)api:(RTCApiName)name{
    RTCEnvironment environment = [self environment];
    NSString *base = kProductionApi;
    switch (environment) {
        case RTCEnvironmentTest:
            base = kTestApi;
            break;
        default:
            break;
    }
    NSString *api = @"/api/v1/live_room_list";
    switch (name) {
        case RTCApiNameRoomList:
            api = @"/api/v1/live_room_list";
            break;
        case RTCApiNameGenRoom:
            api = @"/api/v1/gen_room";
            break;
        case RTCApiNameGetVendor:
            api = @"/api/v1/get_vendor";
            break;
        case RTCApiNameUpdateRoom:
            api = @"/api/v1/update_room";
            break;
        case RTCApiNameRoomStatus:
            api = @"/api/v1/room_status";
            break;
        default:
            break;
    }
    NSString *interface = [NSString stringWithFormat:@"%@%@",base,api];
    return interface;
}


-(void)GET:(NSDictionary *)params name:(RTCApiName)name completion:(RTCRequestCompletion)completion{
    NSString *interface = [self api:name];
    
    NSArray *allKeys = params.allKeys;
    
    for (NSInteger i=0; i<allKeys.count; i++) {
        NSString *key = allKeys[i];
        if (allKeys.count == 1) {
            interface = [NSString stringWithFormat:@"%@?%@=%@",interface,key,params[key]];
        }
        else if (i == (allKeys.count - 1)){
            interface = [NSString stringWithFormat:@"%@%@=%@",interface,key,params[key]];
        }
        else{
            if (i == 0) {
                interface = [NSString stringWithFormat:@"%@?%@=%@&",interface,key,params[key]];
            }
            else{
                interface = [NSString stringWithFormat:@"%@%@=%@&",interface,key,params[key]];
            }
        }
    }
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:interface]];
    request.HTTPMethod = @"GET";
    request.timeoutInterval = 30;
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSUInteger transaction = self.transaction;
//    NSLog(@"start request transaction:%ld",transaction);
    [[self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (response) {
                NSLog(@"end request transaction:%ld,error:%@,statusCode:%ld",transaction,error,((NSHTTPURLResponse *)response).statusCode);
            }
            else{
                NSLog(@"end request transaction:%ld,error:%@",transaction,error);
            }
            completion(nil,RTCErrorCodeRequestError);
        }
        else{
            if (data) {
                NSError *_error = nil;
                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&_error];
                if (_error) {
                    NSLog(@"end request transaction:%ld,error:%@,statusCode:%ld",transaction,_error,((NSHTTPURLResponse *)response).statusCode);
                    completion(nil,RTCErrorCodeResponseError);
                }
                else{
//                    NSLog(@"end request transaction:%ld,statusCode:%ld",transaction,((NSHTTPURLResponse *)response).statusCode);
                    completion(result,RTCErrorCodeSuccess);
                }
            }
            else{
                NSLog(@"end request transaction:%ld,unknown statusCode:%ld",transaction,((NSHTTPURLResponse *)response).statusCode);
                completion(nil,RTCErrorCodeResponseUnknown);
            }
        }
        
    }] resume];
    
}

-(void)POST:(NSDictionary *)body api:(NSString *)interface completion:(RTCRequestCompletion)completion{
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:interface]];
    request.HTTPMethod = @"POST";
    [request setValue:@"application/json; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
    NSError *error = nil;
    NSData *bytes = [NSJSONSerialization dataWithJSONObject:body options:NSJSONWritingPrettyPrinted error:&error];
    if (error) {
        completion(nil,RTCErrorCodeParamIllegal);
        return;
    }
    request.HTTPBody = bytes;
    request.timeoutInterval = 30;
    NSUInteger transaction = self.transaction;
//    NSLog(@"start request transaction:%ld",transaction);
    [[self.session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (error) {
            if (response) {
                NSLog(@"end request transaction:%ld,error:%@,statusCode:%ld",transaction,error,((NSHTTPURLResponse *)response).statusCode);
            }
            else{
                NSLog(@"end request transaction:%ld,error:%@",transaction,error);
            }
            completion(nil,RTCErrorCodeRequestError);
        }
        else{
            if (data) {
                NSError *_error = nil;
                NSDictionary *result = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&_error];
                if (_error) {
                    NSLog(@"end request transaction:%ld,error:%@,statusCode:%ld",transaction,_error,((NSHTTPURLResponse *)response).statusCode);
                    completion(nil,RTCErrorCodeResponseError);
                }
                else{
//                    NSLog(@"end request transaction:%ld,statusCode:%ld",transaction,((NSHTTPURLResponse *)response).statusCode);
                    completion(result,RTCErrorCodeSuccess);
                }
            }
            else{
                NSLog(@"end request transaction:%ld,unknown statusCode:%ld",transaction,((NSHTTPURLResponse *)response).statusCode);
                completion(nil,RTCErrorCodeResponseUnknown);
            }
        }
        
    }] resume];
    
}


-(void)POST:(NSDictionary *)params name:(RTCApiName)name completion:(RTCRequestCompletion)completion{
    NSString *interface = [self api:name];
    [self POST:params api:interface completion:completion];
}
-(void)clearAllRoom{
    [self GET:@{@"app_id":self.mAppId} name:RTCApiNameRoomList completion:^(NSDictionary * _Nullable result, RTCErrorCode httpCode) {
        NSLog(@"room list:%@",result);
        dispatch_async(dispatch_get_main_queue(), ^{
            NSArray *dummy = result[@"data"];
            if ([dummy isKindOfClass:NSArray.class]) {
                for (NSNumber *roomId in dummy) {
                    NSString *_roomId = [NSString stringWithFormat:@"%@",roomId];
                    [self update:3 roomId:_roomId];
                }
            }
        });
    }];
}

-(void)update:(NSInteger)status roomId:(NSString *)roomId{
    NSString *version = [LVRTCEngine versionName];
    [self POST:@{@"app_id":self.appServerAppID,@"room_id":roomId,@"status":[NSString stringWithFormat:@"%ld",status],@"sdk_version":version,@"os":@"ios",@"vendor":@"octopus"} name:RTCApiNameUpdateRoom completion:^(NSDictionary * _Nullable result, RTCErrorCode httpCode) {
        if (httpCode != RTCErrorCodeSuccess) {
            NSLog(@"update room status:%ld,result:%@",status,result);
        }
    }];
}


/**
    * state: ０:初始化, １:创建, ２:开始直播, 3:直播结束
    */
-(void)update:(NSInteger)status{
    [self update:status roomId:[RTCNetworkManager sharedManager].roomId];
}



@end
