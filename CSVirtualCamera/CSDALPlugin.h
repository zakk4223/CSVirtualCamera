//
//  CSDALPlugin.h
//  CSVirtualCamera
//
//  Created by Zakk on 5/3/20.
//  Copyright © 2020 Zakk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMediaIO/CMIOHardwarePlugIn.h>
#import "CSVirtualCameraUtil.h"
#import "CSCMObject.h"
#import "CSCMDevice.h"
#import "CSCMStream.h"
#import "CSVirtualCameraPeerProtocol.h"
#import "CSVirtualCameraAssistantProtocol.h"


NS_ASSUME_NONNULL_BEGIN

@interface CSDALPlugin : NSObject <CSVirtualCameraPeerProtocol, NSXPCListenerDelegate>
{
    NSMutableDictionary *_objects;
    NSMutableDictionary *_devices;
    CMIOHardwarePlugInInterface *_pluginInterface;
    id<CSVirtualCameraAssistantProtocol> _assistant;
    NSXPCListener *_myListener;
    xpc_connection_t _conn;
}


@property (assign) CMIOHardwarePlugInRef pluginRef;

-(CSCMObject *)getObject:(CMIOObjectID)forID;
-(void)addObject:(CSCMObject *)cmObject;
-(void)removeObject:(CSCMObject *)cmObject;


-(void)createDevice:(NSString *)name withUID:(NSString *)uid withModel:(NSString *)modelName withManufacturer:(NSString *)manufacturer width:(NSUInteger)width height:(NSUInteger)height pixelFormat:(OSType)pixelFormat frameRate:(float) frameRate;
-(void)destroyDevice:(NSString *)uuid;
-(void)connectToAssistant;
-(void)publishNewFrame:(NSString *)deviceUUID withIOSurface:(IOSurface *)ioSurface;
-(CMIOHardwarePlugInRef _Nullable )getPluginInterface;
-(void)subscribeToDevice:(CSCMDevice *)device;
-(void)unsubscribeFromDevice:(CSCMDevice *)device;


@end

NS_ASSUME_NONNULL_END
