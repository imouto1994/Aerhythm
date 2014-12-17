#import <Parse/Parse.h>

#define kMaxDataByteSizeForParseUpload 10485760
#define kMaxNumDayForOldRequest 2

@protocol SongRequestProgressProtocol<NSObject>

- (void)displayProgress:(int)percent forPurpose:(BOOL)purpose;

@end

typedef NS_ENUM(NSUInteger, SongRequestType) {
    kAskSong = 0,
    kSendSong = 1
};


@interface SongRequest : PFObject <PFSubclassing>

// Class properties for request content
@property (nonatomic, readonly, strong) NSString * fromUserId;
@property (nonatomic, readonly, strong) NSString * toUserId;
@property (nonatomic, readwrite, strong) NSString * requestFacebookId;
@property (nonatomic, readonly) SongRequestType requestType;
// Class properties for song content
@property (nonatomic, readonly, strong) NSString * songName;
@property (nonatomic, readonly, strong) NSString * songArtist;
@property (nonatomic, readonly, strong) PFFile * songFile;
// This property is filled by the class only when the object is sent to Parse server
@property (nonatomic, readonly, strong) NSString * fromUserName;

+ (NSString *)parseClassName;
// EFFECTS: Returns a string which is a parse class name for this class

+ (SongRequest *)requestForAskingSong;
// EFFECTS: A factory method that creates an empty request for asking a song

+ (SongRequest *)requestForAskingSongWithName:(NSString *)songName
                                    andArtist:(NSString *)songArtist
                                     fromUser:(NSString *)fromUserId
                                       toUser:(NSString *)toUserId;
// EFFECTS: A factory method that creates a request for asking a song with the input parameters

+ (SongRequest *)requestForAskingSongWithName:(NSString *)songName
                                    andArtist:(NSString *)songArtist
                                     fromUser:(NSString *)fromUserId
                                       toUser:(NSString *)toUserId
                         andFacebookRequestId:(NSString *)facebookRequestId;
// EFFECTS: A factory method that creates a request for asking a song with the input parameters
//          including the assigned facebook request id

+ (SongRequest *)requestForSendingSongWithName:(NSString *)songName
                                     andArtist:(NSString *)songArtist
                                       andData:(NSData *)songData
                                      fromUser:(NSString *)fromUserId
                                        toUser:(NSString *)toUserId;
// REQUIRES: songData != nil and songData must have size not larger than MAX_DATA_BYTE_SIZE
// EFFECTS: A factory method that creates a request for sending a song with the given data and other
//          information

+ (SongRequest *)requestForSendingSongWithName:(NSString *)songName
                                     andArtist:(NSString *)songArtist
                                       andData:(NSData *)songData
                                      fromUser:(NSString *)fromUserId
                                        toUser:(NSString *)toUserId
                          andFacebookRequestId:(NSString *)facebookRequestId;
// REQUIRES: songData != nil and songData must have size not larger than MAX_DATA_BYTE_SIZE
// EFFECTS: A factory method that creates a request for sending a song with the given data and other
//          information including the assigned facebook request id

+ (void)getAllRequestsOfType:(SongRequestType)requestType
                      toUser:(NSString *)toUserId
        andCompletionHandler:(void (^) (NSArray * requestList, NSError * error))handler;
// REQUIRES: toUserId != nil
// EFFECTS: Retrieves all requests that are sent to the input user id of the specified type

- (void)saveRequestInBackgroundWithBlock:(PFBooleanResultBlock)block;
// REQUIRES: self != nil
// EFFECTS: Saves the song request in background with the input completion handler, and progress handler

- (void)saveRequestInBackgroundWithBlock:(PFBooleanResultBlock)block
                           progressBlock:(PFProgressBlock)progressBlock;
// REQUIRES: self != nil
// EFFECTS: Saves the song request in background with the input completion handler, and progress handler

- (void)downloadSongDataInBackgroundWithBlock:(PFDataResultBlock)resultBlock;
// REQUIRES: self != nil && requestType == SEND_SONG
// EFFECTS: Asynchronously gets song data from cache if available or fetches its contents
//          from the Parse server

- (void)downloadSongDataInBackgroundWithBlock:(PFDataResultBlock)resultBlock
                                progressBlock:(PFProgressBlock)progressBlock;
// REQUIRES: self != nil && requestType == SEND_SONG
// EFFECTS: Asynchronously gets song data from cache if available or fetches its contents
//          from the Parse server

- (void)saveSongDataInBackgroundWithBlock:(PFBooleanResultBlock)block;
// REQUIRES: self != nil && requestType == SEND_SONG
// EFFECTS: Saves the song data in background with the input completion handler
//          The song data may be not saved if it is already in Parse server and is not dirty

- (void)checkIfRequestIsNewInBackgroundWithBlock:(void (^) (BOOL existed, NSError * error))block;
// REQUIRES: self != nil
// EFFECTS: Checks in background if this request is new (i.e. there is no same request within a period of time
//          that is specified in MAX_NUM_DAY_FOR_OLD_REQUEST)

- (BOOL)isOutdatedRequest;
// REQUIRES: self != nil
// EFFECTS: Returns YES if this request is outdated (i.e. the creation time exceeds the period of time
//          specified in in MAX_NUM_DAY_FOR_OLD_REQUEST). Returns NO otherwise

+ (void)getRequestsInBackgroundWithType:(SongRequestType)requestType
                               fromUser:(NSString *)fromUserId
                                 toUser:(NSString *)toUserId
                            andSongName:(NSString *)songName
                          andSongArtist:(NSString *)songArtist
                     andCompletionBlock:(void (^) (NSArray * objects, NSError * error))block;
// EFFECTS: Gets in background requests with the specified information

@end
