//
//  FacebookHelper.m
//  Aerhythm
//
//  Created by Nguyen Truong Duy on 3/4/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "FacebookHelper.h"
#import "Connectivity.h"

static NSString * const kCurrentUserFriendsGraphPath = @"me/friends";

@implementation FacebookHelper

+ (BOOL)hasLoggedIn {
    // EFFECTS: Returns true if the user has logged in to Facebook before
    
    return [PFUser currentUser] && [PFFacebookUtils isLinkedWithUser:[PFUser currentUser]];
}

+ (BOOL)hasPublishPermission {
    // EFFECTS: Returns true if the current session has publish permission.
    
    NSArray * permissions = [[FBSession activeSession] permissions];
    if ([permissions indexOfObject:@"publish_actions"] == NSNotFound) {
        return NO;
    }
    
    return YES;
}

+ (void)postToCurrentUserWallWithParam:(NSDictionary *)param
                  andCompletionHandler:(void (^)(FBRequestConnection *, id, NSError *))handler {
    // REQUIRES: param != nil
    // EFFECTS: Posts to the current user's Facebook wall a status with input parameters
    
    if (![Connectivity hasInternetConnection]) {
        // Do not post if there is no internet connection
        return;
    }
    if (![FacebookHelper getCachedCurrentUserId]) {
        return;
    }
    
    NSString * graphPath = [NSString stringWithFormat:@"/%@/feed", [FacebookHelper getCachedCurrentUserId]];
    [FBRequestConnection startWithGraphPath:graphPath
                                 parameters:param
                                 HTTPMethod:@"POST"
                          completionHandler:handler];
}

+ (void)publishStoryWithObject:(id<FBOpenGraphObject>)newObject
                 andActionType:(NSString *)actionType
          andCompletionHandler:(void (^) (FBRequestConnection * connection,
                                          id result,
                                          NSError * error))handler {
    // REQUIRES: newObject != nil, and actionType != nil
    // EFFECTS: Publishes a story with the input Facebook object and action type. The function first
    //          posts the object to Facebook, then publishes action story with the new object id received
    
    if (![Connectivity hasInternetConnection]) {
        // Do not share if there is no internet connection
        return;
    }
    if (![FacebookHelper getCachedCurrentUserId]) {
        return;
    }
    
    NSString * graphPath = [NSString stringWithFormat:@"/%@/", [FacebookHelper getCachedCurrentUserId]];
    graphPath = [graphPath stringByAppendingString:actionType];
    
    NSArray * nameComponent = [[newObject type] componentsSeparatedByString:@":"];
    NSString * objectTypeName = [nameComponent objectAtIndex:1];
    
    // Post object first
    [FBRequestConnection startForPostOpenGraphObject:(id<FBOpenGraphObject>)newObject
                                   completionHandler:^(FBRequestConnection * connection,
                                                       id result, NSError * error)
     {
         if (error) {
             handler(connection, result, error);
         } else {
             // Create and Update action with the object id and publish it
             NSString * objectId = [result objectForKey:@"id"];
             id<FBOpenGraphObject> action = (id<FBOpenGraphObject>) [FBGraphObject graphObject];
             [action setObject:objectId forKey:objectTypeName];
             [FBRequestConnection startForPostWithGraphPath:graphPath
                                                graphObject:action
                                          completionHandler:handler];
         }
     }];
}

+ (void)requestAndStoreCurrentUserInfoWithCompletionHandler:(void (^) (FBRequestConnection * connection,
                                                                     id result,
                                                                     NSError * error))handler {
    // EFFECTS: Requests, gets and stores the Facebook id of the current user
    
    if (![Connectivity hasInternetConnection]) {
        return;
    }
    
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection * connection,
                                                           id result, NSError * error) {
        if (!error) {
            NSString * facebookId = [result objectForKey:@"id"];
            NSString * facebookName = [result objectForKey:@"name"];
            
            [FacebookHelper storeCurrentUserId:facebookId];
            [FacebookHelper storeCurrentUserName:facebookName];
            
            [FacebookHelper requestAndStoreCurrentUserFriendsWithCompletionHandler:
             ^(FBRequestConnection * connection, id result, NSError * error) {
                 [[PFUser currentUser] saveInBackground];
                 handler(connection, result, error);
            }];
            return;
        }
        
        handler(connection, result, error);
    }];
}

+ (void)storeCurrentUserId:(NSString *)facebookId {
    // REQUIRES: facebookId is a valid id of the current user
    // EFFECTS: Stores the Facebook id of the current user for later use
    
    [[PFUser currentUser] setObject:facebookId forKey:@"facebookId"];
}

