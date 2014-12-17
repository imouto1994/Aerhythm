//
//  SongRequest.m
//  Aerhythm
//
//  Created by Nguyen Truong Duy on 17/4/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "SongRequest.h"
#import <Parse/PFObject+Subclass.h>

static NSString * const kSongRequestParseClassName = @"SongRequest";
static NSString * const kRequestTypeKey =@"requestType";
static NSString * const kToUserIdKey = @"toUserId";
static NSString * const kSongNameKey = @"songName";
static NSString * const kSongArtistKey = @"songArtist";
static NSString * const kFromUserIdKey = @"fromUserId";

@interface SongRequest ()

@property (nonatomic, strong, readwrite) PFFile * songFile;
@property (nonatomic, readwrite) SongRequestType requestType;
@property (nonatomic, strong, readwrite) NSString * fromUserName;
@property (nonatomic, strong, readwrite) NSString * fromUserId;
@property (nonatomic, strong, readwrite) NSString * toUserId;
@property (nonatomic, strong, readwrite) NSString * songName;
@property (nonatomic, strong, readwrite) NSString * songArtist;

@end

@implementation SongRequest

@dynamic fromUserId;
@dynamic toUserId;
@dynamic requestFacebookId;
@dynamic requestType;
@dynamic songName;
@dynamic songArtist;
@dynamic songFile;
@dynamic fromUserName;

+ (NSString *)parseClassName
{
    // EFFECTS: Returns a string which is a parse class name for this class
    return kSongRequestParseClassName;
}

- (void)emptyAllFields
{
    // REQUIRES: self != nil
    // EFFECTS: Sets all fields in self to be null
    
    self.songName = (NSString *)[NSNull null];
    self.songArtist = (NSString *)[NSNull null];
    self.requestFacebookId = (NSString *)[NSNull null];
    self.fromUserId = (NSString *)[NSNull null];
    self.toUserId = (NSString *)[NSNull null];
    self.songFile = (PFFile *)[NSNull null];
    self.fromUserName = (NSString *)[NSNull null];
}

+ (SongRequest *)requestForAskingSong
{
    // EFFECTS: A factory method that creates an empty request for asking a song
    
    SongRequest * askRequest = [SongRequest object];
    if (askRequest) {
        askRequest.requestType = kAskSong;
        // A request of asking songs does not have song data
        [askRequest emptyAllFields];
    }
    
    return askRequest;
}

+ (SongRequest *)requestForAskingSongWithName:(NSString *)songName
                                    andArtist:(NSString *)songArtist
                                     fromUser:(NSString *)fromUserId
                                       toUser:(NSString *)toUserId
{
    // EFFECTS: A factory method that creates a request for asking a song with the input parameters

    SongRequest * askRequest = [SongRequest requestForAskingSong];
    if (askRequest) {
        askRequest.songName = songName;
        askRequest.songArtist = songArtist;
        askRequest.fromUserId = fromUserId;
        askRequest.toUserId = toUserId;
    }
    
    return askRequest;
}

+ (SongRequest *)requestForAskingSongWithName:(NSString *)songName
                                    andArtist:(NSString *)songArtist
                                     fromUser:(NSString *)fromUserId
                                       toUser:(NSString *)toUserId
                         andFacebookRequestId:(NSString *)facebookRequestId
{
    // EFFECTS: A factory method that creates a request for asking a song with the input parameters
    //          including the assigned facebook request id
    
    SongRequest * askRequest = [SongRequest requestForAskingSongWithName:songName
                                                               andArtist:songArtist
                                                                fromUser:fromUserId
                                                                  toUser:toUserId];
    if (askRequest) {
        askRequest.requestFacebookId = facebookRequestId;
    }
    return askRequest;
}

+ (SongRequest *)requestForSendingSongWithData:(NSData *)songData
{
    // REQUIRES: songData != nil and songData must have size not larger than MAX_DATA_BYTE_SIZE
    // EFFECTS: A factory method that creates a request for sending a song with the given data
    
    SongRequest * sendRequest = [SongRequest object];
    if (sendRequest) {
        sendRequest.requestType = kSendSong;
        [sendRequest emptyAllFields];
        sendRequest.songFile = [PFFile fileWithData:songData];
    }
    return sendRequest;
}

