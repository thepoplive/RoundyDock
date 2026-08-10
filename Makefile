ARCHS = armv7 arm64
TARGET = iphone:clang:latest:7.0

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = RoundyDock

RoundyDock_FILES = Tweak.xm
RoundyDock_CFLAGS = -fobjc-arc
RoundyDock_FRAMEWORKS = UIKit CoreGraphics QuartzCore

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
