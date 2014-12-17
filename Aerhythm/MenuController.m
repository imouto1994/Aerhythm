#import "MenuController.h"
#import "FacebookHelper.h"
#import "Utilities.h"
#import "Connectivity.h"
#import "MailController.h"
#import "MDRadialProgressView.h"
#import "AerhythmNavigationController.h"
#import "GameStatisticsManager.h"
#import <QuartzCore/QuartzCore.h>

#define kLoggedIn 0
#define kWaitForLogIn 1
#define kAskForLogInAlertTag 7

@interface MenuController () <UIAlertViewDelegate>

@end

@implementation MenuController {
    // The view for background image
    UIImageView *backgroundImageView;
    // Progress view for uploading and downloading
    MDRadialProgressView *progressView;
    // Latest progress percentage
    int currentProgress;
    // The purpose for the current background purpose
    BOOL isUploadingPurpose;
}

-(void) viewDidLoad{
    [super viewDidLoad];
    currentProgress = -1;
    isUploadingPurpose = YES;
}

- (void)viewWillAppear:(BOOL)animated{
    // MODIFIES: self
    // EFFECTS: Setup the menu screen for every time it appears
    
    [super viewWillAppear:animated];
    
    // Setup buttons in the screen
    UIImage *startButtonImage = [Utilities loadImageWithName:@"startButton"];
    UIImage *designLevelButtonImage = [Utilities loadImageWithName:@"designButton"];
    UIImage *upgradeButtonImage = [Utilities loadImageWithName:@"upgradeButton"];
    UIImage *mailButtonImage = [Utilities loadImageWithName:@"mailIcon"];
    UIImage *infoButtonImage = [Utilities loadImageWithName:@"infoIcon"];
    [self.startButton setImage:startButtonImage forState:UIControlStateNormal];
    [self.designLevelButton setImage:designLevelButtonImage forState:UIControlStateNormal];
    [self.upgradeButton setImage:upgradeButtonImage forState:UIControlStateNormal];
    [self.mailButton setImage:mailButtonImage forState:UIControlStateNormal];
    [self.infoButton setImage:infoButtonImage forState:UIControlStateNormal];
    
    // Setup background
    UIImage *background = [Utilities loadImageWithName:@"menuScreen"];
    backgroundImageView = [[UIImageView alloc] initWithImage:background];
    [backgroundImageView setFrame:CGRectMake(0, 0, 768, 1024)];
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];
    
    // Setup social / login button
    if ([FacebookHelper hasLoggedIn]) {
        [self updateSocialButtonWithState:kLoggedIn];
        // Check if the session is still valid
        if ([Connectivity hasInternetConnection]) {
            FBRequest * fbRequest = [FBRequest requestForMe];
            [fbRequest startWithCompletionHandler:^(FBRequestConnection * connection, id result, NSError * error) {
                if (!error) {
                    // Logged in
                    return;
                }
                
                if ([error.userInfo[FBErrorParsedJSONResponseKey][@"body"][@"error"][@"type"]
                     isEqualToString:@"OAuthException"]) {
                    // Invalid session
                    [self updateSocialButtonWithState:kWaitForLogIn];
                    
                    // Pop up alert to ask users to log in again
                    UIAlertView * askForLoginAlert = [[UIAlertView alloc]
                                                      initWithTitle:@"Facebook Session"
                                                      message:@"Your Facebook session is invalidated. Please log in again"
                                                      delegate:self
                                                      cancelButtonTitle:@"Cancel"
                                                      otherButtonTitles:@"Log In", nil];
                    askForLoginAlert.tag = kAskForLogInAlertTag;
                    [askForLoginAlert show];
                }
            }];
        }
    } else {
        [self updateSocialButtonWithState:kWaitForLogIn];
    }
    
    progressView = [[MDRadialProgressView alloc] initWithFrame:CGRectMake(687, 942, 70, 70)];
	progressView.progressTotal = 100;
    progressView.progressCounter = (currentProgress == -1) ? 0 : currentProgress;
    progressView.backgroundColor = [UIColor clearColor];
    progressView.theme.thickness = 70.0;
	progressView.theme.incompletedColor = [UIColor colorWithRed:0.65 green:0.65 blue:0.65 alpha:0.8];
    progressView.theme.completedColor = [UIColor clearColor];
	progressView.theme.centerColor = [UIColor clearColor];
    progressView.theme.sliceDividerThickness = 0.0;
    progressView.theme.sliceDividerColor = [UIColor clearColor];
	progressView.theme.sliceDividerHidden = NO;
    progressView.hidden = currentProgress == -1;
    [self.view addSubview:progressView];
    [self.view bringSubviewToFront:self.mailButton];
}

- (void)viewDidDisappear:(BOOL)animated{
    // MODIFIES: self
    // EFFECTS: Remove unnecessary things when the menu screen disappears
    
    [super viewDidDisappear:animated];
    
    // Release the background image view
    [backgroundImageView removeFromSuperview];
    backgroundImageView = nil;
    
    [self.view.layer removeAllAnimations];
    
    [progressView removeFromSuperview];
    progressView = nil;
    
    // Release the image representations for the buttons
    [self.startButton setImage:nil forState:UIControlStateNormal];
    [self.upgradeButton setImage:nil forState:UIControlStateNormal];
    [self.loginButton setImage:nil forState:UIControlStateNormal];
    [self.mailButton setImage:nil forState:UIControlStateNormal];
    [self.infoButton setImage:nil forState:UIControlStateNormal];
}


