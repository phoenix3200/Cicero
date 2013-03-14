//
//  PandoraHook.mm
//  PandoraHook
//
//  Created by Public Nuisance on 4/22/09.
//  Copyright __MyCompanyName__ 2009. All rights reserved.
//
//  MobileSubstrate, libsubstrate.dylib, and substrate.h are
//  created and copyrighted by Jay Freeman a.k.a saurik and 
//  are protected by various means of open source licensing.
//
//  Additional defines courtesy Lance Fetters a.k.a ashikase
//


//#define TESTING

#import "common.h"
#import "defines.h"
#import "GetClasses.h"


#import "ssp.h"

//#import "serialmgr.h"

#import "SearchEngineParser.h"

#import "SearchEngineNavigationController.h"

#import "EngineManager.h"







//#import "ActionMenu.h"

//#import "UIWebView.h"



//#import "UINavigationController.h"
//#import "UIImage.h"


extern "C"
{
	 UIImage* _UIImageWithName(NSString* name);
	
}




void ClassLogger(Class cls)
{
	NSLog(@"@interface %s : %s {", class_getName(cls), class_getName(class_getSuperclass(cls)));
	
	unsigned int nIvarList;
	Ivar* ivarList = class_copyIvarList(cls, &nIvarList);
	for(unsigned int i=0; i<nIvarList; i++)
	{
		NSLog(@"%s %s", ivar_getTypeEncoding(ivarList[i]), ivar_getName(ivarList[i]));
		
	}
	free(ivarList);
	
	NSLog(@"};");
	
	unsigned int nMethodList;
	Method* methodList = class_copyMethodList(cls, &nMethodList);
	for(unsigned int i=0; i<nMethodList; i++)
	{
		NSLog(@"%s %s", method_getTypeEncoding(methodList[i]), method_getName(methodList[i]));
		
	}
	
	NSLog(@"@end;");
	
	free(methodList);
	
	
}


@class ExtendedSearchField;

CGRect ExtendedSearchField$leftViewRectForBounds$(id self, SEL sel, CGRect bounds)
{
	return (CGRect){{10.0f, 8.0f}, {16.0, 16.0}};
	//return (CGRect){{30.0f, 8.0f}, {16.0, 16.0}};
	
}

CGRect ExtendedSearchField$_textRectExcludingButtonsForBounds$(id self, SEL sel, CGRect bounds)
{
	return (CGRect){{bounds.origin.x+3.0f, bounds.origin.y+2.0f}, {bounds.size.width-3.0f-11.0f, bounds.size.height-2.0f*2}};
}



HOOKDEF(void, ExtendedSearchField, layoutSubviews)
{
	HookLog();
	CALL_ORIG(ExtendedSearchField, layoutSubviews);
	
	UIPushButton* leftView = (UIPushButton*)((UITextField*)self).leftView;
	
	NSData* iconData = [[[EngineManager sharedInstance] currentEngine] objectForKey: @"icondata"];
	
	UIImage* currImage = iconData ? [[UIImage alloc] initWithData: iconData] : [UIImage kitImageNamed: @"UISearchFieldIcon.png"];
	
	NSType(currImage);
	
	
	if(!leftView)// || currIconDirty)
	{
		//currIconDirty = YES;
		//GETCLASS(UIPushButton);
		leftView = [[UIPushButton alloc] initWithFrame: (CGRect){(CGPoint){0.0f,0.0f},(CGSize){0.0f,0.0f}}];
		[leftView addTarget: self action: @selector(_leftButtonClicked:) forControlEvents: UIControlEventTouchUpInside];
		
		
		[leftView setImage: currImage forState: 0];
		[leftView sizeToFit];
		[leftView setOpaque: NO];
		[leftView setBackgroundColor: nil];
		[(UIView*) leftView setCharge: -0.15f];
		
		[((UITextField*)self) setLeftView: leftView];
		//leftView.frame.origin.x += 10.0f;
		[((UITextField*)self) setLeftViewMode: UITextFieldViewModeAlways];
		
		//[((UITextField*)self) _setLeftViewOffset: (CGPoint){3.0f, -5.0f}];
		
		[leftView setUserInteractionEnabled: YES];
	//	currIconDirty = NO;
	}
	
	//if(iconData)
	//	[currImage release];
	/*
	else if(currIconDirty)
	{
		[leftView setImage: currImage forState: 0];
		[leftView setNeedsDisplay];
	}
	*/
	NSLine();
}

