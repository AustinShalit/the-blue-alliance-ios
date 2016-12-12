//
//  DistrictRanking.m
//  the-blue-alliance-ios
//
//  Created by Zach Orr on 9/17/15.
//  Copyright © 2015 The Blue Alliance. All rights reserved.
//

#import "DistrictRanking.h"
#import "District.h"
#import "EventPoints.h"
#import "Team.h"
#import "Team+Fetch.h"
#import "Event+Fetch.h"

@implementation DistrictRanking

@dynamic pointTotal;
@dynamic rank;
@dynamic rookieBonus;
@dynamic district;
@dynamic eventPoints;
@dynamic team;

+ (instancetype)insertDistrictRankingWithDistrictRankingDict:(NSDictionary<NSString *, id> *)districtRankingDict forDistrict:(District *)district forTeam:(Team *)team inManagedObjectContext:(NSManagedObjectContext *)context {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"district == %@ AND team == %@", district, team];
    return [self findOrCreateInContext:context matchingPredicate:predicate configure:^(DistrictRanking *districtRanking) {
        districtRanking.district = district;
        districtRanking.pointTotal = districtRankingDict[@"point_total"];
        districtRanking.rank = districtRankingDict[@"rank"];
        districtRanking.rookieBonus = districtRankingDict[@"rookie_bonus"];
        districtRanking.team = team;
        
        /*
        NSDictionary *eventPointsDict = districtRankingDict[@"event_points"];
        for (NSString *eventKey in [eventPointsDict allKeys]) {
            NSDictionary *eventPointDict = eventPointsDict[eventKey];
            dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
            
            __block Event *event;
            [Event fetchEventWithKey:eventKey inManagedObjectContext:context withCompletionBlock:^(Event * _Nullable e, NSError * _Nullable error) {
                event = e;
                dispatch_semaphore_signal(semaphore);
            }];
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            if (event == nil) {
                continue;
            }
            
            districtRanking.eventPoints = [districtRanking.eventPoints setByAddingObject:[EventPoints insertEventPointsWithEventPointsDict:eventPointDict forEvent:event andTeam:team inManagedObjectContext:context]];
        }
        */
    }];
}

+ (NSArray *)insertDistrictRankingsWithDistrictRankings:(NSArray<NSDictionary<NSString *, id> *> *)districtRankings forDistrict:(District *)district inManagedObjectContext:(NSManagedObjectContext *)context {
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (NSDictionary *districtRanking in districtRankings) {
        NSString *teamKey = districtRanking[@"team_key"];
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        __block Team *team;
        [Team fetchTeamWithKey:teamKey inManagedObjectContext:context withCompletionBlock:^(Team * _Nonnull t, NSError * _Nonnull error) {
            team = t;
            dispatch_semaphore_signal(semaphore);
        }];
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        if (!team) {
            continue;
        }

        [arr addObject:[self insertDistrictRankingWithDistrictRankingDict:districtRanking forDistrict:district forTeam:team inManagedObjectContext:context]];
    }
    return arr;
}

@end
