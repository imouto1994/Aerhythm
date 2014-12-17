#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "Constant.h"

@interface GameMusicPlayer : NSObject
// OVERVIEW: This is the music player in the game. It has the purpose to determine the current bullet type for player jet or additional speed for enemy jet bullet.

-(id) initWithMusicData:(NSArray *)musicData andFilePath:(NSString *)filePath;
// MODIFIES: self
// EFFECTS: Initialize the object with an assigned music data and its corresponding file path

-(void) updateOnset;
// REQUIRES: self != nil
// EFFECTS: Update the current processed onset data

-(CGFloat) getAdditionalSpeedForEnemyBullet;
// REQUIRES: self != nil
// EFFECTS: Determine the current additional speed for enemy bullets

-(BulletType) determineBulletType;
// REQUIRES: self != nil
// EFFECTS: Determine the bullet type for player jet

-(void) play;
// REQUIRES: self != nil
// EFFECTS: Start playing the assigned music audio

-(void) pause;
// REQUIRES: self != nil
// EFFECTS: Pause playing the music audio

-(void) fadeOut;
// REQUIRES: self != nil
// EFFECTS: Fade out the currently playing music

-(void) reset;
// REQUIRES: self != nil
// EFFECTS: Reset the currently played music audio

-(void) stopForBackground;
// REQUIRES: self != nil
// EFFECTS: Remove audio before entering background

-(NSTimeInterval) getCurrentTime;
// REQUIRES: self != nil
// EFFECTS: Get the current time in the music player

@end
