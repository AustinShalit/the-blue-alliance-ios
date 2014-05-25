//
//  EventViewController.h
//  the-blue-alliance-ios
//
//  Created by Donald Pinckney on 5/24/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@interface EventViewController : UIPageViewController <UIPageViewControllerDataSource>

- (instancetype) initWithEvent:(Event *)event;

@end