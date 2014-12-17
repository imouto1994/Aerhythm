#import "HighscoreCell.h"
#import "CircularView.h"
#import "Utilities.h"
#import "FacebookHelper.h"
#include "Connectivity.h"
#include "SongRequest.h"
#include "LocalGiftSongs.h"
#include <SDWebImage/UIImageView+WebCache.h>

@interface HighscoreCell()

@property (nonatomic) BOOL isSearching;

@end

@implementation HighscoreCell {
    // Image view for the profile picture
    UIImageView * profileImageView;
    // Label for the profile name
    UILabel * profileNameLabel;
    // Label for the song name
    UILabel * songNameLabel;
    // Label for the score
    UILabel * scoreLabel;
    // Itunes button to refre to app Itunes
    UIButton * itunesButton;
    // Request button to request friends to share songs
    UIButton * requestButton;
    // Indicator View that it is currently searching for the song on iTunes
    UIActivityIndicatorView *searchingIndicator;
}

static UIColor * defaultErrorMessageColor;
static UIColor * defaultSuccessMessageColor;

+ (void)initialize {
    defaultErrorMessageColor = [UIColor colorWithRed:202 / 255.0
                                               green:44 / 255.0
                                                blue:2 / 255.0
                                               alpha:1.0];
    defaultSuccessMessageColor = [UIColor colorWithRed:0 / 255.0
                                                 green:167 / 255.0
                                                  blue:21 / 255.0
                                                 alpha:1.0];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = [[UIView alloc] init];
        self.selectedBackgroundView = [[UIView alloc] init];
        
        // Add view for table cell
        UIView *cellView = [[UIView alloc] init];
        [cellView setFrame:CGRectMake(0, 0, 768, 130)];
        
        // Add table cell frame
        UIImage *tableFrame = [Utilities loadImageWithName:@"tableFrame"];
        UIImageView *frameView = [[UIImageView alloc] initWithImage:tableFrame];
        [frameView setFrame:CGRectMake(0, 0, 768, 130)];
        [cellView addSubview:frameView];
        [cellView sendSubviewToBack:frameView];
        
        // Add profile image
        CircularView *profileBorderView = [[CircularView alloc] initWithFrame:CGRectMake(20 ,20, 90, 90)];
        [cellView addSubview:profileBorderView];
        UIImage *testImage = [Utilities loadImageWithName:@"level1-artwork"];
        profileImageView = [[UIImageView alloc] initWithImage:testImage];
        [profileImageView setFrame:CGRectMake(0, 0, 90, 90)];
        [profileBorderView addSubview:profileImageView];
        
        // Add profile name
        profileNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(128, 74, 216, 31)];
        [profileNameLabel setFont:[UIFont fontWithName:@"Futura (Light)" size:20]];
        profileNameLabel.text = @"Aerymth Testing";
        [cellView addSubview:profileNameLabel];
        
        // Add song name
        songNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(248, 0, 500, 40)];
        [songNameLabel setFont:[UIFont fontWithName:@"Futura (Light)" size:20]];
        songNameLabel.text = @"Song Name: Aerymth Song Testing";
        [cellView addSubview:songNameLabel];
        
        // Add score
        scoreLabel = [[UILabel alloc] initWithFrame:CGRectMake(378, 48, 316, 57)];
        [scoreLabel setFont:[UIFont fontWithName:@"Futura (Light)" size:40]];
        scoreLabel.text = @"Score: 99999";
        [cellView addSubview:scoreLabel];
        
        // Add button
        UIImage *itunesImage = [Utilities loadImageWithName:@"itunesButton"];
        itunesButton = [[UIButton alloc] initWithFrame:CGRectMake(690, 48, 50, 50)];
        [itunesButton setImage:itunesImage forState:UIControlStateNormal];
        [itunesButton addTarget:self
                         action:@selector(searchSong:)
               forControlEvents:UIControlEventTouchUpInside];
        [cellView addSubview:itunesButton];
        
        UIImage *requestImage = [Utilities loadImageWithName:@"mailButton"];
        requestButton = [[UIButton alloc] initWithFrame:CGRectMake(640, 48, 50, 50)];
        [requestButton setImage:requestImage forState:UIControlStateNormal];
        [requestButton addTarget:self
                          action:@selector(requestSong:)
                forControlEvents:UIControlEventTouchUpInside];
        [cellView addSubview:requestButton];
        
        searchingIndicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(690, 48, 50, 50)];
        searchingIndicator.hidden = YES;
        [cellView addSubview:searchingIndicator];
        
        [self addSubview:cellView];
    }
    
    return self;
}

- (void)setIsGlobalRanked:(BOOL)isGlobalRanked {
    _isGlobalRanked = isGlobalRanked;
    if (_isGlobalRanked && !requestButton.hidden) {
        requestButton.hidden = YES;
    } else if (!_isGlobalRanked && requestButton.hidden) {
        requestButton.hidden = NO;
    }
}

