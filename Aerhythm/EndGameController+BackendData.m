//
//  EndGameController+BackendData.m
//  Aerhythm
//
//  Created by Nguyen Truong Duy on 6/4/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "EndGameController+BackendData.h"
#import <Parse/Parse.h>
#import "FacebookHelper.h"
#import "Constant.h"

@implementation EndGameController(BackendData)

- (void)storeGameStatisticsToParse
{
    // REQUIRES: self != nil
    // EFFECTS: Stores the game statistics of the current user at the current level to Parse
    
    if (![FacebookHelper getCachedCurrentUserId]) {
        // No Facebook id. Not storing to Parse
        return;
    }
    
    PFObject * statObject = [self getCurrentGameStatParseObject];
    
    // Query if an object with such userId and levelId has already existed
    PFQuery * query = [PFQuery queryWithClassName:kGameStatisticsParseClassName];
    [query whereKey:@"userId" equalTo:statObject[@"userId"]];
    [query whereKey:@"levelId" equalTo:statObject[@"levelId"]];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray * objects, NSError * error) {
        if (error) {
            NSLog(@"Error occurred %@", error);
            return;
        }
        
        if ([objects count] == 0) {
            NSLog(@"New object");
            NSLog(@"new object %@", statObject);
            // This is a new object. Add to DB
            [statObject saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
                NSLog(@"Error in storing: %@", error);
            }];
        } else {
            NSLog(@"Existed object");
            // Update the object
            PFObject * existedStatObj = objects[0];
            // Compare the two scores
            CGFloat oldScore = [(NSNumber *)existedStatObj[@"score"] floatValue];
            
            // Always update username
            existedStatObj[@"userName"] = statObject[@"userName"];
            
            if (oldScore < self.gameStatistics.score) {
                // Update game statistics if the new score if higher
                NSLog(@"update");
                existedStatObj[@"songName"] = statObject[@"songName"];
                existedStatObj[@"artist"] = statObject[@"artist"];
                existedStatObj[@"modelType"] = statObject[@"modelType"];
                existedStatObj[@"score"] = statObject[@"score"];
            }
            if (self.gameStatistics.isWon) {
                existedStatObj[@"isWon"] = [NSNumber numberWithBool:self.gameStatistics.isWon];
            }
            
            [existedStatObj saveInBackgroundWithBlock:^(BOOL succeeded, NSError * error) {
                
            }];
        }
    }];
}

- (void)getAndDisplayWorldTopPlayers:(NSUInteger)numTopPlayers
{
    // REQUIRES: self != nil
    // EFFECTS: Retrieves and displays world top players at the current level
    
    PFQuery * topQuery = [PFQuery queryWithClassName:kGameStatisticsParseClassName];
    
    // Prepare the query
    [topQuery whereKey:@"levelId" equalTo:[NSNumber numberWithUnsignedInteger:
                                           self.gameStatistics.levelId]];
    [topQuery orderByDescending:@"score"];
    topQuery.limit = numTopPlayers;
    
    // Query
    [topQuery findObjectsInBackgroundWithBlock:^(NSArray * topPlayers, NSError * error) {
        if (error) {
            NSLog(@"Error occurred %@", error);
            return;
        }
        
        NSArray * syncTopPlayers = [self syncServerTopPlayers:topPlayers
                                         withMaxNumTopPlayers:numTopPlayers];
        NSLog(@"World top players");
        for (PFObject * player in syncTopPlayers) {
            NSLog(@"Player with id %@ and name %@ and song name %@ and score %@", player[@"userId"],
                  player[@"userName"], player[@"songName"], player[@"score"]);
        }
        
        self.worldHighscorePlayerList = syncTopPlayers;
        self.highscorePlayerList = self.worldHighscorePlayerList;
        
        // Reload Data
        [self.highscoreTable reloadData];
    }];
}

