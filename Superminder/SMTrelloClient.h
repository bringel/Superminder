//
//  SMTrelloClient.h
//  Superminder
//
//  Created by Bradley Ringel on 5/1/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMTrelloUser.h"

static NSString * const kTrelloUserKey = @"trello-user-key";
static NSString * const kNeedsReauthentication = @"SuperminderNeedsReauthentication";

@interface SMTrelloClient : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (strong, nonatomic) NSString *apiKey;
@property (strong, nonatomic) SMTrelloUser *currentUser;
@property (nonatomic) BOOL needsReauthentication;

+ (instancetype)sharedClient;

- (void)getCurrentUserInfo;
- (void)getAlBoardDataForUser:(SMTrelloUser *)user;
- (void)getDataForBoardIDs:(NSArray *)boardIDs;
- (void)getDataForBoard:(NSString *)boardID;

@end
