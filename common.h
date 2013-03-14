
#import <Foundation/Foundation.h>

#import <substrate.h>
#import <objc/message.h>

#import <UIKit/UIApplication.h>
#import <UIKit/UIKit.h>

#import <CFNetwork/CFNetwork.h>
#import <pthread.h>

#import <notify.h>

#import "UIPushButton.h"
#import "WebFrame.h"

#import "CFUserNotification.h"


extern "C" UIApplication *UIApp;

extern "C" id lockdown_connect();
extern "C" void lockdown_disconnect(id port);
extern "C" NSString *lockdown_copy_value(id port, int idk, CFStringRef value);
extern "C" CFStringRef kLockdownUniqueDeviceIDKey;
extern "C" CFStringRef kLockdownProductVersionKey;		// systemVersion
extern "C" CFStringRef kLockdownProductTypeKey;			// model
