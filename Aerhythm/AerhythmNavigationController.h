#import <UIKit/UIKit.h>

@interface AerhythmNavigationController : UINavigationController
// OVERVIEW: This is the navigation controller used to navigate between the view controllers in Aerhythm

- (void) stopMusic;
// REQUIRES: self != nil
// EFFECTS: Stop the background music

- (void) configMusicFor:(UIViewController *)viewController;
// REQUIRES: self != nil
// EFFECTS: Config the background music according to the given view controller

-(void) displayProgressCompleteForPurpose:(BOOL)isUploadingPurpose;
// REQUIRES: self != nil
// EFFECTS: Display message showing that the uploading or downloading progress is complete

@end
