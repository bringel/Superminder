//
//  SMTrelloBoard.h
//  Superminder
//
//  Created by Bradley Ringel on 5/10/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UIColor+Hexadecimal.h"

@class SMTrelloList;

@interface SMTrelloBoard : NSObject

@property (strong, nonatomic) NSString *boardID;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSArray *lists;
@property (strong, nonatomic) UIColor *backgroundColor;
@property (strong, nonatomic) NSURL *backgroundImageURL;
@property (strong, nonatomic) NSDictionary *labels;
@property (strong, nonatomic) NSString *boardDescription;

+ (NSCache *)boardBackgroundsCache;

- (instancetype)initWithJSONData:(NSDictionary *)data;
- (void)addList:(SMTrelloList *)list;
- (SMTrelloList *)listWithID:(NSString *)listID;

@end
