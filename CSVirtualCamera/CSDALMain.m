//
//  CSDALMain.m
//  CSVirtualCamera
//
//  Created by Zakk on 5/4/20.
//  Copyright © 2020 Zakk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSDalMain.h"

CSDALPlugin *DALPlugin;


CMIOHardwarePlugInRef CSDALPluginMain(CFAllocatorRef allocator, CFUUIDRef requestedTypeUUID)
{
    if (!CFEqual(requestedTypeUUID, kCMIOHardwarePlugInTypeID))
    {
        return NULL;
    }
    DALPlugin = [[CSDALPlugin alloc] init];
    CMIOHardwarePlugInRef pIface = [DALPlugin getPluginInterface];
    return (CMIOHardwarePlugInRef)pIface;
}




