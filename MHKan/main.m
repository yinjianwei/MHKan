//
//  main.m
//  MHKan
//
//  Created by Yinjw on 2017/11/2.
//  Copyright © 2017年 yinjianwei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

int main(int argc, char * argv[]) {
    @autoreleasepool {
        int result;
        @try{
            result = UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
        }
        @catch(NSException *exception) {
            NSLog(@"exception:%@", exception);
        }
        @finally {
            
        }
        return result;
    }
}
