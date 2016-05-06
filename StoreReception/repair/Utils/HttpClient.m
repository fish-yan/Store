//
//  HttpClient.m
//  Repair
//
//  Created by Kassol on 15/9/9.
//  Copyright (c) 2015年 CJM. All rights reserved.
//

#import "HttpClient.h"
#import "Utils.h"

@interface HttpClient ()
@property (strong, nonatomic) AFHTTPRequestOperationManager *manager;
@property (strong, nonatomic) NSString *baseURL;
@property (strong, nonatomic) NSMutableDictionary *listMap;
@end

@implementation HttpClient

static HttpClient *sharedInstance = nil;

- (instancetype)init {
    self = [super init];
    _manager = [AFHTTPRequestOperationManager manager];
    _manager.requestSerializer = [AFJSONRequestSerializer serializer];
    _manager.requestSerializer.timeoutInterval = 10.f;
    _listMap = [NSMutableDictionary dictionary];
    [_listMap setObject:@"RepairIsCheckList" forKey:PREORDER];
    [_listMap setObject:@"RepairWaitList" forKey:WAITING];
    [_listMap setObject:@"RepairIsWorkingList" forKey:WORKING];
    [_listMap setObject:@"RepairAllList" forKey:FINISH];
    [_listMap setObject:@"RepairMyList" forKey:MYWORKING];
    [_listMap setObject:@"RepairMyFinishList" forKey:MYFINISH];
    return self;
}

+ (instancetype)sharedHttpClient {
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        sharedInstance = [[self alloc] init];
    });
    return sharedInstance;
}

- (void)setBaseURL:(NSString *)baseURL {
    _baseURL = baseURL;
}

- (void)loginWithOption:(NSDictionary *)option
                success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    [_manager POST:[_baseURL stringByAppendingString:@"UserLogin"] parameters:option success:success failure:failure];
}

- (void)getCarNumbers:(NSDictionary *)option
              success:(void (^)(AFHTTPRequestOperation *, id))success
              failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [_manager POST:[_baseURL stringByAppendingString:@"ReapirStyleCount"] parameters:option success:success failure:failure];
}

- (void)getPreOrderList:(NSDictionary *)option
                success:(void (^)(AFHTTPRequestOperation *, id))success
                failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [_manager POST:[_baseURL stringByAppendingString:@"RepairPreList"] parameters:option success:success failure:failure];
}

- (void)getPreOrderDetail:(NSDictionary *)option
                  success:(void (^)(AFHTTPRequestOperation *, id))success
                  failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [_manager POST:[_baseURL stringByAppendingString:@"RepairPreDesc"] parameters:option success:success failure:failure];
}

- (void)getUnRepairList:(NSDictionary *)option
                success:(void (^)(AFHTTPRequestOperation *, id))success
                failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [_manager POST:[_baseURL stringByAppendingString:@"UnRepairList"] parameters:option success:success failure:failure];
}

- (void)getUnRepairDetail:(NSDictionary *)option
                  success:(void (^)(AFHTTPRequestOperation *, id))success
                  failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [_manager POST:[_baseURL stringByAppendingString:@"RepairItemDesc"] parameters:option success:success failure:failure];
}

- (void)getRepairDetail:(NSDictionary *)option
                success:(void (^)(AFHTTPRequestOperation *, id))success
                failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [_manager POST:[_baseURL stringByAppendingString:@"RepairDesc"] parameters:option success:success failure:failure];
}

- (void)getMyRepairList:(NSDictionary *)option
                success:(void (^)(AFHTTPRequestOperation *, id))success
                failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [_manager POST:[_baseURL stringByAppendingString:@"RepairMyList"] parameters:option success:success failure:failure];
}

- (void)getAllRepairList:(NSDictionary *)option
                success:(void (^)(AFHTTPRequestOperation *, id))success
                failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [_manager POST:[_baseURL stringByAppendingString:@"RepairIsWorkingList"] parameters:option success:success failure:failure];
}

- (void)getAllFinishedList:(NSDictionary *)option
                   success:(void (^)(AFHTTPRequestOperation *, id))success
                   failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [_manager POST:[_baseURL stringByAppendingString:@"RepairAllList"] parameters:option success:success failure:failure];
}

