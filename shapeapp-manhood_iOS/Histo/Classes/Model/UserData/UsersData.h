//
//  UsersData.h
//  CoolHisto
//
//  Created by Viktor Gubriienko on 24.03.14.
//  Copyright (c) 2014 Viktor Gubriienko. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UsersData : NSObject

//@property (nonatomic, readonly) NSString *rootKey;

@property (nonatomic, readonly) NSArray *lengthBins;
@property (nonatomic, readonly) NSArray *lengthCounts;
@property (nonatomic, readonly) NSArray *girthBins;
@property (nonatomic, readonly) NSArray *girthCounts;
@property (nonatomic, readonly) NSArray *thicknessBins;
@property (nonatomic, readonly) NSArray *thicknessCounts;
@property (nonatomic, readonly) float averageLength;
@property (nonatomic, readonly) float averageGirth;
@property (nonatomic, readonly) float averageThickness;

@property (nonatomic, readonly) NSInteger usersCount;


- (instancetype)initWithContentsOfFile:(NSString*)filePath rootKey:(NSString*)rootKey;

- (float)lengthOfUserWithID:(NSString*)userID;
- (float)girthOfUserWithID:(NSString*)userID;
- (float)thicknessOfUserWithID:(NSString*)userID;

- (CGPoint)basePositionOfUserWithID:(NSString*)userID;
- (CGPoint)midPositionOfUserWithID:(NSString*)userID;
- (CGPoint)upperPositionOfUserWithID:(NSString*)userID;
- (CGPoint)tipPositionOfUserWithID:(NSString*)userID;

- (NSString*)userIDWithNearestLength:(float)length;
- (NSString*)userIDWithNearestGirth:(float)girth;
- (NSString*)userIDWithNearestThickness:(float)thickness;

- (NSUInteger)positionOfUserWithNearestLength:(float)length;
- (NSUInteger)positionOfUserWithNearestGirth:(float)girth;
- (NSUInteger)positionOfUserWithNearestThickness:(float)thickness;

- (NSUInteger)positionByLengthOfUserWithID:(NSString*)userID;
- (NSUInteger)positionByGirthOfUserWithID:(NSString*)userID;
- (NSUInteger)positionByThicknessOfUserWithID:(NSString*)userID;

- (NSString*)userIDByLengthPosition:(NSUInteger)position;
- (NSString*)userIDByGirthPosition:(NSUInteger)position;
- (NSString*)userIDByThicknessPosition:(NSUInteger)position;

@end
