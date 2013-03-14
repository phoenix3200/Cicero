

//#define TESTING

#import "common.h"
#import "defines.h"

#import "GetClasses.h"

#import "EngineManager.h"

#import "SearchEngineParser.h"



typedef struct
{
	NSString* xmlURL;
//	NSString* name;
//	NSString* iconURL;
//	NSString* searchURL;
}search_engine;

//#define fixed_engine_cnt 5

NSString* fixed_engines[] =
{
	@"http://mycroft.mozdev.org/installos.php/14909/google.xml",
	@"http://mycroft.mozdev.org/installos.php/28561/wikipedia.xml",
	@"http://mycroft.mozdev.org/opensearch.xml",
	@"http://mycroft.mozdev.org/installos.php/32415/bing.xml",
	@"http://mycroft.mozdev.org/installos.php/13110/youtube.xml",
	@"http://mycroft.mozdev.org/installos.php/13127/IMDb.xml",
	nil
};


@implementation EngineManager

static EngineManager* shared = nil;
+ (id) sharedInstance
{
	if(!shared)
	{
		shared = [[EngineManager alloc] init];
	}
	return shared;
}

- (id) init
{
	if(self = [super init])
	{
		//NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
		//NSDictionary* sspprefs = [defaults persistentDomainForName:@"com.phoenix.ssp"];
		
		NSDictionary* sspprefs = [[NSDictionary alloc] initWithContentsOfFile: @"/var/mobile/Library/Safari/BrowserSearch.plist"];
		
		engines = [[sspprefs objectForKey: @"SearchEngines"] retain];
		if(!engines)
		{
			NSLog(@"resetting prefs");
			[self resetPrefs];
			[self updatePrefs];
		}
		else
		{
			[self setActiveEngine: [sspprefs objectForKey: @"activeEngine"]];
			// set this up...how?
			//activeEngine = [[sspprefs objectForKey: @"activeEngine"] retain];
		}
		[sspprefs release];
	}
	return self;
}

- (void) resetPrefs
{
	[engines release];
	engines = [[NSMutableArray alloc] init];
	
	SearchEngineParser* parser = [[SearchEngineParser alloc] init];
	
	for(int i=0; fixed_engines[i]; i++)//fixed_engines[i].xmlURL; i++)
	{
		NSString *xmlURL = fixed_engines[i];//.xmlURL;
		NSDictionary* dict = [parser processURL: xmlURL];
		/*
		NSMutableDictionary* dict = [[NSMutableDictionary alloc] init];
		
		[dict setObject: forKey:
		
		 NSData *imagedata = [[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: currIcon ? currIcon : @"http://www.google.com/favicon.ico"]];
		 UIImage *image = [[UIImage alloc] initWithData: imagedata];

		
		NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:
							  ,		@"xmlurl",
							  fixed_engines[i].name,		@"name",
							  fixed_engines[i].iconURL,		@"iconurl",
							  fixed_engines[i].searchURL,	@"searchurl",
							  nil];
		 
		*/
		[engines addObject: dict];
	}
	[self setActiveEngine: fixed_engines[0]];//@"http://mycroft.mozdev.org/installos.php/14909/google.xml"];
}


- (void) updatePrefs
{
	NSDictionary* dict = [[NSDictionary alloc] initWithObjectsAndKeys:
						  engines, @"SearchEngines",
						  activeEngine, @"activeEngine",
						  nil];
	
	[dict writeToFile: @"/var/mobile/Library/Safari/BrowserSearch.plist" atomically: YES];
	
	notify_post("com.phoenix.cicero");
	
	/*
	NSUserDefaults* defaults = [NSUserDefaults standardUserDefaults];
	[defaults setPersistentDomain: dict forName: @"com.phoenix.ssp"];	
	[defaults synchronize];
	*/
	
	
	[dict release];
}

- (bool) containsEngine: (NSString*) xmlURL
{
	for(NSDictionary* dict in engines)
	{
		if([[dict objectForKey: @"xmlurl"] isEqualToString: xmlURL])
			return YES;
	}
	return NO;
}

- (void) addSearchEngineObject: (NSDictionary*) engine
{
	[engines addObject: engine];
	[self updatePrefs];	
}

- (void) addSearchEngine: (NSString*) xmlURL
{
	SearchEngineParser* parser = [[SearchEngineParser alloc] init];
	NSDictionary* engine = [parser processURL: xmlURL];
	[parser release];
	[engines addObject: engine];
	[self updatePrefs];
}

- (void) removeEngineAtIndex: (int) index
{
	SelLog();
	NSLine();
	
	if(index <= [engines count])
	{
		if([[[engines objectAtIndex: index] objectForKey: @"xmlurl"] isEqualToString: activeEngine])
		{
			[self setActiveEngine: [[engines objectAtIndex: 0] objectForKey: @"xmlurl"]];
		}
		
		[engines removeObjectAtIndex: index];
	}
	[self updatePrefs];
}

- (void) setActiveEngine: (NSString*) newEngine
{
	NSLine();
	
	
	[activeEngine release];
	activeEngine = [newEngine retain];
	// more initialization crap
	
	[self updatePrefs];
	
	NSDictionary* currEngine = [self currentEngine];
	
	//[[[EngineManager sharedInstance] currentEngine] objectForKey: @"iconData"];
	
//	GETCLASS(BrowserController);
	UIView* _addressView;
	
	id sharedBC = [$BrowserController sharedBrowserController];

	NSType(sharedBC);
	
	object_getInstanceVariable(sharedBC, "_addressView", reinterpret_cast<void **> (&_addressView));
	
	NSType(_addressView);
	
	UITextField *_searchTextField;
	object_getInstanceVariable(_addressView, "_searchTextField", reinterpret_cast<void **> (&_searchTextField));
	
	NSType(_searchTextField);
	
	NSData* iconData = [currEngine objectForKey: @"icondata"];
	UIImage *image = iconData ? [[UIImage alloc] initWithData: iconData] : [UIImage kitImageNamed: @"UISearchFieldIcon.png"];
	
	NSString* name = [currEngine objectForKey: @"name"];
	
//	[_addressView updateSearchEngineStrings];
	
	if(_searchTextField)
	{
		NSLine();
		[[_searchTextField leftView] setImage: image forState: 0];		
		
		[_searchTextField setPlaceholder: name];
		[_searchTextField setReturnKeyType: UIReturnKeySearch];
		
//		[_searchTextField setNeedsLayout];
	}
	
//	if(iconData)
//		[image release];			
}

- (NSString*) grepEngineName
{
	return activeGrepEngineName;
}

- (void) addGrepEngine
{
	[self addSearchEngine: activeGrepEngineXML];
}

- (void) setGrepEngineName: (NSString*) name xml: (NSString*) xml
{
	[activeGrepEngineXML release];
	activeGrepEngineXML = [xml retain];
	[activeGrepEngineName release];
	activeGrepEngineName = [name retain];
}


- (NSDictionary*) engineAtIndex: (int) index
{
	if(index <= [engines count])
	{
		return [engines objectAtIndex: index];
	}
	return nil;
}

- (int) engineCount
{
	SelLog();
	
	return [engines count];
}

- (NSDictionary*) currentEngine
{
	for(NSDictionary* dict in engines)
	{
		if([[dict objectForKey: @"xmlurl"] isEqualToString: activeEngine])
			return dict;
	}
	return nil;
}


@end