@class TabController, TabDocument, WebHTMLView, DOMHTMLDocument, DOMHTMLCollection;



void GrepSearchEngine(id self, TabDocument* document)	
{
	NSString* activeGrepEngineXML = nil;
	NSString* activeGrepEngineName = nil;
	{
		UIWebDocumentView *view = [document browserView];//[document documentView];
		UIWebView *webView = [view webView];
		WebFrame *mainFrame = [webView mainFrame];
		WebHTMLView* documentView = [mainFrame documentView];
		DOMHTMLDocument *htmldoc = [mainFrame DOMDocument];
		
		
		
//		DOMRange* range = [mainFrame convertNSRangeToDOMRange:(NSRange) {2300, 20}];
		
//		[view selectDOMRange: range];
//		[mainFrame _scrollDOMRangeToVisible: range];
//		[view scrollSelectionToVisible: YES]; // meaningless null instruction
		
		
		if([htmldoc isKindOfClass: [DOMHTMLDocument class]])
		{
			DOMHTMLElement *htmlmainelem = [htmldoc documentElement];
			if([htmlmainelem isKindOfClass: $DOMHTMLHtmlElement])
			{
				DOMHTMLCollection *htmlmaincoll = [htmlmainelem children];
				
				int nMainColl = [htmlmaincoll length];
				for(int i=0; i<nMainColl; i++)
				{
					DOMHTMLElement *htmlheadelem = [htmlmaincoll item: i];
					//NSLog(@"Class type is %@", [[htmlheadelem class] description]);
					if([htmlheadelem isKindOfClass: $DOMHTMLHeadElement])
					{
						DOMHTMLCollection *htmlheadcoll = [htmlheadelem children];
						int nHeadColl = [htmlheadcoll length];
						for(int j=0; j<nHeadColl; j++)
						{
							DOMHTMLElement *htmlsubelem = [htmlheadcoll item: j];
							if([htmlsubelem isKindOfClass: $DOMHTMLLinkElement]
							   && [[htmlsubelem rel] isEqualToString: @"search"]
							   && [[htmlsubelem type] isEqualToString: @"application/opensearchdescription+xml"] )
							{
								NSLog(@"Found search! %@ %@ %@", [htmlsubelem title], [htmlsubelem href], [htmlsubelem target]);
								
								activeGrepEngineXML = [htmlsubelem href];
								activeGrepEngineName = [htmlsubelem title];
								//[[[SearchEngineParser alloc] initWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: [htmlsubelem href]]]] release];
							}
						}
					}
					if([htmlheadelem isKindOfClass: $DOMHTMLBodyElement])
					{
						DOMHTMLCollection *htmlheadcoll = [htmlheadelem children];
						int nHeadColl = [htmlheadcoll length];
						for(int j=0; j<nHeadColl; j++)
						{
							DOMHTMLElement *htmlsubelem = [htmlheadcoll item: j];
							//NSLog(@"sub is %@", [[htmlsubelem class] description]);
							//NSLog(@"inner text %@", [htmlsubelem innerText]);
							
						}
					}
					
				}
			}
		}
	}
	[[EngineManager sharedInstance] setGrepEngineName: activeGrepEngineName xml: activeGrepEngineXML];
	
}


HOOKDEF(void, TabController, tabDocument$progressChanged$, TabDocument* document, float progress)
{
	HookLog();
	CALL_ORIG(TabController, tabDocument$progressChanged$, document, progress);
	GrepSearchEngine(self, document);
}

HOOKDEF(void, TabController, tabDocument$didFinishLoadingWithError$, TabDocument* document, id error)
{
	HookLog();
	CALL_ORIG(TabController, tabDocument$didFinishLoadingWithError$, document, error);
	if(!error)
		GrepSearchEngine(self, document);
}



