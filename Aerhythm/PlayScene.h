#import <SpriteKit/SpriteKit.h>
#import "GameMusicPlayer.h"
#import "GameAchievement.h"
#import "LightningBolt.h"

#define kHeightHPBar 55

// The basic layers to contains sub-nodes in the game
typedef NS_ENUM(NSInteger, WorldLayer){
    kBackgroundLayer = 0,
    kEnemyLayer = 1,
    kPlayerLayer = 2,
    kHUDLayer = 3,
    kBlurLayer = 4,
    kLayerCount = 5
};

@class PlayerJet;

// Completion Block when successfully load all assets
typedef void (^AssetLoadCompletionHandler)(void);

@protocol PlaySceneDelegate <NSObject>
// OVERVIEW: This is the protocol for the delegate of the scene. It has the responsibility to show current progress of loading scene assets or handling when the game scene ends.

- (void)showCurrentLoadingAssetProgressAt:(NSInteger) progress;
// EFFECTS: Show the current progress of loading assets

- (void)gameDidEnd;
//EFFECTS: Notify that the game has ended through the delegate

- (void)updateManaView:(NSInteger)counter;

@end

@interface PlayScene : SKScene
// OVERVIEW: This is the main scene for in-game screen

// The world node which contains all other nodes
@property (strong, nonatomic, readonly) SKSpriteNode * world;
// The player node
@property (strong, nonatomic, readonly) PlayerJet * playerJet;
// The music player
@property (strong, nonatomic) GameMusicPlayer * musicPlayer;

@property (nonatomic) float gameScore;
// Game score gained during the game

// Game achievement manager
@property (strong, nonatomic) GameAchievement * gameAchievement;

// Delegate for loading scene
@property (weak, nonatomic) id<PlaySceneDelegate> delegate;

/* Build game world */
- (void)buildGameWorld;

/* Load Scene Assets */
- (void)loadSceneAssetsWithCompletionHandler:(AssetLoadCompletionHandler)callback;
// EFFECTS: Loads all assets with an assigned completion block

- (void)loadSceneAssets;
// EFFECTS: Load all assets

+ (void)releaseLevelSharedAssets;
// EFFECTS: Releases all unncessary shared assets for level

+ (void)releaseModelSharedAssets;
// EFFECTS: Releases all unnecessary shared assets for model

+ (void)releaseBackgroundAssets;
// EFFECTS: Releases all background image assets

- (void)addNode:(SKNode *)node atWorldLayer:(WorldLayer)layer;
// REQUIRES: self != nil
// MODIFIES: self
// EFFECTS: Adds a node at an assigned layer

- (SKNode *)getWorldLayer:(WorldLayer)layer;
// REQUIRES: self != nil
// EFFECTS: Gets the specified layer node

- (void)applyDamage:(CGFloat)damage WithRadius:(CGFloat)radius FromPosition:(CGPoint)position;
// REQUIRES: self != nil, radius >= 0
// MODIFIES: self
// EFFECTS: apply damage to all enemy jets with radius from a position

- (void)increaseGamescoreBy:(float)score;
// EFFECT: increase game score by input score

- (void)increaseManaBy:(float)mana;
// EFFECTS: Increase player jet's mana

- (void)increaseEnemyKilled;
// EFFECT: increase number of enemies killed;

- (void)addAchievementToScore;
// EFFECT: add points earned from achievement to game score

- (void)playerDidUseRevival;
// EFFECT: notify game achievement manager that player obtained a powerup

- (void)playerDidKillBoss;
// EFFECT: notify game achievement manager that player killed boss

- (void)killAllEnemiesExceptBoss;
// EFFECT: kill all enemies on the screen except for boss enemy

- (LightningBolt*)addLightningBoltAimedAtPlayerWithLifetime:(CGFloat)lifetime
                                           andLineDrawDelay:(CGFloat)lineDrawDelay
                                               andThickness:(CGFloat)thickness;

- (void)shake:(NSInteger)times
 atAmplitudeX:(NSInteger)amplitudeX
andAmplitudeY:(NSInteger)amplitudeY;

- (void)pauseGame;
// REQUIRES: self != nil
// MODIFIES: self
// EFFECTS: Pause game

- (void)resumeGame;
// REQUIRES: self != nil
// MODIFIES: self
// EFFECTS: Resume game

- (void)pauseGameForBackground;
// REQUIRES: self != nil
// MODIFIES: self
// EFFECTS: Pause game before entering background

- (void)performSpecialMove;

+ (void)setNumBackground:(NSUInteger)numBackground;
// EFFECTS: Sets the number of background images of this level

+ (void)setLevelId:(NSUInteger)newLevelId;
// EFFECTS: Sets the level id to this scene

+ (NSUInteger)sLevelId;
// EFFECTS: Gets the level id

@end
