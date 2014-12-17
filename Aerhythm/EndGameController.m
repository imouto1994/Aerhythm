#import "EndGameController.h"
#import "Utilities.h"
#import "Connectivity.h"
#import <Social/Social.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "HighscoreCell.h"
#import "EndGameController+BackendData.h"
#import "FacebookHelper+Aerhythm.h"

#define kNumTopHighScoreDisplayed 10
#define kAlertTagForLogIn 1
#define kAlertTagForPublishPermission 2

static NSString * const kHighScoreCellId = @"Cell_Identifier";
static NSString * const kEndGameStatRestorationKey = @"endGameStatistics";
static NSString * const kWorldRankingFlagRestorationKey = @"showWorldRanking";
static NSString * const kAchievementRestorationKey = @"endGameAchievements";

@interface EndGameController()

@end

@implementation EndGameController{
    // The view for background image
    UIImageView *backgroundImageView;
    // The top bar for the table
    UIImageView *topBarView;
    // The bottom bar for the table
    UIImageView *bottomBarView;
    // The wifi indicator
    UIImageView *noWifiIndicatorView;
    // Indicator that the game is currently posting to Facebook
    BOOL postingToFacebook;
    // Indicator that the game is currently posting to Twitter
    BOOL postingToTwitter;
    // Indicator that the game has already posted to Facebook
    BOOL postedToFacebook;
    // Indicator that the game has already posted to Twitter
    BOOL postedToTwitter;
    // Indicator that whether the highscore table is showing world ranking or not
    BOOL showWorldRanking;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.highscoreTable.delegate = self;
    self.highscoreTable.dataSource = self;
    [self.highscoreTable registerClass:[HighscoreCell class] forCellReuseIdentifier:kHighScoreCellId];
    
    // Setup table bar
    topBarView = [[UIImageView alloc] init];
    [topBarView setFrame:CGRectMake(0, 435, 768, 31)];
    [self.view addSubview:topBarView];
    [self.view bringSubviewToFront:topBarView];
    bottomBarView = [[UIImageView alloc] init];
    [bottomBarView setFrame:CGRectMake(0, 825, 768, 31)];
    [self.view addSubview:bottomBarView];
    [self.view bringSubviewToFront:bottomBarView];
    
    // Setup score label
    self.scoreLabel.font = [UIFont fontWithName:@"Futura (Light)" size:60];
    
    postingToFacebook = NO;
    postingToTwitter = NO;
    postedToFacebook = NO;
    postedToFacebook = NO;
    
    showWorldRanking = YES;
    // Parse
    self.highscorePlayerList = nil;
    self.worldHighscorePlayerList = nil;
    self.friendHighscorePlayerList = nil;
    BOOL hasInternetConnection = [Connectivity hasInternetConnection];
    if (self.gameStatistics && hasInternetConnection) {
        [self storeGameStatisticsToParse];
        // Download top score
        [self getAndDisplayWorldTopPlayers:kNumTopHighScoreDisplayed];
    } else if(!hasInternetConnection) {
        [self indicateNoWifi];
    }
}

- (void) indicateNoWifi{
    UIImage *noWifiIndicatorImage = [Utilities loadImageWithName:@"noWifiIcon"];
    noWifiIndicatorView = [[UIImageView alloc] init];
    [noWifiIndicatorView setImage:noWifiIndicatorImage];
    [noWifiIndicatorView setFrame:CGRectMake(300, 512, 187, 187)];
    [self.view addSubview:noWifiIndicatorView];
}