+ (void)storeCurrentUserName:(NSString *)facebookName {
    [[PFUser currentUser] setObject:facebookName forKey:@"facebookName"];
}

+ (NSString *)getCachedCurrentUserId {
    // EFFECTS: Gets the cached Facebook name of the current user
    //          Returns nil if there is no cache Facebook name
    
    return [[PFUser currentUser] objectForKey:@"facebookId"];
}

+ (NSString *)getCachedCurrentUserName {
    // EFFECTS: Gets the cached Facebook name of the current user
    //          Returns nil if there is no cache Facebook name
    
    return [[PFUser currentUser] objectForKey:@"facebookName"];
}

+ (void)getProfilePictureWithUserId:(NSString *)facebookId
                            andSize:(ProfilePictureSize)sizeType
               andCompletionHandler:(void (^) (NSData * fetchedData, NSError * error))handler {
    // EFFECTS: Requests, and fetches Facebook profile picture of the user with the given id and with
    //          the specified picture size
    
    if (![Connectivity hasInternetConnection]) {
        return;
    }
    
    NSURL * profileUrl = [FacebookHelper getProfilePictureUrlWithUserId:facebookId
                                                                andSize:sizeType];
    
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:profileUrl];
    
    [NSURLConnection sendAsynchronousRequest:urlRequest
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse * response, NSData * data, NSError * connectionError) {
                               handler(data, connectionError);
                           }];
}

+ (NSURL *)getProfilePictureUrlWithUserId:(NSString *)facebookId
                                  andSize:(ProfilePictureSize)sizeType {
    // EFFECTS: Gets the URL of the Facebook profile picture of the user with the given id and with
    //          the specified picture size
    
    NSString * sizeString = @"";
    switch (sizeType) {
        case kSmall:
            sizeString = @"small";
            break;
        case kNormal:
            sizeString = @"normal";
            break;
        case kLarge:
            sizeString = @"large";
            break;
        case kSquare:
            sizeString = @"square";
            break;
    }
    NSString * urlString = [NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?type=%@",
                            facebookId, sizeString];
    
    return [NSURL URLWithString:urlString];
}

+ (void)requestAndStoreCurrentUserFriendsWithCompletionHandler:(void (^) (FBRequestConnection * connection,
                                                                          id result,
                                                                          NSError * error))handler {
    // EFFECTS: Requests, and stores the friend lists of the current user
    
    if (![Connectivity hasInternetConnection]) {
        return;
    }
    if (![FacebookHelper getCachedCurrentUserId]) {
        return;
    }
    
    NSString * friendGraphPath = [NSString stringWithFormat:@"/%@/friends",
                                  [FacebookHelper getCachedCurrentUserId]];
    
    [FBRequestConnection startWithGraphPath:friendGraphPath
                          completionHandler:^(FBRequestConnection * connection, id result, NSError * error) {
                              if (error) {
                                  handler(connection, result, error);
                                  return;
                              }
                              
                              NSArray * fbFriendListData = result[@"data"];
                              
                              // Get Facebook id of friends
                              NSMutableArray * friendIdList = [[NSMutableArray alloc] init];
                              for (id friendData in fbFriendListData) {
                                  [friendIdList addObject:friendData[@"id"]];
                              }
                              [[PFUser currentUser] setObject:friendIdList forKey:@"friends"];
                              
                              // Get the list of friends playing Aerhythm
                              [FacebookHelper filterAerhythmFriendsWithFriendList:friendIdList];
                              
                              handler(connection, result, error);
                          }];
}

+ (void)filterAerhythmFriendsWithFriendList:(NSArray *)friendIdList {
    // REQUIRES: friendIdList != nil
    // EFFECTS: Filters and saves the list of friends that also play Aerhythm to the current user
    //          information variable
    
    PFQuery * query = [PFUser query];
    [query whereKey:@"facebookId" containedIn:friendIdList];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error) {
        if (error) {
            NSLog(@"Error in query database for App friends: %@", error);
            return;
        }
        
        NSMutableArray * aerhythmFriendIdList = [[NSMutableArray alloc] init];
        for (PFObject * friendData in objects) {
            [aerhythmFriendIdList addObject:friendData[@"facebookId"]];
        }
        
        // A user is a friend of himself
        if ([FacebookHelper getCachedCurrentUserId]) {
            [aerhythmFriendIdList addObject:[FacebookHelper getCachedCurrentUserId]];
        }
        
        [[PFUser currentUser] setObject:aerhythmFriendIdList forKey:@"appFriends"];
    }];
}

