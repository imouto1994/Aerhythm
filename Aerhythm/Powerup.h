//
//  Powerup.h
//  Aerhythm
//
//  Created by Nguyen Ngoc Nhu Thao on 3/27/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "GameObject.h"
#import "Constant.h"

@interface Powerup : GameObject
// OVERVIEW: This is the sprite node for all power-ups in the game.

// The type of power-up
@property (nonatomic) PowerupType powerupType;

- (id)initAtPosition:(CGPoint)position withType:(PowerupType)type;
// MODIFIES: self
// EFFECTS: Init method for the power-ups

+ (Powerup*)powerupAtPosition:(CGPoint)position withType:(PowerupType)type;
// EFFECTS: Factory method for power-up. It will create a power-up at a specific position and type

+ (void) updatePowerups;
// MODIFIES: Strengths of different types of power-up
// EFFECTS: Update the strenghts for power-ups

+ (NSInteger) reviveStock;
// EFFECTS: Get the remaining available times for revival

+ (void) updateReviveStock:(NSInteger)remainingTimes;
// MODIFIES: remaining time of revival stock
// EFFECTS: Update the remaining times for revival

+ (CGFloat) healAmount;
// EFFECTS: Get the heal amount for each power-up

+ (CGFloat) shieldDuration;
// EFFECTS: Get the shield duration for each power-up

+ (CGFloat) doubleFireDuration;
// EFFECTS: Get the duration for double fire

+ (CGFloat) tripleFireDuration;
// EFFECTS: Get the duration for triple fire

+ (CGFloat) quadrupleFireDuration;
// EFFECTS: Get the duration for quadruple fire

+ (CGFloat) pursueDuration;
// EFFECTS: Get the duration for pursue fire

@end
