
#define CLCLASS(cls) \
	extern Class $ ## cls

#include "ClassList.h"
#undef CLCLASS


void GetClasses();