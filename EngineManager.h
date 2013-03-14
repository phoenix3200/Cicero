

@interface EngineManager : NSObject
{
	NSMutableArray* engines;
	NSString* activeEngine;
	
	NSString* activeGrepEngineXML;
	NSString* activeGrepEngineName;
}

+ (id) sharedInstance;
- (id) init;

- (void) resetPrefs;
- (void) updatePrefs;
- (void) setActiveEngine: (NSString*) newEngine;
- (NSDictionary*) engineAtIndex: (int) index;
- (int) engineCount;
- (NSDictionary*) currentEngine;

@end;