//
//  NSDictionary+jsonString.m
//  StoreReception
//
//  Created by cjm-ios on 15/7/7.
//  Copyright (c) 2015年 cjm-ios. All rights reserved.
//

#import "NSDictionary+jsonString.h"

@implementation NSDictionary (jsonString)

- (NSString*)DataTOjsonString
{
    NSString *jsonString = nil;
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self
                                                       options:NSJSONWritingPrettyPrinted // Pass 0 if you don't care about the readability of the generated string
                                                         error:&error];
    if (! jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

@end
