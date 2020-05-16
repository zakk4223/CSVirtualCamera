//
//  CSCMObject.h
//  CSVirtualCamera
//
//  Created by Zakk on 5/4/20.
//  Copyright © 2020 Zakk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMediaIO/CMIOHardwarePlugIn.h>
#import "CSVirtualCameraUtil.h"
NS_ASSUME_NONNULL_BEGIN

@interface CSCMObject : NSObject
{
    NSDictionary *_propertyRetainMap;
}

@property (strong) NSMutableDictionary *propertyMap;
@property (assign) CMIOObjectID objectID;
@property (strong) NSDictionary *propertyWriteMap;


-(OSStatus)setProperty:(const CMIOObjectPropertyAddress *)propertyName withSize:(NSUInteger)size withData:(void *)dataPtr;
-(UInt32)getProperty:(const CMIOObjectPropertyAddress *)propertyName withSize:(UInt32)size withPtr:(void *)dataPtr;
-(bool)hasProperty:(const CMIOObjectPropertyAddress *)propertyName;
-(UInt32)getPropertyDataSize:(const CMIOObjectPropertyAddress *)propertyName;
-(OSStatus)createObjectForClass:(CMIOClassID)classID usingPlugin:(CMIOHardwarePlugInRef _Nullable )plugin;
-(OSStatus)createObjectUsingPlugin:(CMIOHardwarePlugInRef _Nullable)plugin;

-(OSStatus)createObjectForClass:(CMIOClassID)classID usingPlugin:(CMIOHardwarePlugInRef)plugin withOwnerID:(CMIOObjectID)ownerID;

-(OSStatus)publishObject:(CMIOHardwarePlugInRef)plugin;
-(OSStatus)unpublishObject:(CMIOHardwarePlugInRef)plugin;

-(OSStatus)setPropertyUsingSelector:(const CMIOObjectPropertySelector)usingSelector withUInt32:(UInt32)value;
-(OSStatus)setPropertyUsingSelector:(const CMIOObjectPropertySelector)usingSelector withFloat64:(Float64)value;
-(UInt32)getPropertyUsingSelector:(CMIOObjectPropertySelector)usingSelector withSize:(UInt32)size withPtr:(void *)dataPtr;
-(OSStatus)setPropertyUsingSelector:(const CMIOObjectPropertySelector)usingSelector withSize:(NSUInteger)size withData:(void *)dataPtr;
-(OSStatus)removePropertyUsingSelector:(const CMIOObjectPropertySelector)usingSelector;
-(bool)isPropertyWritable:(CMIOObjectPropertySelector)selector;


@end

NS_ASSUME_NONNULL_END
