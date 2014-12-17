#import "RequestCell.h"
#import <MediaPlayer/MediaPlayer.h>
#import "Utilities.h"
#import "TSLibraryImport.h"
#import "Connectivity.h"
#import "MenuController.h"
#import "FacebookHelper.h"
#import "LocalGiftSongs.h"

@implementation RequestCell

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)acceptButtonTapped:(UIButton *)sender {
    // Show popup
    if (![Connectivity hasInternetConnection]) {
        return;
    }
    NSString * currentUserId = [FacebookHelper getCachedCurrentUserId];
    if (!currentUserId) {
        return;
    }
    
    // Check if the requested song is in the media library or in the local
    CGRect originalFrame = CGRectMake(600, 40, 200, 35);
    BOOL isLocalGift = YES;
    if ([Utilities querySongWithSongName:self.songRequest.songName
                           andArtistName:self.songRequest.songArtist]) {
        isLocalGift = NO;
    } else if ([LocalGiftSongs existGiftSongWithName:self.songRequest.songName
                                           andArtist:self.songRequest.songArtist]) {
        isLocalGift = YES;
    } else {
        [Utilities showMessage:@"Song not found"
                     withColor:[UIColor whiteColor]
                       andSize:20.0
             fromOriginalFrame:originalFrame
                   withOffsetX:-100
                    andOffsetY:0
                        inView:self
                  withDuration:0.75];
        return;
    }
    
    if (isLocalGift) {
        [self shareSongInLocalGifts];
    } else {
        [self shareSongInMediaLibrary];
    }
}

- (void)shareSongInMediaLibrary {
    // REQUIRES: The requested song is in the media library. And self != nil
    // EFFECTS: Uploads the requested song data, and the reply request to Parse server
    //          if the user approves the request and if song data meet requirements
    //          Nofifies the recipient via Facebook
    
    // Search for the file
    MPMediaItem * mediaItem = [Utilities querySongWithSongName:self.songRequest.songName
                                                 andArtistName:self.songRequest.songArtist];
    NSURL * assetURL = [mediaItem valueForProperty:MPMediaItemPropertyAssetURL];
    
    if (!assetURL) {
        return;
    }
    
    [Utilities removeTempFilesFromDocuments];
    
    // Get file extension
    NSString * ext = [TSLibraryImport extensionForAssetURL:assetURL];
    // Get file path
    NSString * filePath = [[Utilities documentsDirectory] stringByAppendingPathComponent:@"TempUploading"];
    NSURL * destinationURL = [[NSURL fileURLWithPath:filePath] URLByAppendingPathExtension:ext];
    // Start importing
    TSLibraryImport * tsImport = [[TSLibraryImport alloc] init];
    [tsImport importAsset:assetURL toURL:destinationURL completionBlock:^(TSLibraryImport *theImport) {
        NSString * path = [[destinationURL absoluteString] lastPathComponent];
        NSString * importedFilePath = [[Utilities documentsDirectory] stringByAppendingPathComponent:path];
        
        [self shareSongWithDataPath:importedFilePath];
    }];
}

- (void)shareSongInLocalGifts {
    // REQUIRES: The requested song is in local gifts. And self != nil
    // EFFECTS: Uploads the requested song data, and the reply request to Parse server
    //          if the user approves the request and if song data meet requirements
    //          Nofifies the recipient via Facebook
    
    NSDictionary * localSongInfo = [LocalGiftSongs queryLocalGiftSongWithName:self.songRequest.songName
                                                                    andArtist:self.songRequest.songArtist];
    NSString * dataPath = localSongInfo[kLocalSongPathKey];
    
    [self shareSongWithDataPath:dataPath];
}

