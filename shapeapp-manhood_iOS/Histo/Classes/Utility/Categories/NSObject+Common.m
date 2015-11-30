//
//  NSObject+Common.m
//  Common
//
//  Created by Viktor Gubriienko on 5/20/10.
//  Copyright 2010. All rights reserved.
//

#import "NSObject+Common.h"

static char _assosiatedDictionaryKey;

typedef float (*FloatReturnObjCMsgSendFunction)(id,SEL);
typedef int (*IntReturnObjCMsgSendFunction)(id,SEL);

@implementation NSObject (Common)

- (void) printClassHieararhy {
	Class currentClass = [self class];
	NSString *result = [NSString stringWithFormat:@"Object's [%@] class hierarhy:\n\t", self];
	NSMutableArray *arr = [NSMutableArray arrayWithCapacity:10];
	
	while (currentClass != nil) {
		[arr addObject:currentClass];
		currentClass = [currentClass superclass];
	}
	
	result = [result stringByAppendingString:[arr componentsJoinedByString:@" -> "]];
	NSLog(@"%@", result);
}

- (void)logProperties{
#ifdef DEBUG
	[self logPropertiesSubLevels:0];
#endif
}

- (void)logPropertiesSubLevels:(NSInteger)aSubLevels{
#ifdef DEBUG
	id objClass =[self class];

	unsigned int outCount, i;
	NSString * name, * attributes;
	objc_property_t *properties = class_copyPropertyList(objClass, &outCount);

	NSLog(@"==========================================================");
	NSLog(@"### Class: %@",NSStringFromClass(objClass));
	NSLog(@"----------------------------------------------------------");
	
	for (i = 0; i < outCount; i++){
		objc_property_t property = properties[i];
		name = [NSString stringWithFormat:@"%s", property_getName(property)];
		attributes = [NSString stringWithFormat:@"%s", property_getAttributes(property)];

		
		SEL propGetSel = NSSelectorFromString(name);
		if ([self respondsToSelector:propGetSel]){
			if ([attributes hasPrefix:@"T@"]){
				id objRes = objc_msgSend(self, propGetSel);
				NSLog(@">>> id %@ = %@\n", name, objRes);
				if (aSubLevels > 0)
					[objRes logPropertiesSubLevels:aSubLevels - 1];
			}
			else if ([attributes hasPrefix:@"Ti"]){
				int intRes = ((IntReturnObjCMsgSendFunction)objc_msgSend)(self,propGetSel);
				NSLog(@">>> int %@ = %d\n", name, (int)intRes);				
			}
			else if ([attributes hasPrefix:@"Tf"]){
				float floatRes = ((FloatReturnObjCMsgSendFunction)objc_msgSend)(self,propGetSel);
				NSLog(@">>> float %@ = %f",name, (float)floatRes);
			}
			else if ([attributes hasPrefix:@"Tf"]){	
				BOOL boolRes = (BOOL)((IntReturnObjCMsgSendFunction)objc_msgSend)(self,propGetSel);
				NSLog(@">>>  BOOL %@ = %@",name, boolRes ? @"YES" : @"NO");
			}
		}
	}
	NSLog(@"^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^");
#endif
}




- (BOOL) isNumber {
	return [self isKindOfClass:[NSNumber class]];
}

- (BOOL) isString {
	return [self isKindOfClass:[NSString class]];	
}

- (BOOL) isDictionary {
	return [self isKindOfClass:[NSDictionary class]];
}

- (BOOL) isArray {
	return [self isKindOfClass:[NSArray class]];	
}

- (BOOL) isDate {
	return [self isKindOfClass:[NSDate class]];	
}

- (BOOL) isData {
	return [self isKindOfClass:[NSData class]];	
}

+ (NSString *)className{
    return NSStringFromClass([self class]);
}

- (NSString *)className{
    return NSStringFromClass([self class]);
}

- (void)setAssosiatedValue:(id)value forKey:(NSString*)key {
    if ( key == nil ) {
        return;
    }
    
    NSMutableDictionary *assosiatedDictionary = objc_getAssociatedObject(self, &_assosiatedDictionaryKey);
    
    // Adding dict if it not exist
    if ( assosiatedDictionary == nil ) {
        assosiatedDictionary = [NSMutableDictionary new];
        objc_setAssociatedObject(self,
                                 &_assosiatedDictionaryKey,
                                 assosiatedDictionary,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC
                                 );
    } 
    
    [assosiatedDictionary setValue:value forKey:key];
    
    // Removing dict if it is empty
    if ( [assosiatedDictionary count] == 0 ) {
        objc_setAssociatedObject(self,
                                 &_assosiatedDictionaryKey,
                                 nil,
                                 OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (id)assosiatedValueForKey:(NSString*)key {
    NSMutableDictionary *assosiatedDictionary = objc_getAssociatedObject(self, &_assosiatedDictionaryKey);
    return [assosiatedDictionary valueForKey:key];
}

@end