- (void)viewWillAppear:(BOOL)animated {
    // MODIFIES: self
    // EFFECTS: Setup the end game screen for every time it appears
   
    [super viewWillAppear:animated];
    
    // Setup the background image view
    UIImage *background = [[UIImage alloc] initWithContentsOfFile:
                           [[NSBundle mainBundle] pathForResource:@"endGameScreen" ofType:@"png"]];
    backgroundImageView = [[UIImageView alloc] initWithImage:background];
    [backgroundImageView setFrame:CGRectMake(0, 0, 768, 1024)];
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];
    
    // Setup bar view
    UIImage *barImage = [[UIImage alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"tableBar" ofType:@"png"]];
    [topBarView setImage:barImage];
    [bottomBarView setImage:barImage];
    
    // Setup button view representation
    UIImage *retryImage = [Utilities loadImageWithName:@"endRetryButton"];
    [self.retryButton setImage:retryImage forState:UIControlStateNormal];
    
    UIImage *menuImage = [Utilities loadImageWithName:@"endMenuButton"];
    [self.menuButton setImage:menuImage forState:UIControlStateNormal];
    
    UIImage *songImage = [Utilities loadImageWithName:@"endSongButton"];
    [self.songButton setImage:songImage forState:UIControlStateNormal];
    
    UIImage *levelImage = [Utilities loadImageWithName:@"endLevelButton"];
    [self.levelButton setImage:levelImage forState:UIControlStateNormal];
    
    UIImage *modelImage = [Utilities loadImageWithName:@"endModelButton"];
    [self.modelButton setImage:modelImage forState:UIControlStateNormal];
    
    UIImage *facebookImage = [Utilities loadImageWithName:@"endFbButton"];
    [self.facebookButton setImage:facebookImage forState:UIControlStateNormal];
    
    UIImage *twitterImage = [Utilities loadImageWithName:@"endTwitterButton"];
    [self.twitterButton setImage:twitterImage forState:UIControlStateNormal];
    
    if(showWorldRanking){
        UIImage *globalImage = [Utilities loadImageWithName:@"endWorldIcon"];
        [self.globalButton setImage:globalImage forState:UIControlStateNormal];
        UIImage *friendDisableImage = [Utilities loadImageWithName:@"endFriendIconDisable"];
        [self.friendButton setImage:friendDisableImage forState:UIControlStateNormal];
        [self.view bringSubviewToFront:self.globalButton];
        [self.view bringSubviewToFront:self.friendButton];
        [self showGlobalTableMessage];
    } else {
        UIImage *globalDisableImage = [Utilities loadImageWithName:@"endWorldIconDisable"];
        [self.globalButton setImage:globalDisableImage forState:UIControlStateNormal];
        UIImage *friendImage = [Utilities loadImageWithName:@"endFriendIcon"];
        [self.friendButton setImage:friendImage forState:UIControlStateNormal];
        [self.view bringSubviewToFront:self.friendButton];
        [self.view bringSubviewToFront:self.globalButton];
        [self showFriendTableMessage];
        
    }
    self.scoreLabel.text = [NSString stringWithFormat:@"%.0f",self.gameStatistics.score];
    [self setupAchievements];
}

- (void) setupAchievements{
    // REQUIRES: self != nil
    // MODIFIES: self
    // EFFECTS: Setup the achievement displays for the end game screen
    
    // Setup enemy achievement
    self.enemyLabel.text = [NSString stringWithFormat:@"Enemy: %ld / %ld ", (long)self.gameAchievements.enemyKilled, (long)self.gameAchievements.totalEnemy];
    [self setStatusForLabel:self.enemyLabel withScore:[self.gameAchievements scoreForKillEnemyAchievement]];
    
    // Setup health achievement
    self.healthLabel.text = [NSString stringWithFormat:@"Health: %.0f / %.0f ", self.gameAchievements.finalHealth, self.gameAchievements.originalHealth];
    [self setStatusForLabel:self.healthLabel withScore:[self.gameAchievements scoreForHealthAchievement]];
    
    // Setup for time achievement
    NSInteger minute = (long)(self.gameAchievements.timePlayed / 60);
    NSInteger second = (long)(self.gameAchievements.timePlayed - minute * 60);
    self.timeLabel.text = [NSString stringWithFormat:@"Time: %ld:%02ld ", (long)minute, (long)second];
    [self setStatusForLabel:self.timeLabel withScore:[self.gameAchievements scoreForTimeAchievement]];
    
    // Setup for boss achievement
    self.killBossLabel.text = @"Kill Boss ";
    [self setStatusForLabel:self.killBossLabel withScore:[self.gameAchievements scoreForKillBossAchievement]];
    
    // Setup for no revival achievement
    self.noRevivalLabel.text = @"No Revival ";
    [self setStatusForLabel:self.noRevivalLabel withScore:[self.gameAchievements scoreForKillBossWithoutRevival]];
}

-(void) setStatusForLabel:(UILabel *)label withScore:(CGFloat) score{
    if(score != 0){
        NSInteger gainedScore = (long)score;
        [self appendBonusScore:gainedScore forLabel:label];
        [self setTextSuccessColor:label];
    } else {
        [self setTextFailColor:label];
    }
}

- (void) setTextSuccessColor:(UILabel *) label{
    label.textColor = [UIColor colorWithRed:0.0 green:167 / 255.0 blue:21 / 255.0 alpha:1.0];
}

- (void) appendBonusScore:(NSInteger) score forLabel:(UILabel *)label{
    label.text = [label.text stringByAppendingString:[NSString stringWithFormat:@"+%ld", (long)score]];
}

