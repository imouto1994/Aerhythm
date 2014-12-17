#import <SpriteKit/SpriteKit.h>
#import "Utilities.h"

@implementation Utilities

#pragma mark - Bitmap Contexts

#pragma mark - Data Maps
+ (void *)createDataMap:(NSString *)mapFileName {
    // EFFECTS: Loads an image with input name and creates a game data map
    
    UIImage * uiImage = [UIImage imageNamed: mapFileName];
    if (!uiImage) {
        NSLog(@"UIImage imageWithContentsOfFile failed on file %@", mapFileName);
        return nil;
    }
    
    CGImageRef inImage = CGImageRetain(uiImage.CGImage);
    // Create the bitmap context.
    CGContextRef cgctx = [Utilities createARGBBitmapContext:inImage];
    
    if (cgctx == NULL) {    // error creating context
        return NULL;
    }
    
    // Get image width, height. We'll use the entire image.
    size_t width = CGImageGetWidth(inImage);
    size_t height = CGImageGetHeight(inImage);
    CGRect rect = CGRectMake(0, 0, width, height);
    
    // Draw the image to the bitmap context. Once we draw, the memory
    // allocated for the context for rendering will then contain the
    // raw image data in the specified color space.
    CGContextDrawImage(cgctx, rect, inImage);
    
    // Now we can get a pointer to the image data associated with the bitmap context.
    void * data = CGBitmapContextGetData(cgctx);
    [Utilities flipARGBImageData:data withWidth:width andHeight:height];
    
    // When finished, release the context.
    CGContextRelease(cgctx);
    
    return data;
}

