//
//  CSCMStream.m
//  CSVirtualCamera
//
//  Created by Zakk on 5/4/20.
//  Copyright © 2020 Zakk. All rights reserved.
//

#import <CoreMediaIO/CMIOSampleBuffer.h>
#import <IOSurface/IOSurfaceObjC.h>
#import "CSCMStream.h"
#import "CSDALPlugin.h"
#import "CSDalMain.h"

@implementation CSCMStream


@synthesize videoFormat = _videoFormat;
@synthesize frameRate = _frameRate;
@synthesize streamClock = _streamClock;

-(instancetype)init
{
    if (self = [super init])
    {
        [self setPropertyUsingSelector:kCMIOStreamPropertyDirection withUInt32:1];
    }
    
    return self;
}


-(instancetype)initWithFormat:(CMVideoFormatDescriptionRef)format framerate:(float)frameRate
{
    if (self = [self init])
    {
        self.frameRate = frameRate;
        self.videoFormat = format;
        [self setPropertyUsingSelector:kCMIOStreamPropertyDirection withUInt32:1];
    }
    
    return self;
}

-(void)updateCurrentFrameDataWithIOSurface:(IOSurface *)surface
{
    CVPixelBufferRef newPixelBuffer;
    CVPixelBufferCreateWithIOSurface(NULL, (__bridge IOSurfaceRef _Nonnull)(surface), NULL, &newPixelBuffer);
    [self updateCurrentFrameData:newPixelBuffer];
    CVPixelBufferRelease(newPixelBuffer);
}


-(void)updateCurrentFrameData:(CVPixelBufferRef)newFrame
{
    CVPixelBufferRetain(newFrame);

    CVPixelBufferRef oldBuffer;
    @synchronized (self)
    {
        oldBuffer = self.currentPixelBuffer;
        
        self.currentPixelBuffer = newFrame;
    }
    
    if (oldBuffer)
    {
        CVPixelBufferRelease(oldBuffer);
    }
    
    if (!_frameTimer)
    {
        [self queuePixelBuffer:self.currentPixelBuffer];
    }
}

-(void)makeTestFrame
{
    CVPixelBufferRef newFrame;
    CMVideoDimensions dims = CMVideoFormatDescriptionGetDimensions(self.videoFormat);
    
    CGFloat cTime = (CGFloat)mach_absolute_time() / NSEC_PER_SEC;
    CGFloat cPos = cTime - floor(cTime);
    
    CVPixelBufferCreate(NULL, dims.width, dims.height, CMFormatDescriptionGetMediaSubType(self.videoFormat), NULL, &newFrame);
    CVPixelBufferLockBaseAddress(newFrame, 0);
    CGContextRef bCtx = CGBitmapContextCreate(CVPixelBufferGetBaseAddress(newFrame), dims.width, dims.height, 8, dims.width*4, CGColorSpaceCreateDeviceRGB(), kCGImageAlphaPremultipliedLast);
    CGContextSetRGBFillColor(bCtx, 1, 1, 1, 1);
    CGContextFillRect(bCtx, CGRectMake(0, 0, dims.width, dims.height));
    CGContextSetRGBFillColor(bCtx, 1, 0, 0, 1);
    CGContextFillRect(bCtx, CGRectMake(cPos * dims.width, 310, 100, 100));
    CGContextRelease(bCtx);
    CVPixelBufferUnlockBaseAddress(newFrame, 0);
    [self updateCurrentFrameData:newFrame];
    CVPixelBufferRelease(newFrame);
    
}
-(void)createFrameTimer
{
    
    if (_frameTimer)
    {
        return;
    }
    
    
    dispatch_source_t newTimer;
    
    newTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0));
    dispatch_source_set_timer(newTimer, DISPATCH_TIME_NOW, ((1/self.frameRate) * NSEC_PER_SEC), 0);
    dispatch_source_set_event_handler(newTimer, ^{
        CVPixelBufferRef queueBuffer;
        @synchronized(self)
        {
            //[self makeTestFrame];
            queueBuffer = self.currentPixelBuffer;
            CVPixelBufferRetain(queueBuffer);
        }
        
        [self queuePixelBuffer:queueBuffer];
        CVPixelBufferRelease(queueBuffer);
    });
    _frameTimer = newTimer;
    
}
-(void)setVideoFormat:(CMVideoFormatDescriptionRef)videoFormat
{
    _videoFormat = videoFormat;
    
    CFArrayRef currVal = NULL;
    
    [self getPropertyUsingSelector:kCMIOStreamPropertyFormatDescriptions withSize:sizeof(CFArrayRef) withPtr:&currVal];
    if (currVal)
    {
        CFRelease(currVal);
    }
    
    CMVideoFormatDescriptionRef oldVal = NULL;
    [self getPropertyUsingSelector:kCMIOStreamPropertyFormatDescription withSize:sizeof(CMVideoFormatDescriptionRef) withPtr:&oldVal];
    if (oldVal)
    {
        CFRelease(oldVal);
    }
    
    
    
    if (_videoFormat)
    {
        CFRetain(_videoFormat);
        [self setPropertyUsingSelector:kCMIOStreamPropertyFormatDescription withSize:sizeof(CMVideoFormatDescriptionRef) withData:&_videoFormat];
    } else {
        [self removePropertyUsingSelector:kCMIOStreamPropertyFormatDescription];
        [self removePropertyUsingSelector:kCMIOStreamPropertyFormatDescriptions];

    }

}

