

//#define TESTING

#import "common.h"
#import "defines.h"

#import "GetClasses.h"


#import "SearchEngineNavigationController.h"

#import "SearchEngineParser.h"
#import "EngineManager.h"



@implementation SearchEngineNavigationController

id SearchEngineNavigationController$shared;

+ (id) sharedNavigationController
{
	if(!SearchEngineNavigationController$shared)
	{
		SearchEngineNavigationController$shared = [[self alloc] initWithControllerDelegate: nil];
	}
	return SearchEngineNavigationController$shared;
}

- (id) initWithControllerDelegate: (id) delegate;
{
	//GETCLASS(PopoverSizingTableViewController);
	tvc = [[$PopoverSizingTableViewController alloc] initWithStyle: UITableViewStylePlain];
	
	self = [super init];
	
	if(!self.viewControllers)
		self.viewControllers = [[NSMutableArray alloc] init];
	
	[self pushViewController: tvc animated: NO];
	
	MSHookIvar<Class>(self, "_navigationBarClass") = [UINavigationBar class];
	MSHookIvar<UIModalTransitionStyle>(self, "_modalTransitionStyle") = (UIModalTransitionStyle) ((1<<31)-1);
	
	tvc.title = @"Search Engines";
	
	((UITableView*) tvc.tableView).dataSource = self;
	((UITableView*) tvc.tableView).delegate = self;

	
	_controllerDelegate = [delegate retain];
	
	return self;
}

- (void) setControllerDelegate: (id) delegate
{
	_controllerDelegate = [delegate retain];
}

-(UITableView*) tableView
{
	NSType(tvc.tableView);
	return tvc.tableView;
}


-(void)popoverController:(id)controller willPresentAfterRotationToInterfaceOrientation:(int)interfaceOrientation;
{
	float xpos = interfaceOrientation>2 ? 510.f : 418.f;
	[controller setPresentationRect: (CGRect){xpos, 0.0f, 48.0f, 48.0f}];//{150.0f, 0.0f, 26.0f, 48.0f}];
//	[controller setPresentationRect: (CGRect){xpos, 10.0f, 48.0f, 80.0f}];//{150.0f, 0.0f, 26.0f, 48.0f}];
}

-(void)popoverControllerDidDismissPopover:(id)popoverController
{
//	GETCLASS(BrowserController);
	id sharedBC = [$BrowserController sharedBrowserController];
	[sharedBC dismissCurrentPopover];
}

/*
 - (CGSize) contentSizeForViewInPopoverView
 {
 NSLine();
 return [super contentSizeForViewInPopoverView];
 //	return _sizeForBiewInPopoverView
 //	return (CGSize){320.0f, 200.0f};
 }
 */

- (float) _minimumHeightInPopoverView
{
	NSLine();
	return 100.0f;
}


-(void) scrollViewWillBeginDragging: (id) scrollView
{
	SelLog();
	if(![[UIDevice currentDevice] isWildcat])
	{
//		GETCLASS(BrowserController);
		id sharedBC = [$BrowserController sharedBrowserController];
		id addressView = [sharedBC addressView];
		id firstResponder = [addressView firstResponder];
		id &_responderForEditingWithoutFirstResponder(MSHookIvar<id>(addressView, "_responderForEditingWithoutFirstResponder"));
		_responderForEditingWithoutFirstResponder = firstResponder;
		
		[firstResponder resignFirstResponder];
		
	//	[[objc_getClass("UIKeyboard") activeKeyboard] minimize];
	}
}


-(void)tableView:(id)view didSelectRowAtIndexPath:(id)indexPath
{
	
	EngineManager* sharedMgr = [EngineManager sharedInstance];
	
	if([indexPath section])
	{
		[sharedMgr addGrepEngine];
		
		[view insertRowsAtIndexPaths: [NSArray arrayWithObject: [NSIndexPath indexPathForRow: [sharedMgr engineCount]-1 inSection: 0]] withRowAnimation:  UITableViewRowAnimationFade];
//		[view deleteRowsAtIndexPaths: [NSArray arrayWithObject: indexPath] withRowAnimation: UITableViewRowAnimationFade];
//		[self tableView: view cellForRowAtIndexPath: ];
		
		
		//- (id) tableView: (id) tv cellForRowAtIndexPath: (NSIndexPath*) indexPath

//		[view reloadData];
		return;
	}
	
	NSDictionary* rowDict = [sharedMgr engineAtIndex: [indexPath row]];
	
	 NSString* newEngine;
	newEngine = [rowDict objectForKey: @"xmlurl"];
	
	/*
	switch([indexPath row])
	{
		case 0:
			newEngine = @"http://mycroft.mozdev.org/installos.php/14909/google.xml";
			break;
		case 1:
			newEngine = @"http://mycroft.mozdev.org/opensearch.xml";
			break;
		case 2:
			newEngine = @"http://static.thepiratebay.org/opensearch.xml";
			break;
		case 3:
			newEngine = @"http://mycroft.mozdev.org/installos.php/28561/wikipedia.xml";
			break;
		case 4:
			newEngine = @"http://digg.com/opensearch.xml";
			break;
			//		case 5:
			//		text = @"Facebook";
			//		break;
	}
	*/
	if(newEngine)
	{
		[sharedMgr setActiveEngine: newEngine];
	}
	//if(newEngine)
	//	[[[SearchEngineParser alloc] initWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: newEngine]]] release];
	
//	GETCLASS(BrowserController);
	id sharedBC = [$BrowserController sharedBrowserController];
	[sharedBC dismissCurrentPopover];
	[[self tableView] removeFromSuperview];
	id addressView = [sharedBC addressView];
	
	id &_responderForEditingWithoutFirstResponder(MSHookIvar<id>(addressView, "_responderForEditingWithoutFirstResponder"));
	if(_responderForEditingWithoutFirstResponder)
	{
		[_responderForEditingWithoutFirstResponder becomeFirstResponder];
		_responderForEditingWithoutFirstResponder = nil;
	}
	
//	[self dismiss];
}

