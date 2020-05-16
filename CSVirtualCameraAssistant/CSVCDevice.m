//
//  CSVCDevice.m
//  CSVirtualCameraAssistant
//
//  Created by Zakk on 5/5/20.
//  Copyright © 2020 Zakk. All rights reserved.
//

#import "CSVCDevice.h"

@implementation CSVCDevice

-(instancetype)init
{
    if (self = [super init])
    {
        self.subscribers = [NSMutableDictionary dictionary];
    }
    return self;
}



@end
