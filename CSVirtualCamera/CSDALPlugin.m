//
//  CSDALPlugin.m
//  CSVirtualCamera
//
//  Created by Zakk on 5/3/20.
//  Copyright © 2020 Zakk. All rights reserved.
//

#import "CSDALPlugin.h"
#import "CSDalMain.h"
#import "CSCMObject.h"
#import <ServiceManagement/ServiceManagement.h>
#import <IOSurface/IOSurfaceObjC.h>

void ObjectShow(CMIOHardwarePlugInRef self, CMIOObjectID obj)
{
    CSCMObject *pluginObj = [DALPlugin getObject:obj];
    if (pluginObj)
    {
        debugLog(@"ObjectShow: %d %@", obj, pluginObj);
    }
}


OSStatus TearDown(CMIOHardwarePlugInRef self)
{
    return kCMIOHardwareNoError;
}

ULONG AddRef(void *self)
{
    return 1;
}

ULONG Release(void *self)
{
    return 0;
}


OSStatus Initialize(CMIOHardwarePlugInRef self)
{
    return kCMIOHardwareNoError;
}

OSStatus InitializeWithObjectID(CMIOHardwarePlugInRef self, CMIOObjectID objectID)
{
    

    
    DALPlugin.pluginRef = self;
    
    CSCMObject *pluginObj = [[CSCMObject alloc] init];
    pluginObj.objectID = objectID;
    [DALPlugin addObject:pluginObj];
    
    //OSStatus err = [DALPlugin createVirtualDevice:@"CocoaSplit Virtual Camera" withFormatType:kCVPixelFormatType_32BGRA usingUID:@"CS VIDEO UID" width:1920 height:1080 framerate:60.0f];
 
    return noErr;
}



HRESULT QueryInterface(void *self, REFIID uuid, LPVOID *interface)
{
    
    
    /*
    if (!interface)
    {
        return E_POINTER;
    }
    */
    
    if (DALPlugin)
    {
        *interface = [DALPlugin getPluginInterface];

        return kCMIOHardwareNoError;
    }

    return kCMIOHardwareUnspecifiedError;
}

Boolean ObjectHasProperty(CMIOHardwarePlugInRef self, CMIOObjectID objectID, const CMIOObjectPropertyAddress*   address)
{
    CSCMObject *pluginObj = [DALPlugin getObject:objectID];
    if (!pluginObj)
    {
        return false;
    }
    
    if ([pluginObj hasProperty:address])
    {
        return true;
    }
    
    return false;
}

OSStatus ObjectGetPropertyDataSize(CMIOHardwarePlugInRef self, CMIOObjectID objectID, const CMIOObjectPropertyAddress* address, UInt32  qualifierDataSize, const void* qualifierData, UInt32* dataSize)
{
    
    CSCMObject *pluginObj = [DALPlugin getObject:objectID];
    if (!pluginObj)
    {
        return kCMIOHardwareBadObjectError;
    }
    
    UInt32 propSize = [pluginObj getPropertyDataSize:address];
    *dataSize = propSize;
    
    
    return noErr;
}

OSStatus ObjectGetPropertyData(CMIOHardwarePlugInRef self, CMIOObjectID objectID, const CMIOObjectPropertyAddress* address, UInt32  qualifierDataSize, const void* qualifierData, UInt32 dataSize, UInt32 *usedSize, void *data)
{
    
    CSCMObject *pluginObj = [DALPlugin getObject:objectID];

    if (!pluginObj)
    {
        data = NULL;
        *usedSize = 0;
        return kCMIOHardwareBadObjectError;
    }
    

    UInt32 propSize = [pluginObj getProperty:address withSize:dataSize withPtr:data];
    *usedSize = propSize;
    
    return noErr;
}




