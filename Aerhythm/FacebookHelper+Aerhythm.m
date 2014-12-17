//
//  FacebookHelper+Aerhythm.m
//  Aerhythm
//
//  Created by Nguyen Truong Duy on 25/4/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "FacebookHelper+Aerhythm.h"
#import "Constant.h"

// Constants specific to Aerhythm
static NSString * const kLevelGraphType = @"aerhythm:level";
static NSString * const kLevelGraphName = @"level";
static NSString * const kCompleteLevelActionType = @"aerhythm:complete";
static NSString * const kAerhythmFacebookPageUrl = @"https://www.facebook.com/pages/Aerhythm/243412032531037";

@implementation FacebookHelper (Aerhythm)

+ (void)postToCurrentUserWallWithLevelStatistics:(GameStatistics *)gameStatistics
                            andCompletionHandler:(void (^) (FBRequestConnection * connection,
                                                            id result,
                                                            NSError * error))handler {
    // EFFECTS: Posts to the current user's Facebook wall a status about his level statistics
    
    NSString * message = [NSString stringWithFormat:@"Played level %lu. Got a score of %.0lf with the song \"%@\" and model \"%@\" #Aerhythm", (unsigned long)gameStatistics.levelId, gameStatistics.score, gameStatistics.songName, [Constant getNameOfPlayerJetWithType:gameStatistics.usedModelType]];
    NSString * imageUrl = [FacebookHelper getSocialImageUrlForLevel:gameStatistics.levelId];
    NSMutableDictionary * param = [[NSMutableDictionary alloc] init];
    [param setObject:message forKey:@"message"];
    if (imageUrl) {
        [param setObject:imageUrl forKey:@"picture"];
        [param setObject:@"Aerhythm" forKey:@"name"];
        [param setObject:@"The Original Music-based 2D Plane Shooting Game" forKey:@"caption"];
        [param setObject:kAerhythmFacebookPageUrl forKey:@"link"];
    }
    
    [FacebookHelper postToCurrentUserWallWithParam:param
                              andCompletionHandler:handler];
}

+ (void)shareStoryCompletingLevel:(NSUInteger)levelId
                        withScore:(NSUInteger)score
                          andSong:(NSString *)songName
                         andModel:(NSString *)modelId
             andCompletionHandler:(void (^) (FBRequestConnection * connection,
                                             id result,
                                             NSError * error))handler {
    // REQUIRES: songName != nil and modelId != nil
    // EFFECTS: Shares on Facebook the story of completing a level in Aerhythm with input information
    
    // Create a level object
    NSMutableDictionary<FBGraphObject> * object = [FBGraphObject openGraphObjectForPost];
    object.provisionedForPost = YES;
    object[@"type"] = kLevelGraphType;
    object[@"title"] = [NSString stringWithFormat:@"Level %lu", (unsigned long)levelId];
    object[@"image"] = [FacebookHelper getSocialImageUrlForLevel:levelId];
    object[@"url"] = kAerhythmFacebookPageUrl;
    
    NSMutableDictionary<FBGraphObject> * customData = [FBGraphObject openGraphObjectForPost];
    customData[@"score"] = [NSString stringWithFormat:@"%lu", (unsigned long)score];
    customData[@"song"] = songName;
    customData[@"model"] = modelId;
    object[@"data"] = customData;
    
    [FacebookHelper  publishStoryWithObject:(id<FBOpenGraphObject>)object
                              andActionType:kCompleteLevelActionType
                       andCompletionHandler:handler];
}

+ (NSString *)getSocialImageUrlForLevel:(NSUInteger)levelId {
    // EFFECTS: Returns a string representing an image url (for social posting) of an input level
    
    if (levelId == 1) {
        return @"http://i739.photobucket.com/albums/xx37/NguyenTruong_Duy/Aerhythm/boss1_zpse7f437a6.png";
    }
    if (levelId == 2) {
        return @"http://i739.photobucket.com/albums/xx37/NguyenTruong_Duy/Aerhythm/boss2_zps9f6b41c1.png";
    }
    if (levelId == 3) {
        return @"http://i739.photobucket.com/albums/xx37/NguyenTruong_Duy/Aerhythm/boss3_zps35030623.png";
    }
    
    // Default (level 4)
    return @"http://i739.photobucket.com/albums/xx37/NguyenTruong_Duy/Aerhythm/boss4_zpse14233d5.png";
}

@end
