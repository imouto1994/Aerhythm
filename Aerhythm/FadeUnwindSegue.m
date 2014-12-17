#import "FadeUnwindSegue.h"

@implementation FadeUnwindSegue

- (void)perform{
    // EFFECTS: Performs the transition in a defined way
    
    // Get the view controllers connected by the unwind segue
    __block UIViewController * sourceViewController = (UIViewController *)[self sourceViewController];
    __block UIViewController * destinationController = (UIViewController *)[self destinationViewController];
    
    // Setup the animation for the segue
    [UIView transitionWithView:sourceViewController.navigationController.view
                      duration:0.5
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
                        [sourceViewController.navigationController popToViewController:destinationController
                                                                              animated:NO];
                    }
                    completion:^(BOOL finished){
                        
                    }];
}


@end
