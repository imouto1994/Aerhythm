#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>

#define QUARTER_PERCENT 0
#define HALF_PERCENT 1
#define THIRD_QUARTER_PERCENT 2

@protocol OnsetDetectorDelegate <NSObject>
// OVERVIEW: This is the delegate protocol for the onset detector. The delegate has the responsibility to show the current progress of
// detecting the onsets in the input audio

-(void) showCurrentSongProcess:(NSInteger) finishingPercent;
// EFFECTS: Show the current progress of processing the input audio

-(void) finishProcessing;
// EFFECTS: Notify the delegate that the music processing has ended

@end

@interface OnsetDetector : NSObject
// OVERVIEW: This class is used to detect the onset in a song by processing its music using the Aubio Framework

// The delegate
@property (weak, nonatomic) id<OnsetDetectorDelegate> delegate;
// The file path for audio input
@property (nonatomic, strong, readonly) NSString *filePath;

- (void) importSongFromURL:(NSURL*)url andTitle:(NSString*)title;
// REQUIRES: self != nil
// EFFECTS: Import the song from the given source URL
// Then, it will start process the audio input

-(void) getOnsetDataFromSongURL:(NSString *)songFilePath;
// REQUIRES: self != nil
// EFFECTS: Get the onset data after processing it from the audio given by its file path

-(NSArray *) getOnsetData;
// REQUIRES: self != nil
// EFFECTS: Get the processed onset data

@end

