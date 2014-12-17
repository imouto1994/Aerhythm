#import "GameJet.h"
#import "PlayerBullet.h"

#define kSpecialFireEffect @"special-fire-effect"
#define kShieldEffect @"shield-effect"

@interface PlayerJet : GameJet
// OVERVIEW: This is an abstract class for the player jet

// The size of the player jet
@property (nonatomic, readonly) CGSize bodySize;

// Mana for ultimate of the player jet
@property (nonatomic) CGFloat currentMana;

// Max mana for the player jet
@property (nonatomic) CGFloat maxMana;

// The bullet type that the player will fire
@property (nonatomic) BulletType bulletType;

// Indicator that the player jet is shocked
@property (nonatomic, readonly) BOOL isShocked;

// Indicator that the player jet is shielded
@property (nonatomic) BOOL isShield;

// Indicator that the player jet is currently confusing enemies
@property (nonatomic) BOOL isConfuseEnemy;

// Indicator if the player jet is currently using any special move
@property (nonatomic) BOOL isUsingSpecialMove;

// The tail emitter of the player jet
@property (nonatomic, strong) SKEmitterNode* tailEmitter;

@property (nonatomic, readonly) PlayerFireType fireType;

- (void)enableSpecialMove;
// REQUIRES: self != nil
// MODIFIES: self
// EFFECTS: Enable the player jet to start using special move

- (void)initSpecialMove;
// REQUIRES: self != nil
// MODIFIES: self
// EFFECTS: Initial setup when the special move is first activated

- (void)removeSpecialMove;
// REQUIRE: self != nil
// MODIFIES: self
// EFFECTS: Remove the special move, let the jet go back to default state

- (void)hitByBullet:(Bullet *)bullet;
// REQUIRES: self != nil
// MODIFIES: self
// EFFECTS: Modify the attributes of the jet when it is hit by a bullet

- (void)hitByEnemy:(SKNode *)enemy;
// REQUIRES: self != nil
// MODIFIES: self
// EFFECTS: Modify the attributes of the jet when it is hit by an enemy

- (Bullet *)fireFromPosition:(CGPoint)firingPosition withVelocity:(CGVector)velocity;
// REQUIRES: self != nil
// EFFECTS: Fire bullets from a position with specified velocity

- (Bullet *)fireFromPosition:(CGPoint)firingPosition;
// REQUIRES: self != nil
// EFFECTS: Fire bullets from a position

- (void)defaultFire;
// REQUIRES: self != nil
// EFFECTS: Set the firing type to default

- (void)handleShieldPowerup;
// REQUIRES: self != nil
// EFFECTS: Handling method when collecting a shield powerup

- (SKTexture *)turnLeftTexture;
// EFFECTS: Get the texture for turn left state

- (SKTexture *)turnRightTexture;
// EFFECTS: Get the texture for turn right state

- (SKTexture *)defaultTexture;
// EFFECTS: Get the texture for the default state

- (SKTexture *)shieldTexture;
// EFFECTS: Get the texture for the shield

- (SKAction *)specialFlagAction;
// EFFECTS: Get the action representing special move

+ (void)setModelType:(PlayerJetType) type;
// EFFECTS: Set the static model type of the player jet

+ (PlayerJetType)modelType;
// EFFECTS: Get the static model type of the player jet

+ (UIColor *)tailEmitterColor;
// EFFECTS: Get the color for the tail emitter

@end
