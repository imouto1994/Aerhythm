#import <UIKit/UIKit.h>
#import "SongRequest.h"

@protocol MailControllerRemoveRequest <NSObject>

- (void)removeSongRequest:(SongRequest *)request;
- (void)hideProcess;

@end

@interface MailController : UIViewController <MailControllerRemoveRequest>
// OVERVIEW: This is the controller for the mail modal popup scren

// The delegate for mail controller protocol
@property (weak, nonatomic) id parentDelegate;

@end
