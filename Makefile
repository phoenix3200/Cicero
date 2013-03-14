TWEAK_NAME = cicero
cicero_OBJCC_FILES = ssp.mm GetClasses.mm\
	SearchEngineParser.mm TextSearch.mm SearchEngineNavigationController.mm EngineManager.mm
cicero_FRAMEWORKS = UIKit CFNetwork
cicero_PRIVATE_FRAMEWORKS = WebCore
cicero_LDFLAGS = -llockdown


ADDITIONAL_OBJCCFLAGS = -fvisibility=hidden

#SDKVERSION = 3.2

GO_EASY_ON_ME =1

include framework/makefiles/common.mk
include framework/makefiles/tweak.mk

