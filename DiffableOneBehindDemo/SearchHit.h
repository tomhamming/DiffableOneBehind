//
//  SearchHit.h
//  DiffableOneBehindDemo
//
//  Created by Hamming, Tom on 3/10/20.
//  Copyright © 2020 Hamming, Tom. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RangeContainer : NSObject
@property NSRange range;
@property (readonly) NSUInteger location;
@property (readonly) NSUInteger length;
@property (readonly) NSUInteger endLocation;
+(RangeContainer *)withRange:(NSRange)range;
@end

@interface StringMatch : NSObject
@property NSUInteger currentSearchIndex;
@property NSUInteger longestRange;
@property (strong) NSString *title;
@property (strong) NSMutableArray<RangeContainer *> *ranges;
@property (readonly) NSString *identifier;
-(NSComparisonResult)compare:(StringMatch *)otherMatch;

+(StringMatch *)matchForSearchString:(NSString *)search inTitle:(NSString *)title caseSensitive:(BOOL)caseSensitive;
@end

@interface SearchHit : NSObject
@property (strong) NSString *title;
@property (strong) StringMatch *match;

@end
