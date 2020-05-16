//
//  CSVirtualCameraAssistant.h
//  CSVirtualCameraAssistant
//
//  Created by Zakk on 5/5/20.
//  Copyright © 2020 Zakk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSVirtualCameraAssistantProtocol.h"

// This object implements the protocol which we have defined. It provides the actual behavior for the service. It is 'exported' by the service to make it available to the process hosting the service over an NSXPCConnection.
@interface CSVirtualCameraAssistant : NSObject <CSVirtualCameraAssistantProtocol>

@property (strong) NSString *peerUUID;
@property (weak) NSXPCConnection *xpcConnection;
@property (weak) NSXPCListener *listener;

// Replace the API of this protocol with an API appropriate to the service you are vending.
-(void)registerAsPeer:(NSXPCListenerEndpoint *)withEndpoint;
-(void)peerSubscribeDevice:(NSString *)deviceUUID;
-(void)peerUnsubscribeDevice:(NSString *)deviceUUID;
-(void)publishNewFrame:(NSString *)deviceUUID withIOSurface:(IOSurface *)ioSurface;
-(void)getListenerEndpoint:(void (^)(NSXPCListenerEndpoint *endpoint))reply;


-(void)createDevice:(NSString *)name withUID:(NSString *)uid withModel:(NSString *)modelName withManufacturer:(NSString *)manufacturer width:(NSUInteger)width height:(NSUInteger)height pixelFormat:(OSType)pixelFormat frameRate:(float) frameRate withReply:(void (^)(NSString *))reply;

-(void)destroyDevice:(NSString *)uuid;

-(void)connectionInvalid;
-(void)connectionLost;
-(void)setPersistOnDisconnect:(bool)persist forDevice:(NSString *)deviceUUID;


@end