-(void) setTextFailColor:(UILabel *) label{
    label.textColor = [UIColor colorWithRed:202 / 255.0 green:44 / 255.0 blue:2 / 255.0 alpha:1.0];
}

- (void)viewDidDisappear:(BOOL)animated {
    // MODIFIES: self
    // EFFECTS: Remove unnecessary things when the end game screen disappears
    
    [super viewDidDisappear:animated];
    
    // Release the background image view
    [backgroundImageView removeFromSuperview];
    backgroundImageView = nil;
    
    [topBarView setImage:nil];
    [bottomBarView setImage:nil];
    
    if(noWifiIndicatorView != nil){
        [noWifiIndicatorView removeFromSuperview];
        noWifiIndicatorView = nil;
    }
    
    // Remove image representation for the buttons
    [self.retryButton setImage:nil forState:UIControlStateNormal];
    [self.menuButton setImage:nil forState:UIControlStateNormal];
    [self.songButton setImage:nil forState:UIControlStateNormal];
    [self.levelButton setImage:nil forState:UIControlStateNormal];
    [self.modelButton setImage:nil forState:UIControlStateNormal];
    [self.facebookButton setImage:nil forState:UIControlStateNormal];
    [self.twitterButton setImage:nil forState:UIControlStateNormal];
    [self.globalButton setImage:nil forState:UIControlStateNormal];
    [self.friendButton setImage:nil forState:UIControlStateNormal];
}

- (IBAction)postScoreToFB:(UIButton *)sender {
    CGRect fbButtonFrame = [self.facebookButton frame];
    CGRect originalFrame = CGRectMake(fbButtonFrame.origin.x - 50, fbButtonFrame.origin.y, 200, 40);
    if(![Connectivity hasInternetConnection]){
        [Utilities showMessage:@"No Wi-fi"
                     withColor:[UIColor colorWithRed:202/255.0 green:44/255.0 blue:2/255.0 alpha:1.0]
                       andSize:25
             fromOriginalFrame:originalFrame
                   withOffsetX:0
                    andOffsetY:-30
                        inView:self.view
                  withDuration:0.5];
        return;
    }
    
    if (![FacebookHelper hasLoggedIn]) {
        NSString * message = @"Please log in to Facebook before sharing score.";
        UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Facebook Login"
                                                              message:message
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                                    otherButtonTitles:@"Log In", nil];
        errorAlert.tag = kAlertTagForLogIn;
        [errorAlert show];
        return;
    }
    
    if (![FacebookHelper hasPublishPermission]) {
        NSString * message = @"Aerhythm needs your permission to publish score.";
        UIAlertView * errorAlert = [[UIAlertView alloc] initWithTitle:@"Publish Permission"
                                                              message:message
                                                             delegate:self
                                                    cancelButtonTitle:@"Cancel"
                                                    otherButtonTitles:@"Allow", nil];
        errorAlert.tag = kAlertTagForPublishPermission;
        [errorAlert show];
        return;
    }
    
    if (postedToFacebook) {
        [Utilities showMessage:@"Already Posted"
                     withColor:[UIColor colorWithRed:202/255.0 green:44/255.0 blue:2/255.0 alpha:1.0]
                       andSize:25
             fromOriginalFrame:originalFrame
                   withOffsetX:0
                    andOffsetY:-30
                        inView:self.view
                  withDuration:0.5];
        return;
    }
    
    if (postingToFacebook) {
        // Tell user to wailt
        [Utilities showMessage:@"Posting..."
                     withColor:[UIColor colorWithRed:202/255.0 green:44/255.0 blue:2/255.0 alpha:1.0]
                       andSize:25
             fromOriginalFrame:originalFrame
                   withOffsetX:0
                    andOffsetY:-30
                        inView:self.view
                  withDuration:0.5];
        
        return;
    }
    
    [self postScoreToFB];
}

