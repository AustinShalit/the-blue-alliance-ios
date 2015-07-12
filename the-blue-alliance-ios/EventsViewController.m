//
//  EventsViewController.m
//  The Blue Alliance
//
//  Created by Donald Pinckney on 5/5/14.
//  Copyright (c) 2014 The Blue Alliance. All rights reserved.
//
#import "EventsViewController.h"
#import "TBAEventsViewController.h"
#import "EventViewController.h"
#import "HMSegmentedControl.h"
#import "Event+Fetch.h"
#import "OrderedDictionary.h"
#import <PureLayout/PureLayout.h>

// TODO: Bring the events view to the current week, like the Android app

static NSString *const EventsViewControllerEmbed = @"EventsViewControllerEmbed";
static NSString *const EventViewControllerSegue  = @"EventViewControllerSegue";

@interface EventsViewController ()

@property (nonatomic, strong) TBAEventsViewController *eventsViewController;
@property (nonatomic, weak) IBOutlet UIView *eventsView;
@property (nonatomic, weak) IBOutlet UIView *segmentedControlView;

@property (nonatomic, strong) OrderedDictionary *events;

@property (nonatomic, strong) HMSegmentedControl *segmentedControl;
@property (nonatomic, assign) NSInteger currentSegmentIndex;

@end


@implementation EventsViewController

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    __weak typeof(self) weakSelf = self;
    self.refresh = ^void() {
        __strong typeof(weakSelf) strongSelf = weakSelf;

        [strongSelf.eventsViewController hideNoDataView];
        [strongSelf updateRefreshBarButtonItem:YES];
        [strongSelf refreshData];
    };
    
    self.yearSelected = ^void(NSUInteger selectedYear) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf cancelRefresh];
        
        if (strongSelf.segmentedControl) {
            strongSelf.segmentedControl.selectedSegmentIndex = 0;
        }
        [strongSelf.eventsViewController hideNoDataView];
        [strongSelf removeData];
        
        strongSelf.currentYear = selectedYear;
        [strongSelf fetchEventsAndRefresh:YES];
    };
    
    [self configureYears];
    [self fetchEventsAndRefresh:YES];
    [self styleInterface];
}

#pragma mark - Data Methods

- (void)removeData {
    self.events = nil;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self updateInterface];
    });
}

- (void)configureYears {
    // TODO: Check if year + 1 exists (for next-season data trickling in)
    
    NSInteger year = [TBAYearSelectViewController currentYear];
    self.years = [TBAYearSelectViewController yearsBetweenStartYear:1992 endYear:year];
    
    if (self.currentYear == 0) {
        self.currentYear = year;
    }
}

- (void)fetchEventsAndRefresh:(BOOL)refresh {
    __weak typeof(self) weakSelf = self;
    [Event fetchEventsForYear:self.currentYear fromContext:self.persistenceController.managedObjectContext withCompletionBlock:^(NSArray *events, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        if (error) {
            NSString *errorMessage = @"Unable to fetch events locally";
            dispatch_async(dispatch_get_main_queue(), ^{
                if (strongSelf.events) {
                    [strongSelf showErrorAlertWithMessage:errorMessage];
                } else {
                    [strongSelf.eventsViewController showNoDataViewWithText:errorMessage];
                }
            });
            return;
        }
        
        if ([events count] == 0) {
            if (refresh && strongSelf.refresh) {
                strongSelf.refresh();
            } else {
                [strongSelf removeData];
            }
        } else {
            strongSelf.events = [Event groupEventsByWeek:events andGroupByType:YES];
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf updateInterface];
            });
        }
    }];
}

- (void)refreshData {
    __weak typeof(self) weakSelf = self;
    __block NSUInteger request = [[TBAKit sharedKit] fetchEventsForYear:self.currentYear withCompletionBlock:^(NSArray *events, NSInteger totalCount, NSError *error) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        
        [strongSelf removeRequestIdentifier:request];
        
        if (error) {
            NSString *errorMessage = @"Unable to load events";
            dispatch_async(dispatch_get_main_queue(), ^{
                if (strongSelf.events) {
                    [strongSelf showErrorAlertWithMessage:errorMessage];
                } else {
                    [strongSelf.eventsViewController showNoDataViewWithText:errorMessage];
                }
            });
        } else {
            dispatch_async(dispatch_get_main_queue(), ^{
                [Event insertEventsWithModelEvents:events inManagedObjectContext:strongSelf.persistenceController.managedObjectContext];
                [strongSelf fetchEventsAndRefresh:NO];
                [strongSelf.persistenceController save];
            });
        }
    }];
    [self addRequestIdentifier:request];
}

