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
- [x] Document SDK
- [x] Signed PKG installer
- [ ] More testing
- [ ] Companion app that creates cameras for NDI and Syphon sources
 

# The APPLE HATES FUN section:

Apple's new-ish security mechanisms are unfriendly to many camera plugins
both virtual and 'real'. Hardened runtime/library validation prevents the
DAL plugin from loading into any process that has said validation enabled.

Most Apple provided applications are hardened and will not load third party
DAL plugins. 

As of macOS 10.15.4:

### Apple apps:

#### Verified working:
  QuickTime Player (has the com.apple.security.cs.disable-library-validation entitlement)


#### Verified NOT WORKING:
  Photo Booth (blocked by library validation)
  Facetime (blocked by library validation)
  Safari (blocked by library validation)


### Third party apps:

#### Verified working:
  Chrome
  Microsoft Teams

#### Verified NOT WORKING:
  Discord (blocked by library validation)
  Zoom 5.0.3 (blocked by library validation). 5.0.4 release notes claim this will work, will update this doc


## Note to application developers

If you want your application to work with virtual cameras (or real cameras/video capture devices that aren't UVC based) you have two choices:
- Disable library validation. With hardened runtime you need to add an entitlement to do so
- Use an XPC service to interact with video devices. Make sure the XPC service has the library validation
  disable entitlement. You will need to vend frames from the XPC service into the main app. You're most
  likely going to want to use an IOSurface to do this. 
  Frame vending is fairly trivial if you are using NSXPCConnection, but your situation may vary. See the SDK
  code in this repo for an example of how to send an IOSurface across an NSXPCConnection. Device enumeration
  and control will also require the use of an XPC service. This may be complex depending on your needs.
  

## Note to users
You can't really do anything about this unfortunately. Your best bet is to bother Apple, or bother individual
app authors to implement an architecture that allows them to interact with cameras from a less restricted
process. IN SOME CASES disabling SIP may help but I would not recommend that course of action and will not
provide instructions on how to do so. You may also be able to 'unsign' apps and strip them of the library validation flags. 


## Note to Apple
Please fix this. With more and more applications adopting library validation users are losing access to not only virtual cameras but legitimate hardware devices. Not everything is a UVC camera...

  
  


   