@interface AddOpenSearchScriptObject : NSObject
{
	NSDictionary* currEngine;
}
+ (NSString*) webScriptNameForSelector: (SEL) sel;
+ (bool) isSelectorExcludedFromWebScript: (SEL) sel;

@end

@implementation AddOpenSearchScriptObject
 
+ (NSString*) webScriptNameForSelector: (SEL) sel
{
	if(sel_isEqual(sel, @selector(AddSearchProviderWithArgument:)))
	{
		return @"AddSearchProvider";
	}
	return nil;
}

+ (bool) isSelectorExcludedFromWebScript: (SEL) sel
{
	return ([self webScriptNameForSelector: sel])? NO : YES;
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)idx
{
	if(idx==1)
	{
		[[EngineManager sharedInstance] addSearchEngineObject: currEngine];
	}
	[currEngine release];
	currEngine = nil;
}

- (NSString*) AddSearchProviderWithArgument: (NSString*) arg
{
	NSLog(@"AddSearchProvider: %@", arg);
	
	SearchEngineParser* parser = [[SearchEngineParser alloc] init];
	currEngine = [[parser processURL: arg] retain];
	[parser release];
	NSString* name =  [currEngine objectForKey: @"name"];
	
	if(name)
	{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle: name message:@"Would you like to add this search engine to Safari?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add",nil];
			[alert show];
	}
	else
	{
		[currEngine release];
		currEngine = nil;
	}
		
	
	
//	[ promptAddSearchEngine: arg];
	
	//[[[SearchEngineParser alloc] initWithData: [NSData dataWithContentsOfURL: [NSURL URLWithString: arg]]] release];
	return @"";
}

@end



//clearSearchEngineScriptObjects

HOOKDEF(void, TabDocument, clearSearchEngineScriptObjects$, id windowScriptObject)
{
	HookLog();
	
	id obj = [[objc_getClass("AddOpenSearchScriptObject") alloc] init];
	[windowScriptObject setValue: obj forKey: @"external"];
	[obj release];
	
	CALL_ORIG(TabDocument, clearSearchEngineScriptObjects$, windowScriptObject);
}


@class BrowserController;




@class AddressView;

@interface NSObject (dc)
- (int) _sectionIndexForSearchSuggestions;
@end

HOOKDEF(NSString*, AddressView, tableView$titleForHeaderInSection$, id tv, int section)
{
	NSDictionary* currentEngine = [[EngineManager sharedInstance] currentEngine];
	
	if(currentEngine==nil || [self _completionsAreSearches]==NO || [self _sectionIndexForSearchSuggestions]!=section)
	{
		return CALL_ORIG(AddressView, tableView$titleForHeaderInSection$, tv, section);
	}
	else
	{
		return [NSString stringWithFormat: @"%@ Suggestions", [currentEngine objectForKey: @"name"]];
	}
	
}


HOOKDEF(void, AddressView, updateSearchEngineStrings)
{
	
	NSString* currName = [[[EngineManager sharedInstance] currentEngine] objectForKey: @"name"];
	
	if(currName)
	{
		NSLine();
		
		//UITextField* _searchTextField = MSHookIvar<UITextField*>(self, DATA(char*, str_searchTextField));
		GETVAR(UITextField*, _searchTextField);
		[_searchTextField setPlaceholder: currName];
		[_searchTextField setReturnKeyType: UIReturnKeySearch];
	}
	else
	{
		NSLine();
		
		CALL_ORIG(AddressView, updateSearchEngineStrings);
	}
}

HOOKDEF(void, BrowserController, _doSearch$, NSString* text)
{
	UIWebDocumentView *view = [[[self tabController] activeTabDocument] browserView];//documentView];
	NSType(view);
	[view findText: text direction: 1];
//	[view findText: text];
}

@class WebView;



