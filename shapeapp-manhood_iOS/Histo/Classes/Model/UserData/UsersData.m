//
//  UsersData.m
//  CoolHisto
//
//  Created by Viktor Gubriienko on 24.03.14.
//  Copyright (c) 2014 Viktor Gubriienko. All rights reserved.
//

#import "UsersData.h"

static NSString *const kJSONLengthKey               = @"length";
static NSString *const kJSONGirthKey                = @"girth";
static NSString *const kJSONThicknessKey            = @"thickness";
static NSString *const kJSONLookupUsersKey          = @"lookup_users";
static NSString *const kJSONBinKey                  = @"bin";
static NSString *const kJSONCountKey                = @"count";
static NSString *const kJSONAverageKey              = @"average";
static NSInteger const kJSONUserLengthIndex         = 0;
static NSInteger const kJSONUserGirthIndex          = 1;
static NSInteger const kJSONUserThicknessIndex      = 2;
static NSInteger const kJSONUserCirclesIndex        = 3;
static NSInteger const kJSONUserLengthPosIndex      = 4;
static NSInteger const kJSONUserGirthPosIndex       = 5;
static NSInteger const kJSONUserThicknessPosIndex   = 6;
static NSInteger const kJSONUserCircleBaseIndex     = 0;
static NSInteger const kJSONUserCircleMidIndex      = 1;
static NSInteger const kJSONUserCircleUpperIndex    = 2;
static NSInteger const kJSONUserCircleTipIndex      = 3;
static NSInteger const kJSONUserCircleXIndex        = 0;
static NSInteger const kJSONUserCircleYIndex        = 1;
static NSInteger const kSearchValueIndex            = 0;
static NSInteger const kSearchUserIDIndex           = 1;


@implementation UsersData {
    NSDictionary *_usersData;
    NSDictionary *_searchData;
}

- (instancetype)initWithContentsOfFile:(NSString*)filePath rootKey:(NSString*)rootKey {
    self = [super init];
    if (self) {
        NSData *jsonData = [NSData dataWithContentsOfFile:filePath];
        if ( jsonData ) {
            _usersData = [NSPropertyListSerialization propertyListWithData:jsonData
                                                                   options:kCFPropertyListMutableContainersAndLeaves
                                                                    format:nil
                                                                     error:nil];
            [self setupSearchData];            
        } else {
            return self = nil;
        }
        
    }
    return self;
    
}

#pragma mark - DynamicProperties

- (void)setupSearchData {
    _searchData = @{kJSONLengthKey: [self createSearchDataForUserDataIndex:kJSONUserLengthIndex positionValueIndex:kJSONUserLengthPosIndex],
                    kJSONGirthKey: [self createSearchDataForUserDataIndex:kJSONUserGirthIndex positionValueIndex:kJSONUserGirthPosIndex],
                    kJSONThicknessKey: [self createSearchDataForUserDataIndex:kJSONUserThicknessIndex positionValueIndex:kJSONUserThicknessPosIndex]};
}

- (NSArray*)createSearchDataForUserDataIndex:(NSInteger)index positionValueIndex:(NSInteger)positionIndex {
    NSMutableArray *searchData = [[NSMutableArray alloc] initWithCapacity:[_usersData[kJSONLookupUsersKey] count]];
    for (NSString *userID in _usersData[kJSONLookupUsersKey]) {
        NSArray *userData = _usersData[kJSONLookupUsersKey][userID];
        [searchData addObject:@[userData[index], userID]];
    }
    
    [searchData sortUsingComparator:^NSComparisonResult(NSArray *userData1, NSArray *userData2) {
        return [userData1[kSearchValueIndex] compare:userData2[kSearchValueIndex]];
    }];
    
    [searchData enumerateObjectsUsingBlock:^(NSArray *searchUserData, NSUInteger idx, BOOL *stop) {
        [_usersData[kJSONLookupUsersKey][searchUserData[kSearchUserIDIndex]] insertObject:@(idx) atIndex:positionIndex];
    }];
    
    return [searchData copy];
}

- (NSArray*)searchUserDataForValue:(float)value withKey:(NSString*)key exact:(BOOL)exact {

    NSArray *allData = _searchData[key];
    NSArray *result;
    
    if ( exact ) {
        
        if ( value < [allData.firstObject[kSearchValueIndex] floatValue] || value > [allData.lastObject[kSearchValueIndex] floatValue] ) {
            result = nil;
        } else {
            for (NSArray *userData in allData) {
                if ( [userData[kSearchValueIndex] floatValue] == value ) {
                    result = userData;
                    break;
                }
            }
        }
        
    } else {
        float valueDiff = MAXFLOAT;
        
        for (NSArray *userData in allData) {
            float diff = fabsf([userData[kSearchValueIndex] floatValue] - value);
            if ( diff < valueDiff ) {
                result = userData;
                valueDiff = diff;
            }
        }

    }
    
    return result;

}

#pragma mark - Public

- (float)lengthOfUserWithID:(NSString*)userID {
    return [_usersData[kJSONLookupUsersKey][userID][kJSONUserLengthIndex] floatValue];
}

- (float)girthOfUserWithID:(NSString*)userID {
    return [_usersData[kJSONLookupUsersKey][userID][kJSONUserGirthIndex] floatValue];
}

- (float)thicknessOfUserWithID:(NSString*)userID {
    return [_usersData[kJSONLookupUsersKey][userID][kJSONUserThicknessIndex] floatValue];
}

