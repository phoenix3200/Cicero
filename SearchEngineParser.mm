//
//  SearchEngineParser.mm
//  ssp
//
//  Created by Public Nuisance on 2/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

//#define TESTING

#import "common.h"
#import "defines.h"

#import "SearchEngineParser.h"

//#define NSLog(...)

NSString* currUrl;
NSString* currName;
NSString* currIcon;
bool currIconDirty;

@implementation SearchEngineParser

- (SearchEngineParser*) init //WithData: (NSData*) data
{
	self = [super init];
	return self;
}

- (NSDictionary*) processURL: (NSString*) xmlurl
{
	
	NSData* data = [NSData dataWithContentsOfURL: [NSURL URLWithString: xmlurl]];
	
	NSLog(@"about to parse: %@", [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding]);
	
	[engine release];
	
	engine = [[NSMutableDictionary alloc] init];
	
	[engine setObject: xmlurl forKey: @"xmlurl"];
	
	_xmlParser = [[NSXMLParser alloc] initWithData: data];
	[_xmlParser setDelegate: self];
	[_xmlParser setShouldProcessNamespaces:NO];
    [_xmlParser setShouldReportNamespacePrefixes:NO];
    [_xmlParser setShouldResolveExternalEntities:NO];
	
	lastKey = nil;
	[_xmlParser parse];
	[_xmlParser release];
	
	return engine;
	
}

- (void)parser:(NSXMLParser *)xmlParser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
	SelLog();
	NSLog(@"<%@> %@", elementName, namespaceURI);
	
	for (id key in attributeDict)
	{
		NSLog(@"  key: %@, value: %@", key, [attributeDict objectForKey:key]);
	}
	lastKey = [elementName retain];
	if([lastKey isEqualToString: @"Image"])
	{
		if( ![[attributeDict objectForKey: @"width"] isEqualToString: @"16"])
		{
			// don't accept
			[lastKey release];
			lastKey = nil;
		}
	}
	if([lastKey isEqualToString: @"Url"])
	{
		NSString* type = [attributeDict objectForKey: @"type"];
		NSString* rel = [attributeDict objectForKey: @"rel"];
		NSString* url = [attributeDict objectForKey: @"template"];
		
		if((!rel || [rel isEqualToString: @"results"]) && [type isEqualToString: @"text/html"])
		{
			NSLog(@"search url set to %@", url);
			
			[engine setObject: url forKey: @"searchurl"];
			
			//currUrl = [url retain];
			// need to replace {searchTerms}
		}
		else if([rel isEqualToString: @"suggestions"] && [type isEqualToString: @"application/json"])
		{
//			NSLog(@"%@", [attributeDict description]);
			[engine setObject: url forKey: @"sugg"];
//			currSugg = [url retain];
		}
		else if([type isEqualToString: @"application/x-suggestions+json"])
		{
			[engine setObject: url forKey: @"sugg"];
		}
				
	}
}

- (void)parser:(NSXMLParser *)xmlParser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	SelLog();
	[lastKey release];
	lastKey = nil;
//	NSLog(@"</%@> %@", elementName, namespaceURI);
}

- (void)parser:(NSXMLParser *)xmlParser foundCharacters:(NSString *)string
{
	SelLog();
	NSLog(@"  %@", string);
	if(lastKey)
	{
		NSLine();
		if([lastKey isEqualToString: @"Image"])
		{
			NSLine();
			
			[engine setObject: string forKey: @"iconurl"];
			
			
			NSData* iconData = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: string]];
			
			UIImage *image = [[UIImage alloc] initWithData: iconData];
			float scaleH = [image size].width / 16.0f;
			
			UIImage* newImage;
			{
				UIGraphicsBeginImageContext((CGSize){16.0f, 16.0f});
				[image drawInRect:CGRectMake(0, 0, 16.0f,16.0f)];
				newImage = UIGraphicsGetImageFromCurrentImageContext();    
				UIGraphicsEndImageContext();
			}
			NSData* iconData2 = UIImagePNGRepresentation(newImage);
			//NSData* iconData2 = UIImagePNGRepresentation([image _imageScaledToSize:(CGSize){16.0f, 16.0f} interpolationQuality: kCGInterpolationHigh]);
			[image release];
			
			[engine setObject: iconData2 forKey: @"icondata"];
			
			/*
			 
			[currIcon release];
			currIcon = [string retain];
			currIconDirty = TRUE;
			
			if(currIcon)
			{
				NSLog(@"current icon location is %@", currIcon);
			}
			
			
			GETCLASS(BrowserController);
			UIView* _addressView;
			object_getInstanceVariable([$BrowserController sharedBrowserController], "_addressView", reinterpret_cast<void **> (&_addressView));
			UITextField *_searchTextField;
			object_getInstanceVariable(_addressView, "_searchTextField", reinterpret_cast<void **> (&_searchTextField));
				
			NSData *imagedata = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: currIcon]];
			UIImage *image = [[UIImage alloc] initWithData: imagedata];
			if(_searchTextField)
			{
				UIImage *resized = [image _imageScaledToSize:(CGSize){16.0, 16.0} interpolationQuality: kCGInterpolationHigh];
				//[_searchTextField setIcon: resized];
				
				[[_searchTextField leftView] setImage: resized forState: 0];
				currIconDirty = FALSE;
				//((UITextField*)self).leftView = leftView;

				//UIImageView* leftView = ((UIImageView*)_searchTextField.leftView);
				//[leftView setImage: image];
				//[leftView sizeToFit];
			}
			[image release];			
			
			*/
			
//			layoutSubviews
			
		}
		if([lastKey isEqualToString: @"ShortName"])
		{
			[engine setObject: string forKey: @"name"];
			/*
			currName = [string retain];
			GETCLASS(BrowserController);
			UIView* _addressView;
			object_getInstanceVariable([$BrowserController sharedBrowserController], "_addressView", reinterpret_cast<void **> (&_addressView));
			[_addressView updateSearchEngineStrings];
			*/
			
			/*
			UITextField *_searchTextField;
			object_getInstanceVariable(_addressView, "_searchTextField", reinterpret_cast<void **> (&_searchTextField));
			_searchTextField.placeholder = string;
			*/
		}
		NSLine();
	}
	NSLine();
}


@end