- (void)setIsSearching:(BOOL)isSearching {
    _isSearching = isSearching;
    dispatch_async(dispatch_get_main_queue(), ^{
        if (isSearching) {
            itunesButton.enabled = NO;
            itunesButton.hidden = YES;
            searchingIndicator.hidden = NO;
            [searchingIndicator startAnimating];
        } else {
            itunesButton.enabled = YES;
            itunesButton.hidden = NO;
            searchingIndicator.hidden = YES;
            [searchingIndicator stopAnimating];
        }
    });
}

- (void)showErrorMessage:(NSString *)message withColor:(UIColor *)color {
    CGRect itunesButtonFrame = [itunesButton frame];
    CGRect originalFrame = CGRectMake(itunesButtonFrame.origin.x - 140,
                                      itunesButtonFrame.origin.y + 50,
                                      280, itunesButtonFrame.size.height);
    [Utilities showMessage:message
                 withColor:color
                   andSize:20
         fromOriginalFrame:originalFrame
               withOffsetX:0
                andOffsetY:-50
                    inView:self
              withDuration:0.5];
    [self fadeButton];
}

- (void)showSuccessMessage:(NSString *)message {
    CGRect itunesButtonFrame = [itunesButton frame];
    CGRect originalFrame = CGRectMake(itunesButtonFrame.origin.x - 140,
                                      itunesButtonFrame.origin.y + 50,
                                      280, itunesButtonFrame.size.height);
    dispatch_async(dispatch_get_main_queue(), ^{
        [Utilities showMessage:message
                     withColor:defaultSuccessMessageColor
                       andSize:20
             fromOriginalFrame:originalFrame
                   withOffsetX:0
                    andOffsetY:-50
                        inView:self
                  withDuration:0.5];
        [self fadeButton];
    });
}

- (void)fadeButton {
    itunesButton.alpha = 1.0;
    requestButton.alpha = 1.0;
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         itunesButton.alpha = 0.0;
                         requestButton.alpha = 0.0;
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.5
                                               delay:0.5
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              itunesButton.alpha = 1.0;
                                              requestButton.alpha = 1.0;
                                          }
                                          completion:^(BOOL finished) {
                                          }];
                     }];
}

- (IBAction)requestSong:(UIButton *)sender {
    if (![Connectivity hasInternetConnection]) {
        return;
    }
    
    NSString * currentUserId = [FacebookHelper getCachedCurrentUserId];
    if (!currentUserId) {
        return;
    }
    
    // If the current user already has the song, no need to send a request
    if ([Utilities querySongWithSongName:self.songName andArtistName:self.artistName] ||
        [LocalGiftSongs existGiftSongWithName:self.songName andArtist:self.artistName]) {
        [self showErrorMessage:@"Duplicate Song"
                     withColor:defaultErrorMessageColor];
        return;
    }
    
    [SongRequest getRequestsInBackgroundWithType:kAskSong
                                        fromUser:currentUserId
                                          toUser:self.ownerFacebookId
                                     andSongName:self.songName
                                   andSongArtist:self.artistName
                              andCompletionBlock:^(NSArray * objects, NSError * error) {
                                  if (error) {
                                      NSLog(@"Error in getting existing requests: %@", error);
                                      return;
                                  }
                                  
                                  if ([objects count] > 0) {
                                      SongRequest * oldRequest = [objects objectAtIndex:0];
                                      if ([oldRequest isOutdatedRequest]) {
                                          // Outdated request. Delete it
                                          [FacebookHelper deleteRequestObjectWithId:oldRequest.requestFacebookId
                                                                          forUserId:oldRequest.toUserId];
                                          [oldRequest deleteInBackground];
                                      } else {
                                          // This is still a fresh request
                                          [self showErrorMessage:@"Duplicate Request"
                                                       withColor:defaultErrorMessageColor];
                                          return;
                                      }
                                  }
                                  
                                  [self presentSongRequestDialog];
                              }];
    
    
}

- (void)presentSongRequestDialog {
    // REQUIRES: self != nil
    // EFFECTS: Shows the Facebook request dialog for asking song request.
    //          Notifies the recipient and saves the request to Parse server if the user approves it
    
    NSString * currentUserId = [FacebookHelper getCachedCurrentUserId];
    NSMutableDictionary* params = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                   self.ownerFacebookId, @"to", nil];
    
    NSString * message = [NSString stringWithFormat:@"Could you share with me the song %@",
                          self.songName];
    
    [FBWebDialogs presentRequestsDialogModallyWithSession:nil
                                                  message:message
                                                    title:@"Song Request"
                                               parameters:params
                                                  handler:
     ^(FBWebDialogResult result, NSURL * resultURL, NSError * error) {
         if (error) {
             // Case A: Error launching the dialog or sending request.
             NSLog(@"Error sending request.");
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
                 
                 SongRequest * askSongRequest = [SongRequest
                                                 requestForAskingSongWithName:self.songName
                                                 andArtist:self.artistName
                                                 fromUser:currentUserId
                                                 toUser:self.ownerFacebookId
                                                 andFacebookRequestId:requestId];
                 [askSongRequest saveRequestInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                 }];
             }
         }
     }
                                              friendCache:[FacebookHelper getRequestFriendCache]
     ];
}

