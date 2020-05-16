//
//  CSVCTracker.m
//  CSVirtualCameraAssistant
//
//  Created by Zakk on 5/5/20.
//  Copyright © 2020 Zakk. All rights reserved.
//

#import "CSVCTracker.h"

@implementation CSVCTracker


-(instancetype) init
{
    if (self = [super init])
    {
        _currentPeers = [NSMutableDictionary dictionary];
        _currentDevices = [NSMutableDictionary dictionary];
    }
    return self;
}
+(CSVCTracker *)sharedTracker
{
    static dispatch_once_t sharedTrackerOnce;
    static CSVCTracker *sharedTracker = nil;
    
    dispatch_once(&sharedTrackerOnce, ^{
        sharedTracker = [[CSVCTracker alloc] init];
    });
    return sharedTracker;
}

-(void)registerDevice:(CSVCDevice *)device withOwner:(id)owner
{
    _currentDevices[device.uid] = device;
    device.owner = owner;
}


-(void)registerPeer:(CSVirtualCameraAssistant *)peer
{
    _currentPeers[peer.peerUUID] = peer;
}

-(void)peerSubscribe:(CSVirtualCameraAssistant *)peer toDevice:(NSString *)device
{
    CSVCDevice *vDev = self.currentDevices[device];
    if (!vDev)
    {
        return;
    }
    
    vDev.subscribers[peer.peerUUID] = peer;
}
-(void)peerUnsubscribe:(CSVirtualCameraAssistant *)peer toDevice:(NSString *)deviceUUID;
{
    CSVCDevice *vDev = self.currentDevices[deviceUUID];
    if (!vDev)
    {
        return;
    }
    
    [vDev.subscribers removeObjectForKey:peer.peerUUID];
    
}

-(CSVCDevice *)getDevice:(NSString *)deviceUUID
{
    return self.currentDevices[deviceUUID];
}

-(void)removeDevice:(NSString *)deviceUUID
{
    [self.currentDevices removeObjectForKey:deviceUUID];
}


@end
