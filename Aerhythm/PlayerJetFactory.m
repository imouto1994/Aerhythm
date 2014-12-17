//
//  PlayerJetFactory.m
//  Aerhythm
//
//  Created by Nguyen Truong Duy on 23/3/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "PlayerJetFactory.h"
#import "OriginalJet.h"
#import "HighDamageJet.h"
#import "HighHealthJet.h"

@implementation PlayerJetFactory

+(PlayerJet *) createPlayerJetAtPosition:(CGPoint)position{
    // EFFECTS: Factory method that creates an instance of PlayerJet based on the selection from user
    
    return [PlayerJetFactory createPlayerJetWithType:[PlayerJet modelType] andAtPosition:position];
}

+ (PlayerJet *)createPlayerJetWithType:(PlayerJetType)jetType andAtPosition:(CGPoint)position
{
    // EFFECTS: Factory method that creates an instance of PlayerJet based on the input jet type
    
    switch (jetType) {
        case kOriginal:
            return [[OriginalJet alloc] initAtPosition:position];
        case kHighDamage:
            return [[HighDamageJet alloc] initAtPosition:position];
        case kHighHealth:
            return [[HighHealthJet alloc] initAtPosition:position];
    }
}

+ (void)loadSharedAssets
{
    // EFFECTS: Loads shared assets (e.g. images) for all player jet types
    [PlayerJetFactory loadsharedAssetsForJetType:[PlayerJet modelType]];
}

+ (void)loadsharedAssetsForJetType:(PlayerJetType)jetType
{
    // EFFECTS: Loads shared assets (e.g. images) for the input player jet type
    NSArray * array = @[[NSNumber numberWithUnsignedInteger:(NSUInteger)jetType]];
    [PlayerJetFactory loadSharedAssetsForJetTypes:array];
}


+ (void)loadSharedAssetsForJetTypes:(NSArray *)jetTypeArray
{
    // EFFECTS: Loads shared assets (e.g. images) for all player jet types
    for (NSNumber * typeNsNumber in jetTypeArray) {
        PlayerJetType jetType = (PlayerJetType) [typeNsNumber unsignedIntegerValue];
        switch (jetType) {
            case kOriginal:
                [OriginalJet loadSharedAssets];
                break;
            case kHighDamage:
                [HighDamageJet loadSharedAssets];
                break;
            case kHighHealth:
                [HighHealthJet loadSharedAssets];
                break;
        }
    }
}

+ (void)releaseSharedAssets
{
    // EFFECTS: Releases shared assets (e.g. images) for all player jet types
    
    [OriginalJet releaseSharedAssets];
    [HighDamageJet releaseSharedAssets];
    [HighHealthJet releaseSharedAssets];
}

@end
