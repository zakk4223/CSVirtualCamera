//
//  CSVirtualCameraAssistantProtocol.h
//  CSVirtualCameraAssistant
//
//  Created by Zakk on 5/5/20.
//  Copyright © 2020 Zakk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOSurface/IOSurfaceObjC.h>

// The protocol that this service will vend as its API. This header file will also need to be visible to the process hosting the service.
@protocol CSVirtualCameraAssistantProtocol

@property (strong) NSString *peerUUID;

// Replace the API of this protocol with an API appropriate to the service you are vending.
-(void)registerAsPeer:(NSXPCListenerEndpoint *)withEndpoint;
-(void)peerSubscribeDevice:(NSString *)deviceUUID;
-(void)peerUnsubscribeDevice:(NSString *)deviceUUID;
-(void)publishNewFrame:(NSString *)deviceUUID withIOSurface:(IOSurface *)ioSurface;
-(void)getListenerEndpoint:(void (^)(NSXPCListenerEndpoint *endpoint))reply;

-(void)setInternalClock:(bool)useClock forDevice:(NSString *)deviceUUID;
-(void)createDevice:(NSString *)name withUID:(NSString *)uid withModel:(NSString *)modelName withManufacturer:(NSString *)manufacturer width:(NSUInteger)width height:(NSUInteger)height pixelFormat:(OSType)pixelFormat frameRate:(float) frameRate withReply:(void (^)(NSString *))reply;
-(void)destroyDevice:(NSString *)uuid;
-(void)setPersistOnDisconnect:(bool)persist forDevice:(NSString *)deviceUUID;


@end

/*
 To use the service from an application or other process, use NSXPCConnection to establish a connection to the service by doing something like this:

     _connectionToService = [[NSXPCConnection alloc] initWithServiceName:@"zakk.lol.CSVirtualCameraAssistant"];
     _connectionToService.remoteObjectInterface = [NSXPCInterface interfaceWithProtocol:@protocol(CSVirtualCameraAssistantProtocol)];
     [_connectionToService resume];

Once you have a connection to the service, you can use it like this:

     [[_connectionToService remoteObjectProxy] upperCaseString:@"hello" withReply:^(NSString *aString) {
         // We have received a response. Update our text field, but do it on the main thread.
         NSLog(@"Result string was: %@", aString);
     }];

 And, when you are finished with the service, clean up the connection like this:

     [_connectionToService invalidate];
*/