- (void) dismiss
{
//	GETCLASS(BrowserController);
	id sharedBC = [$BrowserController sharedBrowserController];
	[sharedBC dismissCurrentPopover];
	[[self tableView] removeFromSuperview];
	
//	GETCLASS(BrowserController);
//	id sharedBC = [$BrowserController sharedBrowserController];
	
	return;
	
//	if(_responderForEditingWithoutFirstResponder)
	
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	SelLog();
	
	if([indexPath section])
	{
		return;
	}
	
	if(editingStyle==	UITableViewCellEditingStyleDelete)
	{
		[[EngineManager sharedInstance] removeEngineAtIndex: [indexPath row]];
	}
	[tableView deleteRowsAtIndexPaths: [NSArray arrayWithObject: indexPath] withRowAnimation: UITableViewRowAnimationFade];

}
/*
- (void)deleteRowsAtIndexPaths:(NSArray *)indexPaths withRowAnimation:(UITableViewRowAnimation)animation;
{
	SelLog();
	NSIndexPath* indexPath = [indexPaths objectAtIndex: 0];
	[[EngineManager sharedInstance] removeEngineAtIndex: [indexPath row]];
	
	[super deleteRowsAtIndexPaths: [NSArray arrayWithObject: indexPath] withRowAnimation: animation];
}
*/

- (id) tableView: (id) tv cellForRowAtIndexPath: (NSIndexPath*) indexPath
{
	SelLog();
	
	UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: nil];
	
	NSString *text = nil;
	
	NSString *imageloc = nil;
	
	EngineManager* sharedMgr = [EngineManager sharedInstance];
	if([indexPath section])
	{
		text = [NSString stringWithFormat: @"Add %@", [sharedMgr grepEngineName]];
	}
	else
	{
		NSDictionary* rowDict = [sharedMgr engineAtIndex: [indexPath row]];
		
		NSLog(@"dict is %@", [rowDict description]);
		text = [rowDict objectForKey: @"name"];
		imageloc = [rowDict objectForKey: @"iconurl"];
		
		if(imageloc)
		{
			NSData *icondata = [rowDict objectForKey: @"icondata"];//[[NSData alloc] initWithContentsOfURL: [NSURL URLWithString: imageloc]];
			
			UIImage *image = icondata ? [[UIImage alloc] initWithData: icondata] : [[UIImage kitImageNamed: @"UISearchFieldIcon.png"] retain];
			cell.imageView.image = image;
		//	if(icondata)
		//		[image release];
		}
	}

	NSLog(@"text is %@", text);
	NSLog(@"imgate is %@", [[cell.imageView.image class] description]);
	
	cell.textLabel.text = text;

	return cell;
}

- (int) tableView: (id) tv numberOfRowsInSection: (NSInteger) section
{
	SelLog();
	
	if(section == 0)
	{
		return [[EngineManager sharedInstance] engineCount];
	}
	else if(section==1)
	{
		return [[EngineManager sharedInstance] grepEngineName] ? 1 : 0;
	}
	return 0;
//	return section<2 ? 5 : 0;
}

- (int) numberOfSectionsInTableView: (id) tv
{
	return [[EngineManager sharedInstance] grepEngineName] ? 2 : 1;
}

- (void) viewDidLoad
{
	SelLog();
	
	[super viewDidLoad];
	if([[UIDevice currentDevice] isWildcat])
	{
		CGRect nbframe = [[self navigationBar] frame];
		CGRect vframe = [[self view] frame];
		[[self navigationTransitionView] setFrame: vframe];//(CGRect) {0.0f, nbframe.origin.y, vframe.size.width, vframe.size.width-nbframe.size.height}]; //pretty peculiar
		
	}
}

- (void) viewWillAppear: (bool) animated
{
	SelLog();
	
	[super viewWillAppear: animated];
	[_controllerDelegate willShowBrowserPanel: self];
}

- (void) viewDidAppear: (bool) animated
{
	SelLog();
	
	[super viewDidAppear: animated];
	[_controllerDelegate didShowBrowserPanel: self];
}

- (void) viewWillDisappear: (bool) animated
{
	SelLog();
	
	[super viewWillDisappear: animated];
	if([_controllerDelegate browserPanel] == self)
	{
		[_controllerDelegate closeBrowserPanel: self];
	}
}

- (void) viewDidDisappear: (bool) animated
{
	SelLog();
	
	[super viewDidDisappear: animated];
	if([_controllerDelegate browserPanel] == self)
	{
		[_controllerDelegate didHideBrowserPanel: self];
	}
}

- (bool) shouldShowBrowserPanel
{
	SelLog();
	return YES;
}

- (int) panelState
{
	SelLog();
	return 3;
}

- (bool) pausesPages
{
	SelLog();
	return YES;
}

- (int) panelType
{
	SelLog();
	return 1;//1;
}

@end

