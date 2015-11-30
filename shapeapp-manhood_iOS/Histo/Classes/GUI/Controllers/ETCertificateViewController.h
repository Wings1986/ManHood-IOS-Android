//
//  ETCertificateViewController.h
//  Histo
//
//  Created by Idriss on 20/02/2014.
//  Copyright (c) 2014 histo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ETBaseViewController.h"

@class SelfUserData;
@class UsersData;
@interface ETCertificateViewController : ETBaseViewController

- (void)setUsersData:(UsersData*)usersData selfUserData:(SelfUserData*)selfUserData;

@end
