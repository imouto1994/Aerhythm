//
//  PlayerJetFactory.h
//  Aerhythm
//
//  Created by Nguyen Truong Duy on 23/3/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PlayerJet.h"
#import "Constant.h"

@interface PlayerJetFactory : NSObject

+(PlayerJet *) createPlayerJetAtPosition:(CGPoint)position;
// EFFECTS: Factory method that creates an instance of PlayerJet according to the selection from player

+ (void)loadSharedAssets;
// EFFECTS: Loads shared assets (e.g. images) for all player jet types

+ (void)releaseSharedAssets;
// EFFECTS: Releases shared assets (e.g. images) for all player jet types

@end
