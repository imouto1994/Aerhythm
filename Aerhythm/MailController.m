#import "MailController.h"
#import "RequestCell.h"
#import "GiftCell.h"
#import "Utilities.h"
#import "FacebookHelper.h"
#import "Connectivity.h"

static NSString * const kRequestIdentifier = @"Request_Identifier";
static NSString * const kGiftIdentifier = @"Gift_Identifier";
#define kNumSections 2

@interface MailController ()<UITableViewDataSource, UITableViewDelegate>

// List of requested songs
@property (strong, nonatomic, readwrite) NSMutableArray * requestAskSongList;
// List of gift songs
@property (strong, nonatomic, readwrite) NSMutableArray * giftList;

@end

@implementation MailController {
    // Background image view for the mail modal window
    UIImageView *mailBackgroundImageView;
    // The table view showing list of requested and gift songs
    UITableView *mailTableView;
    // The button to exit the mail modal screen
    UIButton *exitButton;
}

- (void)viewDidLoad{
    // MODIFIES: self
    // EFFECTS: Setup the view when it is first loaded
    
    [super viewDidLoad];
    
    // Load the background image
    mailBackgroundImageView = [[UIImageView alloc] init];
    [mailBackgroundImageView setFrame:CGRectMake(0, 0, 768, 800)];
    UIImage *mailBackgroundImage = [Utilities loadImageWithName:@"mailModalBackground"];
    [mailBackgroundImageView setImage:mailBackgroundImage];
    [self.view addSubview:mailBackgroundImageView];
    
    // Setup the table
    mailTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 90, 768, 688) style:UITableViewStyleGrouped];
    mailTableView.backgroundColor = [UIColor clearColor];
    mailTableView.separatorStyle = UITableViewCellAccessoryNone;
    mailTableView.separatorColor = [UIColor clearColor];
    mailTableView.delegate = self;
    mailTableView.dataSource = self;
    [mailTableView registerClass:[RequestCell class] forCellReuseIdentifier:kRequestIdentifier];
    [mailTableView registerClass:[GiftCell class] forCellReuseIdentifier:kGiftIdentifier];
    [self.view addSubview:mailTableView];
    
    // Setup the button
    UIImage *exitButtonImage = [Utilities loadImageWithName:@"rejectIcon"];
    exitButton  = [[UIButton alloc] initWithFrame:CGRectMake(730, 0, 40, 40)];
    [exitButton setImage:exitButtonImage forState:UIControlStateNormal];
    [exitButton addTarget:self action:@selector(exitNotificationScreen:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:exitButton];
    
    // Initialize request data
    self.requestAskSongList = [[NSMutableArray alloc] init];
    self.giftList = [[NSMutableArray alloc] init];
    
    [self loadAskSongRequestList];
    [self loadGiftList];
}

- (void)viewDidDisappear:(BOOL)animated {
    // MODIFIES: self
    // EFFECTS: Setup the view when it disappeared
    
    // Release the table and its background
    [mailTableView removeFromSuperview];
    mailTableView = nil;
    [mailBackgroundImageView removeFromSuperview];
    mailBackgroundImageView = nil;
    
    // Release the button
    [exitButton removeFromSuperview];
    [exitButton setImage:nil forState:UIControlStateNormal];
    exitButton = nil;
}

- (void)viewWillLayoutSubviews {
    // MODIFIES: self
    // EFFECTS: Layout the view and its subviews when it is loaded
    
    [super viewWillLayoutSubviews];
    self.view.superview.frame = CGRectMake(0, 112, 768, 800);
}

- (IBAction) exitNotificationScreen:(UIButton *)sender {
    // MODIFIES: self
    // EFFEFCT: Handle when the exit button is tapped
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)loadAskSongRequestList {
    // EFFECTS: Fetches the list of all requests for songs for the current user from Parse server
    
    if (![Connectivity hasInternetConnection]) {
        return;
    }
    
    NSString * currentUserId = [FacebookHelper getCachedCurrentUserId];
    if (!currentUserId) {
        return;
    }
    
    [SongRequest getAllRequestsOfType:kAskSong
                               toUser:currentUserId
                 andCompletionHandler:^(NSArray * requestList, NSError * error) {
                     if (error) {
                         NSLog(@"Error in fetching ask-song requests: %@", error);
                         return;
                     }
                     
                     self.requestAskSongList = [NSMutableArray arrayWithArray:requestList];
                     [mailTableView reloadData];
                 }];
}

