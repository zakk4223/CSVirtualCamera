//
//  CSVCTracker.h
//  CSVirtualCameraAssistant
//
//  Created by Zakk on 5/5/20.
//  Copyright © 2020 Zakk. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CSVCDevice.h"
#import "CSVirtualCameraAssistant.h"

NS_ASSUME_NONNULL_BEGIN

@interface CSVCTracker : NSObject


@property (strong) NSMutableDictionary *currentDevices;
@property (strong) NSMutableDictionary *currentPeers;

+(CSVCTracker *)sharedTracker;

-(void)registerDevice:(CSVCDevice *)device withOwner:(id)owner;
-(void)registerPeer:(CSVirtualCameraAssistant *)peer;
-(void)peerSubscribe:(CSVirtualCameraAssistant *)peer toDevice:(NSString *)device;
-(void)peerUnsubscribe:(CSVirtualCameraAssistant *)peer toDevice:(NSString *)deviceUUID;
-(CSVCDevice *)getDevice:(NSString *)deviceUUID;
-(void)removeDevice:(NSString *)deviceUUID;

@end

NS_ASSUME_NONNULL_END
