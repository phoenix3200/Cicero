
#import "common.h"
#import "defines.h"

#define CLCLASS(cls) \
	Class $ ## cls
#include "ClassList.h"
#undef CLCLASS

void GetClasses()
{
	#define CLCLASS(cls) \
		$ ## cls = objc_getClass(#cls)
	#include "ClassList.h"
	#undef CLCLASS
}