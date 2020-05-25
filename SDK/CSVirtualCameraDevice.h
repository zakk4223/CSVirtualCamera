//
//  CSVirtualCameraDevice.h
//  CSVirtualCamera
//
//  Created by Zakk on 5/6/20.
//  Copyright © 2020 Zakk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>
#import <IOSurface/IOSurfaceObjC.h>

#define CSVC_DAL_PATH @"/Library/CoreMediaIO/Plug-Ins/DAL/CSVirtualCamera.plugin"

NS_ASSUME_NONNULL_BEGIN


@protocol CSVirtualCameraProtocol
-(void)publishNewFrame:(NSString *)deviceUUID withIOSurface:(IOSurface *)ioSurface;
-(void)createDevice:(NSString *)name withUID:(NSString *)uid withModel:(NSString *)modelName withManufacturer:(NSString *)manufacturer width:(NSUInteger)width height:(NSUInteger)height pixelFormat:(OSType)pixelFormat frameRate:(float) frameRate withReply:(void (^)(NSString *))reply;
-(void)destroyDevice:(NSString *)uuid;
-(void)setInternalClock:(bool)useClock forDevice:(NSString *)deviceUUID;
-(void)setPersistOnDisconnect:(bool)persist forDevice:(NSString *)deviceUUID;
@end


@interface CSVirtualCameraDevice : NSObject
{
    NSXPCConnection *_XPCconnection;
    id<CSVirtualCameraProtocol> _assistant;
    
}

/*
 Is CSVirtualCamera installed? This just checks for the DAL plugin
 */
+(bool)isInstalled;

/*
 The camera name. This is the name that users will see in the most applications
 */
@property (strong) NSString *name;
/*
 The UID of the camera device. Users typically won't see this.
 Most applications use the UID to 'remember' cameras; it is probably a good idea to keep this consistent for your application
 if you want other apps to behave as expected.
 */
@property (strong) NSString *deviceUID;
/*
 The model name of the camera. Optional
 */
@property (strong) NSString *modelName;
/*
 The manfacturer of the camera. Optional
 */
@property (strong) NSString *manufacturer;

/*
 Camera framerate. You can feed frames at whatever framerate you want, but should try to match this framerate as best you can
 */
@property (assign) float frameRate;

@property (assign) UInt32 width;
@property (assign) UInt32 height;
/*
 Pixel format of the frames you plan to publish.
 If you publish frames that don't match this pixel format, they will be converted using a VTPixelTransferSession
 
 This is the same type as CVPixelBuffer's pixel format. Example: kCVPixelFormatType_32BGRA
 */
@property (assign) OSType pixelFormat;

/*
 This flag is set to true if the camera has been created and is capable of accepting video frames.
 If you publish frames before this is setup they will be dropped
 */
@property (assign) bool isReady;

/*
 TRUE: The camera will run an internal clock that maintains a steady frameRate to the client(s)
       regardless of the rate you publish frames.
 FALSE: Cameras do not run an internal clock and publish frames to the client ASAP.
 
 Note: due to the way DAL plugins work, the 'clock' runs independently in each process consuming frames from a given camera.
 */
@property (assign) bool useInternalClock;

/*
 Normally camera devices are destroyed when the application that created them exits.
 Set this to TRUE if you want the camera to not be destroyed on exit.
 You can 're-create' the camera and start publishing frames from another process/application
 To re-create the same camera, use the same deviceUID (see above)
 */
@property (assign) bool persistOnDisconnect;

/* Create the device. The completion block is called asynchronously once the camera is ready to
   publish frames. The isReady flag will be set to true before the completionBlock is called.
 */
-(void)createDeviceWithCompletionBlock:(void (^)(void))completionBlock;
/*
 Destroy this camera device. It will be removed immediately and unpublished from all clients (even ones receiving frames from it)
 */
-(void)destroyDevice;

/*
 Publish a CVPixelBuffer video frame. The most efficient path is to use an IOSurface backed CVPixelBuffer with the same pixelFormat the camera was created with
 Non-IOSurface backed buffers will have their data copied to an IOSurface for publishing
 */


-(void)publishCVPixelBufferFrame:(CVPixelBufferRef)videoFrame;
/*
 If you have raw IOSurface buffers, you can use this method to publish them.
 Note: IOSurface is 'toll free bridged' with IOSurfaceRef, so you can just pass an IOSurfaceRef to this method with appropriate casting.
 */
-(void)publishIOSurfaceFrame:(IOSurface *)videoFrame;

@end

/* Example
     _cameraDevice = [[CSVirtualCameraDevice alloc] init];
     _cameraDevice.deviceUID = @"EXAMPLE VCAM UID";
     _cameraDevice.frameRate = 60.0f;
     _cameraDevice.width = 1920;
     _cameraDevice.height = 1080;
     _cameraDevice.name = @"EXAMPLE VIRTUAL CAMERA"
     _cameraDevice.pixelFormat = kCVPixelFormatType_32BGRA
     [_cameraDevice createDeviceWithCompletionBlock:^{
         _cameraDevice.persistOnDisconnect = YES;
         //_cameraDevice is now ready to publish frames
     }];
 ...
 
 //Publish a frame
 
 [_cameraDevice publishCVPixelBufferFrame:videoFrame];
 
 ... later in app life cycle...
 //Remove camera device
 [_cameraDevice destroyDevice];
 */
NS_ASSUME_NONNULL_END