- (void)loadGiftList {
    // EFFECTS: Fetches the list of all gifts (send-song requests) for the current user from Parse server
    
    if (![Connectivity hasInternetConnection]) {
        return;
    }
    
    NSString * currentUserId = [FacebookHelper getCachedCurrentUserId];
    if (!currentUserId) {
        return;
    }
    
    [SongRequest getAllRequestsOfType:kSendSong
                               toUser:currentUserId
                 andCompletionHandler:^(NSArray * requestList, NSError * error) {
                     if (error) {
                         NSLog(@"Error in fetching send-song requests: %@", error);
                         return;
                     }
                     
                     self.giftList = [NSMutableArray arrayWithArray:requestList];
                     [mailTableView reloadData];
                 }];
}

#pragma mark - Table View Data Source

- (NSInteger )numberOfSectionsInTableView:(UITableView *)tableView {
    // EFFECTS: Return the number of sections in the table view
    
    return kNumSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // EFFECTS: Return the number of rows in a specific section
    
    if(section == 0) {
        return [self.requestAskSongList count];
    } else if(section == 1) {
        return [self.giftList count];
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // EFFECTS: Construct a cell according to the index path in the  table view
    
    MailCell * cell = nil;
    if(indexPath.section == 0){
        cell = (MailCell *)[tableView dequeueReusableCellWithIdentifier:kRequestIdentifier];
        if(!cell) {
            cell = [[RequestCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kRequestIdentifier];
        }
        
        cell.songRequest = self.requestAskSongList[indexPath.row];
        
    } else if(indexPath.section == 1){
        cell = (MailCell *)[tableView dequeueReusableCellWithIdentifier:kGiftIdentifier];
        if(!cell) {
            cell = [[GiftCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kGiftIdentifier];
        }
        
        cell.songRequest = self.giftList[indexPath.row];
    }
    
    [cell displaySongRequestData];
    cell.delegate = self;
    
    return cell;
}

#pragma mark - Table View Delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // EFFECTS: Return the height for each row in the table
    
    return 120;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // EFFECTS: Return the height for each footer the table
    
    return 1.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    // EFFECTS: Return the height for each header for the table
    
    return 45.0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    // EFFECTS: Return the view for each header in the table
    
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 768, 45.0)];
    [headerView setBackgroundColor:[UIColor clearColor]];
    
    UIImageView *titleImageView = [[UIImageView alloc] init];
    if(section == 0){
        UIImage *titleImage = [Utilities loadImageWithName:@"requestSectionHeader"];
        [titleImageView setImage:titleImage];
        [titleImageView setFrame:CGRectMake(0, 0, 230, 50)];
        [headerView addSubview:titleImageView];
    } else if(section == 1){
        UIImage *titleImage = [Utilities loadImageWithName:@"giftSectionHeader"];
        [titleImageView setImage:titleImage];
        [titleImageView setFrame:CGRectMake(0, 0, 128, 50)];
        [headerView addSubview:titleImageView];
    }
    return headerView;
}

#pragma mark MailControllerRemoveRequest
- (void)removeSongRequest:(SongRequest *)request {
    // EFFECTS: Removes the given request from one of the two request lists of self
    //          Reloads the table
    
    NSMutableArray * targetList = self.requestAskSongList;
    if (request.requestType == kSendSong) {
        targetList = self.giftList;
    }
    
    for (NSUInteger ind = 0; ind < [targetList count]; ind++) {
        SongRequest * currentRequest = [targetList objectAtIndex:ind];
        
        if ([[currentRequest objectId] isEqualToString:[request objectId]]) {
            [FacebookHelper deleteCurrentUserRequestObjectWithId:currentRequest.requestFacebookId];
            [targetList removeObjectAtIndex:ind];
            [currentRequest deleteInBackground];
            [mailTableView reloadData];
            return;
        }
    }
}

- (void)hideProcess {
    // EFFECTS: Hide the current mail modal screen
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
