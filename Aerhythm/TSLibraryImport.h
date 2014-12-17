#define TSLibraryImportErrorDomain @"TSLibraryImportErrorDomain"

#define TSUnknownError @"TSUnknownError"
#define TSFileExistsError @"TSFileExistsError"

#define kTSUnknownError -65536
#define kTSFileExistsError -48 //dupFNErr

typedef NSInteger AVAssetExportSessionStatus;

@class AVAssetExportSession;

@interface TSLibraryImport : NSObject {
	// OVERVIEW: This class is used to import the files between 2 locations in the device.
    // This class interface and implementation are provided by TapSquare.
    
    AVAssetExportSession* exportSession;
	NSError* movieFileErr;
}

// Error in the the transfer process
@property (readonly) NSError* error;
// Status of the transfer session
@property (readonly) AVAssetExportSessionStatus status;
// The current progress
@property (readonly) float progress;

+(NSString*) extensionForAssetURL:(NSURL*)assetURL;
// EFFECTS: Pass in the NSURL* you get from an MPMediaItem's MPMediaItemPropertyAssetURL property to get the file's extension.

-(void) importAsset:(NSURL*)assetURL toURL:(NSURL*)destURL completionBlock:(void (^)(TSLibraryImport* import))completionBlock;
// EFFECTS: Import the given asset from source |assetURL| to the |destURL|.
// After finishing importing, a given completion block will be executed.

@end