NSString* CommonQueryFixer(NSString* url, NSString* query)
{
	NSString* stringURL = [url stringByReplacingOccurrencesOfString: @"{searchTerms}" withString: query];
	
	//[stringURL replaceAllTextBetweenString: @"{" andString: @"*}" fromDictionary: options: range:
	
	
	stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{count}" withString: @"20"];
	stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{count*}" withString: @""];
	
	stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{startIndex}" withString: @"0"];
	stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{startIndex*}" withString: @""];
	
	stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{startPage}" withString: @"0"];
	stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{startPage*}" withString: @""];
	
	stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{language}" withString: @"en"];
	stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{language*}" withString: @"en"];
	
	stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{inputEncoding}" withString: @"UTF-8"];
	stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{inputEncoding*}" withString: @"UTF-8"];
	
	stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{outputEncoding}" withString: @"UTF-8"];
	stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{outputEncoding*}" withString: @"UTF-8"];
	
	return stringURL;
}



@class SearchQueryBuilder;

HOOKDEF(NSURL*, SearchQueryBuilder, searchURL)
{
	HookLog();
	NSURL* url;
	
	
	GETVAR(id, engineInfo);
	
	
	
	NSString *currUrl = [[[EngineManager sharedInstance] currentEngine] objectForKey: @"searchurl"];
	
	
	if((engineInfo && [[engineInfo shortName] isEqualToString: @"Wikipedia"]) || currUrl==nil)
	{
		NSLine();
		url = CALL_ORIG(SearchQueryBuilder, searchURL);
	}
	else
	{
		GETVAR(NSString*, queryString);
		NSLog(@"current URL is %@", currUrl);
		
		
		NSString* stringURL = CommonQueryFixer(currUrl, queryString);
		/*
		NSString* stringURL = [currUrl stringByReplacingOccurrencesOfString: @"{searchTerms}" withString: queryString];
		
		//[stringURL replaceAllTextBetweenString: @"{" andString: @"*}" fromDictionary: options: range:
		
		
		stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{count}" withString: @"20"];
		stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{count*}" withString: @""];
		
		stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{startIndex}" withString: @"0"];
		stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{startIndex*}" withString: @""];
		
		stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{startPage}" withString: @"0"];
		stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{startPage*}" withString: @""];
		
		stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{language}" withString: @"en"];
		stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{language*}" withString: @"en"];
		
		stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{inputEncoding}" withString: @"UTF-8"];
		stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{inputEncoding*}" withString: @"UTF-8"];
		
		stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{outputEncoding}" withString: @"UTF-8"];
		stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{outputEncoding*}" withString: @"UTF-8"];
		*/
		NSLog(@"stringURL is %@", stringURL);
		url = [NSURL URLWithString: stringURL];
		
	}
	
	NSLog(@"Search URL is %@", [url absoluteString]);
	return url;
}

@class SearchSuggestionManager;

HOOKDEF(NSString*, SearchSuggestionManager, suggestionQueryStringForSearchString$, NSString* string)
{
	
	HookLog();
	NSString* queryString;
	
	NSDictionary *currEngine = [[EngineManager sharedInstance] currentEngine];
	
	queryString = CALL_ORIG(SearchSuggestionManager, suggestionQueryStringForSearchString$, string);
	NSLog(@"default queryString: %@", queryString);
	if(!currEngine)
	{
		
	}
	else
	{
	//	GETVAR(NSString*, queryString);
		
		
		
		NSString* currUrl = [currEngine objectForKey: @"sugg"];
		NSLog(@"current URL is %@", currUrl);
		
		if(currUrl)
		{
			NSString* stringURL = CommonQueryFixer(currUrl, string);
		/*
			NSString* stringURL = [currUrl stringByReplacingOccurrencesOfString: @"{searchTerms}" withString: string];
		
			//[stringURL replaceAllTextBetweenString: @"{" andString: @"*}" fromDictionary: options: range:
		
		
			stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{count}" withString: @"20"];
			stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{count*}" withString: @""];
		
			stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{startIndex}" withString: @"0"];
			stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{startIndex*}" withString: @""];
		
			stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{startPage}" withString: @"0"];
			stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{startPage*}" withString: @""];
		
			stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{language}" withString: @"en"];
			stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{language*}" withString: @"en"];
		
			stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{inputEncoding}" withString: @"UTF-8"];
			stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{inputEncoding*}" withString: @"UTF-8"];
		
			stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{outputEncoding}" withString: @"UTF-8"];
			stringURL = [stringURL stringByReplacingOccurrencesOfString: @"{outputEncoding*}" withString: @"UTF-8"];
		*/
			queryString = stringURL;
//			NSLog(@"stringURL is %@", stringURL);
		}
		else
		{
			queryString = @"";
		}
		//ret = stringURL;
		//url = [NSURL URLWithString: stringURL];
		
	}
	
	NSLog(@"Search string is %@", queryString);//[url absoluteString]);
	return queryString;
}

