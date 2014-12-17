// This is an abstract class for the enemy jet

#import "Gamejet.h"
#import "EnemyBullet.h"

#define kDefaultFireCounter 500.0

@interface EnemyJet : GameJet{
    // The slow factor of the enemy jet if it is under slow effect
    CGFloat slowFactor;
    
    // The number of consecutive freezing bullets needed to make this jet frozen
    int numberNeededFrozenBullet;
    
    // The number of wind bullets needed to make this jet pushed
    int numberNeededWindBullet;
    
    // The damage received if it is under fire effect
    CGFloat fireDamage;
}

// The bullet type for the enemy jet
@property (nonatomic) BulletType bulletType;
// The speed of the enemy jet
@property (nonatomic) CGFloat jetSpeed;
// The radius of the body of the jet
@property (nonatomic, readonly) CGFloat radius;
// The fire counter to check whether the jet is allowed to fire a bullet
@property (nonatomic, readwrite) CGFloat fireCounter;
// The original firing speed of the enemy jet
@property (nonatomic, readonly) CGFloat originalFiringSpeed;

// Indicator whether the jet is being slowed
@property (nonatomic, readonly) BOOL isSlowed;
// Indicator whether the jet is being frozen
@property (nonatomic, readonly) BOOL isFrozen;
// Indicator whether the jet is pushed
@property (nonatomic, readonly) BOOL isPushed;
// Indicator whether the jet is able to fire
@property (nonatomic, readwrite) BOOL isAbleToFire;
// Indicator whether the jet is mobile
@property (nonatomic, readonly) BOOL mobile;

// Indicator whether the firing speed is being slowed
@property (nonatomic, readonly) BOOL isFiringSpeedSlowed;
// Indicator whether the enemy jet is shocked
@property (nonatomic, readonly) BOOL isShocked;

// Indicator whether the enemy het is moving to visible regions in scene
@property (nonatomic, readwrite) BOOL isMovingToScene;

// Indicator whether the enemy jet is immune to bullet effect and damage
@property (nonatomic, readwrite) BOOL isImmuneToBullet;

// A hint of the current player position
@property (nonatomic, readwrite) CGPoint userPositionHint;



- (id)initAtPosition:(CGPoint)position withRadius:(CGFloat)radius enableFire:(BOOL)isEnableFire;
// MODIFIES: self
// EFFECTS: Initialize the sprite node at an assigned position and radius and indicate whether the enemy should be
//      able to fire at the beginning

- (id)initAtPosition:(CGPoint)position enableFire:(BOOL)isEnableFire;
// MODIFIES: self
// EFFECTS: Initialize the sprite node at an assigned position and indicate whether the enemy should be
//      able to fire at the beginning

- (id)initAtPosition:(CGPoint)position withRadius:(CGFloat)radius;
// MODIFIES: self
// EFFECTS: Initialize the sprite node at an assigned position and radius

- (void)fireWithHint:(BOOL)hasHint andPlayerPositionHint:(CGPoint)playerPosition;
// REQUIRES: self != nil, playerPosition is in the coordinnate system of self
// EFFECTS: Handles the action that the jet fires the bullets. Player position may be provided as a hint

- (void)updateWithHint:(BOOL)hasHint andPlayerPositionHint:(CGPoint)playerPosition;
// REQUIRES: self != nil, playerPosition is in the coordinnate system of self
// EFFECTS: Update the enemy jet's state. Player position may be provided as a hint

- (void)performDeathWithEmitter;
// REQUIRES: self != nil
// MODIFIES: self
// EFFECTS: Handle when enemy jet is death, add emitter to enemy jet

- (void)generatePowerupsOfTypes:(NSArray*)typeArray;
// EFFECTS: generate power-ups with given types and pre-defined probability

- (void)updateGamescore;
// EFFECTS: update game kScore after an enemy jet is dead

- (CGVector)getOriginalVelocity;
// REQUIRES: self != nil
// EFFECTS: Returns the original velocity of self

+ (SKTexture *)sDefaultTexture;
// EFFECTS: Get the shared default texture

+ (SKTexture *)sDeadTexture;
// EFFECTS: Get the shared dead texture

+ (SKTexture *)sFrozenTexture;
// EFFECTS: Get the shared frozen texture

+ (SKTextureAtlas *)sTextureAtlas;
// EFFECTS: Get the shared atlas for the enemy jets

+ (float)scoreGain;
// EFFECTS: Get the score gained when this enemy is dead

@end
