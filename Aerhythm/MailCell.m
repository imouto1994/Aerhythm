#import "MailCell.h"
#import "CircularView.h"
#import "Utilities.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "FacebookHelper.h"

@implementation MailCell{
    UIImageView *profileImageView;
    UILabel *profileNameLabel;
    UILabel *songNameLabel;
    UILabel *artistNameLabel;
    UIButton *acceptButton;
    UIButton *rejectButton;
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.backgroundView = [[UIView alloc] init];
        self.selectedBackgroundView = [[UIView alloc] init];
        
        // Add view for table cell
        UIView *cellView = [[UIView alloc] init];
        [cellView setFrame:CGRectMake(0, 0, 768, 120)];
        
        // Add table cell frame
        UIImage *tableFrame = [Utilities loadImageWithName:@"tableMail"];
        UIImageView *frameView = [[UIImageView alloc] initWithImage:tableFrame];
        [frameView setFrame:CGRectMake(0, 10, 768, 100)];
        [cellView addSubview:frameView];
        [cellView sendSubviewToBack:frameView];
        
        // Add profile image
        CircularView *profileBorderView = [[CircularView alloc] initWithFrame:CGRectMake(0 ,15, 90, 90)];
        [cellView addSubview:profileBorderView];
        UIImage *testImage = [Utilities loadImageWithName:@"level1-artwork"];
        profileImageView = [[UIImageView alloc] initWithImage:testImage];
        [profileImageView setFrame:CGRectMake(0, 0, 90, 90)];
        [profileBorderView addSubview:profileImageView];
        
        // Add profile name
        profileNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(95, 65, 216, 31)];
        [profileNameLabel setFont:[UIFont fontWithName:@"Futura (Light)" size:20]];
        [profileNameLabel setTextColor:[UIColor whiteColor]];
        profileNameLabel.text = @"Aerymth Testing";
        [cellView addSubview:profileNameLabel];
        
        // Add song name
        songNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(275, 0, 500, 57)];
        [songNameLabel setFont:[UIFont fontWithName:@"Futura (Light)" size:20]];
        [songNameLabel setTextColor:[UIColor whiteColor]];
        songNameLabel.text = @"Song Name: Aerymth Song Testing";
        [cellView addSubview:songNameLabel];
        
        // Add artist name
        artistNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(275, 70, 500, 57)];
        [artistNameLabel setFont:[UIFont fontWithName:@"Futura (Light)" size:20]];
        [artistNameLabel setTextColor:[UIColor whiteColor]];
        artistNameLabel.text = @"Artist: 30 Seconds To Mars";
        [cellView addSubview:artistNameLabel];
        
        // Add button
        UIImage *tickImage = [Utilities loadImageWithName:@"tickIcon"];
        UIImage *rejectImage = [Utilities loadImageWithName:@"rejectIcon"];
        acceptButton = [[UIButton alloc] initWithFrame:CGRectMake(710, 20, 36, 36)];
        [acceptButton setImage:tickImage forState:UIControlStateNormal];
        rejectButton = [[UIButton alloc] initWithFrame:CGRectMake(710, 60, 36, 36)];
        [rejectButton setImage:rejectImage forState:UIControlStateNormal];
        [acceptButton addTarget:self action:@selector(acceptButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [rejectButton addTarget:self action:@selector(rejectButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [cellView addSubview:acceptButton];
        [cellView addSubview:rejectButton];
        [self addSubview:cellView];
    }
    return self;
}

- (void)displaySongRequestData {
    // REQUIRES: self != nil
    // EFFECTS: Displays the song request data on cell view
    
    profileNameLabel.text = self.songRequest.fromUserName;
    songNameLabel.text = self.songRequest.songName;
    artistNameLabel.text = self.songRequest.songArtist;
    [profileImageView setImageWithURL:[FacebookHelper getProfilePictureUrlWithUserId:self.songRequest.fromUserId
                                                                             andSize:kNormal]
                     placeholderImage:[Utilities loadImageWithName:@"level1-artwork"]];
}

- (IBAction)acceptButtonTapped:(UIButton *)sender {
    // to be implemented by subclasses
}

- (IBAction)rejectButtonTapped:(UIButton *)sender {
    
    [self.delegate removeSongRequest:self.songRequest];
}

@end
