# CSVirtualCamera
CocoaSplit Virtual Camera plugin

This is an implementation of a CoreMediaIO DAL plugin that provides virtual (software driven) camera support.
The plugin allows for dynamic creation and destruction of virtual cameras via an XPC based API.

Contents of this repo:

CSVirtualCamera: the CMIO DAL plugin

CSVirtualCameraAssistant: The LaunchAgent that implements the mach/XPC service for the API

SDK: Required files for creating and controlling virtual camera devices

### TODO:
- [ ] Document SDK
- [ ] Signed PKG installer
- [ ] More testing
 
