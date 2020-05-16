//
//  CSCMObject.m
//  CSVirtualCamera
//
//  Created by Zakk on 5/4/20.
//  Copyright © 2020 Zakk. All rights reserved.
//

#import "CSCMObject.h"
#import <objc/objc.h>
#import <objc/runtime.h>

@implementation CSCMObject

-(instancetype)init
{
    if (self = [super init])
    {
        _propertyMap = [NSMutableDictionary dictionary];
        self.propertyWriteMap = [NSDictionary dictionary];
        _propertyRetainMap = @{@(kCMIODevicePropertyDeviceUID): @YES,
                               @(kCMIOObjectPropertyName): @YES,
                               @(kCMIOStreamPropertyPreferredFormatDescription): @YES,
                               @(kCMIOStreamPropertyFormatDescriptions): @YES,
                               @(kCMIOStreamPropertyFormatDescription): @YES,
                               @(kCMIOStreamPropertyClock): @YES,
                               @(kCMIODevicePropertyModelUID): @YES
                               
        };
        
    }
    
    return self;
}

-(OSStatus)createObjectUsingPlugin:(CMIOHardwarePlugInRef _Nullable)plugin
{
    return noErr;
}


-(OSStatus)createObjectForClass:(CMIOClassID)classID usingPlugin:(CMIOHardwarePlugInRef)plugin
{
    return [self createObjectForClass:classID usingPlugin:plugin withOwnerID:kCMIOObjectSystemObject];
}


-(OSStatus)createObjectForClass:(CMIOClassID)classID usingPlugin:(CMIOHardwarePlugInRef)plugin withOwnerID:(CMIOObjectID)ownerID
{
    
    OSStatus err = CMIOObjectCreate(plugin, ownerID, classID, &_objectID);
    
    if (err != noErr)
    {
        debugLog(@"Failed to create object with classID %d (%p)", classID, self);
        return err;
    }
    
    return err;
}
-(bool)hasProperty:(const CMIOObjectPropertyAddress *)propertyName
{
    if (_propertyMap[@(propertyName->mSelector)])
    {
        return YES;
    }
    return NO;
}


-(OSStatus)setPropertyUsingSelector:(const CMIOObjectPropertySelector)usingSelector withSize:(NSUInteger)size withData:(void *)dataPtr
{
    NSData *propertyData = [NSData dataWithBytes:dataPtr length:size];
    _propertyMap[@(usingSelector)] = propertyData;
    return noErr;
}

-(OSStatus)setPropertyUsingSelector:(const CMIOObjectPropertySelector)usingSelector withUInt32:(UInt32)value
{
    return [self setPropertyUsingSelector:usingSelector withSize:sizeof(UInt32) withData:&value];
    
}

-(OSStatus)setPropertyUsingSelector:(const CMIOObjectPropertySelector)usingSelector withFloat64:(Float64)value
{
    return [self setPropertyUsingSelector:usingSelector withSize:sizeof(Float64) withData:&value];
}


-(OSStatus)setProperty:(const CMIOObjectPropertyAddress *)propertyName withSize:(NSUInteger)size withData:(void *)dataPtr
{
    return [self setPropertyUsingSelector:propertyName->mSelector withSize:size withData:dataPtr];

}

-(UInt32)getPropertyUsingSelector:(CMIOObjectPropertySelector)usingSelector withSize:(UInt32)size withPtr:(void *)dataPtr
{
    UInt32 usedSize = 0;
    NSData *propertyData = _propertyMap[@(usingSelector)];
    if (!propertyData)
    {
        return usedSize;
    }
    
    if (size < propertyData.length)
    {
        return usedSize;
    }
    usedSize = (UInt32)propertyData.length;

    if (_propertyRetainMap[@(usingSelector)] && propertyData && propertyData.bytes)
    {
        //Clients expect to CFRelease whatever this is..
        CFTypeRef tmpRef;
        memcpy(&tmpRef, propertyData.bytes, usedSize);
        CFRetain(tmpRef);
    }
    usedSize = (UInt32)propertyData.length;
    memcpy(dataPtr, propertyData.bytes, usedSize);
    return usedSize;
}
-(UInt32)getProperty:(const CMIOObjectPropertyAddress *)propertyName withSize:(UInt32)size withPtr:(void *)dataPtr
{
    return [self getPropertyUsingSelector:propertyName->mSelector withSize:size withPtr:dataPtr];
}

-(UInt32)getPropertyDataSize:(const CMIOObjectPropertyAddress *)propertyName
{
    if ([self hasProperty:propertyName])
    {
        NSData *propData = _propertyMap[@(propertyName->mSelector)];
        if (propData)
        {
            return (UInt32)propData.length;
        }
    }
    return 0;
}

-(OSStatus)removePropertyUsingSelector:(const CMIOObjectPropertySelector)usingSelector
{
    [_propertyMap removeObjectForKey:@(usingSelector)];
    return noErr;
}


-(OSStatus)publishObject:(CMIOHardwarePlugInRef)plugin
{
    return noErr;
}

-(OSStatus)unpublishObject:(CMIOHardwarePlugInRef)plugin
{
    return noErr;
}


-(bool)isPropertyWritable:(CMIOObjectPropertySelector)selector
{
    if (self.propertyWriteMap[@(selector)])
    {
        return YES;
    }
    
    return NO;
}



@end
