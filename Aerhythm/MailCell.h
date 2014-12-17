#import <UIKit/UIKit.h>
#import "SongRequest.h"
#import "MailController.h"

@interface MailCell : UITableViewCell

@property (strong, nonatomic) UIImage *profilePicture;
@property (strong, nonatomic) SongRequest * songRequest;
@property (weak, nonatomic) id<MailControllerRemoveRequest> delegate;

- (IBAction)acceptButtonTapped:(UIButton *)sender;
- (IBAction)rejectButtonTapped:(UIButton *)sender;

- (void)displaySongRequestData;
// REQUIRES: self != nil
// EFFECTS: Displays the song request data on cell view

@end
