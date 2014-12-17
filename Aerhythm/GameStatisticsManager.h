//
//  GameStatisticsManager.h
//  Aerhythm
//
//  Created by Nguyen Truong Duy on 14/6/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameStatistics.h"

@interface GameStatisticsManager : NSObject

+ (void)loadUserGameStatistics;

+ (NSUInteger)getHighestWonLevel;

+ (GameStatistics *)getStatisticsForLevel:(NSUInteger)levelId;

@end