void ExtendedSearchField$_leftButtonClicked$(id self, SEL sel, UIView* view)
{
	NSLog(@"button pressed");
	
	if(![self isFirstResponder])
	{
		return;
	}
	
	//GETCLASS(BrowserController);
	
	// 1 =  BookmarksNavigationController
	// 2 = 
	
	id sharedBC = [$BrowserController sharedBrowserController];
	
	[sharedBC dismissCurrentPopover];
	
	id cvc = [SearchEngineNavigationController sharedNavigationController];
	[cvc setDelegate: sharedBC];
	
	//id cvc = [[SearchEngineNavigationController alloc] initWithControllerDelegate: sharedBC];
	
	
	if([[UIDevice currentDevice] isWildcat])
	{
		id controller = [[$RotatablePopoverController alloc] initWithContentViewController: cvc];
		
		float xpos = [sharedBC orientation]>2 ? 510.f : 418.f;
		
		[controller setPresentationRect: (CGRect){xpos, 0.0f, 48.0f, 48.0f}];//{150.0f, 0.0f, 26.0f, 48.0f}];
//		[controller setPresentationRect: (CGRect){418.f, 10.0f, 48.0f, 34.0f}];//{150.0f, 0.0f, 26.0f, 48.0f}];
		id buttonBar = MSHookIvar<id>(sharedBC, "_buttonBar");
		[controller setPresentationView: buttonBar];
		[controller setPermittedArrowDirections: 1];
		[controller setPassthroughViews: [NSArray arrayWithObject: buttonBar]];
		[controller setDelegate: cvc];
		
		[controller presentPopoverAnimated: NO];
		
		
		[sharedBC setCurrentPopoverController: controller];
		[controller release];	
	}
	else
	{
		id tableView = [cvc tableView];
		NSType([tableView superview]);
		id activeKb = [objc_getClass("UIKeyboard") activeKeyboard];
		
		
		id buttonBar = MSHookIvar<id>(sharedBC, "_buttonBar");
		
		UIView* view = [buttonBar superview];
		
		
		//float width = [[UIScreen mainScreen] applicationFrame].size.width;
		
		
		//[tableView setOrigin: (CGRect){0.0f, 0.0f}];
		[tableView setFrame: (CGRect){{0.0f, 60.0f}, { [view frame].size.width, [view frame].size.height - 60.0f}}];
		[tableView setAutoresizingMask: UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
		//[tableView setFrame: (CGRect){0.0f, 0.0f, 320.0f, 320.0f}];
		
		//[view addSubview: tableView];
		[view insertSubview: tableView belowSubview: activeKb];
		
		NSType([tableView superview]);
		NSType([[tableView superview] superview]);
		[tableView reloadData];
	}
	
//	[[$BrowserController sharedBrowserController] showBrowserPanelType: 10];
}









HOOKDEF(void, BrowserController, _presentModalViewControllerFromBookmarksButton$, id cvc)
{
	HookLog();
	//id cvc = [[CustomNavigationController alloc] initWithControllerDelegate: self];
	id controller = [[$RotatablePopoverController alloc] initWithContentViewController: cvc];
	[controller setPresentationRect: (CGRect){550.f, 10.0f, 48.0f, 34.0f}];//{150.0f, 0.0f, 26.0f, 48.0f}];
	id buttonBar = MSHookIvar<id>(self, "_buttonBar");
	[controller setPresentationView: buttonBar];
//	[controller setSupportsRotation: NO];
	
	[controller setPermittedArrowDirections: 1];
	[controller setPassthroughViews: [NSArray arrayWithObject: buttonBar]];
	[controller presentPopoverAnimated: NO];
	[self setCurrentPopoverController: controller];
	[controller release];	
}

@class DOMHTMLFormElement;
@class UIWebFormCompletionController;

HOOKDEF(void, UIWebFormCompletionController, _frame$sourceFrame$willSubmitRegularForm$withValues$, WebFrame* frame, WebFrame* sourceFrame, DOMHTMLFormElement* form, NSDictionary* values)
{
	HookLog();
	NSType(frame);
	NSType(sourceFrame);
	NSType(form);
	NSLog(@"name = %@", [form name]);
	NSLog(@"action = %@", [form action]);
	NSLog(@"method = %@", [form method]);
	NSLog(@"target = %@", [form target]);
	NSType([form elements]);
	//DOMHTMLCollection*
	{
		DOMHTMLCollection* htmlformcoll = [form elements];
		int nFormColl = [htmlformcoll length];
		for(int i=0; i<nFormColl; i++)
		{
			DOMHTMLElement* formelem = [htmlformcoll item: i];
			NSType(formelem);
			if([formelem isKindOfClass: $DOMHTMLInputElement])
			{
				NSLog(@"name = %@", [formelem name]);
			//	NSLog(@"accessKey = %@", [formelem accessKey]);
			//	NSLog(@"accept = %@", [formelem accept]);
			}
		}
	}
	
	NSType(values);
	NSLog(@"values = %@", [values description]);
	CALL_ORIG(UIWebFormCompletionController, _frame$sourceFrame$willSubmitRegularForm$withValues$, frame, sourceFrame, form, values);
	
	
	
	//GETCLASS(DOMHTMLFormElement);
	//ClassLogger($DOMHTMLFormElement);
	//ClassLogger(object_getClass($DOMHTMLFormElement));
	
}

@class WebFrame, DOMRange, WebDefaultFormDelegate;

HOOKDEF(void, WebDefaultFormDelegate, webViewDidBeginEditing$, id webview)
{
	SelLog();
	NSType(webview);
//	NSType(frame);
	
	CALL_ORIG(WebDefaultFormDelegate, webViewDidBeginEditing$, webview);
}

@class UIWebFormDelegate;

HOOKDEF(void, UIWebFormDelegate, frame$sourceFrame$willSubmitForm$withValues$submissionListener$, id frame, id sourceFrame, id form, id values, id listener)
{
	HookLog();
	CALL_ORIG(UIWebFormDelegate, frame$sourceFrame$willSubmitForm$withValues$submissionListener$, frame, sourceFrame, form, values, listener);	
}

HOOKDEF(void, UIWebFormDelegate, textFieldDidBeginEditing$inFrame$, id field, id frame)
{
	HookLog();
	CALL_ORIG(UIWebFormDelegate, textFieldDidBeginEditing$inFrame$, field, frame);
}

HOOKDEF(bool, UIWebFormDelegate, webView$shouldBeginEditingInDOMRange$, id webView, id domrange)
{
	HookLog();
	return CALL_ORIG(UIWebFormDelegate, webView$shouldBeginEditingInDOMRange$, webView, domrange);
}

HOOKDEF(id, UIWebFormCompletionController, initWithDOMElement$webFrame$, id domElement, id webFrame)
{
	HookLog();
	NSType(domElement);
	NSType(webFrame);
	return CALL_ORIG(UIWebFormCompletionController, initWithDOMElement$webFrame$, domElement, webFrame);
}

HOOKDEF(void, AddressView, textFieldDidEndEditing$, id textView)
{
	SelLog();
	
	id cvc = [SearchEngineNavigationController sharedNavigationController];
	
	id &_responderForEditingWithoutFirstResponder(MSHookIvar<id>(self, "_responderForEditingWithoutFirstResponder"));
	
	if(_responderForEditingWithoutFirstResponder)
	{
		NSType(_responderForEditingWithoutFirstResponder);
	}
	else
	{
		CALL_ORIG(AddressView, textFieldDidEndEditing$, textView);
	}
	
}

HOOKDEF(void, AddressView, cancel)
{
	SelLog();
	
	id cvc = [SearchEngineNavigationController sharedNavigationController];
	
	CALL_ORIG(AddressView, cancel);
	[cvc dismiss];
}

@class AddressTextField;

HOOKDEF(void, AddressTextField, becomeFirstResponder)
{
	id cvc = [SearchEngineNavigationController sharedNavigationController];
	[cvc dismiss];
	
	CALL_ORIG(AddressTextField, becomeFirstResponder);
}



void UpdateHooking()
{
	NSLine();
	
	
	if(_TabDocument$clearSearchEngineScriptObjects$==nil)
	{
		NSLine();
		GetClasses();
		
		//GETCLASS(SearchSuggestionManager);
		HOOKMESSAGE(SearchSuggestionManager, suggestionQueryStringForSearchString:, suggestionQueryStringForSearchString$);
		
		
		//GETCLASS(UIWebFormCompletionController);
//		ClassLogger($UIWebFormCompletionController);
//		ClassLogger(object_getClass($UIWebFormCompletionController));
		HOOKMESSAGE(UIWebFormCompletionController,
					initWithDOMElement:webFrame:,
					initWithDOMElement$webFrame$);
		HOOKCLASSMESSAGE(UIWebFormCompletionController,
						 _frame:sourceFrame:willSubmitRegularForm:withValues:,
						 _frame$sourceFrame$willSubmitRegularForm$withValues$);
		
		
		//GETCLASS(UIWebFormDelegate);
		HOOKMESSAGE(UIWebFormDelegate,
					textFieldDidBeginEditing:inFrame:,
					textFieldDidBeginEditing$inFrame$);
		HOOKMESSAGE(UIWebFormDelegate,
					webView:shouldBeginEditingInDOMRange:,
					webView$shouldBeginEditingInDOMRange$);
//					frame:sourceFrame:willSubmitForm:withValues:submissionListener:,
//					frame$sourceFrame$willSubmitForm$withValues$submissionListener$);
		
		
		
		
		NSLog(@"hook initialized");
		//GETCLASS(ExtendedSearchField);
		HOOKMESSAGE(ExtendedSearchField, layoutSubviews, layoutSubviews);
		
		class_addMethod($ExtendedSearchField, @selector(_leftButtonClicked:), (IMP) ExtendedSearchField$_leftButtonClicked$, "v@:@");
		class_addMethod($ExtendedSearchField, @selector(leftViewRectForBounds:), (IMP) ExtendedSearchField$leftViewRectForBounds$, "{CGRect={CGPoint=ff}{CGSize=ff}}@:{CGRect={CGPoint=ff}{CGSize=ff}}");
		
		class_addMethod($ExtendedSearchField, @selector(_textRectExcludingButtonsForBounds:), (IMP) ExtendedSearchField$_textRectExcludingButtonsForBounds$, "{CGRect={CGPoint=ff}{CGSize=ff}}@:{CGRect={CGPoint=ff}{CGSize=ff}}");
		
		//ExtendedSearchField$leftViewRectForBounds$
		
		//GETCLASS(TabController);
		//ClassLogger($TabController);
		
		HOOKMESSAGE(TabController, tabDocument:progressChanged:, tabDocument$progressChanged$);

		HOOKMESSAGE(TabController, tabDocument:didFinishLoadingWithError:, tabDocument$didFinishLoadingWithError$);
		
//		GETCLASS(TabDocument);
		//ClassLogger($TabDocument);
		{
			HOOKMESSAGE(TabDocument, tmp, clearSearchEngineScriptObjects$);
		}
		//clearSearchEngineScriptObjects:
		//HOOKMESSAGE(TabDocument, webView:windowScriptObjectAvailable:, webView$windowScriptObjectAvailable$);
		
		
//		GETCLASS(SearchQueryBuilder);
		//ClassLogger($SearchQueryBuilder);
		HOOKMESSAGE(SearchQueryBuilder, searchURL, searchURL);
		
		//[SearchQueryBuilder searchURL]
		
		
		
		
		// TOGGLE FOR IN-PAGE SEARCH
//		HOOKMESSAGE(BrowserController, _doSearch:, _doSearch$);
		
		
	//	GETCLASS(AddressView);
		HOOKMESSAGE(AddressView, updateSearchEngineStrings, updateSearchEngineStrings);
		HOOKMESSAGE(AddressView, cancel, cancel);
		HOOKMESSAGE(AddressView, textFieldDidEndEditing:, textFieldDidEndEditing$);
		HOOKMESSAGE(AddressView, tableView:titleForHeaderInSection:, tableView$titleForHeaderInSection$);
		
		GETCLASS(AddressTextField);
		HOOKMESSAGE(AddressTextField, becomeFirstResponder, becomeFirstResponder);
		
		
		
//		HOOKMESSAGE(AddressView, search, search);
		
		
//		GETCLASS(WebView);
//		HOOKMESSAGE(WebView, setSelectedDOMRange:affinity:, setSelectedDOMRange$affinity$);
		
				
		
	//	GETCLASS(BookmarksNavigationController);
	//	ClassLogger($BookmarksNavigationController);
	//	ClassLogger(object_getClass($BookmarksNavigationController));
		
		
//		if(dlopen("/Library/MobileSubstrate/DynamicLibraries/ActionMenu.dylib", RTLD_LAZY | RTLD_NOLOAD))
//		{
//			ActionMenuInit();
//		}
		
//		GETCLASS(UIWebSelection);
//		HOOKMESSAGE(UIWebSelection, selectionChanged, selectionChanged);
//		HOOKMESSAGE(UIWebSelection, setBase:, setBase$);
//		HOOKMESSAGE(UIWebSelection, setExtent:, setExtent$);
		
//		GETCLASS(UIWebSelectionView);
//		HOOKMESSAGE(UIWebSelectionView, startSelectionCreationWithPoint:, startSelectionCreationWithPoint$);
//		HOOKMESSAGE(UIWebSelectionView, updateSelectionCreationWithPoint:, updateSelectionCreationWithPoint$);
//		HOOKMESSAGE(UIWebSelectionView, endSelectionCreationWithPoint:, endSelectionCreationWithPoint$); 
//		HOOKMESSAGE(UIWebSelectionView, nodeInPristineGraphAtPoint:, nodeInPristineGraphAtPoint$);
		
		
//		GETCLASS(GetSearchEngineScriptObject);
//		class_addMethod($GetSearchEngineScriptObject, @selector(description), (IMP) GetSearchEngineScriptObject$description, "@@:");
//		HOOKMESSAGE(GetSearchEngineScriptObject, invokeDefaultMethodWithArguments:, invokeDefaultMethodWithArguments$);
//		TabDocument.webView_windowScriptObjectAvailable_
		
		[EngineManager sharedInstance];
		
		
	}
}



__attribute__((constructor)) void sspInitialize()
{
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];	
	NSBundle *main = [NSBundle mainBundle];
	NSString *identifier = [main bundleIdentifier];
	
	if([identifier isEqualToString: @"com.apple.mobilesafari"])
	{
		// delay, then registration check
		
		CFRunLoopRef loop = CFRunLoopGetCurrent();
		CFRunLoopTimerRef hookTimer = CFRunLoopTimerCreate(kCFAllocatorDefault, CFAbsoluteTimeGetCurrent()+0.5f, 0.0f, 0, 0, (CFRunLoopTimerCallBack) UpdateHooking, NULL);
		CFRunLoopAddTimer(loop, hookTimer, kCFRunLoopCommonModes);
		
		CFNotificationCenterRef darwin = CFNotificationCenterGetDarwinNotifyCenter();
		CFNotificationCenterAddObserver(darwin, NULL, (CFNotificationCallback) UpdateHooking, (CFStringRef) @"com.phoenix.cicero-registered", NULL, NULL);
		
		_TabDocument$clearSearchEngineScriptObjects$=nil;
		
		
	}
	[pool release];
}

