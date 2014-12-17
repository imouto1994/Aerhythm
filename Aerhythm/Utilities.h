#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "Constant.h"

@class SKEmitterNode;

@interface Utilities : NSObject

+ (void *)createDataMap:(NSString *)mapFileName;
// EFFECTS: Loads an image with input name and creates a game data map

+ (BOOL)areSameRGBColor:(RGBColor)colorOne and:(RGBColor)colorTwo;
// EFFECTS: returns YES if the two RGB colors are the same; returns NO otherwise

+ (SKEmitterNode *)createEmitterNodeWithEmitterNamed:(NSString *)emitterFileName;
// EFFECTS: Creates an emitter node with given file name

+ (UIImage *)loadImageWithName:(NSString *)imageName;
// REQUIRES: imageName != nil
// EFFECTS: Loads an image with the input name

+ (MPMediaItem *)querySongWithSongName:(NSString *)songName
                         andArtistName:(NSString *)artistName;
// EFFECTS: Finds and returns a song with the given name and artists in the user's music library

+ (NSString *)documentsDirectory;
// EFFECTS: Gets the path to the document directory

+ (void)removeTempFilesFromDocuments;
// EFFECTS: Removes the temp files from the Document directory

+ (void)spinImageView:(UIImageView *)imageView
          withOptions:(UIViewAnimationOptions)option
            withDelay:(CGFloat) delay;
// EFFECTS: Spins an image view with specific ease options and delay duration

+ (void)showMessage:(NSString *)inputMessage
          withColor:(UIColor *)color
            andSize:(CGFloat)size
  fromOriginalFrame:(CGRect)originalFrame
        withOffsetX:(CGFloat)offsetX
         andOffsetY:(CGFloat)offsetY
             inView:(UIView *) view
       withDuration:(CGFloat) duration;
// EFFECTS: Shows message with given attributes

+ (void)showBackgroundSongInfo:(NSString *)songName
                     andArtist:(NSString *)artistName
                        inView:(UIView *)view;
// EFFECTS: Shows the song background info in a specific given view

+ (void)showProgressComplete:(NSString *)message
                      inView:(UIView *)view;
// EFFECTS: Shows the message for complete uploading or downloading progress in a specific view

@end
