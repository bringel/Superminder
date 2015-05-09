//
//  NSURLRequest.m
//  Superminder
//
//  Created by Bradley Ringel on 5/2/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import "NSURLRequest+SMRequestBuilding.h"

@implementation NSURLRequest (SMRequestBuilding)

+ (NSURLRequest *)buildRequestForPath:(NSString *)path withParameters:(NSDictionary *)params relativeToURL:(NSURL *)baseURL usingMethod:(NSString *)httpMethod{
    NSURLComponents *components = [[NSURLComponents alloc] init];
    NSMutableArray *queryParams = [[NSMutableArray alloc] init];
    
    for (NSString *key in params) {
        NSURLQueryItem *item = [[NSURLQueryItem alloc] initWithName:key value:params[key]];
        [queryParams addObject:item];
    }
    
    components.path = path;
    components.queryItems = queryParams;
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[components URLRelativeToURL:baseURL]];
    request.HTTPMethod = httpMethod;
    
    return [request copy];
}

@end
