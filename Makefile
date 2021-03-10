include $(THEOS)/makefiles/common.mk

export ARCHS = arm64 arm64e

TOOL_NAME = SneakyShot

SneakyShot_FILES = $(wildcard *.m) $(wildcard *.c)
SneakyShot_CFLAGS = -fobjc-arc
SneakyShot_CODESIGN_FLAGS = -Sent.xml

include $(THEOS_MAKE_PATH)/tool.mk
