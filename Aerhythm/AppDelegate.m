#import "AppDelegate.h"
#import "GameController.h"
#import "PlayScene.h"
#import "MenuController.h"
#import "FacebookHelper.h"
#import "AerhythmNavigationController.h"
#import "SongRequest.h"
#import "Connectivity.h"
#import "GameStatisticsManager.h"

#import <AVFoundation/AVFoundation.h>
#import <Parse/Parse.h>

static NSString * const kParseAppId = @"VnDOrmLKyCUtOD8loWOVbndHhQq6cy9H0IW85hBs";
static NSString * const kParseClientKey = @"c8jGZRrMDMqrW099VyqFST2YeWSYHIG7aALwpkwL";
static NSString * const kEncodeRestorationTimeKey = @"encodeRestorationTime";
static const NSTimeInterval kMaxTimeForStateRestoration = 15 * 60;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // place all initialization code here that needs to be called "before" state restoration occurs
    
    // Register Parse custom classes
    [SongRequest registerSubclass];
    
    // Use Parse
    [Parse setApplicationId:kParseAppId clientKey:kParseClientKey];
    
    // Track  Parse statistics around application opens
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    // Initialize Facebook
    [PFFacebookUtils initializeFacebook];
    
    [self startAudio];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // Place all code that should occur "after" state restoration occurs
    
    [application setStatusBarStyle:UIStatusBarStyleDefault];
    [application setStatusBarHidden:YES];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application{
    
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    //UIViewController * topController = ((UINavigationController *)self.window.rootViewController).topViewController;
    //se[topController viewDidDisappear:NO];

    // Save Parse current user data
    if ([Connectivity hasInternetConnection]) {
        [[PFUser currentUser] saveInBackground];
    } else {
        [[PFUser currentUser] saveEventually];
    }
    
    [self removeAudioMusic];
    [self stopAudio];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    [self removeAudioMusic];
    [self stopAudio];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
    [self startAudio];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
    
    // Get the facebook information if the user has logged in before
    if ([FacebookHelper hasLoggedIn]) {
        [FacebookHelper requestAndStoreCurrentUserInfoWithCompletionHandler:^(FBRequestConnection * connection,
                                                                              id result, NSError * error) {
            [GameStatisticsManager loadUserGameStatistics];
        }];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
}

// Variables to check whether the shared audio session is active or not
static BOOL isAudioSessionActive = NO;

- (void)startAudio {
    // EFFECTS: Re-enable the audio session
    
    // Get the shared audio session
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    NSError *error = nil;
    
    if (audioSession.otherAudioPlaying) { // check if there is any other current audio playing
        [audioSession setCategory: AVAudioSessionCategoryAmbient error:&error];
    } else {
        [audioSession setCategory: AVAudioSessionCategorySoloAmbient error:&error];
    }
    
    // Activate the audio session
    if (!error) {
        [audioSession setActive:YES error:&error];
        isAudioSessionActive = YES;
    }
    
    AerhythmNavigationController *navigationController =(AerhythmNavigationController *)self.window.rootViewController;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        [navigationController configMusicFor:navigationController.topViewController];
    });
}

- (void)removeAudioMusic {
    // EFFECTS: Remove the currently playing music audio in the game if exists
    
    UIViewController * currentController = ((UINavigationController *)self.window.rootViewController).visibleViewController;
    if([currentController isKindOfClass:[GameController class]]) {
        // currently in-game
        GameController * gameController = (GameController *)currentController;
        SKView *currentView = (SKView *)gameController.view;
        
        // Setup the pause view to be seen when the player enter games later
        if(currentView.scene != nil && [currentView.scene isKindOfClass:[PlayScene class]]){
            PlayScene * currentScene = (PlayScene *)currentView.scene;
            [gameController setupPauseView];
            [gameController.pauseView setHidden:NO];
            // Pause game before entering background
            [currentScene pauseGameForBackground];
        }
    }
    
    // Stop background music if exists
    AerhythmNavigationController *navigationController = (AerhythmNavigationController *)self.window.rootViewController;
    [navigationController stopMusic];
}

- (void)stopAudio {
    // EFFECTS: Stop the audio session if it is currently active
    
    if (!isAudioSessionActive) { // not active
        return;
    }
    
    // Get the shared audio session
    AVAudioSession * audioSession = [AVAudioSession sharedInstance];
    NSError * error = nil;
    
    // Stop the audio session recursively until there is no more error
    [audioSession setActive:NO error:&error];
    if (error) {
        [self stopAudio];
    } else {
        isAudioSessionActive = NO;
    }
}

// For Facebook Authentication
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation
{
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

#pragma mark - State Preservation and Restoration
// For state preservation and restoration
- (BOOL)application:(UIApplication *)application shouldRestoreApplicationState:(NSCoder *)coder {
    // EFFECTS: Checks if we should opt-in for state restoration
    
    NSTimeInterval storedTimeSeconds = (NSTimeInterval)[coder decodeDoubleForKey:kEncodeRestorationTimeKey];
    NSTimeInterval currentSeconds = [[NSDate date] timeIntervalSince1970];
    if (currentSeconds - storedTimeSeconds < kMaxTimeForStateRestoration) {
        return YES;
    }
    return NO;
}

- (BOOL)application:(UIApplication *)application shouldSaveApplicationState:(NSCoder *)coder {
    // EFFECTS: Checks if we should opt-in for state preservation
    
    UIViewController * topController = ((UINavigationController *)self.window.rootViewController).topViewController;
    if ([topController isKindOfClass:[MenuController class]]) {
        // Not preserve this application state
        return NO;
    }
    
    return YES;
}

- (void)application:(UIApplication *)application willEncodeRestorableStateWithCoder:(NSCoder *)coder
{
    // EFFECTS: Encodes any state at the app delegate level
    
    // Store the date
    NSDate * currentDate = [NSDate date];
    NSTimeInterval seconds = [currentDate timeIntervalSince1970];
    [coder encodeDouble:(double)seconds forKey:kEncodeRestorationTimeKey];
    
    // For testing
    NSLog(@"Encoding state");
}

- (void)application:(UIApplication *)application didDecodeRestorableStateWithCoder:(NSCoder *)coder {
    // EFFECTS: Decodes any state at the app delegate level
    
    // For testing
    NSLog(@"Restored app state");
}

@end