- (void)postScoreToFB {
    CGRect fbButtonFrame = [self.facebookButton frame];
    CGRect originalFrame = CGRectMake(fbButtonFrame.origin.x - 50, fbButtonFrame.origin.y, 200, 40);
    
    postingToFacebook = YES;
    
    [FacebookHelper postToCurrentUserWallWithLevelStatistics:self.gameStatistics
                                        andCompletionHandler:^(FBRequestConnection * connection, id result, NSError * error) {
                                            postingToFacebook = NO;
                                            if (error) {
                                                NSString * errorMessage = @"Please try again later.";
                                                NSString * errorTitle = @"Facebook Sharing Error";
                                                
                                                if ([FBErrorUtility shouldNotifyUserForError:error]) {
                                                    errorTitle = @"Facebook Error";
                                                    errorMessage = [FBErrorUtility userMessageForError:error];
                                                } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryAuthenticationReopenSession) {
                                                    errorTitle = @"Session Error";
                                                    errorMessage = @"Your current session is no longer valid. Please log in again.";
                                                } else if ([FBErrorUtility errorCategoryForError:error] == FBErrorCategoryUserCancelled) {
                                                    return;
                                                }
                                                
                                                UIAlertView * errorAlert = [[UIAlertView alloc]
                                                                            initWithTitle:errorTitle
                                                                            message:errorMessage
                                                                            delegate:nil
                                                                            cancelButtonTitle:@"OK"
                                                                            otherButtonTitles:nil];
                                                [errorAlert show];
                                            } else {
                                                postedToFacebook = YES;
                                            }

                                        }];
    
    [Utilities showMessage:@"Posted"
                 withColor:[UIColor colorWithRed:0/255.0 green:167/255.0 blue:21/255.0 alpha:1.0]
                   andSize:25
         fromOriginalFrame:originalFrame
               withOffsetX:0
                andOffsetY:-30
                    inView:self.view
              withDuration:0.5];
}

- (IBAction)postScoreToTwitter:(UIButton *)sender {
    if (postedToTwitter) {
        // No repost
        return;
    }
    
    if (postingToTwitter) {
        // Tell user to wait
        return;
    }
    
    SLComposeViewController * tweetSheet = [SLComposeViewController
                                            composeViewControllerForServiceType:SLServiceTypeTwitter];
    if (tweetSheet) {
        postingToTwitter = YES;
        tweetSheet.completionHandler = ^(SLComposeViewControllerResult result) {
            postingToTwitter = NO;
            
            if (result == SLComposeViewControllerResultDone) {
                postedToTwitter = YES;
            } else if (result == SLComposeViewControllerResultCancelled) {
                NSLog(@"Cancel");
                postedToTwitter = NO;
            }
        };
        
        NSString * message = [NSString stringWithFormat:@"Played level %lu. Got a score of %.0lf with the song \"%@\" and model \"%@\" #Aerhythm", (unsigned long)self.gameStatistics.levelId, self.gameStatistics.score,
                              self.gameStatistics.songName, [Constant getNameOfPlayerJetWithType:self.gameStatistics.usedModelType]];
        [tweetSheet setInitialText:message];
        [self presentViewController:tweetSheet animated:NO completion:nil];
    }
}

- (IBAction)retryButtonTapped:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)friendButtonTapped:(UIButton *)sender {
    if (![FacebookHelper hasLoggedIn]) {
        CGRect originalFrame = CGRectMake(355, 395, 330, 50);
        [Utilities showMessage:@"Not logged in" withColor:[UIColor blackColor] andSize:25 fromOriginalFrame:originalFrame withOffsetX:100 andOffsetY:0 inView:self.view withDuration:0.5];
        return;
    }
    
    if (showWorldRanking) {
        UIImage *activeFriendIconImage = [Utilities loadImageWithName:@"endFriendIcon"];
        UIImage *disableGlobalIconImage = [Utilities loadImageWithName:@"endWorldIconDisable"];
        [self.friendButton setImage:activeFriendIconImage forState:UIControlStateNormal];
        [self.globalButton setImage:disableGlobalIconImage forState:UIControlStateNormal];
        [self.view bringSubviewToFront:self.globalButton];
        showWorldRanking = NO;
        self.highscorePlayerList = self.friendHighscorePlayerList;
        [self showFriendTableMessage];
        [self refreshTable];
    }
}

- (IBAction)globalButtonTapped:(UIButton *)sender {
    if (!showWorldRanking) {
        UIImage *activeGlobalIconImage = [Utilities loadImageWithName:@"endWorldIcon"];
        UIImage *disableFriendIconImage = [Utilities loadImageWithName:@"endFriendIconDisable"];
        [self.friendButton setImage:disableFriendIconImage forState:UIControlStateNormal];
        [self.globalButton setImage:activeGlobalIconImage forState:UIControlStateNormal];
        [self.view bringSubviewToFront:self.friendButton];
        showWorldRanking = YES;
        self.highscorePlayerList = self.worldHighscorePlayerList;
        [self showGlobalTableMessage];
        [self refreshTable];
    }
}

- (void) showGlobalTableMessage{
    CGRect originalFrame = CGRectMake(0, 440, 320, 50);
    [Utilities showMessage:@"GLOBAL" withColor:[UIColor blackColor] andSize:40 fromOriginalFrame:originalFrame withOffsetX:0 andOffsetY:-45 inView:self.view withDuration:0.5];
}

