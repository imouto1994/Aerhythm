//
//  LocalGiftSongs.m
//  Aerhythm
//
//  Created by Nguyen Truong Duy on 17/4/14.
//  Copyright (c) 2014 nus.cs3217. All rights reserved.
//

#import "LocalGiftSongs.h"
#import "Utilities.h"
#import <dispatch/dispatch.h>

static NSString * const kGiftSongListFileName = @"giftSongList.plist";
static NSString * const kGiftSongListKey = @"giftSongList";

@implementation LocalGiftSongs

static dispatch_queue_t storeGiftSongQueue;

+ (void)initialize {
    storeGiftSongQueue = dispatch_queue_create("giftSongQueue", NULL);
}

+ (NSArray *)getLocalGiftSongList {
    // EFFECTS: Gets and returns an array of gift songs stored locally. Each element is an NSDictionary
    //          with keys LOCAL_SONG_NAME_KEY, LOCAL_SONG_ARTIST_KEY, and LOCAL_SONG_PATH_KEY
    
    NSArray * localGiftSongList = [[NSArray alloc] init];
    
    NSString * documentPath = [Utilities documentsDirectory];
    NSString * plistPath = [documentPath stringByAppendingPathComponent:kGiftSongListFileName];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:plistPath]) {
        NSDictionary * plistContent = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
        localGiftSongList = [plistContent objectForKey:kGiftSongListKey];
    }
    
    return localGiftSongList;
}

+ (void)deleteGiftSong:(NSDictionary *)songInfo {
    if (![LocalGiftSongs existGiftSongWithName:songInfo[kLocalSongNameKey]
                                     andArtist:songInfo[kLocalSongArtistKey]]) {
        return;
    }
    
    dispatch_async(storeGiftSongQueue, ^{
        NSFileManager * fileManager = [NSFileManager defaultManager];
        NSString * songFilePath = [songInfo objectForKey:kLocalSongPathKey];
        if([fileManager fileExistsAtPath:songFilePath]){
            NSLog(@"Check");
            [fileManager removeItemAtPath:songFilePath error:nil];
        }
        NSMutableArray * localGiftSongList = [[NSMutableArray alloc]
                                              initWithArray:[LocalGiftSongs getLocalGiftSongList]];
        [localGiftSongList removeObject:songInfo];
        NSDictionary * giftSongListDict = [NSDictionary dictionaryWithObject:localGiftSongList
                                                                      forKey:kGiftSongListKey];
        NSString * plistPath = [[Utilities documentsDirectory]
                                stringByAppendingPathComponent:kGiftSongListFileName];
        [giftSongListDict writeToFile:plistPath atomically:YES];
    });
}

+ (void)storeGiftSongWithName:(NSString *)songName
                    andArtist:(NSString *)songArtist
                      andData:(NSData *)songData {
    // EFFECTS: Stores locally the gift song with the input name, artist and song data
    
    if (!songArtist) {
        songArtist = @"";
    }
    
    dispatch_async(storeGiftSongQueue, ^(void) {
        // Name the local file
        NSDate * nowDate = [NSDate date];
        NSString * fileName = [NSString stringWithFormat:@"localGift_%lu.dat",
                               (long)[nowDate timeIntervalSince1970]];
        NSString * documentsPath = [Utilities documentsDirectory];
        NSString * songDataPath = [documentsPath stringByAppendingPathComponent:fileName];
        
        NSMutableDictionary * localSongInfo = [[NSMutableDictionary alloc] init];
        [localSongInfo setObject:songName forKey:kLocalSongNameKey];
        [localSongInfo setObject:songArtist forKey:kLocalSongArtistKey];
        [localSongInfo setObject:songDataPath forKey:kLocalSongPathKey];
        
        NSMutableArray * localGiftSongList = [[NSMutableArray alloc]
                                              initWithArray:[LocalGiftSongs getLocalGiftSongList]];
        
        
        // Save the song data
        if ([songData writeToFile:songDataPath atomically:YES]) {
            // Update the gift song list on local storage
            [localGiftSongList addObject:localSongInfo];
            NSDictionary * giftSongListDict = [NSDictionary dictionaryWithObject:localGiftSongList
                                                                          forKey:kGiftSongListKey];
            
            NSString * plistPath = [documentsPath stringByAppendingPathComponent:kGiftSongListFileName];
            [giftSongListDict writeToFile:plistPath atomically:YES];
        } else {
            NSLog(@"Error writing song %@ data to file %@", songName, songDataPath);
        }
        
    });
}

+ (BOOL)existGiftSongWithName:(NSString *)songName andArtist:(NSString *)songArtist {
    // EFFECTS: Returns true if there exists a song with the given name and artist in the list of local
    //          gift songs

    if ([LocalGiftSongs queryLocalGiftSongWithName:songName andArtist:songArtist]) {
        return YES;
    }
    
    return NO;
}

+ (NSDictionary *)queryLocalGiftSongWithName:(NSString *)songName
                                   andArtist:(NSString *)songArtist {
    // REQUIRES: songName != nil
    // EFFECTS: Gets the local gift song information that matches the input song name and artist.
    //          The song information is an NSDictionary with keys LOCAL_SONG_NAME_KEY,
    //          LOCAL_SONG_ARTIST_KEY, and LOCAL_SONG_PATH_KEY
    
    if (!songArtist) {
        songArtist = @"";
    }
    
    NSArray * giftSongList = [LocalGiftSongs getLocalGiftSongList];
    for (NSDictionary * giftSong in giftSongList) {
        if ([giftSong[kLocalSongNameKey] isEqualToString:songName] &&
            [giftSong[kLocalSongArtistKey] isEqualToString:songArtist]) {
            return giftSong;
        }
    }
    
    return nil;
}

@end
