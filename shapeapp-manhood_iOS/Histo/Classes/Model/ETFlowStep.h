//
//  ETFlowStep.h
//  Histo
//
//  Created by Viktor Gubriienko on 12.03.14.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ETFlowStep : NSObject

@property (nonatomic, strong) NSString *ID;
@property (nonatomic, strong) NSString *type;
@property (nonatomic, strong) NSDictionary *options;
@property (nonatomic, strong) id data;

// Will run at step reset or dealloc. Need for shared resources (files, etc) there
@property (nonatomic, copy) void(^finilizeBlock)(ETFlowStep *sender);

- (void)reset;

@end
