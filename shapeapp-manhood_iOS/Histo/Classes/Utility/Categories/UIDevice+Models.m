//
//  UIDevice+Models.m
//  Histo
//
//  Created by Viktor Gubriienko on 21.05.14.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import "UIDevice+Models.h"
#import <sys/utsname.h>


@implementation UIDevice (Models)

+ (NSString *)hardwareModel {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *raw = [NSString stringWithCString:systemInfo.machine
                                       encoding:NSUTF8StringEncoding];
    
    NSDictionary *transform = @{@"x86_64": @"Simulator x64",
                                @"i386": @"Simulator",
                                @"iPod1,1": @"iPod Touch",
                                @"iPod2,1": @"iPod Touch 2G",
                                @"iPod3,1": @"iPod Touch 3G",
                                @"iPod4,1": @"iPod Touch 4G",
                                @"iPod5,1": @"iPod Touch 5G",
                                @"iPhone1,1": @"iPhone",
                                @"iPhone1,2": @"iPhone 3G",
                                @"iPhone2,1": @"iPhone 3GS",
                                @"iPhone3,1": @"iPhone 4",
                                @"iPhone4,1": @"iPhone 4S",
                                @"iPhone5,1": @"iPhone 5",
                                @"iPhone5,2": @"iPhone 5",
                                @"iPhone5,3": @"iPhone 5c",
                                @"iPhone5,4": @"iPhone 5c",
                                @"iPhone6,1": @"iPhone 5s",
                                @"iPhone6,2": @"iPhone 5s",
                                @"iPad1,1": @"iPad",
                                @"iPad2,1": @"iPad 2",
                                @"iPad2,5": @"iPad Mini",
                                @"iPad3,1": @"iPad 3",
                                @"iPad3,4": @"iPad 4",
                                @"iPad4,1": @"iPad Air",
                                @"iPad4,2": @"iPad Air",
                                @"iPad4,4": @"iPad Mini 2G",
                                @"iPad4,5": @"iPad Mini 2G",
                                };
    
    NSString *model = transform[raw];
    if (!model) {
        model = @"Unknown";
    }
    
    return model;
}

+ (BOOL)isiPad {
    return [self isDeviceFromList:@[@"iPad"]];
}

+ (BOOL)isSimulator {
    return [self isDeviceFromList:@[@"x86_64", @"i386"]];
}

+ (BOOL)isiPhone {
    return [self isDeviceFromList:@[@"iPhone"]];
}

+ (BOOL)isiPod {
    return [self isDeviceFromList:@[@"iPod"]];
}

+ (BOOL)isiPhoneOriPod {
    return [self isDeviceFromList:@[@"iPhone", @"iPod"]];
}

#pragma mark - Private

+ (BOOL)isDeviceFromList:(NSArray*)devices {
    struct utsname systemInfo;
    uname(&systemInfo);
    NSString *raw = [NSString stringWithCString:systemInfo.machine
                                       encoding:NSUTF8StringEncoding];
    
    for (NSString *device in devices) {
        if ( [raw rangeOfString:device].location != NSNotFound ) {
            return YES;
        }
    }
    
    return NO;
}

@end