- (IBAction)searchSong:(UIButton *)sender {
    // REQUIRES: self != nil
    // EFFECTS: Searching for a song and link to iTunes App
    
    if ([self.songName isKindOfClass:[NSNull class]] ||
        [self.artistName isKindOfClass:[NSNull class]] ||
        self.songName.length == 0 ||
        self.artistName.length == 0) {
        [self showErrorMessage:@"Invalid fields"
                     withColor:defaultErrorMessageColor];
        return;
    }
    
    // this creates the base of the Link Maker url call.
    NSString* baseURLString = @"https://itunes.apple.com/search";
    NSString* searchTerm = [NSString stringWithFormat:@"%@ %@", self.artistName, self.songName];
    NSString* searchUrlString = [NSString stringWithFormat:@"%@?media=music&entity=song&term=%@&artistTerm=%@&songTerm=%@&limit=1&country=US", baseURLString, searchTerm, self.artistName, self.songName];
    
    // must change spaces to +
    searchUrlString = [searchUrlString stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    //make it a URL
    searchUrlString = [searchUrlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* searchUrl = [NSURL URLWithString:searchUrlString];
    
    // start the Link Maker search
    NSURLRequest* request = [NSURLRequest requestWithURL:searchUrl];
    self.isSearching = YES;
    NSLog(@"Start");
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[HighscoreCell sOperationQueue]
                           completionHandler:^(NSURLResponse * response, NSData * data, NSError * error) {
        if(error != nil) {
            NSLog(@"Error:%@", error);
        } else {
            NSError* jsonError = nil;
            NSDictionary* dict = [NSJSONSerialization JSONObjectWithData:data options:0 error:&jsonError];
            if(jsonError != nil) {
                // do something with the error here
                NSLog(@"JSON Error: %@", jsonError);
            } else {
                NSArray* resultsArray = dict[@"results"];
                self.isSearching = NO;
                // it is possible to get no results. Handle that here
                if(resultsArray.count == 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [self showErrorMessage:@"No results"
                                     withColor:defaultErrorMessageColor];
                    });
                } else {
                    // extract the needed info to pass to the iTunes store search
                    [self showSuccessMessage:@"Song Found!"];
                    NSDictionary* trackDict = resultsArray[0];
                    NSString* trackViewUrlString = trackDict[@"trackViewUrl"];
                    if(trackViewUrlString.length == 0) {
                        NSLog(@"No trackViewUrl");
                    } else {
                        NSURL* trackViewUrl = [NSURL URLWithString:trackViewUrlString];
                        NSLog(@"trackViewURL:%@", trackViewUrl);
                        
                        // dispatch the call to switch to the iTunes store with the proper search url
                        dispatch_async(dispatch_get_main_queue(), ^{
                            [[UIApplication sharedApplication] openURL:trackViewUrl];
                        });
                    }
                }
            }
        }
    }];
    
}

- (void)setProfileName:(NSString *)profileName {
    // REQUIRES: self != nil
    // MODIFIES: self.profileName
    // EFFECTS: Override the SETTER method for profile name
    
    _profileName = profileName;
    [profileNameLabel setText:_profileName];
}

- (void)setProfilePictureUrl:(NSURL *)profilePictureUrl {
    // REQUIRES: self != nil
    // MODIFIES: self.profilePictureUrl
    // EFFECTS: Override the SETTER method for profile picture url. Load the profile picture
    
    _profilePictureUrl = profilePictureUrl;
    [profileImageView setImageWithURL:profilePictureUrl
                     placeholderImage:[Utilities loadImageWithName:@"level1-artwork"]];
}

- (void)setScore:(CGFloat)score {
    // REQUIRES: self != nil
    // MODIFIES: self.score
    // EFFECTS: Override the SETTER method for score
    
    _score = score;
    [scoreLabel setText:[NSString stringWithFormat:@"Score: %.0f", score]];
}

- (void)setSongName:(NSString *)songName {
    // REQUIRES: self != nil
    // MODIFIES: self.songName
    // EFFECTS: Override the SETTER method for song name
    
    _songName = songName;
    [songNameLabel setText:[NSString stringWithFormat:@"Song name: %@", songName]];
}

- (void)hideRequestSongButton {
    // REQUIRES: self != nil
    // EFFECTS: Hides the request song button in this cell
    
    requestButton.hidden = YES;
}

static NSOperationQueue * operationQueue;
+ (NSOperationQueue *)sOperationQueue {
    if(!operationQueue) {
        operationQueue = [[NSOperationQueue alloc] init];
    }
    return operationQueue;
}

@end
