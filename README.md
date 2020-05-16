# CSVirtualCamera
CocoaSplit Virtual Camera plugin

This is an implementation of a CoreMediaIO DAL plugin that provides virtual (software driven) camera support.
The plugin allows for dynamic creation and destruction of virtual cameras via an XPC based API.

Contents of this repo:

CSVirtualCamera: the CMIO DAL plugin

CSVirtualCameraAssistant: The LaunchAgent that implements the mach/XPC service for the API

SDK: Required files for creating and controlling virtual camera devices


The API is intentionally barebones and simple. One call to create the device (with width, height and pixel format), one call to publish a video frame, and one call to destroy the device.

Video frames must be CVPixelBuffers. The most efficient path is if the CVPixelBuffer is backed by an IOSurface. Non-IOSurface buffers will be copied to an IOSurface for publishing.

### TODO:
- [ ] Document SDK
- [ ] Signed PKG installer
- [ ] More testing
- [ ] Companion app that creates cameras for NDI and Syphon sources
 