+ (SongRequest *)requestForSendingSongWithName:(NSString *)songName
                                     andArtist:(NSString *)songArtist
                                       andData:(NSData *)songData
                                      fromUser:(NSString *)fromUserId
                                        toUser:(NSString *)toUserId
{
    // REQUIRES: songData != nil and songData must have size not larger than MAX_DATA_BYTE_SIZE
    // EFFECTS: A factory method that creates a request for sending a song with the given data and other
    //          information
    
    SongRequest * sendRequest = [SongRequest requestForSendingSongWithData:songData];
    if (sendRequest) {
        sendRequest.songName = songName;
        sendRequest.songArtist = songArtist;
        sendRequest.fromUserId = fromUserId;
        sendRequest.toUserId = toUserId;
    }
    
    return sendRequest;
}

+ (SongRequest *)requestForSendingSongWithName:(NSString *)songName
                                     andArtist:(NSString *)songArtist
                                       andData:(NSData *)songData
                                      fromUser:(NSString *)fromUserId
                                        toUser:(NSString *)toUserId
                          andFacebookRequestId:(NSString *)facebookRequestId
{
    // REQUIRES: songData != nil and songData must have size not larger than MAX_DATA_BYTE_SIZE
    // EFFECTS: A factory method that creates a request for sending a song with the given data and other
    //          information including the assigned facebook request id
    
    SongRequest * sendRequest = [SongRequest requestForSendingSongWithName:songName
                                                                 andArtist:songArtist
                                                                   andData:songData
                                                                  fromUser:fromUserId
                                                                    toUser:toUserId];
    if (sendRequest) {
        sendRequest.requestFacebookId = facebookRequestId;
    }
    
    return sendRequest;
}

- (void)saveRequestInBackgroundWithBlock:(PFBooleanResultBlock)block
{
    // REQUIRES: self != nil
    // EFFECTS: Saves the song request in background with the input completion handler, and progress handler
    
    [self saveRequestInBackgroundWithBlock:block
                             progressBlock:^(int percentDone) {
                                 NSLog(@"Store file %@ progress = %d", self.songName, percentDone);
                             }];
}

+ (void)getAllRequestsOfType:(SongRequestType)requestType
                      toUser:(NSString *)toUserId
        andCompletionHandler:(void (^) (NSArray * requestList, NSError * error))handler
{
    // REQUIRES: toUserId != nil
    // EFFECTS: Retrieves all requests that are sent to the input user id of the specified type
    
    PFQuery * query = [SongRequest query];
    [query whereKey:kRequestTypeKey equalTo:[NSNumber numberWithUnsignedInteger:requestType]];
    [query whereKey:kToUserIdKey equalTo:toUserId];
    
    [query findObjectsInBackgroundWithBlock:handler];
}

- (void)downloadSongDataInBackgroundWithBlock:(PFDataResultBlock)resultBlock
{
    // REQUIRES: self != nil && requestType == SEND_SONG
    // EFFECTS: Asynchronously gets song data from cache if available or fetches its contents
    //          from the Parse server
    
    [self downloadSongDataInBackgroundWithBlock:resultBlock
                                  progressBlock:^(int percentDone) {
                                      NSLog(@"Download song %@ with progress = %d", self.songName, percentDone);
                                  }];
}

- (void)saveSongDataInBackgroundWithBlock:(PFBooleanResultBlock)block {
    // REQUIRES: self != nil && requestType == SEND_SONG
    // EFFECTS: Saves the song data in background with the input completion handler
    //          The song data may be not saved if it is already in Parse server and is not dirty
    
    if (self.requestType != kSendSong || !self.songFile) {
        return;
    }
    if (!self.songFile.isDirty) {
        return;
    }
    
    [self.songFile saveInBackgroundWithBlock:block
                               progressBlock:^(int percentDone) {
        NSLog(@"Store file %@ progress = %d", self.songName, percentDone);
    }];
}

- (void)checkIfRequestIsNewInBackgroundWithBlock:(void (^) (BOOL existed, NSError * error))block {
    // REQUIRES: self != nil
    // EFFECTS: Checks in background if this request is new (i.e. there is no same request within a period of time
    //          that is specified in MAX_NUM_DAY_FOR_OLD_REQUEST)
    
    [SongRequest getRequestsInBackgroundWithType:self.requestType
                                        fromUser:self.fromUserId
                                          toUser:self.toUserId
                                     andSongName:self.songName
                                   andSongArtist:self.songArtist
                              andCompletionBlock:^(NSArray * objects, NSError * error) {
                                  BOOL existed = NO;
                                  if ([objects count] > 0) {
                                      SongRequest * existingRequest = [objects objectAtIndex:0];
                                      if (![existingRequest isOutdatedRequest]) {
                                          existed = YES;
                                      }
                                  }
                                  block(existed, error);
                              }];
}

