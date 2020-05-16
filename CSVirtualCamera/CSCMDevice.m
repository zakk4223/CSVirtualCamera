//
//  CSCMDevice.m
//  CSVirtualCamera
//
//  Created by Zakk on 5/4/20.
//  Copyright © 2020 Zakk. All rights reserved.
//

#import <IOKit/audio/IOAudioTypes.h>

#import "CSCMDevice.h"
#import "CSDalMain.h"

@implementation CSCMDevice

@synthesize name = _name;
@synthesize deviceUID = _deviceUID;



-(instancetype)init
{
    if (self = [super init])
    {
        self.name = @"CocoaSplit Virtual Camera";
        self.deviceUID = @"CocoaSplit Virtual Camera Device";
        self.stream = [[CSCMStream alloc] init];
        
        [self setPropertyUsingSelector:kCMIODevicePropertyTransportType withUInt32:kIOAudioDeviceTransportTypeBuiltIn];
        //[self setPropertyUsingSelector:kCMIODevicePropertyDeviceIsRunningSomewhere withUInt32:1];
        [self setPropertyUsingSelector:kCMIODevicePropertyDeviceCanBeDefaultDevice withUInt32:1];
        [self setPropertyUsingSelector:kCMIODevicePropertyHogMode withUInt32:-1];
        [self setPropertyUsingSelector:kCMIODevicePropertyDeviceIsAlive withUInt32:1];
        //[self setPropertyUsingSelector:kCMIODevicePropertyDeviceIsRunning withUInt32:1];
        [self setPropertyUsingSelector:kCMIODevicePropertyExcludeNonDALAccess withUInt32:1];
        [self setPropertyUsingSelector:kCMIODevicePropertyDeviceMaster withUInt32:-1];
        [self setPropertyUsingSelector:kCMIODevicePropertySuspendedByUser withUInt32:0];
        self.propertyWriteMap = @{@(kCMIODevicePropertyHogMode): @YES,
                                  @(kCMIODevicePropertyExcludeNonDALAccess): @YES,
                                  
        };
    }
    
    return self;
    
}

-(OSStatus)unpublishObject:(CMIOHardwarePlugInRef)plugin
{
    OSErr err = noErr;
    CMIOObjectID myId = self.objectID;
    
    if (self.stream)
    {
        err = [self.stream unpublishObject:plugin];
        
    }
    
    if (err == noErr)
    {
        err = CMIOObjectsPublishedAndDied(plugin, kCMIOObjectSystemObject, 0, nil, 1, &myId);
    }
    
    return err;
}


-(OSStatus)publishObject:(CMIOHardwarePlugInRef)plugin
{
    CMIOObjectID myID = self.objectID;
    
    OSStatus err = CMIOObjectsPublishedAndDied(plugin, kCMIOObjectSystemObject, 1, &myID, 0, nil);
    
    
    if (self.stream)
    {
        err = [self.stream publishObject:plugin];
    }
    return err;
}



-(OSStatus)createObjectUsingPlugin:(CMIOHardwarePlugInRef _Nullable)plugin
{
    OSStatus err = [self createObjectForClass:kCMIODeviceClassID usingPlugin:plugin];
    if (err != noErr)
    {
        debugLog(@"FAILED TO CREATE DEVICE WITH ERROR %d", err);
    }
    
    [DALPlugin addObject:self];
    
    self.stream.deviceID = self.objectID;
    
    err = [self.stream createObjectUsingPlugin:plugin];
    
    if (err == noErr)
    {
        CMIOObjectID streamID = self.stream.objectID;
        [self setPropertyUsingSelector:kCMIODevicePropertyStreams withSize:sizeof(CMIOObjectID) withData:&streamID];
    }
    return err;
}


-(void)setDeviceUID:(NSString *)deviceUID
{
    _deviceUID = deviceUID;
    CFStringRef cfString = CFBridgingRetain(deviceUID);
    CMIOObjectPropertyAddress addr;
    addr.mSelector = kCMIODevicePropertyDeviceUID;
    [self setProperty:&addr withSize:sizeof(CFStringRef) withData:&cfString];
}

-(NSString *)deviceUID
{
    return _deviceUID;
}


-(void)setName:(NSString *)name
{
    _name = name;
    CFStringRef cfString = (__bridge CFStringRef)(name);
    CMIOObjectPropertyAddress addr;
    addr.mSelector = kCMIOObjectPropertyName;
    [self setProperty:&addr withSize:sizeof(CFStringRef) withData:&cfString];
}

-(NSString *)name
{
    return _name;
}

@end