- (CGPoint)basePositionOfUserWithID:(NSString*)userID {
    return CGPointMake([_usersData[kJSONLookupUsersKey][userID][kJSONUserCirclesIndex][kJSONUserCircleBaseIndex][kJSONUserCircleXIndex] floatValue],
                       [_usersData[kJSONLookupUsersKey][userID][kJSONUserCirclesIndex][kJSONUserCircleBaseIndex][kJSONUserCircleYIndex] floatValue]);
}

- (CGPoint)midPositionOfUserWithID:(NSString*)userID {
    return CGPointMake([_usersData[kJSONLookupUsersKey][userID][kJSONUserCirclesIndex][kJSONUserCircleMidIndex][kJSONUserCircleXIndex] floatValue],
                       [_usersData[kJSONLookupUsersKey][userID][kJSONUserCirclesIndex][kJSONUserCircleMidIndex][kJSONUserCircleYIndex] floatValue]);
}

- (CGPoint)upperPositionOfUserWithID:(NSString*)userID {
    return CGPointMake([_usersData[kJSONLookupUsersKey][userID][kJSONUserCirclesIndex][kJSONUserCircleUpperIndex][kJSONUserCircleXIndex] floatValue],
                       [_usersData[kJSONLookupUsersKey][userID][kJSONUserCirclesIndex][kJSONUserCircleUpperIndex][kJSONUserCircleYIndex] floatValue]);
}

- (CGPoint)tipPositionOfUserWithID:(NSString*)userID {
    return CGPointMake([_usersData[kJSONLookupUsersKey][userID][kJSONUserCirclesIndex][kJSONUserCircleTipIndex][kJSONUserCircleXIndex] floatValue],
                       [_usersData[kJSONLookupUsersKey][userID][kJSONUserCirclesIndex][kJSONUserCircleTipIndex][kJSONUserCircleYIndex] floatValue]);
}

- (NSString*)userIDWithNearestLength:(float)length {
    return [self searchUserDataForValue:length withKey:kJSONLengthKey exact:NO][kSearchUserIDIndex];
}

- (NSString*)userIDWithNearestGirth:(float)girth {
    return [self searchUserDataForValue:girth withKey:kJSONGirthKey exact:NO][kSearchUserIDIndex];
}

- (NSString*)userIDWithNearestThickness:(float)thickness {
    return [self searchUserDataForValue:thickness withKey:kJSONThicknessKey exact:NO][kSearchUserIDIndex];
}

- (NSUInteger)positionOfUserWithNearestLength:(float)length {
    return [_searchData[kJSONLengthKey] indexOfObject:[self searchUserDataForValue:length withKey:kJSONLengthKey exact:NO]];
}

- (NSUInteger)positionOfUserWithNearestGirth:(float)girth {
    return [_searchData[kJSONGirthKey] indexOfObject:[self searchUserDataForValue:girth withKey:kJSONGirthKey exact:NO]];
}

- (NSUInteger)positionOfUserWithNearestThickness:(float)thickness {
    return [_searchData[kJSONThicknessKey] indexOfObject:[self searchUserDataForValue:thickness withKey:kJSONThicknessKey exact:NO]];
}

- (NSString*)userIDByLengthPosition:(NSUInteger)position {
    if (position >= self.usersCount) {
        return nil;
    } else {
        return _searchData[kJSONLengthKey][position][kSearchUserIDIndex];
    }
}

- (NSString*)userIDByGirthPosition:(NSUInteger)position {
    if (position >= self.usersCount) {
        return nil;
    } else {
        return _searchData[kJSONGirthKey][position][kSearchUserIDIndex];
    }
}

- (NSString*)userIDByThicknessPosition:(NSUInteger)position {
    if (position >= self.usersCount) {
        return nil;
    } else {
        return _searchData[kJSONThicknessKey][position][kSearchUserIDIndex];
    }
}

- (NSUInteger)positionByLengthOfUserWithID:(NSString*)userID {
    return [_usersData[kJSONLookupUsersKey][userID][kJSONUserLengthPosIndex] unsignedIntegerValue];
}

- (NSUInteger)positionByGirthOfUserWithID:(NSString*)userID {
    return [_usersData[kJSONLookupUsersKey][userID][kJSONUserGirthPosIndex] unsignedIntegerValue];
}

- (NSUInteger)positionByThicknessOfUserWithID:(NSString*)userID {
    return [_usersData[kJSONLookupUsersKey][userID][kJSONUserThicknessPosIndex] unsignedIntegerValue];
}

#pragma mark - DynamicProperties

- (NSInteger)usersCount {
    return [_usersData[kJSONLookupUsersKey] count];
}

- (NSArray *)lengthBins {
    return _usersData[kJSONLengthKey][kJSONBinKey];
}

- (NSArray *)lengthCounts{
    return _usersData[kJSONLengthKey][kJSONCountKey];
}

- (NSArray *)girthBins {
    return _usersData[kJSONGirthKey][kJSONBinKey];
}

- (NSArray *)girthCounts {
    return _usersData[kJSONGirthKey][kJSONCountKey];
}

- (NSArray *)thicknessBins {
    return _usersData[kJSONThicknessKey][kJSONBinKey];
}

- (NSArray *)thicknessCounts {
    return _usersData[kJSONThicknessKey][kJSONCountKey];
}

- (float)averageLength {
    return [_usersData[kJSONAverageKey][kJSONUserLengthIndex] floatValue];
}

- (float)averageGirth {
    return [_usersData[kJSONAverageKey][kJSONUserGirthIndex] floatValue];
}

- (float)averageThickness {
    return [_usersData[kJSONAverageKey][kJSONUserThicknessIndex] floatValue];
}

@end
