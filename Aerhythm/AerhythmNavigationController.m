#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AerhythmNavigationController.h"
#import "FadeUnwindSegue.h"
#import "GameController.h"
#import "EndGameController.h"
#import "MenuController.h"
#import "Utilities.h"

#define kUploadCompleteMessage @"Upload Complete"
#define kDownloadCompleteMessage @"Download Complete"

@interface AerhythmNavigationController() <AVAudioPlayerDelegate>

@end

@implementation AerhythmNavigationController{
    // The query used for querying music track from library
    MPMediaQuery *mediaQuery;
    // The current track used for playing background music
    MPMediaItem *currentBackgroundTrack;
    // The audio player
    AVAudioPlayer *currentPlayer;
    // The last time played of the current track before being paused
    NSTimeInterval lastTime;
}

- (UIStoryboardSegue *)segueForUnwindingToViewController:(UIViewController *)toViewController fromViewController:(UIViewController *)fromViewController identifier:(NSString *)identifier {
    // EFFECTS: Setup the unwind segue for every unwind segue to be from FadeUnwindSegue class
    
    FadeUnwindSegue *segue = [[FadeUnwindSegue alloc] initWithIdentifier:identifier source:fromViewController destination:toViewController];
    return segue;
}

-(void) pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    // REQUIRES: self != nil
    // EFFECTS: Push the given view controller, setup the background music according to this view controller
    
    [super pushViewController:viewController animated:animated];
    [self configMusicFor:viewController];
}

-(NSArray *) popToViewController:(UIViewController *)viewController animated:(BOOL)animated{
    // REQUIRES: self != nil
    // EFFECTS: Pop to a given view controller, setup the background music according to this view controller
    
    [self configMusicFor:viewController];
    return [super popToViewController:viewController animated:animated];
}

-(void) displayProgressCompleteForPurpose:(BOOL)isUploadingPurpose{
    // REQUIRES: self != nil
    // EFFECTS: Display message showing that the uploading or downloading progress is complete
    
    UIViewController *topViewController = self.topViewController;
    if(isUploadingPurpose == YES){
        [Utilities showProgressComplete:kUploadCompleteMessage inView:topViewController.view];
    } else {
        [Utilities showProgressComplete:kDownloadCompleteMessage inView:topViewController.view];
    }
}

-(void) configMusicFor:(UIViewController *)viewController{
    // REQUIRES: self != nil
    // EFFECTS: Config the background music according to the given view controller
    
    if([viewController isKindOfClass:[GameController class]] || [viewController isKindOfClass:[EndGameController class]]){
        [self stopMusic];
        currentBackgroundTrack = nil;
        lastTime = 0.0;
    } else {
        [self play];
        if([viewController isKindOfClass:[MenuController class]]){
            NSString *songName = [currentBackgroundTrack valueForProperty:MPMediaItemPropertyTitle];
            NSString *artistName = [currentBackgroundTrack valueForProperty:MPMediaItemPropertyArtist];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                [Utilities showBackgroundSongInfo:songName andArtist:artistName inView:viewController.view];
            });
        }
    }
}

-(void) play{
    // REQUIRES: self != nil
    // EFFECTS: Start playing background music
    
    if(currentPlayer == nil){
        if(currentBackgroundTrack == nil){
            [self getRandomTrack];
        }
        NSURL *trackURL = [currentBackgroundTrack valueForProperty:MPMediaItemPropertyAssetURL];
        currentPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:trackURL error:nil];
        currentPlayer.delegate = self;
        currentPlayer.pan = 0.0;
        [currentPlayer prepareToPlay];
        currentPlayer.currentTime = lastTime;
        [currentPlayer play];
    }
}

-(void) stopMusic{
    // REQUIRES: self != nil
    // EFFECTS: Stop the background music
    
    if(currentPlayer != nil){
        lastTime = currentPlayer.currentTime;
    }
    currentPlayer = nil;
}

-(void) getRandomTrack{
    // REQUIRES: self != nil
    // EFFECTS: Retrieve a random track in the music library
    
    // Check if we can re-use an MPMediaQuery
    if (mediaQuery == nil){
        mediaQuery = [[MPMediaQuery alloc] init];
    }
    
    // Get all Media Items into an Array (Fast)
    NSArray *allTracks = [mediaQuery items];
    // Check we have enough Tracks for a Random Choice
    if ([allTracks count] < 2){
        currentBackgroundTrack = nil;
        return;
    }
    // Pick Random Track
    int trackNumber = arc4random() % [allTracks count];
    currentBackgroundTrack = [allTracks objectAtIndex:trackNumber];
}

#pragma mark - AVAudioPlayer Delegate
-(void) audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag{
    // EFFECTS: Remove the current track when it is finished and replace with a new random track
    
    if(currentPlayer == player){
        [self stopMusic];
        currentBackgroundTrack = nil;
        lastTime = 0.0;
        [self configMusicFor:self.topViewController];
    }
}
@end
