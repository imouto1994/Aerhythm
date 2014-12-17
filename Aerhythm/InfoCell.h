#import <UIKit/UIKit.h>

@interface InfoCell : UITableViewCell
// OEVERVIEW: This is the cell used for representing the info for an element in the info table in the Info screen.

// Name of representing image
@property (strong, nonatomic) NSString *representingImageName;
// Title of the element
@property (strong, nonatomic) NSString *title;
// Details of the element
@property (strong, nonatomic) NSString *details;

@end
