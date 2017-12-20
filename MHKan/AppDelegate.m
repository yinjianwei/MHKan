//
//  AppDelegate.m
//  MHKan
//
//  Created by Yinjw on 2017/11/2.
//  Copyright © 2017年 yinjianwei. All rights reserved.
//

#import "AppDelegate.h"
#import "ViewController.h"
#import "NetworkManager.h"
#import "ServiceListViewController.h"
#import "DrawViewController.h"
#import "TestViewController.h"

@interface AppDelegate ()

@property(nonatomic, strong)NSString*   tmp1;
@property(nonatomic, copy)NSString*   tmp2;

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    CGRect frame = [[UIScreen mainScreen] bounds];
    self.window = [[UIWindow alloc] initWithFrame:frame];
    self.window.backgroundColor = [UIColor whiteColor];
    ServiceListViewController* vc = [[ServiceListViewController alloc] init];
    UINavigationController* navi = [[UINavigationController alloc] initWithRootViewController:vc];
    self.window.rootViewController = navi;
    [self.window makeKeyAndVisible];
    
//    [self transferJson];
    
    return YES;
}

-(void)transferJson
{
    NSString* file = [[NSBundle mainBundle] pathForResource:@"city" ofType:@"js"];
    NSData* data = [NSData dataWithContentsOfFile:file];
    NSError* error;
    NSArray* jsonData = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];
    if(jsonData)
    {
        NSInteger count = jsonData.count;
        NSMutableDictionary* provData = [[NSMutableDictionary alloc] init];
        for(int i = 0;i < count;i++)
        {
            NSDictionary* info = [jsonData objectAtIndex:i];
            NSString* prov = [info objectForKey:@"prov"];
            NSString* city = [info objectForKey:@"city"];
            city = city ? city : prov;
            NSString* area = [info objectForKey:@"area"];
            if(area && ![area isEqualToString:@""])
            {
                NSMutableDictionary* cityData = [provData objectForKey:prov];
                if(!cityData)
                {
                    cityData = [[NSMutableDictionary alloc] init];
                }
                NSMutableArray* areaData = [cityData objectForKey:city];
                if(!areaData)
                {
                    areaData = [[NSMutableArray alloc] init];
                }
                [areaData addObject:area];
                [cityData setObject:areaData forKey:city];
                [provData setObject:cityData forKey:prov];
            }
        }
        
        NSMutableArray* finalData = [[NSMutableArray alloc] init];
        for(NSString* prov in provData)
        {
            NSMutableDictionary* writeProvData = [[NSMutableDictionary alloc] init];
            NSMutableArray* writeCityData = [[NSMutableArray alloc] init];
            
            NSMutableDictionary* cityData = [provData objectForKey:prov];
            for(NSString* city in cityData)
            {
                NSMutableDictionary* cityDict = [[NSMutableDictionary alloc] init];
                [cityDict setObject:city forKey:@"name"];
                [cityDict setObject:[cityData objectForKey:city] forKey:@"area"];
                [writeCityData addObject:cityDict];
            }
            
            [writeProvData setObject:prov forKey:@"name"];
            [writeProvData setObject:writeCityData forKey:@"city"];
            [finalData addObject:writeProvData];
        }
        [finalData sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            NSString* prov1 = [obj1 objectForKey:@"name"];
            NSString* prov2 = [obj2 objectForKey:@"name"];
            return prov1 > prov2;
        }];
        NSData* writeData = [NSJSONSerialization dataWithJSONObject:finalData options:NSJSONWritingPrettyPrinted error:nil];
        NSString* str = [[NSString alloc] initWithData:writeData encoding:NSUTF8StringEncoding];
        NSArray* paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
        NSString* cachesPath = [[paths objectAtIndex:0] stringByAppendingPathComponent:@"Caches"];
        NSString* filePath = [cachesPath stringByAppendingPathComponent:@"city.js"];
        NSURL *url = [NSURL fileURLWithPath:filePath];
        BOOL result = [str writeToURL:url atomically:YES encoding:NSUTF8StringEncoding error:nil];
        if(!result)
        {
            NSLog(@"write error！");
        }
    }
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
