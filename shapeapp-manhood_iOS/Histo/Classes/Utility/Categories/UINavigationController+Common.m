//
//  UINavigationController+Common.m
//  Common
//
//  Created by Viktor Gubriienko on 20.01.10.
//  Copyright 2010. All rights reserved.
//

#import "UINavigationController+Common.h"


@implementation UINavigationController (Common)

- (UIViewController*) viewCtrlWithClass:(Class) viewCtrlClass {
	for (UIViewController *ctrl in self.viewControllers) {
		if ( [ctrl isMemberOfClass:viewCtrlClass] ) {
			return ctrl;
		}
	}
	
	return nil;
}

@end
