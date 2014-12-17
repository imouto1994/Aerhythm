//
//  GameStatisticsManager.m
//  Aerhythm
//
//  Created by Nguyen Truong Duy on 14/6/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "GameStatisticsManager.h"
#import "FacebookHelper+Aerhythm.h"
#import "Constant.h"
#import <Parse/Parse.h>
#import "Connectivity.h"

@implementation GameStatisticsManager

static NSMutableDictionary * sMapLevelToStatistics;

+ (void)loadUserGameStatistics {
    
    sMapLevelToStatistics = [NSMutableDictionary dictionary];
    
    NSString * facebookId = [FacebookHelper getCachedCurrentUserId];
    if (facebookId && [Connectivity hasInternetConnection]) {
        PFQuery * query = [PFQuery queryWithClassName:kGameStatisticsParseClassName];
        [query whereKey:@"userId" equalTo:facebookId];
        NSArray * gameStatArray = [query findObjects];
        for (PFObject * statObj in gameStatArray) {
            NSUInteger levelId = [statObj[@"levelId"] unsignedIntegerValue];
            GameStatistics * levelStat = [[GameStatistics alloc] initWithLevelId:levelId];
            levelStat.songName = statObj[@"songName"];
            levelStat.songArtist = statObj[@"songArtist"];
            levelStat.usedModelType = (PlayerJetType)[statObj[@"modelType"] integerValue];
            levelStat.score = (CGFloat)[statObj[@"score"] doubleValue];
            levelStat.isWon = [statObj[@"isWon"] boolValue];
            [sMapLevelToStatistics setObject:levelStat
                                   forKey:[NSNumber numberWithUnsignedInteger:levelId]];
        }
        
    } else {
        // Search in local storage
        for (NSUInteger levelId = 1; levelId <= kNumLevel; levelId++) {
            GameStatistics * levelStat = [GameStatistics loadHighestOfflineStatisticsForLevel:levelId];
            if (levelStat) {
                [sMapLevelToStatistics setObject:levelStat
                                       forKey:[NSNumber numberWithUnsignedInteger:levelId]];
            }
        }
    }
}

+ (NSUInteger)getHighestWonLevel {
    if (!sMapLevelToStatistics) {
        return 0;
    }
    for (NSUInteger levelId = 1; levelId <= kNumLevel; levelId++) {
        GameStatistics * levelStat = [sMapLevelToStatistics
                                      objectForKey:[NSNumber numberWithUnsignedInteger:levelId]];
        if (!levelStat || !levelStat.isWon) {
            return levelId - 1;
        }
    }
    return kNumLevel;
}

+ (GameStatistics *)getStatisticsForLevel:(NSUInteger)levelId {
    return [sMapLevelToStatistics objectForKey:[NSNumber numberWithUnsignedInteger:levelId]];
}

@end
