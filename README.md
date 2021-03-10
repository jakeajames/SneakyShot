# SneakyShot

Kernel-based method to take screenshots on iOS. Works with encrypted videos.

This code is one year old. I open-sourced it now since I probably won't look into it for the time being.
The issue with it is that it only reads from one framebuffer and most of the time the results will be a few seconds old.
Image is saved as an uncompressed bitmap file. The vinfo address is hardcoded for iPad5,3 iOS 12.4.
