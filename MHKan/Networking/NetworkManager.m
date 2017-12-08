//
//  NetworkManager.m
//  MHKan
//
//  Created by Yinjw on 2017/11/16.
//  Copyright © 2017年 yinjianwei. All rights reserved.
//

#import "NetworkManager.h"
#import <UIKit/UIKit.h>
#import "NetDataQueue.h"
#import "BaseProtocols.h"

static NSString * kWiTapBonjourType = @"_mhkan._tcp.";

@interface NetworkManager() <NSNetServiceDelegate, NSNetServiceBrowserDelegate, NSStreamDelegate>
{
    dispatch_semaphore_t semaphore;
}

@property(nonatomic, strong)NSNetService*   service;
@property(nonatomic, strong)NSMutableArray<NSNetService*>* findServices;
@property(nonatomic, strong)NSNetServiceBrowser* browser;
@property(nonatomic, strong)NSInputStream*      inputStream;
@property(nonatomic, strong)NSOutputStream*     outputStream;

@property(nonatomic)BOOL                isServiceStart;
@property(nonatomic, copy)FindFunc      findFunc;
@property(nonatomic, copy)ConnetFunc    connectFunc;
@property(nonatomic, copy)RecvFunc      recvFunc;
@property(nonatomic)NSInteger           streamOpenCount;

@property(nonatomic, strong)NSMutableData*      tmpData;    //用于接收未传送完的数据

@property(nonatomic, strong)NetDataQueue*   dataQueue;
@property(nonatomic, strong)NSMutableDictionary* protocolProcessers;

@end

@implementation NetworkManager

+(NetworkManager*)sharedManager
{
    static NetworkManager* sharedManager;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        sharedManager = [[NetworkManager alloc] init];
        [sharedManager initManager];
    });
    
    return sharedManager;
}

-(void)initManager
{
    self.isServiceStart = NO;
    self.streamOpenCount = 0;
    self.tmpData = nil;
    
    self.service = [[NSNetService alloc] initWithDomain:@"local." type:kWiTapBonjourType name:[UIDevice currentDevice].name port:0];
    self.service.includesPeerToPeer = YES;
    [self.service setDelegate:self];
    
    self.findServices = [[NSMutableArray alloc] init];
    
    self.browser = [[NSNetServiceBrowser alloc] init];
    self.browser.includesPeerToPeer = YES;
    self.browser.delegate = self;
    
    self.dataQueue = [[NetDataQueue alloc] init];
    self.protocolProcessers = [[NSMutableDictionary alloc] init];
    
    semaphore = dispatch_semaphore_create(1);
}

#pragma mark - serveice

-(void)startServiceWithFindFunc:(FindFunc)findFunc
{
    self.findFunc = findFunc;
    
    if(!self.isServiceStart)
    {
        [self.service publishWithOptions:NSNetServiceListenForConnections];
        self.isServiceStart = YES;
    }
}

-(void)stopService
{
    if(self.isServiceStart)
    {
        [self.service stop];
        self.isServiceStart = NO;
    }
}

#pragma mark - serviceBrowser

-(void)startBrowser
{
    [self.browser searchForServicesOfType:kWiTapBonjourType inDomain:@"local"];
}

-(void)closeBrowser
{
    [self.browser stop];
}

#pragma mark - NSInputStream & NSOutputStream

-(void)initStreamWithServiceIndex:(NSInteger)index
{
    if(self.streamOpenCount > 2)
    {
        NSLog(@"connect stream over 2, can not init!");
        return;
    }
    
    if(index < 0 || index >= self.findServices.count)
    {
        return;
    }
    
    NSNetService* service = [self.findServices objectAtIndex:index];
    
    NSInputStream *     inStream;
    NSOutputStream *    outStream;
    BOOL success = [service getInputStream:&(inStream) outputStream:&(outStream)];
    if(success)
    {
        self.inputStream = inStream;
        self.outputStream = outStream;
        
        [self openStream];
    }
}