-(CMVideoFormatDescriptionRef)videoFormat
{
    return _videoFormat;
}


-(OSStatus)unpublishObject:(CMIOHardwarePlugInRef)plugin
{
    CMIOObjectID myID = self.objectID;
    
    OSStatus err = CMIOObjectsPublishedAndDied(plugin, self.deviceID, 0, nil, 1, &myID);
    return err;
}


-(OSStatus)publishObject:(CMIOHardwarePlugInRef)plugin
{
    CMIOObjectID myID = self.objectID;
    
   OSStatus err = CMIOObjectsPublishedAndDied(plugin, self.deviceID, 1, &myID, 0, nil);
    
    return err;
}


-(OSStatus)createObjectUsingPlugin:(CMIOHardwarePlugInRef _Nullable)plugin
{
    
    CFTypeRef newClock = NULL;
    
    CMIOStreamClockCreate(NULL, CFSTR("CSVCClock"), (__bridge const void *)(self), CMTimeMake(1, 10), 100, 10, &newClock);
    self.streamClock = newClock;
    
    CMSimpleQueueRef newQueue = NULL;
    
    CMSimpleQueueCreate(NULL, 10, &newQueue);
    self.streamQueue = newQueue;
    
    OSStatus err = [self createObjectForClass:kCMIOStreamClassID usingPlugin:plugin withOwnerID:self.deviceID];
    if (err != noErr)
    {
        debugLog(@"FAILED TO CREATE DEVICE WITH ERROR %d", err);
    }
    
    [DALPlugin addObject:self];

    
    return err;
}

-(void)setFrameRate:(float)frameRate
{
    _frameRate = frameRate;
    //[self setPropertyUsingSelector:kCMIOStreamPropertyFrameRate withFloat64:frameRate];
    [self setPropertyUsingSelector:kCMIOStreamPropertyFrameRates withFloat64:frameRate];
   // [self setPropertyUsingSelector:kCMIOStreamPropertyMinimumFrameRate withFloat64:frameRate];
    AudioValueRange avRange;
    avRange.mMaximum = frameRate;
    avRange.mMinimum = frameRate;
    
    //[self setPropertyUsingSelector:kCMIOStreamPropertyFrameRateRanges withSize:sizeof(AudioValueRange) withData:&avRange];
    
    if (_frameTimer)
    {
        dispatch_source_set_timer(_frameTimer, DISPATCH_TIME_NOW, ((1/self.frameRate) * NSEC_PER_SEC), 0);

    }
}

-(float)frameRate
{
    return _frameRate;
}

-(CFTypeRef)streamClock
{
    return _streamClock;
}

-(void)setStreamClock:(CFTypeRef)streamClock
{
    _streamClock = streamClock;
    
    [self setPropertyUsingSelector:kCMIOStreamPropertyClock withSize:sizeof(CFTypeRef) withData:&streamClock];
}

-(void)queuePixelBuffer:(CVPixelBufferRef)pixelBuffer
{
    if (!pixelBuffer || !self.streamQueue)
    {
        return;
    }
        
    
    uint64_t currentTime = mach_absolute_time();
    
    if (CMSimpleQueueGetCount(self.streamQueue) >= CMSimpleQueueGetCapacity(self.streamQueue))
    {
        return;
    }
    
    CMSampleTimingInfo timingInfo;
    timingInfo.duration = CMTimeMake(1, self.frameRate);
    timingInfo.presentationTimeStamp = CMTimeMake(mach_absolute_time(), NSEC_PER_SEC);
    timingInfo.decodeTimeStamp = kCMTimeInvalid;
    OSStatus err = CMIOStreamClockPostTimingEvent(timingInfo.presentationTimeStamp, currentTime, false, self.streamClock);
    if (err != noErr)
    {
        return;
    }
    
    CMFormatDescriptionRef frameDesc;
    CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixelBuffer, &frameDesc);
    
    CMSampleBufferRef sampleBuffer;
    CMIOSampleBufferCreateForImageBuffer(NULL, pixelBuffer, frameDesc, &timingInfo, self.frameSequenceNumber, kCMIOSampleBufferNoDiscontinuities, &sampleBuffer);
    CFRelease(frameDesc);
    
    CMSimpleQueueEnqueue(self.streamQueue, sampleBuffer);
    if (self.queueAlteredProc)
    {
        self.queueAlteredProc(self.objectID, sampleBuffer, self.queueAltertedRefCon);
    }
    self.frameSequenceNumber++;
}

-(void)activateInternalClock
{
    [self createFrameTimer];
}

-(void)deactivateInternalClock
{
    if (_frameTimer)
    {
        dispatch_cancel(_frameTimer);
        _frameTimer = nil;
    }
}


-(void)startStream
{
    
    if (_frameTimer)
    {
        dispatch_resume(_frameTimer);
    } else if (self.currentPixelBuffer) {
        //Idle image?
        [self queuePixelBuffer:self.currentPixelBuffer];
    }
        
}

-(void)stopStream
{
    if (_frameTimer)
    {
        dispatch_suspend(_frameTimer);
    }
}



-(void)dealloc
{
    if (self.streamQueue)
    {
        CFRelease(self.streamQueue);
    }
    
    if (self.streamClock)
    {
        CFRelease(self.streamClock);
    }
}

@end
