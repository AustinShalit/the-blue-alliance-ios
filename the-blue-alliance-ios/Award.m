//
//  Award.m
//  the-blue-alliance
//
//  Created by Zach Orr on 4/3/16.
//  Copyright © 2016 The Blue Alliance. All rights reserved.
//

#import "Award.h"
#import "AwardRecipient.h"
#import "TBAAward.h"
#import "Event.h"

@implementation Award

@dynamic name;
@dynamic awardType;
@dynamic year;
@dynamic event;
@dynamic recipients;

+ (Award *)insertAwardWithModelAward:(TBAAward *)modelAward forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"awardType == %@ && year == %@ && event == %@", @(modelAward.awardType), @(modelAward.year), event];
    return [self findOrCreateInContext:context matchingPredicate:predicate configure:^(Award *award) {
        award.name = modelAward.name;
        award.year = @(modelAward.year);
        award.awardType = @(modelAward.awardType);
        award.event = event;
        award.recipients = [NSSet setWithArray:[AwardRecipient insertAwardRecipientsWithModelAwardRecipients:modelAward.recipientList forAward:award inManagedObjectContext:context]];
    }];
}

+ (NSArray<Award *> *)insertAwardsWithModelAwards:(NSArray<TBAAward *> *)modelAwards forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (TBAAward *award in modelAwards) {
        [arr addObject:[self insertAwardWithModelAward:award forEvent:event inManagedObjectContext:context]];
    }
    return arr;
}

@end
