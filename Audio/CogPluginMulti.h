//
//  CogPluginMulti.h
//  CogAudio
//
//  Created by Christopher Snowhill on 10/21/13.
//
//

#import <Cocoa/Cocoa.h>
#import "Plugin.h"

@interface CogDecoderMulti : NSObject <CogDecoder> {
    NSArray *theDecoders;
    id<CogDecoder> theDecoder;
    NSMutableArray *cachedObservers;
}

-(id)initWithDecoders:(NSArray *)decoders;

@end

@interface CogContainerMulti : NSObject {
}

+ (NSArray *)urlsForContainerURL:(NSURL *)url containers:(NSArray *)containers;

@end

@interface CogMetadataReaderMulti : NSObject {
}

+ (NSDictionary *)metadataForURL:(NSURL *)url readers:(NSArray *)readers;

@end

@interface CogPropertiesReaderMulti : NSObject {
}

+ (NSDictionary *)propertiesForSource:(id<CogSource>)source readers:(NSArray *)readers;

@end
