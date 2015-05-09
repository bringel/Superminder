//
//  SMTrelloUser.h
//  Superminder
//
//  Created by Bradley Ringel on 5/2/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SMTrelloUser : NSObject

@property (strong, nonatomic) NSString *userID;
@property (strong, nonatomic) NSString *userName;
@property (strong, nonatomic) NSString *fullName;

@property (strong, nonatomic) NSArray *boards;

- (instancetype)initWithJSONData:(NSDictionary *)data;

@end
