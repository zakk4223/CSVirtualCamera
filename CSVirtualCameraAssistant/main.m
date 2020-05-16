//
//  main.m
//  testxpc
//
//  Created by Zakk on 5/6/20.
//  Copyright © 2020 Zakk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSVirtualCameraPeerProtocol.h"
#import "CSVirtualCameraAssistant.h"


@interface ServiceDelegate : NSObject <NSXPCListenerDelegate>
@end

@implementation ServiceDelegate


//TODO: Make the 'top level' protocol create a new endpoint when a peer registers and move that protocol to the new endponit so peer/producer are separated entirely

- (BOOL)listener:(NSXPCListener *)listener shouldAcceptNewConnection:(NSXPCConnection *)newConnection {

    newConnection.exportedInterface = [NSXPCInterface interfaceWithProtocol:@protocol(CSVirtualCameraAssistantProtocol)];
    
 
    CSVirtualCameraAssistant *exportedObject = [CSVirtualCameraAssistant new];
    newConnection.exportedObject = exportedObject;
    exportedObject.listener = listener;
    newConnection.interruptionHandler = ^{
        NSLog(@"CONNECTION INTERRUPTED");
        [exportedObject connectionLost];
    };
    
    newConnection.invalidationHandler = ^{
        NSLog(@"CONNECTION INVALID");
        [exportedObject connectionInvalid];
    };
    
    
    [newConnection resume];
    return YES;
}
@end


int main(int argc, const char *argv[])
{
    // Create the delegate for the service.
    ServiceDelegate *delegate = [ServiceDelegate new];
    
    // Set up the one NSXPCListener for this service. It will handle all incoming connections.
    NSXPCListener *listener = [[NSXPCListener alloc] initWithMachServiceName:@"com.cocoasplit.vcam.assistant"];
    listener.delegate = delegate;
    
    // Resuming the serviceListener starts this service. This method does not return.
    [listener resume];
    [[NSRunLoop currentRunLoop] run];

    return 0;
}