OSStatus ObjectSetPropertyData(CMIOHardwarePlugInRef self, CMIOObjectID objectID, const CMIOObjectPropertyAddress *address, UInt32 qualifierDataSize, const void *qualifierData, UInt32 dataSize, const void *data)
{
    CSCMObject *pluginObj = [DALPlugin getObject:objectID];
    if (!pluginObj)
    {
        return kCMIOHardwareBadObjectError;
    }
    
    
    return [pluginObj setProperty:address withSize:dataSize withData:data];
}

OSStatus ObjectIsPropertySettable(CMIOHardwarePlugInRef               self,
                                 CMIOObjectID                        objectID,
                                 const CMIOObjectPropertyAddress*    address,
                                 Boolean*                            isSettable)
{
    CSCMObject *pluginObj = [DALPlugin getObject:objectID];
    if (!pluginObj)
    {
        return kCMIOHardwareBadObjectError;
    }
    
    if ([pluginObj isPropertyWritable:address->mSelector])
    {
        *isSettable = true;
    } else {
        *isSettable = false;
    }
    
    return noErr;
}

OSStatus DeviceSuspend(CMIOHardwarePlugInRef   self, CMIODeviceID device)
{
    return noErr;
}


OSStatus DeviceResume(CMIOHardwarePlugInRef   self, CMIODeviceID device)
{
    return noErr;
}

OSStatus DeviceProcessAVCCommand(CMIOHardwarePlugInRef   self,
                             CMIODeviceID            device,
                             CMIODeviceAVCCommand*   ioAVCCommand)
{
    return kCMIOHardwareIllegalOperationError;
}

OSStatus DeviceProcessRS422Command(CMIOHardwarePlugInRef   self,
                                CMIODeviceID            device,
                                CMIODeviceRS422Command* ioRS422Command)
{
    return kCMIOHardwareIllegalOperationError;
}


OSStatus StreamDeckPlay(CMIOHardwarePlugInRef   self,
                    CMIOStreamID            stream)
{
    return kCMIOHardwareIllegalOperationError;
}

OSStatus StreamDeckStop(CMIOHardwarePlugInRef   self,
                    CMIOStreamID            stream)
{
    return kCMIOHardwareIllegalOperationError;
}

OSStatus StreamDeckJog(CMIOHardwarePlugInRef   self,
                    CMIOStreamID            stream,
                    SInt32 speed)
{

    return kCMIOHardwareIllegalOperationError;
}

OSStatus
StreamDeckCueTo(CMIOHardwarePlugInRef   self,
                    CMIOStreamID            stream,
                    Float64                 frameNumber,
                    Boolean                 playOnCue)
{
    return kCMIOHardwareIllegalOperationError;
}

OSStatus DeviceStartStream(CMIOHardwarePlugInRef   self,
                        CMIODeviceID            device,
                        CMIOStreamID            stream)
{
    CSCMStream *streamObj = (CSCMStream *)[DALPlugin getObject:stream];
    if (!streamObj)
    {
        return kCMIOHardwareBadObjectError;
    }
    
    [streamObj startStream];
    CSCMDevice *CSDevice = (CSCMDevice *)[DALPlugin getObject:streamObj.deviceID];
    [DALPlugin subscribeToDevice:CSDevice];
    return noErr;
}

OSStatus DeviceStopStream(CMIOHardwarePlugInRef   self,
                        CMIODeviceID            device,
                        CMIOStreamID            stream)
{
    CSCMStream *streamObj = (CSCMStream *)[DALPlugin getObject:stream];
    if (!streamObj)
    {
        return kCMIOHardwareBadObjectError;
    }
    
    [streamObj stopStream];
    CSCMDevice *CSDevice = (CSCMDevice *)[DALPlugin getObject:streamObj.deviceID];
    [DALPlugin unsubscribeFromDevice:CSDevice];
    return noErr;
}

