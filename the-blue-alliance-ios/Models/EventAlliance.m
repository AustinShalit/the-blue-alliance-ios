#import "EventAlliance.h"

@implementation EventAlliance

+ (instancetype)insertEventAllianceWithModelEventWebcast:(TBAEventAlliance *)modelEventAlliance forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context {
    // Check for pre-existing object
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"EventAlliance" inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
    
    // Specify criteria for filtering which objects to fetch
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"event == %@", event];
    [fetchRequest setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *existingObjs = [context executeFetchRequest:fetchRequest error:&error];
    for (EventAlliance *ea in existingObjs) {
        [context deleteObject:ea];
    }
    
    EventAlliance *eventAlliance = [NSEntityDescription insertNewObjectForEntityForName:@"EventAlliance" inManagedObjectContext:context];
 
#warning turn these in to team objects?
    eventAlliance.picks = modelEventAlliance.picks;
    eventAlliance.declines = modelEventAlliance.declines;
    eventAlliance.event = event;
    
    return eventAlliance;
}

+ (NSArray *)insertEventAlliancesWithModelEventAlliances:(NSArray *)modelEventAlliances forEvent:(Event *)event inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (TBAEventAlliance *eventAlliance in modelEventAlliances) {
        [arr addObject:[self insertEventAllianceWithModelEventWebcast:eventAlliance forEvent:event inManagedObjectContext:context]];
    }
    return arr;
}

@end