+ (CGContextRef)createARGBBitmapContext:(CGImageRef)inImage {
    CGContextRef context = NULL;
    
    // Get image width, height. We'll use the entire image.
    size_t pixelsWide = CGImageGetWidth(inImage);
    size_t pixelsHigh = CGImageGetHeight(inImage);
    
    // Declare the number of bytes per row. Each pixel in the bitmap in this
    // example is represented by 4 bytes; 8 bits each of red, green, blue, and
    // alpha.
    int bitmapBytesPerRow = (int)(pixelsWide * 4);
    int bitmapByteCount = (int)(bitmapBytesPerRow * pixelsHigh);
    
    // Use the generic RGB color space.
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    if (colorSpace == NULL) {
        fprintf(stderr, "Error allocating color space\n");
        return NULL;
    }
    
    // Allocate memory for image data. This is the destination in memory
    // where any drawing to the bitmap context will be rendered.
    void * bitmapData = malloc(bitmapByteCount);
    if (bitmapData == NULL) {
        fprintf(stderr, "Memory not allocated!");
        CGColorSpaceRelease(colorSpace);
        return NULL;
    }
    
    // Create the bitmap context. We want pre-multiplied ARGB, 8-bits
    // per component. Regardless of what the source image format is
    // (CMYK, Grayscale, and so on) it will be converted over to the format
    // specified here by CGBitmapContextCreate.
    context = CGBitmapContextCreate(bitmapData,
                                    pixelsWide,
                                    pixelsHigh,
                                    8,      // bits per component
                                    bitmapBytesPerRow,
                                    colorSpace,
                                    (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    if (context == NULL) {
        free(bitmapData);
        fprintf(stderr, "Context not created!");
    }
    
    // When finished, release the colorspace before returning.
    CGColorSpaceRelease(colorSpace);
    
    return context;
}

+ (void)flipARGBImageData:(void *)data withWidth:(NSUInteger)width andHeight:(NSUInteger)height {
    NSUInteger strideRow = width * 4;
    NSUInteger strideCol = 4;
    uint8_t * imageData = (uint8_t *)data;
    
    for (NSUInteger row = 0; row < height; row++) {
        NSUInteger oppositeRow = height - 1 - row;
        if (oppositeRow <= row) {
            break;
        }
        
        // Swap the two row
        for (NSUInteger col = 0; col < width; col++) {
            for (NSUInteger depth = 0; depth < 4; depth++) {
                uint8_t temp = imageData[row * strideRow + col * strideCol + depth];
                imageData[row * strideRow + col * strideCol + depth] = imageData[oppositeRow * strideRow +
                                                                                 col * strideCol + depth];
                imageData[oppositeRow * strideRow + col * strideCol + depth] = temp;
            }
        }
    }
}

+ (BOOL)areSameRGBColor:(RGBColor)colorOne and:(RGBColor)colorTwo {
    // EFFECTS: returns YES if the two RGB colors are the same; returns NO otherwise
    
    if (colorOne.red == colorTwo.red && colorOne.green == colorTwo.green &&
        colorOne.blue == colorTwo.blue) {
        return YES;
    }
    
    return NO;
}

+ (MPMediaItem *)querySongWithSongName:(NSString *)songName
                         andArtistName:(NSString *)artistName {
    // EFFECTS: Finds and returns a song with the given name and artists in the user's music library
    
    MPMediaQuery * query = [[MPMediaQuery alloc] init];
    // Get all Media Items into an Array (Fast)
    NSArray * allTracks = [query items];
    for(MPMediaItem * song in allTracks) {
        NSString * currentSongName = [song valueForProperty:MPMediaItemPropertyTitle];
        NSString * currentArtistName = [song valueForProperty:MPMediaItemPropertyArtist];
        if([currentSongName isEqual:songName] &&
           ((!currentArtistName && !artistName) || ([currentArtistName isEqual:artistName]))) {
            return song;
        }
    }
    
    return nil;
}

#pragma mark - DOCUMENT FOLDER
+ (void)removeTempFilesFromDocuments {
    // EFFECTS: Remove the temp files from the Document directory
    
    NSError * error;
    // Get the documents folder of your sandbox
    NSArray * dirFiles;
    if ((dirFiles = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:
                     [Utilities documentsDirectory] error:&error]) == nil) {
        [NSException raise:@"Document File Retrieve Error" format:@"Cannot retrieve the files in document directory"];
    };
    
    // Find the files with the extensions you want
    NSArray * mp3Files = [dirFiles filteredArrayUsingPredicate:
                          [NSPredicate predicateWithFormat:@"self ENDSWITH '.mp3'"]];
    NSArray * m4aFiles = [dirFiles filteredArrayUsingPredicate:
                          [NSPredicate predicateWithFormat:@"self ENDSWITH '.m4a'"]];
    NSArray * m4pFiles = [dirFiles filteredArrayUsingPredicate:
                          [NSPredicate predicateWithFormat:@"self ENDSWITH '.m4p'"]];
    
    // Loop on arrays and delete every file corresponds to specific filename
    for (NSString * fileName in mp3Files) {
        if (![[NSFileManager defaultManager] removeItemAtPath:
              [[Utilities documentsDirectory] stringByAppendingPathComponent:fileName]
                                                        error:&error]) {
            [NSException raise:@"Remove File Error" format:@"Cannot remove a mp3 file"];
        }
    }
    
    for (NSString * fileName in m4aFiles) {
        if (![[NSFileManager defaultManager] removeItemAtPath:
              [[Utilities documentsDirectory] stringByAppendingPathComponent:fileName]
                                                        error:&error]) {
            [NSException raise:@"Remove File Error" format:@"Cannot remove a m4a file"];
        }
    }
    for (NSString * fileName in m4pFiles) {
        if (![[NSFileManager defaultManager] removeItemAtPath:
              [[Utilities documentsDirectory] stringByAppendingPathComponent:fileName]
                                                        error:&error]) {
            [NSException raise:@"Remove File Error" format:@"Cannot remove a m4p file"];
        }
    }
}

+ (NSString *)documentsDirectory {
    // EFFECTS: Get the path to the document directory
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentDirectory = [paths objectAtIndex:0];
    return documentDirectory;
}

#pragma mark - Create SK nodes
+ (SKEmitterNode *)createEmitterNodeWithEmitterNamed:(NSString *)emitterFileName {
    return [NSKeyedUnarchiver unarchiveObjectWithFile:
            [[NSBundle mainBundle] pathForResource:emitterFileName ofType:@"sks"]];
}

#pragma mark - Load Image
+ (UIImage *)loadImageWithName:(NSString *)imageName {
    // REQUIRES: imageName != nil
    // EFFECTS: Loads an image with the input name
    
    return [[UIImage alloc] initWithContentsOfFile:
            [[NSBundle mainBundle] pathForResource:imageName ofType:@"png"]];
}

#pragma mark - Animation
+ (void)spinImageView:(UIImageView *)imageView
          withOptions:(UIViewAnimationOptions)option
            withDelay:(CGFloat)delay {
    // EFFECTS: Spins an image view with specific ease options and delay duration
    
    if(option == UIViewAnimationOptionCurveEaseIn) {
        [UIView animateWithDuration:20.0f
                              delay:delay
                            options:option
                         animations:^{
                             imageView.transform = CGAffineTransformRotate(imageView.transform, M_PI / 2.0);
                         }
                         completion:^(BOOL finished) {
                             if(finished){
                                 [self spinImageView:imageView
                                         withOptions:UIViewAnimationOptionCurveLinear
                                           withDelay:0.0];
                             }
                         }];
    } else {
        [UIView animateWithDuration:15.0f
                              delay:delay
                            options:option
                         animations:^{
                             imageView.transform = CGAffineTransformRotate(imageView.transform, M_PI / 2.0);
                         }
                         completion:^(BOOL finished) {
                             if(finished){
                                 [self spinImageView:imageView
                                         withOptions:UIViewAnimationOptionCurveLinear
                                           withDelay:0.0];
                             }
                         }];
    }
}

+ (void)showMessage:(NSString *)inputMessage
          withColor:(UIColor *)color
            andSize:(CGFloat)size
  fromOriginalFrame:(CGRect)originalFrame
        withOffsetX:(CGFloat)offsetX
         andOffsetY:(CGFloat)offsetY
             inView:(UIView *)view
       withDuration:(CGFloat)duration {
    // EFFECTS: Shows message with given attributes
    
    __block UILabel * message = [[UILabel alloc] init];
    [message setText:inputMessage];
    [message setTextAlignment:NSTextAlignmentCenter];
    [message setFont:[UIFont fontWithName:@"Futura (Light)" size:size]];
    [message setFrame:originalFrame];
    [message setTextColor:color];
    [message setAlpha:0.0];
    [view addSubview:message];
    [UIView animateWithDuration:0.5
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [message setFrame:CGRectMake(originalFrame.origin.x + offsetX, originalFrame.origin.y + offsetY, originalFrame.size.width, originalFrame.size.height)];
                         [message setAlpha:1.0];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.5
                                               delay:duration
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              [message setFrame:originalFrame];
                                              [message setAlpha:0.0];
                                          }
                                          completion:^(BOOL finished){
                                              [message removeFromSuperview];
                                              message = nil;
                                          }];
                     }];
}

