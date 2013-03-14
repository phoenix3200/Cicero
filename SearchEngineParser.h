//
//  SearchEngineParser.h
//  ssp
//
//  Created by Public Nuisance on 2/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//



//extern NSString* currIcon;
//extern bool currIconDirty;
//extern NSString* currUrl;
//extern NSString* currName;


@interface SearchEngineParser : NSObject
{
	NSXMLParser* _xmlParser;
	
	NSString* lastKey;
	
	//NSDictionary* xmlProperties;
	NSMutableDictionary* engine;
	
//	NSString** currPtr;
//	NSString* ShortName;
//	NSString* LongName;
//	NSString* Description;
	
};

- (SearchEngineParser*) initWithData: (NSData*) data;

@end
