//
//  SMTrelloClient.h
//  Superminder
//
//  Created by Bradley Ringel on 5/1/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SMTrelloUser.h"

extern NSString * const kTrelloUserKey;

@protocol SMTrelloClientDelegate

@optional

- (void)boardLoaded:(SMTrelloBoard *)board;
- (void)allBoardsLoadedForUser:(SMTrelloUser *)user;

@end

@interface SMTrelloClient : NSObject <NSURLSessionDelegate, NSURLSessionTaskDelegate, NSURLSessionDataDelegate>

@property (strong, nonatomic) NSString *apiKey;
@property (strong, nonatomic) SMTrelloUser *currentUser;
@property (nonatomic) BOOL needsReauthentication;

@property (weak, nonatomic) id<SMTrelloClientDelegate> delegate;

+ (instancetype)sharedClient;

- (void)getCurrentUserInfo;
- (void)getAllBoardDataForUser:(SMTrelloUser *)user;
- (void)getDataForBoardIDs:(NSArray *)boardIDs;
- (void)getDataForBoard:(NSString *)boardID;

@end
