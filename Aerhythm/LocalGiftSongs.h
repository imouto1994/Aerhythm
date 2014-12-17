//
//  LocalGiftSongs.h
//  Aerhythm
//
//  Created by Nguyen Truong Duy on 17/4/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import <Foundation/Foundation.h>

static NSString const * kLocalSongNameKey = @"songName";
static NSString const * kLocalSongArtistKey = @"songArtist";
static NSString const * kLocalSongPathKey = @"dataPath";

@interface LocalGiftSongs : NSObject

+ (NSArray *)getLocalGiftSongList;
// EFFECTS: Gets and returns an array of gift songs stored locally. Each element is an NSDictionary
//          with keys LOCAL_SONG_NAME_KEY, LOCAL_SONG_ARTIST_KEY, and LOCAL_SONG_PATH_KEY

+ (void)deleteGiftSong:(NSDictionary *)songInfo;
// EFFECTS: Deletes the local gift song with the specified name and artist if it exists.

+ (void)storeGiftSongWithName:(NSString *)songName
                    andArtist:(NSString *)songArtist
                      andData:(NSData *)songData;
// EFFECTS: Stores locally the gift song with the input name, artist and song data

+ (BOOL)existGiftSongWithName:(NSString *)songName andArtist:(NSString *)songArtist;
// EFFECTS: Returns true if there exists a song with the given name and artist in the list of local
//          gift songs

+ (NSDictionary *)queryLocalGiftSongWithName:(NSString *)songName
                                   andArtist:(NSString *)songArtist;
// REQUIRES: songName != nil
// EFFECTS: Gets the local gift song information that matches the input song name and artist.
//          The song information is an NSDictionary with keys LOCAL_SONG_NAME_KEY,
//          LOCAL_SONG_ARTIST_KEY, and LOCAL_SONG_PATH_KEY

@end
