//
//  NSURLRequest.h
//  Superminder
//
//  Created by Bradley Ringel on 5/2/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSURLRequest (SMRequestBuilding)

+ (NSURLRequest *)buildRequestForPath:(NSString *)path withParameters:(NSDictionary *)params relativeToURL:(NSURL *)baseURL usingMethod:(NSString *)httpMethod;

@end
