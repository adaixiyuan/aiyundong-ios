//
//  BLTSendData.m
//  LoveSports
//
//  Created by zorro on 15-1-27.
//  Copyright (c) 2015年 zorro. All rights reserved.
//

#import "BLTSendData.h"
#import "BLTManager.h"
#import "NSDate+XY.h"

@implementation AlarmClockModel

@end

@implementation BLTSendData

+ (void)sendBasicSetOfInformationData:(NSInteger)scale
                           withHourly:(NSInteger)hourly
                           withJetLag:(NSInteger)lag
                      withUpdateBlock:(BLTAcceptDataUpdateValue)block
{
    UInt8 val[7] = {0xBE, 0x01, 0x01, 0xFE, scale, hourly, (UInt8)((0x01 << 7) | (lag * 2))};
    [self sendDataToWare:&val withLength:7 withUpdate:block];
}

+ (void)sendLocalTimeInformationData:(NSDate *)date
                          withHourly:(NSInteger)hourly
                     withUpdateBlock:(BLTAcceptDataUpdateValue)block
{
    UInt8 val[13] = {0xBE, 0x01, 0x02, 0xFE,
                    (UInt8)(date.year >> 8), (UInt8)date.year, date.month, date.day,
                    date.weekday, 8, date.hour, date.minute, date.second};
    [self sendDataToWare:&val withLength:13 withUpdate:block];
}

+ (void)sendUserInformationBodyDataWithBirthDay:(NSDate *)date
                                     withWeight:(NSInteger)weight
                                     withTarget:(NSInteger)target
                                   withStepAway:(NSInteger)step
                                withUpdateBlock:(BLTAcceptDataUpdateValue)block
{
    UInt8 val[15] = {0xBE, 0x01, 0x03, 0xFE,
        (UInt8)(date.year >> 8), (UInt8)date.year, date.month, date.day,
        (UInt8)(weight >> 8), (UInt8)weight, (UInt8)(target >> 16), (UInt8)(target >> 8),
        (UInt8)target, (UInt8)(step >> 8) ,(UInt8)step};
    [self sendDataToWare:&val withLength:15 withUpdate:block];
}

+ (void)sendCheckDateOfHardwareDataWithUpdateBlock:(BLTAcceptDataUpdateValue)block
{
    UInt8 val[4] = {0xBE, 0x01, 0x02, 0xED};
    [self sendDataToWare:&val withLength:4 withUpdate:block];
}

+ (void)sendLookBodyInformationDataWithUpdateBlock:(BLTAcceptDataUpdateValue)block
{
    UInt8 val[4] = {0xBE, 0x01, 0x03, 0xED};
    [self sendDataToWare:&val withLength:4 withUpdate:block];
}

+ (void)sendSetHardwareScreenDataWithDisplay:(BOOL)black
                                 withWaiting:(BOOL)noWaiting
                             withUpdateBlock:(BLTAcceptDataUpdateValue)block
{
    UInt8 val[6] = {0xBE, 0x01, 0x04, 0xED, black, noWaiting};
    [self sendDataToWare:&val withLength:6 withUpdate:block];
}

+ (void)sendPasswordProtectionDataWithOpen:(BOOL)open
                          withPassword:(NSString *)password
                       withUpdateBlock:(BLTAcceptDataUpdateValue)block
{
    NSInteger number = [password integerValue];
    UInt8 val[7] = {0xBE, 0x01, 0x05, 0xED, open, (UInt8)(number >> 8), (UInt8)number};
    [self sendDataToWare:&val withLength:7 withUpdate:block];
}

+ (void)sendHardwareStartupModelDataWithModel:(NSInteger)model
                                    withTimes:(NSArray *)times
                              withUpdateBlock:(BLTAcceptDataUpdateValue)block
{
    UInt8 val[20] = {0xBE, 0x01, 0x06, 0xFE, model};
    
    int count = 4;
    if (times)
    {
        for (NSString *time in times)
        {
            count++;
            if (count > 19)
            {
                break;
            }

            NSInteger index = [time integerValue];
            val[count] = index / 10;
        }
    }
    
    if (count < 20)
    {
        for (int i = count + 1; i < 20; i++)
        {
            val[count] = 0xFF;
        }
    }
    
    [self sendDataToWare:&val withLength:20 withUpdate:block];
}