- (void)getMyFinishedList:(NSDictionary *)option
                  success:(void (^)(AFHTTPRequestOperation *, id))success
                  failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [_manager POST:[_baseURL stringByAppendingString:@"RepairMyFinishList"] parameters:option success:success failure:failure];
}

- (void)getWorkerList:(NSDictionary *)option
              success:(void (^)(AFHTTPRequestOperation *, id))success
              failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [_manager POST:[_baseURL stringByAppendingString:@"RepairUserList"] parameters:option success:success failure:failure];
}

- (void)getServiceItem:(NSDictionary *)option
               success:(void (^)(AFHTTPRequestOperation *, id))success
               failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [_manager POST:[_baseURL stringByAppendingString:@"ReapirServerItem"] parameters:option success:success failure:failure];
}

- (void)repairPerson:(NSDictionary *)option
            isRework:(BOOL)isRework
             success:(void (^)(AFHTTPRequestOperation *, id))success
             failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    if (isRework) {
        [_manager POST:[_baseURL stringByAppendingString:@"RepairItemPerson"] parameters:option success:success failure:failure];
    } else {
        [_manager POST:[_baseURL stringByAppendingString:@"RepairPerson"] parameters:option success:success failure:failure];
    }
    
}


- (void)finishRepair:(NSDictionary *)option
             success:(void (^)(AFHTTPRequestOperation *, id))success
             failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [_manager POST:[_baseURL stringByAppendingString:@"FinishRepair"] parameters:option success:success failure:failure];
}
- (void)subimtCheck:(NSDictionary *)option
           success:(void (^)(AFHTTPRequestOperation *, id))success
           failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [_manager POST:[_baseURL stringByAppendingString:@"SubmitCheckStatus"] parameters:option success:success failure:failure];
}

- (void)finishLast:(NSDictionary *)option
           success:(void (^)(AFHTTPRequestOperation *, id))success
           failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [_manager POST:[_baseURL stringByAppendingString:@"FinishRepairLast"] parameters:option success:success failure:failure];
}

- (void)getListWithStatus:(NSString *)status option:(NSDictionary *)option
                  success:(void (^)(AFHTTPRequestOperation *, id))success
                  failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [_manager POST:[_baseURL stringByAppendingString:[_listMap objectForKey:status]] parameters:option success:success failure:failure];
}

- (void)getDetailWithType:(NSString *)type option:(NSDictionary *)option
                  success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                  failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    if ([type isEqualToString:PREORDER]) {
        [_manager POST:[_baseURL stringByAppendingString:@"RepairItemDesc"] parameters:option success:success failure:failure];
    } else if ([type isEqualToString:FINISH] || [type isEqualToString:MYFINISH]) {
        [_manager POST:[_baseURL stringByAppendingString:@"RepairDesc"] parameters:option success:success failure:failure];
    } else {
        [_manager POST:[_baseURL stringByAppendingString:@"RepairItemDesc"] parameters:option success:success failure:failure];
    }
}

- (void)getCarCheckList:(NSDictionary *)option
                  success:(void (^)(AFHTTPRequestOperation *, id))success
                  failure:(void (^)(AFHTTPRequestOperation *, NSError *))failure {
    [_manager POST:[_baseURL stringByAppendingString:@"GetCarCheckList"] parameters:option success:success failure:failure];
}

- (void)addCarCheck:(NSDictionary *)option
            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    [_manager POST:[_baseURL stringByAppendingString:@"AddCarCheck"] parameters:option success:success failure:failure];
}

- (void)getCarCheckDesc:(NSDictionary *)option
            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    [_manager POST:[_baseURL stringByAppendingString:@"GetCarCheckDesc"] parameters:option success:success failure:failure];
}
- (void)getProjects:(NSDictionary *)option
                success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
                failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    [_manager POST:[_baseURL stringByAppendingString:@"GetProjects"] parameters:option success:success failure:failure];
}

- (void)repairReturn:(NSDictionary *)option
             success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
             failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure{
    [_manager POST:[_baseURL stringByAppendingString:@"RepairReturn"] parameters:option success:success failure:failure];
}

@end