+ (NSArray *)getCachedCurrentUserFriendsId {
    // EFFECTS: Gets the cached of the list of Facebook ids of current user's friends
    
    return [[PFUser currentUser] objectForKey:@"friends"];
}

+ (NSArray *)getCachedCurrentUserAppFriendsId {
    // EFFECTS: Gets the cached of the list of Facebook ids of current user's friends that play Aerhythm
    
    return [[PFUser currentUser] objectForKey:@"appFriends"];
}

+ (void)deleteRequestObjectWithId:(NSString *)requestObjectId
                        forUserId:(NSString *)recipientId {
    // REQUIRES: requestObjectId != nil and recipientId != nil
    // EFFECTS: Deletes the request object with input id associated with the input user id.
    
    if (!recipientId) {
        return;
    }
    if (!requestObjectId) {
        return;
    }
    if (![Connectivity hasInternetConnection]) {
        return;
    }
    
    NSString * graphPath = [NSString stringWithFormat:@"/%@_%@", requestObjectId, recipientId];
    [FBRequestConnection startWithGraphPath:graphPath
                                 parameters:nil
                                 HTTPMethod:@"DELETE"
                          completionHandler:^(FBRequestConnection * connection, id result, NSError * error) {
                          }];
}

+ (void)deleteCurrentUserRequestObjectWithId:(NSString *)requestObjectId {
    // REQUIRES: requestObjectId != nil
    // EFFECTS: Deletes the request object with input id associated with current user.
    
    if (!requestObjectId) {
        return;
    }
    if (![FacebookHelper getCachedCurrentUserId]) {
        return;
    }
    if (![Connectivity hasInternetConnection]) {
        return;
    }
    
    [FacebookHelper deleteRequestObjectWithId:requestObjectId
                                    forUserId:[FacebookHelper getCachedCurrentUserId]];
}

+ (NSString *)getRequestIdFromURL:(NSURL *)resultUrl {
    // REQUIRES: resultUrl != nil, resultUrl conforms to RFC 1808, and
    //           resultUrl is passed from Facebook when sending requests
    // EFFECTS: Parses and returns that request object id from the input url
    
    NSArray * components = [resultUrl.query componentsSeparatedByString:@"&"];
    for (NSString * pair in components) {
        NSArray * keyValueArray = [pair componentsSeparatedByString:@"="];
        NSString * key = keyValueArray[0];
        if ([key isEqualToString:@"request"]) {
            return keyValueArray[1];
        }
    }
    
    return nil;
}

+ (void)loginFacebookWithPermissions:(NSArray *)permissions
                     andSuccessBlock:(void (^)())successBlock {
    // EFFECTS: Performs Facebook login with the input array of requested permissions and success block.
    //          The error handling is handled by the function itself. An alert view may be shown up
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser * user, NSError * error) {
            if (!user) {
                if (error) {
                    // Handle errors
                    NSString * errorMessage = @"Please try again later.";
                    NSString * errorTitle = @"Facebook Login Error";
                    
                    if ([FBErrorUtility shouldNotifyUserForError:error]) {
                        errorTitle = @"Facebook Error";
                        errorMessage = [FBErrorUtility userMessageForError:error];
                    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
                        errorTitle = @"Session Error";
                        errorMessage = @"Your current session is no longer valid. Please log in again.";
                    } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                        return;
                    }
                    
                    UIAlertView * alertError = [[UIAlertView alloc]
                                                initWithTitle:errorTitle
                                                message:errorMessage
                                                delegate:nil
                                                cancelButtonTitle:@"OK"
                                                otherButtonTitles:nil];
                    [alertError show];
                }
            } else {
                successBlock();
            }
        }];
    });
}

+ (void)requestPublishPermissionWithSuccessBlock:(void (^)())successBlock {
    // EFFECTS: Asks for permissions to publish things on current user's Facebook page
    //          The error handling is handled by the function itself. An alert view may be shown up
    
    NSArray * publishPermission = @[@"publish_actions"];
    
    [FacebookHelper loginFacebookWithPermissions:publishPermission andSuccessBlock:successBlock];
}

static FBFrictionlessRecipientCache * facebookRequestFriendCache = nil;
+ (FBFrictionlessRecipientCache *)getRequestFriendCache {
    // EFFECTS: Returns the cache of friends for requests
    
    if (facebookRequestFriendCache) {
        facebookRequestFriendCache = [[FBFrictionlessRecipientCache alloc] init];
    }
    
    [facebookRequestFriendCache prefetchAndCacheForSession:nil];
    
    return facebookRequestFriendCache;
}

@end