+ (void)showBackgroundSongInfo:(NSString *)songName
                     andArtist:(NSString *)artistName
                        inView:(UIView *)view {
    // EFFECTS: Shows the song background info in a specific given view

    // Setup background music info view
    __block UIView * backgroundInfoView = [[UIView alloc] initWithFrame:CGRectMake(0, 1024, 476, 100)];
    // Info background
    UIImage * backgroundInfoImage = [Utilities loadImageWithName:@"backgroundMusicInfoBoard"];
    UIImageView * backgroundInfoImageView = [[UIImageView alloc] initWithImage:backgroundInfoImage];
    [backgroundInfoImageView setFrame:CGRectMake(0, 0, 476, 100)];
    // Info song name
    UILabel * backgroundSongNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 330, 30)];
    backgroundSongNameLabel.textColor = [UIColor whiteColor];
    [backgroundSongNameLabel setFont:[UIFont fontWithName:@"Futura (Light)" size:20]];
    backgroundSongNameLabel.text = songName;
    // Info artist name
    UILabel * backgroundArtistNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, 300, 30)];
    backgroundArtistNameLabel.textColor = [UIColor whiteColor];
    [backgroundArtistNameLabel setFont:[UIFont fontWithName:@"Futura (Light)" size:20]];
    backgroundArtistNameLabel.text = artistName;
    
    [backgroundInfoView addSubview:backgroundInfoImageView];
    [backgroundInfoView addSubview:backgroundSongNameLabel];
    [backgroundInfoView addSubview:backgroundArtistNameLabel];
    [view addSubview:backgroundInfoView];
    
    CGRect originalFrame = [backgroundInfoView frame];
    [UIView animateWithDuration:0.75
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [backgroundInfoView setFrame:CGRectMake(originalFrame.origin.x,originalFrame.origin.y - originalFrame.size.height, originalFrame.size.width, originalFrame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.75
                                               delay:2.0
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              [backgroundInfoView setFrame:originalFrame];
                                          }
                                          completion:^(BOOL finished){
                                              [backgroundInfoView removeFromSuperview];
                                              backgroundInfoView = nil;
                                          }];
                     }];
}

+ (void)showProgressComplete:(NSString *)message inView:(UIView *)view {
    // EFFECTS: Show the message for complete uploading or downloading progress in a specific view
    
    __block UIView * progressResultView = [[UIView alloc] initWithFrame:CGRectMake(0, 1024, 310, 65)];
    // Image background for progress result
    UIImage * backgroundResultImage = [Utilities loadImageWithName:@"backgroundMusicInfoBoard"];
    UIImageView * backgroundResultImageView = [[UIImageView alloc] initWithImage:backgroundResultImage];
    [backgroundResultImageView setFrame:CGRectMake(-100, 0, 476, 100)];
    // Result message
    UILabel * resultMessageLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 30, 450, 30)];
    resultMessageLabel.textColor = [UIColor whiteColor];
    [resultMessageLabel setFont:[UIFont fontWithName:@"Futura (Light)" size:23]];
    resultMessageLabel.text = message;
    
    [progressResultView addSubview:backgroundResultImageView];
    [progressResultView addSubview:resultMessageLabel];
    [view addSubview:progressResultView];
    
    CGRect originalFrame = [progressResultView frame];
    [UIView animateWithDuration:0.75
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         [progressResultView setFrame:CGRectMake(originalFrame.origin.x,originalFrame.origin.y - originalFrame.size.height, originalFrame.size.width, originalFrame.size.height)];
                     }
                     completion:^(BOOL finished) {
                         [UIView animateWithDuration:0.75
                                               delay:2.0
                                             options:UIViewAnimationOptionCurveEaseInOut
                                          animations:^{
                                              [progressResultView setFrame:originalFrame];
                                          }
                                          completion:^(BOOL finished) {
                                              [progressResultView removeFromSuperview];
                                              progressResultView = nil;
                                          }];
                     }];
}

@end
