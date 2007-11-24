//
//  BufferChain.m
//  CogNew
//
//  Created by Vincent Spader on 1/4/06.
//  Copyright 2006 Vincent Spader. All rights reserved.
//

#import "BufferChain.h"
#import "OutputNode.h"
#import "AudioSource.h"
#import "CoreAudioUtils.h"

@implementation BufferChain

- (id)initWithController:(id)c
{
	self = [super init];
	if (self)
	{
		controller = c;
		streamURL = nil;
		userInfo = nil;

		inputNode = nil;
		converterNode = nil;
	}
	
	return self;
}

- (void)buildChain
{
	[inputNode release];
	[converterNode release];
	
	inputNode = [[InputNode alloc] initWithController:self previous:nil];
	converterNode = [[ConverterNode alloc] initWithController:self previous:inputNode];
	
	finalNode = converterNode;
}

- (BOOL)open:(NSURL *)url withOutputFormat:(AudioStreamBasicDescription)outputFormat
{	
	[self setStreamURL:url];

	[self buildChain];
	
	id<CogSource> source = [AudioSource audioSourceForURL:url];
	NSLog(@"Opening: %@", url);
	if (![source open:url])
	{
		NSLog(@"Couldn't open source...");
		return NO;
	}

	if (![inputNode openWithSource:source])
		return NO;

	if (![converterNode setupWithInputFormat:propertiesToASBD([inputNode properties]) outputFormat:outputFormat])
		return NO;

//		return NO;

	return YES;
}

- (BOOL)openWithInput:(InputNode *)i withOutputFormat:(AudioStreamBasicDescription)outputFormat
{
	NSLog(@"New buffer chain!");
	[self buildChain];

	if (![inputNode openWithDecoder:[i decoder]])
		return NO;
	
	NSLog(@"Input Properties: %@", [inputNode properties]);
	if (![converterNode setupWithInputFormat:propertiesToASBD([inputNode properties]) outputFormat:outputFormat])
		return NO;
		
	return YES;
}

- (void)launchThreads
{
	NSLog(@"Properties: %@", [inputNode properties]);

	[inputNode launchThread];
	[converterNode launchThread];
}

- (void)setUserInfo:(id)i
{
	[i retain];
	[userInfo release];
	userInfo = i;
}

- (id)userInfo
{
	return userInfo;
}

- (void)dealloc
{
	[userInfo release];
	[streamURL release];
	
	[inputNode release];
	[converterNode release];

	NSLog(@"Bufferchain dealloc");
	
	[super dealloc];
}

- (void)seek:(double)time
{
	long frame = time * [[[inputNode properties] objectForKey:@"sampleRate"] floatValue];

	[inputNode seek:frame];
}

- (BOOL)endOfInputReached
{
	return [controller endOfInputReached:self];
}

- (BOOL)setTrack: (NSURL *)track
{
	return [inputNode setTrack:track];
}

- (void)initialBufferFilled:(id)sender
{
	NSLog(@"INITIAL BUFFER FILLED");
	[controller launchOutputThread];
}

- (void)inputFormatDidChange:(AudioStreamBasicDescription)format
{
	NSLog(@"FORMAT DID CHANGE!");
}


- (InputNode *)inputNode
{
	return inputNode;
}

- (id)finalNode
{
	return finalNode;
}

- (NSURL *)streamURL
{
	return streamURL;
}

- (void)setStreamURL:(NSURL *)url
{
	[url retain];
	[streamURL release];

	streamURL = url;
}

- (void)setShouldContinue:(BOOL)s
{
	[inputNode setShouldContinue:s];
	[converterNode setShouldContinue:s];
}

@end
