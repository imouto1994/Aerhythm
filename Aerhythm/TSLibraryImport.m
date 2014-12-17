#import "TSLibraryImport.h"
#import <AVFoundation/AVFoundation.h>

@interface TSLibraryImport()

+(BOOL) validIpodLibraryURL:(NSURL*)url;
// EFFECTS: Check if the given URL is a valid url for the library in the device

-(void) extractQuicktimeMovie:(NSURL*)movieURL toFile:(NSURL*)destURL;
// EFFECTS: Extract the quick time movie file from the given source url to the assigned destination

@end

@implementation TSLibraryImport

+(BOOL) validIpodLibraryURL:(NSURL*)url {
    // EFFECTS: Check if the given url is a valid url for the ipod library
    
	NSString* IPOD_SCHEME = @"ipod-library";
	if (url == nil){
        return NO;
    }
	if (url.scheme == nil){
        return NO;
    }
	if ([url.scheme compare:IPOD_SCHEME] != NSOrderedSame) {
        return NO;
    }
	if ([url.pathExtension compare:@"mp3"] != NSOrderedSame &&
		[url.pathExtension compare:@"aif"] != NSOrderedSame &&
		[url.pathExtension compare:@"m4a"] != NSOrderedSame &&
		[url.pathExtension compare:@"wav"] != NSOrderedSame) {
		return NO;
	}
	return YES;
}

+(NSString*) extensionForAssetURL:(NSURL*)assetURL {
    // EFFECTS: Pass in the NSURL* you get from an MPMediaItem's MPMediaItemPropertyAssetURL property to get the file's extension.
    
	if (nil == assetURL){
		@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"nil assetURL" userInfo:nil];
    }
	if (![TSLibraryImport validIpodLibraryURL:assetURL]){
		@throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"Invalid iPod Library URL: %@", assetURL] userInfo:nil];
    }
	return assetURL.pathExtension;
}

-(void) doMp3ImportToFile:(NSURL*)destURL completionBlock:(void (^)(TSLibraryImport* import))completionBlock {
    // EFFECTS: Start import the given file to destination url with a given completion block
    
	NSURL* tmpURL = [[destURL URLByDeletingPathExtension] URLByAppendingPathExtension:@"mov"];
	[[NSFileManager defaultManager] removeItemAtURL:tmpURL error:nil];
	exportSession.outputURL = tmpURL;
	
	exportSession.outputFileType = AVFileTypeQuickTimeMovie;
	[exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
		if (exportSession.status == AVAssetExportSessionStatusFailed) {
			completionBlock(self);
		} else if (exportSession.status == AVAssetExportSessionStatusCancelled) {
			completionBlock(self);
		} else {
			@try {
				[self extractQuicktimeMovie:tmpURL toFile:destURL];
			}
			@catch (NSException * e) {
				OSStatus code = noErr;
				if ([e.name compare:TSUnknownError]) code = kTSUnknownError;
				else if ([e.name compare:TSFileExistsError]) code = kTSFileExistsError;
				NSDictionary* errorDict = [NSDictionary dictionaryWithObject:e.reason forKey:NSLocalizedDescriptionKey];
				
				movieFileErr = [[NSError alloc] initWithDomain:TSLibraryImportErrorDomain code:code userInfo:errorDict];
			}
			//clean up the tmp .mov file
			[[NSFileManager defaultManager] removeItemAtURL:tmpURL error:nil];
			completionBlock(self);
		}
		[exportSession release];
		exportSession = nil;
	}];
}