- (void) showFriendTableMessage{
    CGRect originalFrame = CGRectMake(455, 440, 330, 50);
    [Utilities showMessage:@"FRIEND" withColor:[UIColor blackColor] andSize:40 fromOriginalFrame:originalFrame withOffsetX:0 andOffsetY:-45 inView:self.view withDuration:0.5];

}

- (void)refreshTable {
    if(self.highscorePlayerList == nil && ![Connectivity hasInternetConnection]){
        if(noWifiIndicatorView == nil){
            [self indicateNoWifi];
        }
        return;
    }
    
    if (!self.highscorePlayerList) {
        if (showWorldRanking) {
            [self getAndDisplayWorldTopPlayers:kNumTopHighScoreDisplayed];
        } else {
            [self getAndDisplayFriendTopPlayers:kNumTopHighScoreDisplayed];
        }
    } else {
        NSLog(@"Refresh data");
        [self.highscoreTable reloadData];
    }
    
    if(noWifiIndicatorView != nil){
        [noWifiIndicatorView removeFromSuperview];
        noWifiIndicatorView = nil;
    }
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag == kAlertTagForLogIn) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            return;
        }
        
        [FacebookHelper loginFacebookWithPermissions:[Constant getAppDefaultFacebookPermissions]
                                     andSuccessBlock:^{
                                         [FacebookHelper requestAndStoreCurrentUserInfoWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                                         }];
                                         
                                         [self postScoreToFB];
                                     }];
        return;
    }
    
    if (alertView.tag == kAlertTagForPublishPermission) {
        if (buttonIndex == alertView.cancelButtonIndex) {
            return;
        }
        
        [FacebookHelper requestPublishPermissionWithSuccessBlock:^{
            [self postScoreToFB];
        }];
        
        return;
    }
}

#pragma mark - Table View Data Source Protocol

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    // EFFECTS: Return the number of rows in a specific section
    
    return [self.highscorePlayerList count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    // EFFECTS: Return the number of sections in the table view
    
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    // EFFECTS: Construct a cell according to the index path in the table view
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:kHighScoreCellId];
    if(cell == nil){
        cell = [[HighscoreCell alloc] initWithStyle:UITableViewCellStyleDefault
                                    reuseIdentifier:kHighScoreCellId];
    }
    
    HighscoreCell * scoreCell = (HighscoreCell *)cell;
    
    PFObject * topPlayer = self.highscorePlayerList[indexPath.row];
    
    scoreCell.ownerFacebookId = topPlayer[@"userId"];
    scoreCell.profileName = topPlayer[@"userName"];
    scoreCell.songName = topPlayer[@"songName"];
    scoreCell.artistName = topPlayer[@"artist"];
    scoreCell.score = (CGFloat) [topPlayer[@"score"] doubleValue];
    scoreCell.profilePictureUrl = [FacebookHelper getProfilePictureUrlWithUserId:topPlayer[@"userId"]
                                                                         andSize:kNormal];
    scoreCell.isGlobalRanked = showWorldRanking;
    
    if (!scoreCell.isGlobalRanked) {
        if ([scoreCell.ownerFacebookId isEqualToString:[FacebookHelper getCachedCurrentUserId]]) {
            [scoreCell hideRequestSongButton];
        }
    }
    
    return cell;
}

#pragma mark - State Preservation and Restoration
- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    // EFFECTS: Encodes retorable state information of this view controller
    
    [coder encodeObject:self.gameStatistics forKey:kEndGameStatRestorationKey];
    [coder encodeObject:self.gameAchievements forKey:kAchievementRestorationKey];
    [coder encodeBool:showWorldRanking forKey:kWorldRankingFlagRestorationKey];
    
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder {
    // EFFECTS: Decodes retorable state information of this view controller
    
    self.gameStatistics = [coder decodeObjectForKey:kEndGameStatRestorationKey];
    self.gameAchievements = [coder decodeObjectForKey:kAchievementRestorationKey];
    showWorldRanking = [coder decodeBoolForKey:kWorldRankingFlagRestorationKey];
    
    [self storeGameStatisticsToParse];
    // Download top score
    if (showWorldRanking) {
        [self getAndDisplayWorldTopPlayers:kNumTopHighScoreDisplayed];
    } else {
        [self getAndDisplayFriendTopPlayers:kNumTopHighScoreDisplayed];
    }
    
    [super decodeRestorableStateWithCoder:coder];
}

@end