- (void)uploadSongDataWithPath:(NSString *)dataPath
          andFacebookRequestId:(NSString *)facebookRequestId {
    // REQUIRES: self != nil and dataPath != nil and facebookRequestId != nil
    // EFFECTS: Uploads the song data with specified data path, and the reply request to Parse server
    
    NSData * songData = [NSData dataWithContentsOfFile:dataPath];
    
    CGRect originalFrame = CGRectMake(600, 40, 200, 35);
    if (!songData) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [Utilities showMessage:@"Invalid Song Data"
                         withColor:[UIColor whiteColor]
                           andSize:20.0
                 fromOriginalFrame:originalFrame
                       withOffsetX:-100
                        andOffsetY:0
                            inView:self
                      withDuration:0.75];
        });
        [FacebookHelper deleteRequestObjectWithId:facebookRequestId
                                        forUserId:self.songRequest.fromUserId];
        return;
    }
    if ([songData length] > kMaxDataByteSizeForParseUpload) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [Utilities showMessage:@"Song Size Too Large"
                         withColor:[UIColor whiteColor]
                           andSize:20.0
                 fromOriginalFrame:originalFrame
                       withOffsetX:-100
                        andOffsetY:0
                            inView:self
                      withDuration:0.75];
        });
        [FacebookHelper deleteRequestObjectWithId:facebookRequestId
                                        forUserId:self.songRequest.fromUserId];
        return;
    }
    
    SongRequest * giftRequest = [SongRequest requestForSendingSongWithName:self.songRequest.songName
                                                                 andArtist:self.songRequest.songArtist
                                                                   andData:songData
                                                                  fromUser:self.songRequest.toUserId
                                                                    toUser:self.songRequest.fromUserId
                                                      andFacebookRequestId:facebookRequestId];
    MailController * mailController = (MailController *) self.delegate;
    MenuController * menuController = (MenuController *) mailController.parentDelegate;
    
    // Save this sending gift request
    SongRequest * currentSongRequest = self.songRequest;
    [giftRequest saveRequestInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
        if (!succeeded) {
            NSLog(@"Error in uploading sending gift request with song %@: %@", currentSongRequest.songName, error);
            return;
        }
        // Remove request
        [currentSongRequest deleteEventually];
    } progressBlock:^(int percentDone) {
        [menuController displayProgress:percentDone forPurpose:YES];
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate hideProcess];
    });
}

- (void)shareSongWithDataPath:(NSString *)dataPath {
    // REQUIRES: self != nil and dataPath != nil
    // EFFECTS: Uploads the song data with specified data path, and the reply request to Parse server
    //          if the user approves the request and if song data meet requirements
    //          Nofifies the recipient via Facebook
    
    CGRect originalFrame = CGRectMake(600, 40, 200, 35);
    
    NSData * songData = [NSData dataWithContentsOfFile:dataPath];
    if (!songData) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [Utilities showMessage:@"Invalid Song Data"
                         withColor:[UIColor whiteColor]
                           andSize:20.0
                 fromOriginalFrame:originalFrame
                       withOffsetX:-100
                        andOffsetY:0
                            inView:self
                      withDuration:0.75];
        });
        return;
    }
    if ([songData length] > kMaxDataByteSizeForParseUpload) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [Utilities showMessage:@"Song Size Too Large"
                         withColor:[UIColor whiteColor]
                           andSize:20.0
                 fromOriginalFrame:originalFrame
                       withOffsetX:-100
                        andOffsetY:0
                            inView:self
                      withDuration:0.75];
        });
        return;
    }
    
    // Show Facebook request dialog
    NSMutableDictionary * params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                    self.songRequest.fromUserId, @"to", nil];
    
    NSString * message = [NSString stringWithFormat:@"Take this song %@ and enjoy the game",
                          self.songRequest.songName];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                      message:message
                                                        title:@"Sending Gift"
                                                   parameters:params
                                                      handler:
         ^(FBWebDialogResult result, NSURL * resultURL, NSError * error) {
             if (error) {
                 // Case A: Error launching the dialog or sending request.
                 NSLog(@"Error sending gift.");
             } else {
                 NSLog(@"Result URL = %@", resultURL);
                 if (result == FBWebDialogResultDialogNotCompleted) {
                     // Case B: User clicked the "x" icon
                     NSLog(@"User canceled request.");
                 } else {
                     NSString * requestId = [FacebookHelper getRequestIdFromURL:resultURL];
                     if (!requestId) {
                         return;
                     }
                     
                     NSLog(@"Request Sent.");
                     SongRequest * giftRequest = [SongRequest requestForSendingSongWithName:self.songRequest.songName
                                                                                  andArtist:self.songRequest.songArtist
                                                                                    andData:songData
                                                                                   fromUser:self.songRequest.toUserId
                                                                                     toUser:self.songRequest.fromUserId
                                                                       andFacebookRequestId:requestId];
                     MailController * mailController = (MailController *) self.delegate;
                     MenuController * menuController = (MenuController *) mailController.parentDelegate;
                     
                     // Save this sending gift request
                     SongRequest * currentSongRequest = self.songRequest;
                     [giftRequest saveRequestInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
                         if (!succeeded) {
                             NSLog(@"Error in uploading sending gift request with song %@: %@", currentSongRequest.songName, error);
                             return;
                         }
                         
                         // Remove request
                         [FacebookHelper deleteCurrentUserRequestObjectWithId:currentSongRequest.requestFacebookId];
                         if ([Connectivity hasInternetConnection]) {
                             [currentSongRequest deleteInBackground];
                         } else {
                             [currentSongRequest deleteEventually];
                         }
                         
                     } progressBlock:^(int percentDone) {
                         [menuController displayProgress:percentDone forPurpose:YES];
                     }];
                     
                     dispatch_async(dispatch_get_main_queue(), ^{
                         [self.delegate hideProcess];
                     });
                 }
             }
         }
                                                  friendCache:[FacebookHelper getRequestFriendCache]
         ];
    });
};
@end
