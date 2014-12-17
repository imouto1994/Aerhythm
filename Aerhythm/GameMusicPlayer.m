#import "GameMusicPlayer.h"
#import "Onset.h"

@interface GameMusicPlayer()

// The actual music player
@property (strong, nonatomic, readwrite) AVAudioPlayer *musicPlayer;
// The processed music data
@property (strong, nonatomic, readwrite) NSArray *musicData;

@end

@implementation GameMusicPlayer{
    // The current counter for checking music data
    int counter;
    // The current onset
    Onset *currentOnset;
    // The current audio URL
    NSURL *fileURL;
    // The current time in audio playing
    NSTimeInterval lastCurrentTime;
}

-(id) initWithMusicData:(NSArray *)musicData andFilePath:(NSString *)filePath{
    // MODIFIES: self
    // EFFECTS: Initialize the object with an assigned music data and its corresponding file path
    
    self = [super init];
    if(self){
        _musicData = musicData;
        fileURL = [NSURL fileURLWithPath:filePath];
        lastCurrentTime = 0.0;
        counter = 0;
    }
    return self;
}

-(void) play{
    // REQUIRES: self != nil
    // EFFECTS: Start playing the assigned music audio
    
    if(_musicPlayer == nil){
        _musicPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
        _musicPlayer.currentTime = lastCurrentTime;
        _musicPlayer.pan = 0.0;
        _musicPlayer.numberOfLoops = -1;
    }
    [_musicPlayer setCurrentTime:lastCurrentTime];
    [_musicPlayer play];
}

-(void) reset{
    lastCurrentTime = 0;
}

-(void) pause{
    // REQUIRES: self != nil
    // EFFECTS: Pause playing the music audio
    
    lastCurrentTime = _musicPlayer.currentTime;
    [_musicPlayer pause];
}

-(void) fadeOut{
    if(_musicPlayer.volume > 0.1){
        _musicPlayer.volume -= 0.02;
        [self performSelector:@selector(fadeOut) withObject:nil afterDelay:0.1];
    } else {
        _musicPlayer = nil;
    }
}


-(void) stopForBackground{
    // REQUIRES: self != nil
    // EFFECTS: Remove audio before entering background
    
    if(_musicPlayer != nil){
        lastCurrentTime = _musicPlayer.currentTime;
        [_musicPlayer stop];
        _musicPlayer = nil;
    }
}

-(void) updateOnset{
    // REQUIRES: self != nil
    // EFFECTS: Update the current processed onset data
    
    NSTimeInterval currentTime = _musicPlayer.currentTime;
    currentOnset = _musicData[counter];
    while(currentTime > currentOnset.time){
        counter++;
        if(counter >= [_musicData count]){
            currentOnset = _musicData[0];
            break;
        } else {
            currentOnset = _musicData[counter];
        }
    }
    if(counter > 0){
        counter--;
    }
    currentOnset = _musicData[counter];
}

-(BulletType) determineBulletType{
    // REQUIRES: self != nil
    // EFFECTS: Determine the bullet type for player jet

    switch (currentOnset.strength) {
        case VERY_WEAK:
            return kPlayerBullet1;
            break;
        case WEAK:
            return kPlayerBullet2;
            break;
        case WEAKER_MEDIUM:
            return kPlayerBullet3;
            break;
        case MEDIUM:
            return kPlayerBullet4;
            break;
        case STRONGER_MEDIUM:
            return kPlayerBullet5;
            break;
        case STRONG:
            return  kPlayerBullet6;
            break;
        case VERY_STRONG:
            return kPlayerBullet7;
            break;
    }
}

-(CGFloat) getAdditionalSpeedForEnemyBullet{
    // REQUIRES: self != nil
    // EFFECTS: Determine the current additional speed for enemy bullets
    
    switch (currentOnset.strength) {
        case VERY_WEAK:
            return 0;
            break;
        case WEAK:
            return 100;
            break;
        case WEAKER_MEDIUM:
            return 200;
            break;
        case MEDIUM:
            return 300;
            break;
        case STRONGER_MEDIUM:
            return 400;
            break;
        case STRONG:
            return 500;
            break;
        case VERY_STRONG:
            return 600;
            break;
    }
}

-(NSTimeInterval) getCurrentTime{
    // REQUIRES: self != nil
    // EFFECTS: Get the current time in the music player
    
    return self.musicPlayer.currentTime;
}

@end
