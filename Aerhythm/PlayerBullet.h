#import "Bullet.h"
#import "EnemyJet.h"
@interface PlayerBullet : Bullet
// This is the class for all types of player bullet

// The spreading property of lightning bullet
@property (nonatomic, readonly) BOOL canSpread;
@property (nonatomic) BOOL isAffectedBySpecialMove;

- (id)initWithPosition:(CGPoint)position
         andBulletType:(BulletType)bulletType
           andVelocity:(CGVector)velocity
             canSpread:(BOOL)canSpread
            fromOrigin:(NSInteger)originType;
// MODIFIES: self
// EFFECTS: Initialize the bullet at an assigned position, bullet type, velocity, canSpread property and its origin

- (id)initWithPosition:(CGPoint)position
         andBulletType:(BulletType)bulletType
           isAffectedBySpecialMove:(BOOL)isAffectedBySpecialMove
            fromOrigin:(NSInteger)originType;
// MODIFIES: self
// EFFECTS: Initialize the bullet at an assigned position, bullet type with condition of being affected by special move and its origin

- (void)updateWithHint:(BOOL)hasHint andEnemyPositionHint:(CGPoint)enemyPosition;
// REQUIRES: self != nil
// MODIFIES: self
// EFFECTS: Update the bullet to move toward enemy


@end