OSStatus StreamCopyBufferQueue(CMIOHardwarePlugInRef               self,
                             CMIOStreamID                        stream,
                             CMIODeviceStreamQueueAlteredProc    queueAlteredProc,
                             void*                               queueAlteredRefCon,
                             CMSimpleQueueRef*                   queue)
{
    CSCMStream *streamObj = (CSCMStream *)[DALPlugin getObject:stream];
    if (!streamObj)
    {
        return kCMIOHardwareBadObjectError;
    }
    
    
    
    streamObj.queueAlteredProc = queueAlteredProc;
    streamObj.queueAltertedRefCon = queueAlteredRefCon;
    //The client expect to be able to release this when done, so retain it here
    if (streamObj.streamQueue)
    {
        CFRetain(streamObj.streamQueue);
    }
    *queue = streamObj.streamQueue;
    
    return noErr;
    
}
@implementation CSDALPlugin

-(instancetype) init
{
    if (self = [super init])
    {
        _objects = [NSMutableDictionary dictionary];
        _devices = [NSMutableDictionary dictionary];
        [self createPluginInterface];
        debugLog(@"CONNECTING TO ASSISTANT");
        [self connectToAssistant];
    }
    return self;
}


-(void)addObject:(CSCMObject *)cmObject
{
    _objects[@(cmObject.objectID)] = cmObject;
}


-(CSCMObject *)getObject:(CMIOObjectID)forID
{
    return _objects[@(forID)];
}

-(void)removeObject:(CSCMObject *)cmObject
{
    [_objects removeObjectForKey:@(cmObject.objectID)];
}


-(void)createPluginInterface
{
    CMIOHardwarePlugInInterface *pluginInterface;
    
    pluginInterface = malloc(sizeof(CMIOHardwarePlugInInterface));
    
    pluginInterface->_reserved = NULL;
    pluginInterface->QueryInterface = QueryInterface;
    pluginInterface->AddRef = AddRef;
    pluginInterface->Release = Release;
    pluginInterface->Initialize = Initialize;
    pluginInterface->InitializeWithObjectID = InitializeWithObjectID;
    pluginInterface->Teardown = TearDown;
    pluginInterface->ObjectShow = ObjectShow;
    pluginInterface->ObjectHasProperty = ObjectHasProperty;
    pluginInterface->ObjectIsPropertySettable = ObjectIsPropertySettable;
    pluginInterface->ObjectGetPropertyDataSize = ObjectGetPropertyDataSize;
    pluginInterface->ObjectGetPropertyData = ObjectGetPropertyData;
    pluginInterface->ObjectSetPropertyData = ObjectSetPropertyData;
    pluginInterface->DeviceSuspend = DeviceSuspend;
    pluginInterface->DeviceResume = DeviceResume;
    pluginInterface->DeviceStartStream = DeviceStartStream;
    pluginInterface->DeviceStopStream = DeviceStopStream;
    pluginInterface->DeviceProcessAVCCommand = DeviceProcessAVCCommand;
    pluginInterface->DeviceProcessRS422Command = DeviceProcessRS422Command;
    pluginInterface->StreamCopyBufferQueue = StreamCopyBufferQueue;
    pluginInterface->StreamDeckPlay = StreamDeckPlay;
    pluginInterface->StreamDeckStop = StreamDeckStop;
    pluginInterface->StreamDeckJog = StreamDeckJog;
    pluginInterface->StreamDeckCueTo = StreamDeckCueTo;
    
    _pluginInterface = pluginInterface;
    
    
}

-(CMIOHardwarePlugInRef)getPluginInterface
{
    return &_pluginInterface;
}

-(void)createDevice:(NSString *)name withUID:(NSString *)uid withModel:(NSString *)modelName withManufacturer:(NSString *)manufacturer width:(NSUInteger)width height:(NSUInteger)height pixelFormat:(OSType)pixelFormat frameRate:(float) frameRate;
{
    
    CMVideoFormatDescriptionRef videoFormat = NULL;
    NSDictionary *extDict = @{(id)kCMFormatDescriptionExtension_FormatName: NSFileTypeForHFSTypeCode(pixelFormat)};
    
    CMVideoFormatDescriptionCreate(NULL, pixelFormat, width, height, (__bridge CFDictionaryRef _Nullable)(extDict), &videoFormat);
    
    CSCMDevice *existingDev = _devices[uid];
    
    if (existingDev)
    {
        existingDev.name = name;
        existingDev.stream.videoFormat = videoFormat;
        existingDev.stream.frameRate = frameRate;
        existingDev.deviceUID = uid;
        existingDev.modelName = modelName;
    } else {
        CSCMDevice *newDev = [[CSCMDevice alloc] init];
        newDev.name = name;
        newDev.stream.videoFormat = videoFormat;
        newDev.stream.frameRate = frameRate;
        newDev.deviceUID = uid;
        newDev.modelName = modelName;
        [newDev createObjectUsingPlugin:self.pluginRef];
        
        [newDev publishObject:self.pluginRef];
        _devices[newDev.deviceUID] = newDev;
    }
}

