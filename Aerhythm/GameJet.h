#import "GameObject.h"
#import "Bullet.h"

// The different states of the jet
typedef NS_ENUM(NSInteger, State){
    STATE_DEFAULT = 0,
    STATE_TURN_LEFT,
    STATE_TURN_RIGHT,
    STATE_DEATH,
    STATE_FROZEN,
};

@interface GameJet : GameObject
// OVERVIEW: This is an abstract class for all the jets in the game

// The current health of the jet
@property (nonatomic) CGFloat health;
@property (nonatomic) CGFloat maxHealth;

// The firing speed rate of the jet
@property (nonatomic) CGFloat firingSpeed;
// The current state of the jet
@property (nonatomic) State currentState;
// Indicator that the jet's state has changed
@property (nonatomic) BOOL hasStateChanged;

- (void)performDeath;
// REQUIRES: self != nil
// MODIFIES: self
// EFFECTS: Handling method when the jet is dead

- (void)fire;
// REQUIRES: self != nil
// EFFECTS: Handling method when the jet fires the bullets

- (BOOL)applyDamage:(CGFloat)damage;
// MODIFIES: self.health
// EFFECTS: Apply an assigned damage to the jet

- (SKEmitterNode *)fireEmitter;
- (SKEmitterNode *)slowEmitter;
- (SKTexture *) shockIconTexture;

@end
