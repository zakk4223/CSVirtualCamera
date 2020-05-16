//
//  CSVirtualCameraPeerProtocol.h
//  CSVirtualCamera
//
//  Created by Zakk on 5/6/20.
//  Copyright © 2020 Zakk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <IOSurface/IOSurfaceObjC.h>

NS_ASSUME_NONNULL_BEGIN

@protocol CSVirtualCameraPeerProtocol <NSObject>

-(void)publishNewFrame:(NSString *)deviceUUID withIOSurface:(IOSurface *)ioSurface;
-(void)createDevice:(NSString *)name withUID:(NSString *)uid withModel:(NSString *)modelName withManufacturer:(NSString *)manufacturer width:(NSUInteger)width height:(NSUInteger)height pixelFormat:(OSType)pixelFormat frameRate:(float)frameRate;

-(void)destroyDevice:(NSString *)uuid;
-(void)useInternalClock:(bool)useClock forDevice:(NSString *)deviceUUID;

@end

NS_ASSUME_NONNULL_END
