#import "InfoController.h"
#import "Utilities.h"

#define kFuturaFontName @"Futura (Light)"
#define kInfoScreenImageName @"infoScreen"
#define kInfoBackButtonImageName @"blueBackButton"
#define kInfoEnemiesButtonImageName @"enemiesButton"
#define kInfoBulletsButtonImageName @"bulletsButton"

@implementation InfoController{
    // The image view for background
    UIImageView *backgroundImageView;
}

-(void) viewWillAppear:(BOOL)animated{
    // REQUIRES: self != nil
    // EFFECTS: Handler method when the view will appear
    
    [super viewWillAppear:animated];
    // Setup the background image view
    UIImage *background = [Utilities loadImageWithName:kInfoScreenImageName];
    backgroundImageView = [[UIImageView alloc] initWithImage:background];
    [backgroundImageView setFrame:CGRectMake(0, 0, 768, 1024)];
    [self.view addSubview:backgroundImageView];
    [self.view sendSubviewToBack:backgroundImageView];
    
    // Setup buttons
    UIImage *backImage = [Utilities loadImageWithName:kInfoBackButtonImageName];
    UIImage *enemiesButtonImage = [Utilities loadImageWithName:kInfoEnemiesButtonImageName];
    UIImage *bulletsButtonImage = [Utilities loadImageWithName:kInfoBulletsButtonImageName];
    
    [self.backButton setImage:backImage forState:UIControlStateNormal];
    [self.enemiesButton setImage:enemiesButtonImage forState:UIControlStateNormal];
    [self.bulletsButton setImage:bulletsButtonImage forState:UIControlStateNormal];
}

-(void) viewDidDisappear:(BOOL)animated{
    // REQUIRES: self != nil
    // EFFECTS: Handler method when the view did disappear
    
    [super viewDidDisappear:animated];
    // Remove background
    [backgroundImageView removeFromSuperview];
    backgroundImageView = nil;
    
    // Remove buttons image display
    [self.backButton setImage:nil forState:UIControlStateNormal];
    [self.enemiesButton setImage:nil forState:UIControlStateNormal];
    [self.bulletsButton setImage:nil forState:UIControlStateNormal];
}

-(IBAction)unwindToInfoScreen:(UIStoryboardSegue *)sender{
    // REQUIRES: self != nil
    // EFFECTS: Handler method to enable other view controllers to unwind back to this view controller
    
}

@end