-(void)destroyDevice:(NSString *)uuid
{
    CSCMDevice *dev = _devices[uuid];
    if (dev)
    {
        [dev unpublishObject:self.pluginRef];
        [_devices removeObjectForKey:uuid];
    }
}

-(void)useInternalClock:(bool)useClock forDevice:(NSString *)deviceUUID
{
    CSCMDevice *dev = _devices[deviceUUID];
    if (dev && dev.stream)
    {
        if (useClock)
        {
            [dev.stream activateInternalClock];
        } else {
            [dev.stream deactivateInternalClock];
        }
    }
}


-(void)publishNewFrame:(NSString *)deviceUUID withIOSurface:(IOSurface *)ioSurface
{
    CSCMDevice *dev = _devices[deviceUUID];
    if (dev && dev.stream)
    {
        [dev.stream updateCurrentFrameDataWithIOSurface:ioSurface];
    }
}
- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection
{
    NSXPCInterface *myInterface = [NSXPCInterface interfaceWithProtocol:@protocol(CSVirtualCameraPeerProtocol)];
    newConnection.exportedInterface = myInterface;
    newConnection.exportedObject = self;
    [newConnection resume];
    return YES;
}


-(void)subscribeToDevice:(CSCMDevice *)device
{
    [_assistant peerSubscribeDevice:device.deviceUID];
}

-(void)unsubscribeFromDevice:(CSCMDevice *)device
{
    [_assistant peerUnsubscribeDevice:device.deviceUID];
}

-(void)connectToAssistant
{
    _myListener = [NSXPCListener anonymousListener];
    _myListener.delegate = self;
    [_myListener resume];
    /*
    NSXPCConnection *brokerInterface = [NSXPCInterface interfaceWithProtocol:@protocol(CSVirtualCameraBrokerProtocol)];
    NSXPCConnection *brokerConnection = [[NSXPCConnection alloc] initWithServiceName:@"zakk.lol.CSVirtualCamera.CSVirtualCameraBroker"];
    
    brokerConnection.remoteObjectInterface = brokerInterface;
    [brokerConnection resume];
    id<CSVirtualCameraBrokerProtocol> brokerObj = [brokerConnection synchronousRemoteObjectProxyWithErrorHandler:^(NSError * _Nonnull error) {
        debugLog(@"ERROR CONNECTING TO BROKER %@", error);
    }];
    
    NSLog(@"BROKER CONNECTION %@ %@", brokerConnection, brokerObj);
    
    [brokerObj getAssistantEndpoint:^(NSXPCListenerEndpoint *endpoint) {
      */
        NSXPCInterface *assistantInterface = [NSXPCInterface interfaceWithProtocol:@protocol(CSVirtualCameraAssistantProtocol)];
        NSXPCConnection *connection = [[NSXPCConnection alloc] initWithMachServiceName:@"com.cocoasplit.vcam.assistant" options:0];
        
        [connection setRemoteObjectInterface:assistantInterface];
        [connection resume];
        _assistant = [connection remoteObjectProxyWithErrorHandler:^(NSError * _Nonnull error) {
            debugLog(@"GOT ERROR CONNECTING %@", error);
        }];
        
        
        
        [_assistant registerAsPeer:_myListener.endpoint];
    //}];

}

@end
    
