//
//  ETSessionManager.h
//  Histo
//
//  Created by Viktor Gubriienko on 30.05.14.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import "AFHTTPSessionManager.h"

@interface ETSessionManager : AFHTTPSessionManager

+ (instancetype)sharedInstance;

@end