- (void)importAsset:(NSURL*)assetURL toURL:(NSURL*)destURL completionBlock:(void (^)(TSLibraryImport* import))completionBlock {
    // EFFECTS: Import the given asset from source |assetURL| to the |destURL|.
    // After finishing importing, a given completion block will be executed.
    
	if (nil == assetURL || nil == destURL){
		@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"nil url" userInfo:nil];
    }
	if (![TSLibraryImport validIpodLibraryURL:assetURL]){
		@throw [NSException exceptionWithName:NSInvalidArgumentException reason:[NSString stringWithFormat:@"Invalid iPod Library URL: %@", assetURL] userInfo:nil];
    }
    
	if ([[NSFileManager defaultManager] fileExistsAtPath:[destURL path]]){
        @throw [NSException exceptionWithName:TSFileExistsError reason:[NSString stringWithFormat:@"File already exists at url: %@", destURL] userInfo:nil];
    }
	
	NSDictionary * options = [[NSDictionary alloc] init];
	AVURLAsset* asset = [AVURLAsset URLAssetWithURL:assetURL options:options];
	if (nil == asset){
		@throw [NSException exceptionWithName:TSUnknownError reason:[NSString stringWithFormat:@"Couldn't create AVURLAsset with url: %@", assetURL] userInfo:nil];
    }
	
	exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetPassthrough];
	if (nil == exportSession){
		@throw [NSException exceptionWithName:TSUnknownError reason:@"Couldn't create AVAssetExportSession" userInfo:nil];
	}
    
	if ([[assetURL pathExtension] compare:@"mp3"] == NSOrderedSame) {
		[self doMp3ImportToFile:destURL completionBlock:completionBlock];
		return;
	}
    
	exportSession.outputURL = destURL;
	
	// Set the output file type appropriately based on asset URL extension
	if ([[assetURL pathExtension] compare:@"m4a"] == NSOrderedSame) {
		exportSession.outputFileType = AVFileTypeAppleM4A;
	} else if ([[assetURL pathExtension] compare:@"wav"] == NSOrderedSame) {
		exportSession.outputFileType = AVFileTypeWAVE;
	} else if ([[assetURL pathExtension] compare:@"aif"] == NSOrderedSame) {
		exportSession.outputFileType = AVFileTypeAIFF;
	} else {
		@throw [NSException exceptionWithName:NSInvalidArgumentException reason:@"unrecognized file extension" userInfo:nil];
	}
    
	[exportSession exportAsynchronouslyWithCompletionHandler:^(void) {
		completionBlock(self);
		[exportSession release];
		exportSession = nil;
	}];
}

-(void) extractQuicktimeMovie:(NSURL*)movieURL toFile:(NSURL*)destURL {
	// EFFECTS: Extract the data from the quick time movie in the source url to the destination url
    
    FILE* src = fopen([[movieURL path] cStringUsingEncoding:NSUTF8StringEncoding], "r");
	if (NULL == src) {
		@throw [NSException exceptionWithName:TSUnknownError reason:@"Couldn't open source file" userInfo:nil];
		return;
	}
	char atom_name[5];
	atom_name[4] = '\0';
	unsigned long atom_size = 0;
	while (true) {
		if (feof(src)) {
			break;
		}
		fread((void*)&atom_size, 4, 1, src);
		fread(atom_name, 4, 1, src);
		atom_size = ntohl(atom_size);
        const size_t bufferSize = 1024*100;
		if (strcmp("mdat", atom_name) == 0) {
			FILE* dst = fopen([[destURL path] cStringUsingEncoding:NSUTF8StringEncoding], "w");
			unsigned char buf[bufferSize];
			if (NULL == dst) {
				fclose(src);
				@throw [NSException exceptionWithName:TSUnknownError reason:@"Couldn't open destination file" userInfo:nil];
			}
            
            atom_size -= 8;
            while (atom_size != 0) {
                size_t read_size = (bufferSize < atom_size)?bufferSize:atom_size;
                if (fread(buf, read_size, 1, src) == 1) {
                    fwrite(buf, read_size, 1, dst);
                }
                atom_size -= read_size;
            }
			fclose(dst);
			fclose(src);
			return;
		}
		if (atom_size == 0){
			break;
        }
		fseek(src, atom_size, SEEK_CUR);
	}
	fclose(src);
	@throw [NSException exceptionWithName:TSUnknownError reason:@"Didn't find mdat chunk"  userInfo:nil];
}

-(NSError*) error {
    // EFFECTS: Return the error in the transferring session
    
	if (movieFileErr) {
		return movieFileErr;
	}
	return exportSession.error;
}

- (AVAssetExportSessionStatus)status {
    // EFFECTS: Return the status of the transport session
    
	if (movieFileErr) {
		return AVAssetExportSessionStatusFailed;
	}
	return exportSession.status;
}

- (float)progress {
    // EFFECTS: Return the current progress
    
	return exportSession.progress;
}

- (void)dealloc {
    // MODIFIES: self
    // EFFECTS: Release the memory
    
	[exportSession release];
	[movieFileErr release];
	[super dealloc];
}
@end
