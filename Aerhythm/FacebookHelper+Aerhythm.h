//
//  FacebookHelper+Aerhythm.h
//  Aerhythm
//
//  Created by Nguyen Truong Duy on 25/4/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "FacebookHelper.h"
#import "GameStatistics.h"

// This category implements Facebook-integrated functions specific to the game Aerhythm

@interface FacebookHelper (Aerhythm)

+ (void)postToCurrentUserWallWithLevelStatistics:(GameStatistics *)gameStatistics
                            andCompletionHandler:(void (^) (FBRequestConnection * connection,
                                                            id result,
                                                            NSError * error))handler;
// EFFECTS: Posts to the current user's Facebook wall a status about his level statistics

+ (void)shareStoryCompletingLevel:(NSUInteger)levelId
                        withScore:(NSUInteger)score
                          andSong:(NSString *)songName
                         andModel:(NSString *)modelId
             andCompletionHandler:(void (^) (FBRequestConnection * connection,
                                             id result,
                                             NSError * error))handler;
// REQUIRES: songName != nil and modelId != nil
// EFFECTS: Shares on Facebook the story of completing a level in Aerhythm with input information

@end
