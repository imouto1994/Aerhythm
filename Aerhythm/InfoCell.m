#import "InfoCell.h"
#import "Utilities.h"

#define kFuturaFontName @"Futura (Light)"

@implementation InfoCell{
    // The view of the cell
    UIView *cellView;
    // The view of the representing image
    UIImageView *representingImageView;
    // The title of the element
    UILabel *titleLabel;
    // The details of the element
    UILabel *detailsLabel;
    
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = [[UIView alloc] init];
        self.selectedBackgroundView = [[UIView alloc] init];
    
        // Add view for upgrade table cell
        cellView = [[UIView alloc] init];
        [cellView setFrame:CGRectMake(0, 0, 768, 400)];
        
        // Add representing image
        representingImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 110, 300, 300)];
        [cellView addSubview:representingImageView];
        
        // Add title
        titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(400, 20, 500, 50)];
        [titleLabel setFont:[UIFont fontWithName:kFuturaFontName size:40]];
        titleLabel.textColor = [UIColor whiteColor];
        [cellView addSubview:titleLabel];
        
        // Add details
        detailsLabel = [[UILabel alloc] initWithFrame:CGRectMake(400, 90, 500, 300)];
        detailsLabel.numberOfLines = 0;
        [detailsLabel setFont:[UIFont fontWithName:kFuturaFontName size:20]];
        detailsLabel.textColor = [UIColor whiteColor];
        [cellView addSubview:detailsLabel];
        
        [self addSubview:cellView];
    }
    return self;
}

-(void) setRepresentingImageName:(NSString *)representingImageName{
    _representingImageName = representingImageName;
    UIImage *image = [Utilities loadImageWithName:representingImageName];
    [representingImageView setImage:image];
}

-(void) setTitle:(NSString *)title{
    _title = title;
    [titleLabel setText:title];
}

-(void) setDetails:(NSString *)details{
    _details = details;
    [detailsLabel setText:details];
}

@end
