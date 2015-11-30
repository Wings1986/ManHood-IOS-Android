//
//  NSData+Common.m
//  VLFN
//
//  Created by Vlad Dudkin on 2/3/12.
//  Copyright (c) 2012 VLF Networks. All rights reserved.
//

#import "NSData+Common.h"
#import <CommonCrypto/CommonDigest.h>

@implementation NSData (Common)
- (NSString*)md5Hash
{
  // Create byte array of unsigned chars
  unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
 
  // Create 16 byte MD5 hash value, store in buffer
  CC_MD5(self.bytes, (CC_LONG)self.length, md5Buffer);
 
  // Convert unsigned char buffer to NSString of hex values
  NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
  for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) 
    [output appendFormat:@"%02x",md5Buffer[i]];
 
  return output;
}

- (NSString*)stringValue {
    return [[NSString alloc] initWithData:self encoding:NSUTF8StringEncoding];
}

@end
