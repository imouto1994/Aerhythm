//
//  GiftCell.m
//  Aerhythm
//
//  Created by Bui Trong Nhan on 4/17/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "GiftCell.h"
#import "LocalGiftSongs.h"
#import "MenuController.h"
#import "FacebookHelper.h"
#import "Connectivity.h"

@implementation GiftCell

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (IBAction)acceptButtonTapped:(UIButton *)sender {
    // Download the file data
    
    MailController *mailController = (MailController *) self.delegate;
    MenuController *menuController = (MenuController *) mailController.parentDelegate;
    
    SongRequest *currentSongRequest = self.songRequest;
    [self.songRequest downloadSongDataInBackgroundWithBlock:^(NSData * data, NSError * error) {
        if (error) {
            NSLog(@"Error in download song %@ data", self.songRequest.songName);
            return;
        }
        
        [LocalGiftSongs storeGiftSongWithName:self.songRequest.songName
                                    andArtist:self.songRequest.songArtist
                                      andData:data];
        
        // Remove request
        [FacebookHelper deleteCurrentUserRequestObjectWithId:currentSongRequest.requestFacebookId];
        if ([Connectivity hasInternetConnection]) {
            [currentSongRequest deleteInBackground];
        } else {
            [currentSongRequest deleteEventually];
        }
        
    } progressBlock:^(int percentDone) {
        [menuController displayProgress:percentDone forPurpose:NO];
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate hideProcess];
    });
}

@end