+ (void)sendSleepToRemindDataWithOpen:(BOOL)open
                             withPlan:(NSInteger)plan
                          withAdvance:(NSInteger)advance
                      withUpdateBlock:(BLTAcceptDataUpdateValue)block
{
    UInt8 val[9] = {0xBE, 0x01, 0x07, 0xFE, open, plan / 60, plan % 60, advance / 60, advance % 60};
    [self sendDataToWare:&val withLength:9 withUpdate:block];
}

+ (void)sendCustomDisplayInterfaceDataWithOrder:(NSArray *)orders
                                withUpdateBlock:(BLTAcceptDataUpdateValue)block
{
    UInt8 val[20] = {0xBE, 0x01, 0x08, 0xFE};
    
    int count = 3;
    if (orders)
    {
        for (NSString *order in orders)
        {
            count++;
            if (count > 19)
            {
                break;
            }
            
            val[count] = [order integerValue];
        }
    }
    
    if (count < 20)
    {
        for (int i = count + 1; i < 20; i++)
        {
            val[count] = 0xFF;
        }
    }
    
    [self sendDataToWare:&val withLength:20 withUpdate:block];
}

+ (void)sendAlarmClockDataWithOpen:(UInt8)open
                         withAlarm:(NSArray *)alarms
                   withUpdateBlock:(BLTAcceptDataUpdateValue)block
{
    UInt8 val[20] = {0xBE, 0x01, 0x09, 0xFE, open};
    
    int count = 3;
    if (alarms)
    {
        for (AlarmClockModel *model in alarms)
        {
            count++;
            if (count > 19)
            {
                break;
            }
            
            val[count] = model.hour;
            count++;
            val[count] = model.minutes;
            count++;
            val[count] = model.repeat;
        }
    }
    
    if (count < 20)
    {
        for (int i = count + 1; i < 20; i++)
        {
            val[count] = 0x00;
        }
    }
    
    [self sendDataToWare:&val withLength:20 withUpdate:block];
}

+ (void)sendSedentaryRemindDataWithOpen:(BOOL)open
                              withTimes:(NSArray *)times
                        withUpdateBlock:(BLTAcceptDataUpdateValue)block
{
    UInt8 val[19] = {0xBE, 0x01, 0x0C, 0xFE, open};
    
    int count = 4;
    if (times)
    {
        for (AlarmClockModel *model in times)
        {
            count++;
            if (count > 18)
            {
                break;
            }
            
            val[count] = model.hour;
            count++;
            val[count] = model.minutes;
        }
    }
    
    [self sendDataToWare:&val withLength:19 withUpdate:block];
}

+ (void)sendSetFactoryModelDataWithUpdateBlock:(BLTAcceptDataUpdateValue)block
{
    UInt8 val[4] = {0xBE, 0x01, 0x0D, 0xED};
    [self sendDataToWare:&val withLength:4 withUpdate:block];
}

+ (void)sendModifyDeviceNameDataWithName:(NSString *)name
                         withUpdateBlock:(BLTAcceptDataUpdateValue)block
{
    UInt8 val[20] = {0xBE, 0x01, 0x0E, 0xFE, name.length};
    
    for (int i = 5; i < 20; i++)
    {
        val[i] = [name characterAtIndex:i];
    }

    [self sendDataToWare:&val withLength:20 withUpdate:block];
    
    if (name.length > 14)
    {
        usleep(5000);
        name = [name substringFromIndex:14];
        [self sendModifyDeviceNameDataWithName:name withUpdateBlock:block];
    }
}

+ (void)sendQueryCurrentPasswordDataWithUpdateBlock:(BLTAcceptDataUpdateValue)block
{
    UInt8 val[4] = {0xBE, 0x01, 0x05, 0xED};
    [self sendDataToWare:&val withLength:4 withUpdate:block];
}

+ (void)sendQShowCurrentPasswordDataWithUpdateBlock:(BLTAcceptDataUpdateValue)block
{
    UInt8 val[4] = {0xBE, 0x01, 0x0F, 0xED};
    [self sendDataToWare:&val withLength:4 withUpdate:block];
}

/**
 *  行针校正命令
 *
 */
+ (void)sendCorrectionCommandDataWithUpdateBlock:(BLTAcceptDataUpdateValue)block
{
    UInt8 val[4] = {0xBE, 0x01, 0x0A, 0xED};
    [self sendDataToWare:&val withLength:4 withUpdate:block];
}

