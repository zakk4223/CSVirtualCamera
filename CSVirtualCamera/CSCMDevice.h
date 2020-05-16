//
//  CSCMDevice.h
//  CSVirtualCamera
//
//  Created by Zakk on 5/4/20.
//  Copyright © 2020 Zakk. All rights reserved.
//

#import "CSCMObject.h"
#import "CSCMStream.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSCMDevice : CSCMObject

@property (strong) NSString *name;
@property (strong) NSString *deviceUID;
@property (strong) NSString *modelName;
@property (strong) NSString *manufacturer;
@property (strong) CSCMStream *stream;

@end

NS_ASSUME_NONNULL_END