- (IBAction)mailButtonTapped:(UIButton *)sender {
    // REQUIRES: self != nil
    // EFFECTS: Handler method to open the "Notification" modal popup screen
    if(![Connectivity hasInternetConnection]){
        CGRect mailButtonFrame = self.mailButton.frame;
        CGRect originalFrame = CGRectMake(mailButtonFrame.origin.x, mailButtonFrame.origin.y + 30, 100, 30);
        [Utilities showMessage:@"No Wi-fi" withColor:[UIColor whiteColor] andSize:23 fromOriginalFrame:originalFrame withOffsetX:-100 andOffsetY:0 inView:self.view withDuration:0.5];
        return;
    }
    
    // Check for facebook login
    if(![FacebookHelper hasLoggedIn]){
        CGRect mailButtonFrame = self.mailButton.frame;
        CGRect originalFrame = CGRectMake(mailButtonFrame.origin.x, mailButtonFrame.origin.y + 30, 150, 30);
        [Utilities showMessage:@"Not logged in" withColor:[UIColor whiteColor] andSize:23 fromOriginalFrame:originalFrame withOffsetX:-140 andOffsetY:0 inView:self.view withDuration:0.5];
        return;
    }
    
    // Check for current background progress
    if(currentProgress != -1){
        CGRect mailButtonFrame = self.mailButton.frame;
        CGRect originalFrame = CGRectMake(mailButtonFrame.origin.x, mailButtonFrame.origin.y + 30, 180, 30);
        NSString *message = (isUploadingPurpose) ? @"Uploading..." : @"Downloading...";
        [Utilities showMessage:message withColor:[UIColor whiteColor] andSize:23 fromOriginalFrame:originalFrame withOffsetX:-160 andOffsetY:0 inView:self.view withDuration:0.8];
        return;
    }
    
    // Show the notification screen
    MailController *mailController = [[MailController alloc] init];
    mailController.modalPresentationStyle = UIModalPresentationFormSheet;
    mailController.parentDelegate = self;
    [self presentViewController:mailController animated:YES completion:nil];
}

-(IBAction)unwindToMenuScreen:(UIStoryboardSegue *)sender{
    // REQUIRES: self != nil
    // EFFECTS: Handler method to enable other view controllers to unwind back to this view controller
    
}

- (void)updateSocialButtonWithState:(NSUInteger)stateTag {
    // REQUIRES: self != nil
    // EFFECTS: Updates the view and state of the Facebook login button based on the input state
    
    // Log out state
    if (stateTag == kWaitForLogIn) {
        self.loginButton.tag = kWaitForLogIn;
        UIImage * loginImage = [Utilities loadImageWithName:@"loginButton"];
        [self.loginButton setImage:loginImage forState:UIControlStateNormal];
        return;
    }
    
    // Log in state
    if (stateTag == kLoggedIn) {
        self.loginButton.tag = kLoggedIn;
        UIImage * logoutImage = [Utilities loadImageWithName:@"logoutButton"];
        [self.loginButton setImage:logoutImage forState:UIControlStateNormal];
        return;
    }
}

- (IBAction)socialButtonTouchHandler:(id)sender {
    // REQUIRES: self != nil
    // EFFECTS: Handler method for Facebook Login and Logout
    
    if (sender != self.loginButton) {
        return;
    }
    
    // Start log in
    if (self.loginButton.tag == kWaitForLogIn) {
        [self loginFacebook];
        return;
    }
    
    // Start log out
    if (self.loginButton.tag == kLoggedIn) {
        [self logoutFacebook];
        return;
    }
}

- (void)loginFacebook{
    // REQURIES: self != nil
    // EFFECTS: Handles Facebook login and authentication
    
    // No internet connection
    if(![Connectivity hasInternetConnection]){
        CGRect originalFrame = CGRectMake(380, 650, 300, 100);
        [Utilities showMessage:@"No Wi-fi" withColor:[UIColor whiteColor] andSize:23 fromOriginalFrame:originalFrame withOffsetX:100 andOffsetY:0 inView:self.view withDuration:0.5];
        return;
    }
    
    // The permissions requested from the user
    NSArray * permissionsArray =[Constant getAppDefaultFacebookPermissions];
    
    // Login PFUser using Facebook
    [PFFacebookUtils logInWithPermissions:permissionsArray block:^(PFUser * user, NSError * error) {
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
            // Log in successful
            [self updateSocialButtonWithState:kLoggedIn];
            
            [FacebookHelper requestAndStoreCurrentUserInfoWithCompletionHandler:
             ^(FBRequestConnection * connection, id result, NSError * error) {
                 [GameStatisticsManager loadUserGameStatistics];
             }];
        }
    }];
}

- (void)logoutFacebook{
    // REQURIES: self != nil
    // EFFECTS: Handles Facebook logout
    
    [PFUser logOut];
    [self updateSocialButtonWithState:kWaitForLogIn];
}

#pragma mark - UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (alertView.tag != kAskForLogInAlertTag) {
        return;
    }
    
    if (buttonIndex != alertView.cancelButtonIndex) {
        [self loginFacebook];
    }
}

#pragma mark - Song Request Protocol Delegate
-(void) displayProgress:(int)percent forPurpose:(BOOL)purpose{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if(percent == 100){
            progressView.progressCounter = 0;
            currentProgress = -1;
            progressView.hidden = YES;
            AerhythmNavigationController *navigationController = (AerhythmNavigationController *)self.navigationController;
            [navigationController displayProgressCompleteForPurpose:isUploadingPurpose];
            return;
        }
        
        currentProgress = percent;
        isUploadingPurpose = purpose;
        if(progressView != nil){
            progressView.hidden = NO;
            progressView.progressCounter = percent;
        }
    });
}

#pragma mark - State Preservation and Restoration

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder {
    // EFFECTS: Encodes retorable state information of this view controller
    
    [super encodeRestorableStateWithCoder:coder];
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder{
    // EFFECTS: Decodes retorable state information of this view controller
    
    [super decodeRestorableStateWithCoder:coder];
}

@end