+ (void)sendCurrentPositionDataWithHour:(NSInteger)hour
                             withMinute:(NSInteger)minute
                             withSecond:(NSInteger)second
                        withUpdateBlock:(BLTAcceptDataUpdateValue)block
{
    UInt8 val[7] = {0xBE, 0x01, 0x10, 0xFE, hour, minute, second};
    [self sendDataToWare:&val withLength:7 withUpdate:block];
}

+ (void)sendSynchronousWorldTimeData:(NSDate *)date
                          withHourly:(NSInteger)hourly
                     withUpdateBlock:(BLTAcceptDataUpdateValue)block
{
    UInt8 val[13] = {0xBE, 0x01, 0x14, 0xFE,
        (UInt8)(date.year >> 8), (UInt8)date.year, date.month, date.day,
        date.weekday, 8, date.hour, date.minute, date.second};
    [self sendDataToWare:&val withLength:13 withUpdate:block];
}

/**
 *  W240 专用
 */
+ (void)sendSetWearingWayDataWithRightHand:(BOOL)right
                           withUpdateBlock:(BLTAcceptDataUpdateValue)block
{
    UInt8 val[5] = {0xBE, 0x01, 0x0B, 0xED, right};
    [self sendDataToWare:&val withLength:5 withUpdate:block];
}

/**
 *  W286 专用
 */
+ (void)sendOpenBacklightSetDataWithOpen:(BOOL)open
                               withTimes:(NSArray *)times
                         withUpdateBlock:(BLTAcceptDataUpdateValue)block
{
    UInt8 val[9] = {0xBE, 0x01, 0x11, 0xFE, open};
    
    int count = 4;
    if (times)
    {
        for (AlarmClockModel *model in times)
        {
            count++;
            if (count > 8)
            {
                break;
            }
            
            val[count] = model.hour;
            count++;
            val[count] = model.minutes;
        }
    }
    
    [self sendDataToWare:&val withLength:9 withUpdate:block];
}

/**
 *           传输运动数据.
 */

+ (void)sendRequestSportDataWithDate:(NSDate *)date
                    withUpdateBlock:(BLTAcceptDataUpdateValue)block
{
    NSInteger order = (date.hour * 60 + date.minute) / 15;
    UInt8 val[10] = {0xBE, 0x02, 0x01, 0xFE,
        (UInt8)(date.year >> 8), (UInt8)date.year,
        date.month, date.day, (UInt8)(order >> 8), (UInt8)order};
    [self sendDataToWare:&val withLength:10 withUpdate:block];
}

+ (void)sendDeleteSportDataWithDate:(NSDate *)date
                    withUpdateBlock:(BLTAcceptDataUpdateValue)block
{
    NSInteger order = (date.hour * 60 + date.minute) / 15;
    UInt8 val[10] = {0xBE, 0x02, 0x02, 0xFE,
        (UInt8)(date.year >> 8), (UInt8)date.year,
        date.month, date.day, (UInt8)(order >> 8), (UInt8)order};
    [self sendDataToWare:&val withLength:10 withUpdate:block];
}

+ (void)sendRequestTodaySportDataWithOrder:(NSInteger)order
                           withUpdateBlock:(BLTAcceptDataUpdateValue)block
{
    UInt8 val[6] = {0xBE, 0x02, 0x03, 0xFE, (UInt8)(order >> 8), (UInt8)order};
    [self sendDataToWare:&val withLength:6 withUpdate:block];
}

+ (void)sendRealtimeTransmissionSportDataWithUpdateBlock:(BLTAcceptDataUpdateValue)block
{
    UInt8 val[4] = {0xBE, 0x02, 0x04, 0xED};
    [self sendDataToWare:&val withLength:4 withUpdate:block];
}

+ (void)sendCloseTransmissionSportDataWithUpdateBlock:(BLTAcceptDataUpdateValue)block
{
    UInt8 val[4] = {0xBE, 0x02, 0x05, 0xED};
    [self sendDataToWare:&val withLength:4 withUpdate:block];
}

#pragma mark --- 命令转发中心 ---
+ (void)sendDataToWare:(void *)val withLength:(NSInteger)length withUpdate:(BLTAcceptDataUpdateValue)block
{
    [BLTAcceptData sharedInstance].updateValue = block;
    
    NSData *sData = [[NSData alloc] initWithBytes:val length:length];
    [[BLTManager sharedInstance] senderDataToPeripheral:sData];
}

@end