-(void)openStream
{
    [self.inputStream setDelegate:self];
    [self.inputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream open];
    
    [self.outputStream setDelegate:self];
    [self.outputStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream open];
}

-(void)closeStream
{
    [self.inputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.inputStream close];
    self.inputStream = nil;
    
    [self.outputStream removeFromRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.outputStream close];
    self.outputStream = nil;
}

-(BOOL)writeData:(NSDictionary*)datas
{
    if(![self.outputStream hasSpaceAvailable])
    {
        NSLog(@"outputStream not hasSpaceAvailable!");
        return NO;
    }
    
    NSError* error;
    NSLog(@"send data:%@", datas);
    NSData* data = [NSJSONSerialization dataWithJSONObject:datas options:NSJSONWritingPrettyPrinted error:&error];
    if(error)
    {
        NSLog(@"send data must be json type");
        return NO;
    }
    uint8_t length = data.length;
    NSMutableData* sendData = [NSMutableData dataWithBytes:&length length:sizeof(uint8_t)];
    [sendData appendData:data];
    NSInteger byteWrite = [self.outputStream write:(const uint8_t *)sendData.bytes maxLength:sendData.length];
    if(byteWrite != sendData.length)
    {
        NSLog(@"byte write error: write=%ld, all=%ld", byteWrite, data.length);
        return NO;
    }
    
    return YES;
}

#pragma mark - NSNetServiceDelegate

-(void)netServiceDidPublish:(NSNetService *)sender
{
    if(sender != self.service)
    {
        return;
    }
    
    [self startBrowser];
}

-(void)netService:(NSNetService *)sender didAcceptConnectionWithInputStream:(NSInputStream *)inputStream outputStream:(NSOutputStream *)outputStream
{
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        if(sender != self.service)
        {
            return;
        }
        
        if(self.inputStream)
        {
            //already have connect ,reject this new one
            [inputStream open];
            [inputStream close];
            [outputStream open];
            [outputStream close];
        }
        else
        {
            [self stopService];
            self.inputStream  = inputStream;
            self.outputStream = outputStream;
            
            [self openStream];
            
            if(self.connectFunc)
            {
                self.connectFunc();
            }
        }
    }];
}

-(void)netService:(NSNetService *)sender didNotPublish:(NSDictionary<NSString *,NSNumber *> *)errorDict
{
    UIAlertController* alertVC = [UIAlertController alertControllerWithTitle:@"出错了" message:@"service发布失败" preferredStyle:UIAlertControllerStyleAlert];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alertVC animated:YES completion:nil];
    
    [self stopService];
}

#pragma mark - NSNetServiceBrowserDelegate

-(void)netServiceBrowser:(NSNetServiceBrowser *)browser didRemoveService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    if(self.browser != browser)
        return;
    
    if(![service isEqual:self.service])
    {
        [self.findServices removeObject:service];
    }
    
    if(!moreComing && self.findFunc)
    {
        self.findFunc();
    }
}

-(void)netServiceBrowser:(NSNetServiceBrowser *)browser didFindService:(NSNetService *)service moreComing:(BOOL)moreComing
{
    if(self.browser != browser)
        return;
    
    if(![service isEqual:self.service])
    {
        [self.findServices addObject:service];
    }
    
    if(!moreComing)
    {
        self.findFunc();
    }
}

#pragma mark - NSStreamDelegate

-(void)stream:(NSStream *)aStream handleEvent:(NSStreamEvent)eventCode
{
    switch(eventCode)
    {
        case NSStreamEventOpenCompleted:{
            self.streamOpenCount++;
            if(self.streamOpenCount == 2)
            {
                [self.service stop];
                self.isServiceStart = NO;
            }
        }break;
        case NSStreamEventHasSpaceAvailable:{
            
        }break;
        case NSStreamEventHasBytesAvailable:{
            if(aStream == self.inputStream)
            {
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
                    [self readData];
                    dispatch_semaphore_signal(semaphore);
                });
            }
            
        }break;
        case NSStreamEventErrorOccurred:{
            
        }break;
        case NSStreamEventEndEncountered:{
            [self closeStream];
            [self startServiceWithFindFunc:nil];
        }break;
        default:
            break;
    }
}

