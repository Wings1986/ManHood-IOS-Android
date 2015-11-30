//
//  SelfUserData.h
//  CoolHisto
//
//  Created by Viktor Gubriienko on 26.03.14.
//  Copyright (c) 2014 Viktor Gubriienko. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SelfUserData : NSObject

@property (nonatomic, readonly) float length;
@property (nonatomic, readonly) float girth;
@property (nonatomic, readonly) float thickness;

@property (nonatomic, readonly) CGPoint basePosition;
@property (nonatomic, readonly) CGPoint midPosition;
@property (nonatomic, readonly) CGPoint upperPosition;
@property (nonatomic, readonly) CGPoint tipPosition;

@property (nonatomic, readonly) NSString *device;
@property (nonatomic, readonly) NSDate *date;

- (instancetype)initWithContentsOfFile:(NSString*)filePath;
- (instancetype)initWithContentsOfFile1:(NSString*)filePath;

@end
