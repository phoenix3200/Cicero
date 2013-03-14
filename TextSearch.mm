//
//  TextSearch.mm
//  ssp_3
//
//  Created by Public Nuisance on 4/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//


#import "common.h"
#import "defines.h"

#import "TextSearch.h"

@class TabController, TabDocument;

//#include <WebCore/DOMHTMLDocument.h>
//#include <WebCore/DOMHTMLHtmlElement.h>


@class DOMHTMLDocument, DOMHTMLElement, DOMHTMLCollection;
@class WebHTMLView, DOMRange, UIWebSelection;

void UIWebDocumentView$selectDOMRange$(UIWebDocumentView* self, SEL sel, DOMRange* range)
{
	//UIWebView *webView = [view webView];
	//WebFrame *mainFrame = [webView mainFrame];
	//WebHTMLView* documentView = [mainFrame documentView];
	//DOMHTMLDocument *htmldoc = [mainFrame DOMDocument];
	
	//NSLog(@"text is %@ %d %d", [range text], [range startOffset], [range endOffset]);
	
	
	[self clearSelection];
	
	GETVAR(id, _webSelectionAssistant);
	//	id _webSelectionAssistant;
	//	object_getInstanceVariable(self, "_webSelectionAssistant", reinterpret_cast<void **> (&_webSelectionAssistant));
	//	NSType(_webSelectionAssistant);
	
	UIView* _tintView;
	object_getInstanceVariable(_webSelectionAssistant, "_tintView", reinterpret_cast<void **> (&_tintView));
	//	NSType(_tintView);
	
	if(![_tintView superview])
	{
		[self addSubview: _tintView];
	}
	
	id _selectionGraph;
	object_getInstanceVariable(_tintView, "_selectionGraph", reinterpret_cast<void **> (&_selectionGraph));
	NSType(_selectionGraph);
	
	
	[_tintView hideControls];
	
	
	[_tintView resetSelection];
	for(id subview in [_tintView handles])
	{
		[subview setAlpha: 1.0f];
	}
	CGRect bounds = [self bounds];
	[_tintView setFrame: bounds];
	if(![_tintView selectionNode])
	{
		[_tintView setSelectionFrame: bounds];
	}
	
	UIWebSelection* selection = [[objc_getClass("UIWebSelection") alloc] initWithDocumentView: self];
	[selection setBase: range];
	
	[_selectionGraph clearNodes];
	id node;
	if([selection valid])
	{
		NSLine();
		node = [_selectionGraph addNodeFromSelection: selection];
	}
	
	[_tintView setSelectionNode: node];
	
	selection = [[_tintView selectionNode] selection];
	[selection applySelectionToWebDocumentView];
	[_tintView updateFrameAndHandles];
	[self selectionChanged];
	[_tintView showControls];
	
}

void UIWebDocumentView$findText$(UIWebDocumentView* self, SEL sel, NSString* text)
{
	NSLog(@"text is %@", text);
	if(text)
		[self findText: text direction: 0];
}

@interface WebFrame (SSP)

- (NSRange) selectedNSRange;

@end


void UIWebDocumentView$findText$direction$(UIWebDocumentView* self, SEL sel, NSString* text, int direction)
{
	NSLog(@"text is %@", text);
	if(!text)
		return;
	
	
	UIWebView *webView = [self webView];
	WebFrame *mainFrame = [webView mainFrame];
	WebHTMLView* documentView = [mainFrame documentView];
	if(![documentView isKindOfClass: objc_getClass("WebHTMLView")])
		return;
	
	DOMHTMLDocument *htmldoc = [mainFrame DOMDocument];
	
	
	NSString* innerText;
	
	if([htmldoc isKindOfClass: [DOMHTMLDocument class]])
	{
		DOMHTMLElement *htmlmainelem = [htmldoc documentElement];
		if([htmlmainelem isKindOfClass: objc_getClass("DOMHTMLHtmlElement")])
		{
			DOMHTMLCollection *htmlmaincoll = [htmlmainelem children];
			
			int nMainColl = [htmlmaincoll length];
			for(int i=0; i<nMainColl; i++)
			{
				DOMHTMLElement *htmlheadelem = [htmlmaincoll item: i];
				if([htmlheadelem isKindOfClass: objc_getClass("DOMHTMLBodyElement")])
				{
					innerText = [htmlheadelem innerText];
					
				}
				
			}
		}
	}
	if(int length = [innerText length])
	{
		//DOMRange* currDOMRange = [webView selectedDOMRange];
		
		NSRange currRange = (NSRange){NSNotFound,0};
		NSType(mainFrame);
		currRange = [mainFrame selectedNSRange];//((NSRange(*)(id, SEL))objc_msgSend)(mainFrame, @selector(selectedNSRange));
		
		//		((void(*)(NSRange &, id, SEL))objc_msgSend_stret)(currRange, mainFrame, @selector(_selectedNSRange));
		//if(currDOMRange)
		//	currRange = reinterpret_cast<NSRange> ([mainFrame convertDOMRangeToNSRange: currDOMRange])l;
		//((void(*)(NSRange &, id, SEL, id))objc_msgSend_stret)(currRange, mainFrame, @selector(_convertDOMRangeToNSRange:), currDOMRange);
		
		int start = currRange.location;
		int end = start + currRange.length;
		if(start==NSNotFound || direction==0)
		{
			start = 0;
			end = 0;
			direction = 1;
		}
		
		
		NSStringCompareOptions searchOptions = NSCaseInsensitiveSearch;
		
		if(direction==-1)
		{
			end = start;
			start = 0;
			searchOptions |= NSBackwardsSearch;
		}
		else
		{
			start = end;
			end = length-start;
		}
		
		NSLog(@"search range {%d %d}", start, end);
		
		NSLog(@"string to match: %@", text);
		NSLog(@"innertext: %@", innerText);
		NSRange match = [innerText rangeOfString: text options: searchOptions range: (NSRange){start, end}];
		if(match.location != NSNotFound)
		{
			NSLog(@"highlighting {%d %d}", match.location, match.length);
			
			DOMRange* range = [mainFrame convertNSRangeToDOMRange: match];
			[self selectDOMRange: range];
			[mainFrame _scrollDOMRangeToVisible: range];
			// put something in here to hide the address bar
		}
	}	
}

void TextSearchInitialize()
{
	GETCLASS(UIWebBrowserView);
	//GETCLASS(UIWebDocumentView);
	class_addMethod($UIWebBrowserView, @selector(selectDOMRange:), (IMP) UIWebDocumentView$selectDOMRange$, "v@:@");
	class_addMethod($UIWebBrowserView, @selector(findText:), (IMP) UIWebDocumentView$findText$, "v@:@");
	class_addMethod($UIWebBrowserView, @selector(findText:direction:), (IMP) UIWebDocumentView$findText$direction$, "v@:@i");
}

