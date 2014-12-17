//
//  EndGameController+BackendData.h
//  Aerhythm
//
//  Created by Nguyen Truong Duy on 6/4/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "EndGameController.h"

@interface EndGameController (BackendData)

- (void)storeGameStatisticsToParse;
// EFFECTS: Stores the game statistics of the current user at the current level to Parse

- (void)getAndDisplayWorldTopPlayers:(NSUInteger)numTopPlayers;
// EFFECTS: Retrieves and displays world top players at the current level

- (void)getAndDisplayFriendTopPlayers:(NSUInteger)numTopPlayers;
// EFFECTS: Retrieves and displays top players among current user's Facebook friends at the current level

@end
