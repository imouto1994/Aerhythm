#import <UIKit/UIKit.h>

@interface HighscoreCell : UITableViewCell

// Facebook ID of player
@property (strong, nonatomic) NSString * ownerFacebookId;
// Profile name of player
@property (strong, nonatomic) NSString * profileName;
// Profile picture URL of player
@property (strong, nonatomic) NSURL * profilePictureUrl;
// Name of song used
@property (strong, nonatomic) NSString * songName;
// Name of artist
@property (strong, nonatomic) NSString * artistName;
// Score
@property (nonatomic) CGFloat score;
// Indicator whether this cell is in global highscore table or friend highscore table
@property (nonatomic) BOOL isGlobalRanked;

- (void)hideRequestSongButton;
// REQUIRES: self != nil
// EFFECTS: Hides the request song button in this cell

@end