- (BOOL)isOutdatedRequest {
    // REQUIRES: self != nil
    // EFFECTS: Returns YES if this request is outdated (i.e. the creation time exceeds the period of time
    //          specified in in MAX_NUM_DAY_FOR_OLD_REQUEST). Returns NO otherwise
    
    NSTimeInterval timeDiff = [self.createdAt timeIntervalSinceNow];
    if (timeDiff > 0) {
        return NO;
    }
    
    timeDiff = -timeDiff;
    if (timeDiff < kMaxNumDayForOldRequest * 24 * 3600) {
        return NO;
    }
    
    return YES;
}

+ (void)getRequestsInBackgroundWithType:(SongRequestType)requestType
                               fromUser:(NSString *)fromUserId
                                 toUser:(NSString *)toUserId
                            andSongName:(NSString *)songName
                          andSongArtist:(NSString *)songArtist
                     andCompletionBlock:(void (^) (NSArray * objects, NSError * error))block {
    // EFFECTS: Gets in background requests with the specified information
    
    PFQuery * requestQuery = [SongRequest query];
    [requestQuery whereKey:kRequestTypeKey equalTo:[NSNumber numberWithUnsignedInteger:requestType]];
    if (fromUserId) {
        [requestQuery whereKey:kFromUserIdKey equalTo:fromUserId];
    } else {
        [requestQuery whereKey:kFromUserIdKey equalTo:[NSNull null]];
    }
    if (toUserId) {
        [requestQuery whereKey:kToUserIdKey equalTo:toUserId];
    } else {
        [requestQuery whereKey:kToUserIdKey equalTo:[NSNull null]];
    }
    if (songName) {
        [requestQuery whereKey:kSongNameKey equalTo:songName];
    } else {
        [requestQuery whereKey:kSongNameKey equalTo:[NSNull null]];
    }
    if (songArtist) {
        [requestQuery whereKey:kSongArtistKey equalTo:songArtist];
    } else {
        [requestQuery whereKey:kSongArtistKey equalTo:[NSNull null]];
    }
    
    [requestQuery findObjectsInBackgroundWithBlock:block];
}

- (void)saveRequestInBackgroundWithBlock:(PFBooleanResultBlock)block
                           progressBlock:(PFProgressBlock)progressBlock {
    // REQUIRES: self != nil
    // EFFECTS: Saves the song request in background with the input completion handler, and progress handler
    
    // Query the from-user name
    PFQuery * userQuery = [PFUser query];
    [userQuery whereKey:@"facebookId" equalTo:self.fromUserId];
    
    [userQuery findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error) {
        if (error) {
            NSLog(@"Error in finding username with id %@", self.fromUserId);
            return;
        }
        if (![objects count]) {
            return;
        }
        
        self.fromUserName = [objects[0] objectForKey:@"facebookName"];
        if (self.requestType == kAskSong || !self.songFile) {
            self.songFile = (PFFile *)[NSNull null];
            [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                    progressBlock(100);
                }
                block(succeeded, error);
            }];
        } else {
            NSLog(@"File dirty = %d", (int)self.songFile.isDirty);
            if (self.songFile.isDirty) {
                // Upload the song file first
                [self.songFile saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
                    if (succeeded) {
                        [self saveInBackgroundWithBlock:block];
                    } else {
                        NSLog(@"%@", error);
                    }
                } progressBlock:progressBlock];
            } else {
                [self saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded) {
                        progressBlock(100);
                    }
                    block(succeeded, error);
                }];
            }
        }
    }];
}

- (void)downloadSongDataInBackgroundWithBlock:(PFDataResultBlock)resultBlock
                                progressBlock:(PFProgressBlock)progressBlock {
    // REQUIRES: self != nil && requestType == SEND_SONG
    // EFFECTS: Asynchronously gets song data from cache if available or fetches its contents
    //          from the Parse server
    
    if (self.requestType == kAskSong || !self.songFile) {
        return;
    }
    
    [self.songFile getDataInBackgroundWithBlock:resultBlock
                                  progressBlock:progressBlock];
}

@end
