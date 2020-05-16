//
//  CSVCDevice.h
//  CSVirtualCameraAssistant
//
//  Created by Zakk on 5/5/20.
//  Copyright © 2020 Zakk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreVideo/CoreVideo.h>

NS_ASSUME_NONNULL_BEGIN

@interface CSVCDevice : NSObject

@property (strong) NSString *name;
@property (strong) NSString *uid;
@property (strong) NSString *modelName;
@property (strong) NSString *manufacturer;
@property (assign) NSUInteger width;
@property (assign) NSUInteger height;
@property (assign) float frameRate;
@property (assign) OSType pixelFormat;
@property (assign) bool persistOnDisconnect;
@property (weak) id owner;
@property (assign) bool useInternalClock;
@property (assign) CVPixelBufferRef noSourceImage;
@property (strong) NSMutableDictionary *subscribers;

@end

NS_ASSUME_NONNULL_END
