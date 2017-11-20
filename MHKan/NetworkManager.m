//
//  NetworkManager.m
//  MHKan
//
//  Created by Yinjw on 2017/11/16.
//  Copyright © 2017年 yinjianwei. All rights reserved.
//

#import "NetworkManager.h"
#import <UIKit/UIKit.h>

static NSString * kWiTapBonjourType = @"_witap2._tcp.";

@interface NetworkManager() <NSNetServiceDelegate, NSNetServiceBrowserDelegate, NSStreamDelegate>

@property(nonatomic, strong)NSNetService*   service;
@property(nonatomic, strong)NSMutableArray* findServices;
@property(nonatomic, strong)NSNetServiceBrowser* browser;
@property(nonatomic, strong)NSInputStream*      inputStream;
@property(nonatomic, strong)NSOutputStream*     outputStream;

@property(nonatomic)BOOL                isServiceStart;
@property(nonatomic, copy)FindFunc      findFunc;
@property(nonatomic, copy)ConnetFunc    connectFunc;
@property(nonatomic, copy)RecvFunc      recvFunc;
@property(nonatomic)NSInteger           streamOpenCount;

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
    
    self.service = [[NSNetService alloc] initWithDomain:@"local." type:kWiTapBonjourType name:[UIDevice currentDevice].name port:0];
    self.service.includesPeerToPeer = YES;
    [self.service setDelegate:self];
    
    self.findServices = [[NSMutableArray alloc] init];
    
    self.browser = [[NSNetServiceBrowser alloc] init];
    self.browser.includesPeerToPeer = YES;
    self.browser.delegate = self;
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

-(void)initStreamWithService:(NSNetService*)service
{
    if(self.streamOpenCount > 2)
    {
        NSLog(@"connect stream over 2, can not init!");
        return;
    }
    
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

-(void)sendData:(NSDictionary*)datas
{
    if(![self.outputStream hasSpaceAvailable])
    {
        NSLog(@"outputStream not hasSpaceAvailable!");
        return;
    }
    
    NSError* error;
    NSData* data = [NSJSONSerialization dataWithJSONObject:datas options:NSJSONWritingPrettyPrinted error:&error];
    if(error)
    {
        NSLog(@"send data must be json type");
        return;
    }
    
    NSInteger byteWrite = [self.outputStream write:(const uint8_t *)data.bytes maxLength:data.length];
    if(byteWrite != data.length)
    {
        NSLog(@"byte write error: write=%ld, all=%ld", byteWrite, data.length);
    }
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
    
    if(!moreComing)
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
                uint8_t byte[100];
                NSInteger byteRead = [self.inputStream read:byte maxLength:100];
                if(byteRead > 0)
                {
                    NSData* data = [NSData dataWithBytes:byte length:byteRead];
                    if(self.recvFunc)
                    {
                        NSError* error;
                        NSDictionary* recvData = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
                        NSLog(@"recive data:%@", recvData);
                        self.recvFunc(recvData);
                    }
                }
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

#pragma mark - self method

-(NSArray*)getAllFindServices
{
    return [NSArray arrayWithArray:self.findServices];
}

-(void)setStreamRecvFunc:(RecvFunc)recvFunc
{
    self.recvFunc = recvFunc;
}

-(void)setNewConnetFunc:(ConnetFunc)connectFunc
{
    self.connectFunc = connectFunc;
}

@end
