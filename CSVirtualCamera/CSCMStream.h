//
//  CSCMStream.h
//  CSVirtualCamera
//
//  Created by Zakk on 5/4/20.
//  Copyright © 2020 Zakk. All rights reserved.
//

#import "CSCMObject.h"
#import <IOSurface/IOSurfaceObjC.h>

NS_ASSUME_NONNULL_BEGIN

@interface CSCMStream : CSCMObject
{
    dispatch_source_t _frameTimer;
}

@property (assign) CMIOObjectID deviceID;
@property (assign) CFTypeRef streamClock;
@property (assign) CMSimpleQueueRef streamQueue;
@property (assign) float frameRate;
@property (assign) CMVideoFormatDescriptionRef videoFormat;
@property (assign) CMIODeviceStreamQueueAlteredProc queueAlteredProc;
@property (assign) void *queueAltertedRefCon;
@property (assign) CVPixelBufferRef currentPixelBuffer;
@property (assign) UInt64 frameSequenceNumber;

-(void)queuePixelBuffer:(CVPixelBufferRef)pixelBuffer;

-(void)startStream;
-(void)stopStream;

-(instancetype)initWithFormat:(CMVideoFormatDescriptionRef)format framerate:(float)frameRate;
-(void)updateCurrentFrameDataWithIOSurface:(IOSurface *)surface;
-(void)updateCurrentFrameData:(CVPixelBufferRef)newFrame;
-(void)activateInternalClock;
-(void)deactivateInternalClock;



@end

NS_ASSUME_NONNULL_END