- (OrderedDictionary *)weekDictionaryForIndex:(NSInteger)index {
    NSArray *weekKeys = [self.events allKeys];
    if (!weekKeys || index >= [weekKeys count]) {
        return nil;
    }
    NSString *weekKey = [weekKeys objectAtIndex:index];
    
    return [self.events objectForKey:weekKey];
}

#pragma mark - Interface Methods

- (void)styleInterface {
    self.segmentedControlView.backgroundColor = [UIColor TBANavigationBarColor];
    self.navigationItem.title = @"Events";

    [self updateInterface];
}

- (void)updateInterface {
    [self updateSegmentedControlForEventKeys:self.events.allKeys];
    [self segmentedControlChangedValue:self.segmentedControl];
}

- (void)updateSegmentedControlForEventKeys:(NSArray *)eventKeys {
    if (!eventKeys || [eventKeys count] == 0) {
        [self.segmentedControl removeFromSuperview];
        self.segmentedControl = nil;
        return;
    }

    if (self.segmentedControl) {
        self.segmentedControl.sectionTitles = eventKeys;
        [self.segmentedControl setNeedsDisplay];
        return;
    }

    self.segmentedControl = [[HMSegmentedControl alloc] initWithSectionTitles:eventKeys];
    
    self.segmentedControl.frame = self.segmentedControlView.frame;
    self.segmentedControl.segmentEdgeInset = UIEdgeInsetsMake(0, 10, 0, 10);
    self.segmentedControl.selectionStyle = HMSegmentedControlSelectionStyleFullWidthStripe;
    self.segmentedControl.selectionIndicatorLocation = HMSegmentedControlSelectionIndicatorLocationDown;
    self.segmentedControl.backgroundColor = [UIColor TBANavigationBarColor];
    self.segmentedControl.selectionIndicatorColor = [UIColor whiteColor];
    self.segmentedControl.segmentWidthStyle = HMSegmentedControlSegmentWidthStyleDynamic;
    self.segmentedControl.selectionIndicatorHeight = 3.0f;
    
    [self.segmentedControl setTitleFormatter:^NSAttributedString *(HMSegmentedControl *segmentedControl, NSString *title, NSUInteger index, BOOL selected) {
        NSAttributedString *attString = [[NSAttributedString alloc] initWithString:title attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
        return attString;
    }];
    [self.segmentedControl addTarget:self action:@selector(segmentedControlChangedValue:) forControlEvents:UIControlEventValueChanged];
    [self.segmentedControlView addSubview:self.segmentedControl];
    
    [self.segmentedControl autoPinEdgesToSuperviewEdgesWithInsets:UIEdgeInsetsZero];
}

- (void)segmentedControlChangedValue:(HMSegmentedControl *)segmentedControl {
    if (self.events && segmentedControl.selectedSegmentIndex < [self.events.allKeys count]) {
        self.eventsViewController.events = [self.events objectAtIndex:segmentedControl.selectedSegmentIndex];
    } else {
        self.eventsViewController.events = nil;
    }
    [self.eventsViewController.tableView reloadData];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:EventsViewControllerEmbed]) {
        self.eventsViewController = (TBAEventsViewController *)segue.destinationViewController;

        __weak typeof(self) weakSelf = self;
        self.eventsViewController.eventSelected = ^(Event *event) {
            [weakSelf performSegueWithIdentifier:EventViewControllerSegue sender:event];
        };
    } else if ([segue.identifier isEqualToString:EventViewControllerSegue]) {
        Event *event = (Event *)sender;
        
        EventViewController *eventViewController = segue.destinationViewController;
        eventViewController.event = event;
    }
}

@end
