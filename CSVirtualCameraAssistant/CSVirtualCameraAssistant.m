//
//  CSVirtualCameraAssistant.m
//  CSVirtualCameraAssistant
//
//  Created by Zakk on 5/5/20.
//  Copyright © 2020 Zakk. All rights reserved.
//

#import "CSVirtualCameraAssistant.h"
#import "CSVirtualCameraPeerProtocol.h"
#import "CSVCTracker.h"
#import "CSVCDevice.h"

@implementation CSVirtualCameraAssistant


// Replace the API of this protocol with an API appropriate to the service you are vending.


-(void)getListenerEndpoint:(void (^)(NSXPCListenerEndpoint *endpoint))reply
{
    reply(self.listener.endpoint);
}


-(void)registerAsPeer:(NSXPCListenerEndpoint *)withEndpoint
{
    NSLog(@"XPC REGISTER PEER %@", self);
    self.peerUUID = [[NSUUID UUID] UUIDString];
    NSXPCConnection *peerConnection = [[NSXPCConnection alloc] initWithListenerEndpoint:withEndpoint];
    [peerConnection setRemoteObjectInterface:[NSXPCInterface interfaceWithProtocol:@protocol(CSVirtualCameraPeerProtocol)]];
    [peerConnection resume];
    self.xpcConnection = peerConnection;
    
    [[CSVCTracker sharedTracker] registerPeer:self];
    id <CSVirtualCameraPeerProtocol> proxy = [peerConnection remoteObjectProxyWithErrorHandler:^(NSError * _Nonnull error) {
        NSLog(@"ERROR IN REMOTE OBJECT PROXY FOR CONNECT BACK");
    }];
    
    for(NSString *deviceUUID in [CSVCTracker sharedTracker].currentDevices)
    {
        CSVCDevice *device = [CSVCTracker sharedTracker].currentDevices[deviceUUID];
        
            
            NSLog(@"CREATING DEVICE IN NEW PEER %@ %@ %@", device, self, self.xpcConnection.remoteObjectProxy);
            [self.xpcConnection.remoteObjectProxy createDevice:device.name withUID:device.uid withModel:device.modelName withManufacturer:device.manufacturer width:device.width height:device.height  pixelFormat:device.pixelFormat frameRate:device.frameRate];
    }
}


-(void)peerSubscribeDevice:(NSString *)deviceUUID
{
    [[CSVCTracker sharedTracker] peerSubscribe:self toDevice:deviceUUID];
}
-(void)peerUnsubscribeDevice:(NSString *)deviceUUID
{
    [[CSVCTracker sharedTracker] peerUnsubscribe:self toDevice:deviceUUID];

}
-(void)publishNewFrame:(NSString *)deviceUUID withIOSurface:(IOSurface *)ioSurface
{
    if (!self.peerUUID) //We're a producer!
    {
        CSVCDevice *myDevice = [[CSVCTracker sharedTracker] getDevice:deviceUUID];
        if (myDevice.owner != self)
        {
            return;
        }
        
        for(NSString *peerUUID in myDevice.subscribers)
        {
            CSVirtualCameraAssistant *dalPeer = myDevice.subscribers[peerUUID];
            [dalPeer.xpcConnection.remoteObjectProxy publishNewFrame:deviceUUID withIOSurface:ioSurface];
        }
    }
}

-(void)setPersistOnDisconnect:(bool)persist forDevice:(NSString *)deviceUUID
{
    CSVCDevice *dev = [[CSVCTracker sharedTracker] getDevice:deviceUUID];
    dev.persistOnDisconnect = persist;
}


-(void)createDevice:(NSString *)name withUID:(NSString *)uid withModel:(NSString *)modelName withManufacturer:(NSString *)manufacturer width:(NSUInteger)width height:(NSUInteger)height pixelFormat:(OSType)pixelFormat frameRate:(float) frameRate withReply:(void (^)(NSString *))reply
{
    if (!self.peerUUID)
    {
        CSVCDevice *existingDevice = [[CSVCTracker sharedTracker] getDevice:uid];
        CSVCDevice *newDevice = nil;
        if (existingDevice)
        {
            newDevice = existingDevice;
        } else {
            newDevice = [[CSVCDevice alloc] init];
        }
        newDevice.name = name;
        newDevice.modelName = modelName;
        newDevice.uid = uid;
        newDevice.width = width;
        newDevice.height = height;
        newDevice.pixelFormat = pixelFormat;
        newDevice.manufacturer = manufacturer;
        newDevice.frameRate = frameRate;
        if (!existingDevice)
        {
            [[CSVCTracker sharedTracker] registerDevice:newDevice withOwner:self];
        }

        if (!newDevice.owner)
        {
            newDevice.owner = self;
        }
        
        if (reply)
        {
            reply(newDevice.uid);
        }
        for(NSUUID *peerUUID in [CSVCTracker sharedTracker].currentPeers)
        {
            //Always recreate in case name/format/fr changed
            CSVirtualCameraAssistant *dalPeer = [CSVCTracker sharedTracker].currentPeers[peerUUID];
            [dalPeer.xpcConnection.remoteObjectProxy createDevice:name withUID:uid withModel:modelName withManufacturer:manufacturer width:width height:height pixelFormat:pixelFormat frameRate:frameRate];
        }
        
    }
}


-(void)setInternalClock:(bool)useClock forDevice:(NSString *)deviceUUID
{
    CSVCDevice *myDevice = [[CSVCTracker sharedTracker] getDevice:deviceUUID];
    myDevice.useInternalClock = useClock;
    
    for(NSUUID *peerUUID in [CSVCTracker sharedTracker].currentPeers)
    {
        CSVirtualCameraAssistant *dalPeer = [CSVCTracker sharedTracker].currentPeers[peerUUID];
        [dalPeer.xpcConnection.remoteObjectProxy useInternalClock:useClock forDevice:deviceUUID];
    }
}


-(void)destroyDevice:(NSString *)uuid
{
    if (!self.peerUUID)
    {
        for(NSUUID *peerUUID in [CSVCTracker sharedTracker].currentPeers)
        {
            CSVirtualCameraAssistant *dalPeer = [CSVCTracker sharedTracker].currentPeers[peerUUID];
            [dalPeer.xpcConnection.remoteObjectProxy destroyDevice:uuid];
        }
        
        [[CSVCTracker sharedTracker] removeDevice:uuid];
        
        
    }
}

-(void)connectionInvalid
{
    
    [self connectionLost];
}

-(void)connectionLost
{
    if (self.peerUUID)
    {
        for(NSString *deviceUUID in [CSVCTracker sharedTracker].currentDevices)
        {
            [self peerUnsubscribeDevice:deviceUUID];
        }
    } else {
        for(NSString *deviceUUID in [CSVCTracker sharedTracker].currentDevices)
        {
            CSVCDevice *dev = [CSVCTracker.sharedTracker getDevice:deviceUUID];
            if (self == dev.owner)
            {
                if (!dev.persistOnDisconnect)
                {
                    [self destroyDevice:deviceUUID];
                }
                dev.owner = nil;
            }
        }
    }
}

@end
