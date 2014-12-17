#import "OnsetDetector.h"
#import "TSLibraryImport.h"
#import "Onset.h"
#import "Utilities.h"
#include <aubio/aubio.h>

#define AUBIO_UNSTABLE 1
#define detect_method "default"

@interface OnsetDetector()

// The file path for imported song
@property (strong, nonatomic, readwrite) NSString *filePath;

@end

@implementation OnsetDetector{
    // Data to keep track of processing onset
    aubio_onset_t * onset;
    fvec_t * in;
    fvec_t * out;
    aubio_source_t * source;
    
    // Onset Data Storage
    NSMutableArray *onsetData;
}

-(id) init{
    // MODIFIES: self
    // EFFECTS: Override init() method from superclass
    
    self = [super init];
    if(self){
        onsetData = [NSMutableArray array];
        _filePath = nil;
    }
    return self;
}

-(NSArray *) getOnsetData{
    // EFFECTS: Return the processed data
    
    return [onsetData copy];
}

-(void) importSongFromURL:(NSURL*)assetURL andTitle:(NSString*)title{
    // EFFECTS: Import the song from the given source URL and then start processing the data of this audio
    
    // Remove previous copied temporary files in Document directory
    [Utilities removeTempFilesFromDocuments];
    title = [self replaceSpaceWith:@"-" fromString:title];
    if (assetURL) {
        // Create destination URL
        NSString* ext = [TSLibraryImport extensionForAssetURL:assetURL];
        NSString*filePath = [[Utilities documentsDirectory] stringByAppendingPathComponent:title];
        NSURL* destinationURL = [[NSURL fileURLWithPath:filePath] URLByAppendingPathExtension:ext];
        
        // Start importing
        TSLibraryImport *tsImport = [[TSLibraryImport alloc] init];
        [tsImport importAsset:assetURL toURL:destinationURL completionBlock:^(TSLibraryImport *theImport) {
            NSString *path = [[destinationURL absoluteString] lastPathComponent];
            NSString *fname = [[Utilities documentsDirectory] stringByAppendingPathComponent:path];
            [self getOnsetDataFromSongURL: fname];
        }];
    }
}

-(char *) getCharArrayFromFilename:(NSURL *)pFilename {
    // EFFECTS: Convert the given url to a character array
    
    NSString *path = [NSString stringWithFormat:@"%@",[pFilename relativePath]];
    char *temp = (char *)[path UTF8String];
    return temp;
}


- (void)cleanUpMemory {
    // EFFECTS: Clean up memory
    
    del_aubio_onset(onset);
    del_fvec(in);
    del_fvec(out);
    del_aubio_source(source);
    
    // Notify finishing processing through the delegate
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.delegate finishProcessing];
    });
}

- (void)updateProgress:(float)duration {
    // EFFECTS: Update the progress of processing through the delegate
    
    dispatch_async(dispatch_get_main_queue(), ^{
        float progress = (aubio_onset_get_last_s(onset)/duration);
        if(progress > 0.75){
            [self.delegate showCurrentSongProcess:THIRD_QUARTER_PERCENT];
        } else if(progress > 0.5){
            [self.delegate showCurrentSongProcess:HALF_PERCENT];
        } else if(progress > 0.25){
            [self.delegate showCurrentSongProcess:QUARTER_PERCENT];
        }
    });
}

-(void) getOnsetDataFromSongURL:(NSString *)songFilePath {
    // REQUIRES: self != nil
    // EFFECTS: Get the onset data after processing it from the audio given by its file path
    
    onsetData = [NSMutableArray array];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^(void){
        // Get file path
        _filePath = [songFilePath copy];
        NSURL *pFilename = [NSURL URLWithString:songFilePath];
        
        // Setup data for processing
        NSData *data = [NSData dataWithContentsOfFile:songFilePath];
        if (data == nil) {
            NSLog(@"Song data is nil");
        } else {
            NSLog(@"Data is OK");
        }
        NSError *error = nil;
        AVAudioPlayer *player =[[AVAudioPlayer alloc] initWithData:data error:&error];
        if (error) {
            NSLog(@"error AVAudioPlayer %@",error.description);
        }
        float duration = player.duration;
        uint_t samplerate =  (uint_t)[[player.settings valueForKeyPath:@"AVSampleRateKey"] longValue];
        uint_t win_size = 1024; // window size
        uint_t n_frames = 0, read = 0;
        uint_t hop_size = win_size / 8;
        
        char_t *source_path = [self getCharArrayFromFilename:pFilename];
        source = new_aubio_source(source_path, samplerate, hop_size);
        
        if (samplerate == 0 ){
            samplerate = aubio_source_get_samplerate(source);
        }
        in = new_fvec (hop_size); // Input audio buffer
        out = new_fvec (2); // Output position
        
        // Create the onset object for detection
        onset = new_aubio_onset(detect_method, win_size, hop_size, samplerate);
        aubio_onset_set_threshold(onset, 0.45);
        aubio_onset_set_silence(onset, -55.0);
        
        uint_t currentFrame = 0;
        smpl_t currentTime = 0;
        NSMutableArray *onsetRate = [NSMutableArray array];
        
        // Start processing
        do {
            // Reload for new data
            aubio_source_do(source, in, &read);
            // Processing onset
            aubio_onset_do(onset,in,out);
            // Get the average onset at each detected frame
            if(aubio_onset_get_last(onset) != currentFrame){ // new onset
                if((int) currentFrame >= 0){ // valid onset
                    [onsetData addObject:[[Onset alloc] initWithTime:currentTime andRate:onsetRate]];
                }
                currentTime = aubio_onset_get_last_s(onset);
                currentFrame = aubio_onset_get_last(onset);
                onsetRate = [NSMutableArray array];
                [onsetRate addObject:[NSNumber numberWithDouble:aubio_onset_get_descriptor(onset)]];
            } else if(aubio_onset_get_last(onset) == currentFrame){
                [onsetRate addObject:[NSNumber numberWithDouble:aubio_onset_get_descriptor(onset)]];
            }
            [self updateProgress:duration];
            n_frames += read;
        } while ( read == hop_size);
        
        [self cleanUpMemory];
    });
}

#pragma mark - STRING MODIFICATION
-(NSString *) replaceSpaceWith:(NSString *)string fromString:(NSString *)str {
    // EFFECTS: Replace all space characters from the given string with another string
    
    str = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    while ([str rangeOfString:@" "].location != NSNotFound) {
        str = [str stringByReplacingOccurrencesOfString:@" " withString:string];
    }
    // Remove symbol which will affect the file path
    str = [self stringToReplace:@"\"" inString:str];
    str = [self stringToReplace:@"/" inString:str];
    str = [self stringToReplace:@"'" inString:str];
    
    return str;
}

-(NSString*) stringToReplace:(NSString*)stringRepleace inString:(NSString*)str {
    // EFFECTS: Replace all given substring occurrences in the given string with dash character
    
    while ([str rangeOfString:stringRepleace].location != NSNotFound) {
        str = [str stringByReplacingOccurrencesOfString:stringRepleace withString:@"-"];
    }
    return str;
}

@end
