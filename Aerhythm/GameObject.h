#import <SpriteKit/SpriteKit.h>
#import "Constant.h"

@class PlayScene;

@interface GameObject : SKSpriteNode
// OVERVIEW: This is an abstract class for all sprite nodes in the game

- (id)initAtPosition:(CGPoint)position;
// MODIFIES: self
// EFFECTS: Initialize the sprite node at an assigned position

- (void) update;
// MODIFIES: self
// EFFECTS: Update the state of the game object, this method is called for each game loop

- (void)initialize;
// MODIFIES: self
// EFFECTS: Setup the game object when it is first initialized

- (void)configurePhysicsBody;
// MODIFIES: self.physisBody
// EFFECTS: Configure the physic body of the game object when it is first initialized

- (void)collidedWith:(SKPhysicsBody *)other;
// MODIFIES: self
// EFFECTS: Handling method when there is a collision from this object's physic body with another object's one

- (void)collidedWithWall:(WallType)wall;
// REQUIRE: self != nil
// EFFECTS: Handle when the enemy jet is colliding with the wall

- (void)addToScene:(PlayScene *)scene;
// EFFECTS: Add this node to an assigned scene

- (PlayScene *)gameObjectScene;
// EFFECTS: Get the reference to the current scene that this game object is in

- (void)removeFromScene; 
// EFFECTS: Remove this node from the current game scene that it is in

- (void)removeEmitter:(SKEmitterNode*)emitter;
// EFFECTS: Remove the emitter from the node

- (void)removeChildWithTexture:(SKTexture*)texture;
// EFFECTS: Remove from the node all children that has the same texture as input texture

+ (void)loadSharedAssets;
// EFFECTS: Load all the shared assets that any instances of this class will use

+ (void)releaseSharedAssets;
// EFFECTS: Releases all shared assets that any instances of this class have loaded

@end
