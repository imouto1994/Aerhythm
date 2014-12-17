//
//  FacebookHelper.h
//  Aerhythm
//
//  Created by Nguyen Truong Duy on 3/4/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Parse/Parse.h>
#import "Constant.h"

/*
 This class has a collection of helper routines related to Facebook API, and Parse - Facebook Integration
 in Aerhythm
 */

@interface FacebookHelper : NSObject

+ (BOOL)hasLoggedIn;
// EFFECTS: Returns true if the user has logged in to Facebook before.

+ (BOOL)hasPublishPermission;
// EFFECTS: Returns true if the current session has publish permission.

+ (void)postToCurrentUserWallWithParam:(NSDictionary *)param
                  andCompletionHandler:(void (^)(FBRequestConnection *, id, NSError *))handler;
// REQUIRES: param != nil
// EFFECTS: Posts to the current user's Facebook wall a status with input parameters

+ (void)publishStoryWithObject:(id<FBOpenGraphObject>)newObject
                 andActionType:(NSString *)actionType
          andCompletionHandler:(void (^) (FBRequestConnection * connection,
                                          id result,
                                          NSError * error))handler;
// REQUIRES: newObject != nil, and actionType != nil
// EFFECTS: Publishes a story with the input Facebook object and action type. The function first
//          posts the object to Facebook, then publishes action story with the new object id received

+ (void)storeCurrentUserId:(NSString *)facebookId;
// REQUIRES: facebookId is a valid id of the current user
// EFFECTS: Stores the Facebook id of the current user for later use

+ (NSString *)getCachedCurrentUserId;
// EFFECTS: Gets the cached Facebook id of the current user
//          Returns nil if there is no cache Facebook id

+ (NSString *)getCachedCurrentUserName;
// EFFECTS: Gets the cached Facebook name of the current user
//          Returns nil if there is no cache Facebook name

+ (void)requestAndStoreCurrentUserInfoWithCompletionHandler:(void (^) (FBRequestConnection * connection,
                                                                       id result,
                                                                       NSError * error))handler;
// EFFECTS: Requests, gets and stores the Facebook information (id, name) of the current user

+ (void)getProfilePictureWithUserId:(NSString *)facebookId
                            andSize:(ProfilePictureSize)sizeType
               andCompletionHandler:(void (^) (NSData * fetchedData, NSError * error))handler;
// EFFECTS: Requests, and fetches Facebook profile picture of the user with the given id and with
//          the specified picture size

+ (NSURL *)getProfilePictureUrlWithUserId:(NSString *)facebookId
                                  andSize:(ProfilePictureSize)sizeType;
// EFFECTS: Gets the URL of the Facebook profile picture of the user with the given id and with
//          the specified picture size

+ (void)requestAndStoreCurrentUserFriendsWithCompletionHandler:(void (^) (FBRequestConnection * connection,
                                                                          id result,
                                                                          NSError * error))handler;
// EFFECTS: Requests, and stores the friend lists of the current user

+ (NSArray *)getCachedCurrentUserFriendsId;
// EFFECTS: Gets the cached of the list of Facebook ids of current user's friends

+ (NSArray *)getCachedCurrentUserAppFriendsId;
// EFFECTS: Gets the cached of the list of Facebook ids of current user's friends that play Aerhythm

+ (void)deleteRequestObjectWithId:(NSString *)requestObjectId
                        forUserId:(NSString *)recipientId;
// REQUIRES: requestObjectId != nil and recipientId != nil
// EFFECTS: Deletes the request object with input id associated with the input user id.

+ (void)deleteCurrentUserRequestObjectWithId:(NSString *)requestObjectId;
// REQUIRES: requestObjectId != nil
// EFFECTS: Deletes the request object with input id associated with current user.

+ (NSString *)getRequestIdFromURL:(NSURL *)resultUrl;
// REQUIRES: resultUrl != nil, resultUrl conforms to RFC 1808, and
//           resultUrl is passed from Facebook when sending requests
// EFFECTS: Parses and returns that request object id from the input url

+ (FBFrictionlessRecipientCache *)getRequestFriendCache;
// EFFECTS: Returns the cache of friends for requests

+ (void)loginFacebookWithPermissions:(NSArray *)permissions
                     andSuccessBlock:(void (^)())successBlock;
// EFFECTS: Performs Facebook login with the input array of requested permissions and success block.
//          The error handling is handled by the function itself. An alert view may be shown up

+ (void)requestPublishPermissionWithSuccessBlock:(void (^)())successBlock;
// EFFECTS: Asks for permissions to publish things on current user's Facebook page
//          The error handling is handled by the function itself. An alert view may be shown up

@end