- (void)getAndDisplayFriendTopPlayers:(NSUInteger)numTopPlayers
{
    // REQUIRES: self != nil
    // EFFECTS: Retrieves and displays top players among current user's Facebook friends at the current level
    
    if (![FacebookHelper getCachedCurrentUserId]) {
        // No Facebook id. Cannot retrieve Facebook friends
        return;
    }
    
    PFQuery * topQuery = [PFQuery queryWithClassName:kGameStatisticsParseClassName];
    
    NSLog(@"%@", [FacebookHelper getCachedCurrentUserAppFriendsId]);
    [topQuery whereKey:@"userId" containedIn:[FacebookHelper getCachedCurrentUserAppFriendsId]];
    [topQuery whereKey:@"levelId" equalTo:[NSNumber numberWithUnsignedInteger:
                                           self.gameStatistics.levelId]];
    [topQuery orderByDescending:@"score"];
    topQuery.limit = numTopPlayers;
    
    [topQuery findObjectsInBackgroundWithBlock:^(NSArray * topPlayers, NSError * error) {
        if (error) {
            NSLog(@"Error occurred %@", error);
            return;
        }
        
        NSArray * syncTopPlayers = [self syncServerTopPlayers:topPlayers
                                         withMaxNumTopPlayers:numTopPlayers];
        NSLog(@"Friend top players");
        for (PFObject * player in syncTopPlayers) {
            NSLog(@"Player with id %@ and name %@ and song name %@ and score %@", player[@"userId"],
                  player[@"userName"], player[@"songName"], player[@"score"]);
        }
        
        self.friendHighscorePlayerList = syncTopPlayers;
        self.highscorePlayerList = self.friendHighscorePlayerList;
        
        // Reload Data
        [self.highscoreTable reloadData];
    }];
}

- (NSArray *)syncServerTopPlayers:(NSArray *)serverTopPlayers
             withMaxNumTopPlayers:(NSUInteger)numTopPlayers
{
    if (![FacebookHelper getCachedCurrentUserId]) {
        // No Facebook id. No need to synchronize with the current game statistics
        return serverTopPlayers;
    }
    
    NSMutableArray * topPlayers = [NSMutableArray arrayWithArray:serverTopPlayers];
    
    // Check if the current player is in the list
    BOOL currentUserInTop = NO;
    for (NSUInteger playerInd = 0; playerInd < [topPlayers count]; playerInd++) {
        PFObject * player = topPlayers[playerInd];
        
        if ([player[@"userId"] isEqualToString:[FacebookHelper getCachedCurrentUserId]]) {
            CGFloat serverScore = (CGFloat) [(NSNumber *)player[@"score"] doubleValue];
            if (serverScore < self.gameStatistics.score) {
                NSLog(@"Here");
                topPlayers[playerInd] = [self getCurrentGameStatParseObject];
            }
            currentUserInTop = YES;
        }
    }
    
    if (!currentUserInTop && [FacebookHelper getCachedCurrentUserId]) {
        [topPlayers addObject:[self getCurrentGameStatParseObject]];
    }
    
    // Sorting
    [topPlayers sortUsingComparator:^(id obj1, id obj2) {
        PFObject * player1 = (PFObject *)obj1;
        PFObject * player2 = (PFObject *)obj2;
        
        double score1 = [player1[@"score"] doubleValue];
        double score2 = [player2[@"score"] doubleValue];
        
        // Sort in descending order
        if (score1 < score2) {
            return NSOrderedDescending;
        }
        if (score1 > score2) {
            return NSOrderedAscending;
        }
        
        return NSOrderedSame;
    }];
    
    NSUInteger cutRange = numTopPlayers;
    if ([topPlayers count] < numTopPlayers) {
        cutRange = [topPlayers count];
    }
    return [topPlayers subarrayWithRange:NSMakeRange(0, cutRange)];
}

- (PFObject *)getCurrentGameStatParseObject
{
    // REQUIRES: self != nil
    // EFFECTS: Returns an instance PFObject that represents game statistics stored in Parse
    
    PFObject * statObject = [PFObject objectWithClassName:kGameStatisticsParseClassName];
    if ([FacebookHelper getCachedCurrentUserName]) {
        statObject[@"userId"] = [FacebookHelper getCachedCurrentUserId];
    } else {
        statObject[@"userId"] = [NSNull null];
    }
    if ([FacebookHelper getCachedCurrentUserName]) {
        statObject[@"userName"] = [FacebookHelper getCachedCurrentUserName];
    } else {
        statObject[@"userName"] = [NSNull null];
    }
    if (self.gameStatistics.songName) {
        statObject[@"songName"] = self.gameStatistics.songName;
    } else {
        statObject[@"songName"] = [NSNull null];
    }
    if (self.gameStatistics.songArtist) {
        statObject[@"artist"] = self.gameStatistics.songArtist;
    } else {
        statObject[@"artist"] = [NSNull null];
    }
    
    statObject[@"levelId"] = [NSNumber numberWithUnsignedInteger:self.gameStatistics.levelId];
    statObject[@"modelType"] = [NSNumber numberWithInteger:(NSInteger)self.gameStatistics.usedModelType];
    statObject[@"score"] = [NSNumber numberWithDouble:self.gameStatistics.score];
    statObject[@"isWon"] = [NSNumber numberWithBool:self.gameStatistics.isWon];
    
    return statObject;
}

@end
