TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e
INSTALL_TARGET_PROCESSES = VideoStar

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = Painuzz
Painuzz_FILES = Tweak.xm
Painuzz_CFLAGS = -fobjc-arc
Painuzz_FRAMEWORKS = UIKit QuartzCore AVFoundation Accelerate

include $(THEOS_MAKE_PATH)/tweak.mk