#pragma mark - public method

-(NSArray<NSString*>*)getAllFindServiceNames
{
    NSMutableArray* names = [[NSMutableArray alloc] init];
    for(int i = 0;i < self.findServices.count;i++)
    {
        [names addObject:[self.findServices objectAtIndex:i].name];
    }
    return [NSArray arrayWithArray:names];
}

-(void)setStreamRecvFunc:(RecvFunc)recvFunc
{
    self.recvFunc = recvFunc;
}

-(void)setNewConnetFunc:(ConnetFunc)connectFunc
{
    self.connectFunc = connectFunc;
}

-(void)sendDataWithParams:(id)params
{
    if(!self.dataQueue)
    {
        return;
    }
    
    if([self.dataQueue addNewNetDataWithParams:params])
    {
        [self sendNetData];
    }
}

-(void)registerProcessObjWithType:(BaseProtocols *)processer type:(ProtocolType)protocolType
{
    id tmpProcesser = [self.protocolProcessers objectForKey:@(protocolType)];
    if(tmpProcesser)
    {
        NSLog(@"already have processer for %ld", protocolType);
        return;
    }
    
    [self.protocolProcessers setObject:processer forKey:@(protocolType)];
}

#pragma mark - self method

-(void)sendNetData
{
    NetData* data = [self.dataQueue getSendData];
    if(data)
    {
//        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//        dispatch_async(queue, ^{
            if([self writeData:data.sendDatas])
            {
                data.isSend = YES;
            }
//        });
    }
}

-(void)readData
{
    uint8_t dataLength = 0;
    
    while([self.inputStream hasBytesAvailable])
    {
        //先判断是否有上次未读完的数据，然后取数据长度, 获取到数据长度后，如果有可读完整数据则读取数据
        if(self.tmpData && self.tmpData.length > 0)
        {
            NSInteger unreadLength = self.tmpData.length - sizeof(self.tmpData.mutableBytes);
            
            uint8_t unreadByte[unreadLength];
            NSInteger byteRead = [self.inputStream read:unreadByte maxLength:unreadLength];
            if(byteRead == unreadLength)
            {
                [self.tmpData appendBytes:unreadByte length:byteRead];
                [self processReciveData:self.tmpData];
                self.tmpData = NULL;
            }
        }
        
        NSInteger byteRead = [self.inputStream read:&dataLength maxLength:sizeof(uint8_t)];
        if(byteRead > 0)
        {
            uint8_t readByte[dataLength];
            byteRead = [self.inputStream read:readByte maxLength:dataLength];
            if(byteRead == dataLength)
            {
                NSData* data = [NSData dataWithBytes:readByte length:byteRead];
                [self processReciveData:data];
            }
            else if(byteRead < 0)
            {
                NSLog(@"read data error!");
                break;
            }
            else if(byteRead < dataLength)
            {
                uint8_t readByte[dataLength];
                byteRead = [self.inputStream read:readByte maxLength:byteRead];
                self.tmpData = [NSMutableData dataWithLength:dataLength];
                [self.tmpData appendBytes:readByte length:byteRead];
                break;
            }
            else
            {
                break;
            }
        }
        else
        {
            break;
        }
        dataLength = 0;
    }
}

-(void)processReciveData:(NSData*)data
{
    NSError* error;
    NSDictionary* recvData = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    NSNumber* protocolType = [recvData objectForKey:PROTOCOL_TYPE];
    NSNumber* processType = [recvData objectForKey:PROCESS_TYPE];
    if(!processType || !processType)
    {
        NSLog(@"recvData:%@", recvData);
    }
    BaseProtocols* processer = [self.protocolProcessers objectForKey:protocolType];
    if(processer)
    {
        [processer processServerData:recvData];
    }
}

@end
