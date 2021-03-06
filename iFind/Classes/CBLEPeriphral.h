//
//  CBLEPeriphral.h
//  iFind
//
//  Created by Carl on 13-9-19.
//  Copyright (c) 2013年 iFind. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>
typedef void (^UpdateRSSIHandler)(int rssi);
typedef void (^RecieveDataHandler)(CBPeripheral * peripheral);
@interface CBLEPeriphral : NSObject <CBPeripheralDelegate>

@property (nonatomic,retain) CBPeripheral * peripheral;
@property (nonatomic,assign) int rssi;
@property (nonatomic,retain) NSString * UUID;
@property (nonatomic,assign) int batteryLevel;
@property (nonatomic,assign) int tag;
@property (nonatomic,retain) CBCharacteristic * characteristicForAlert;
@property (nonatomic,retain) CBCharacteristic * characteristicForAlertLevel;
@property (nonatomic,retain) CBCharacteristic * characteristicForBattery;
@property (nonatomic,copy) UpdateRSSIHandler updateRSSIHandler;
@property (nonatomic,copy) RecieveDataHandler remoteControlHandler;
-(id)initWithPeripheral:(CBPeripheral *)peripheral;

-(void)discoverServices;
-(void)writeAlertLevelNone;
-(void)writeAlertLevelMid;
-(void)writeAlertLevelHigh;
-(void)writeAlertLevel:(int)level;
-(void)readRSSI:(NSTimer *)timer;
@end
