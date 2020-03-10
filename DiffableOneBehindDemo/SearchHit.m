//
//  SearchHit.m
//  DiffableOneBehindDemo
//
//  Created by Hamming, Tom on 3/10/20.
//  Copyright © 2020 Hamming, Tom. All rights reserved.
//

#import "SearchHit.h"

@implementation RangeContainer
+(RangeContainer *)withRange:(NSRange)range
{
    RangeContainer *result = [[RangeContainer alloc] init];
    result.range = range;
    return result;
}

-(NSUInteger)location
{
    return self.range.location;
}

-(NSUInteger)length
{
    return self.range.length;
}

-(NSUInteger)endLocation
{
    return self.range.location + self.range.length;
}
@end

@implementation StringMatch

-(id)init
{
    self = [super init];
    self.ranges = [NSMutableArray array];
    return self;
}

-(NSComparisonResult)compare:(StringMatch *)otherMatch
{
    //Order descending by range length, then by range location
    if (otherMatch.longestRange < self.longestRange)
    {
        return NSOrderedAscending;
    }
    else if (otherMatch.longestRange > self.longestRange)
    {
        return NSOrderedDescending;
    }
    else
    {
        if (otherMatch.ranges.firstObject.location > self.ranges.firstObject.location)
            return NSOrderedAscending;
        else if (otherMatch.ranges.firstObject.location < self.ranges.firstObject.location)
            return NSOrderedDescending;
        else
            return [self.title compare:otherMatch.title];
    }
}

+(StringMatch *)matchForSearchString:(NSString *)search inTitle:(NSString *)title caseSensitive:(BOOL)caseSensitive
{
    if (search.length == 0 && title.length == 0)
        return nil;
    
    if (!caseSensitive)
    {
        search = search.lowercaseString;
        title = title.lowercaseString;
    }
    
    NSMutableArray<StringMatch *> *results = [NSMutableArray array];
    
    StringMatch *currMatch = nil;
    for (NSUInteger i = 0; i < title.length; i++)
    {
        //If the first character of our search string matches here, begin a new match
        unichar tc = [title characterAtIndex:i];
        if (tc == [search characterAtIndex:0])
        {
            currMatch = [[StringMatch alloc] init];
            currMatch.title = title;
            [results addObject:currMatch];
            NSRange rng = NSMakeRange(i, 1);
            [currMatch.ranges addObject:[RangeContainer withRange:rng]];
            currMatch.currentSearchIndex = 1;
            currMatch.longestRange = 1;
        }
        
        for (StringMatch *m in results)
        {
            //If we didn't just add a match above, check to see if its next letter matches the current letter in title
            if (i != m.ranges.firstObject.location && m.currentSearchIndex < search.length && tc == [search characterAtIndex:m.currentSearchIndex])
            {
                m.currentSearchIndex++;
                
                RangeContainer *lastRange = m.ranges.lastObject;
                if (i == lastRange.endLocation)
                {
                    //Expand the range by one
                    lastRange.range = NSMakeRange(lastRange.location, lastRange.length + 1);
                }
                else
                {
                    //New range, since we skipped a letter
                    [m.ranges addObject:[RangeContainer withRange:NSMakeRange(i, 1)]];
                }
                
                m.longestRange = MAX(m.longestRange, m.ranges.lastObject.range.length);
            }
        }
    }
    
    NSMutableArray *toRemove = [NSMutableArray array];
    for (StringMatch *m in results)
    {
        if (m.currentSearchIndex != search.length)
            [toRemove addObject:m];
    }
    [results removeObjectsInArray:toRemove];
    
    [results sortUsingSelector:@selector(compare:)];
    return results.firstObject;
}

@end

@implementation SearchHit

-(NSUInteger)hash
{
    return self.title.hash;
}

-(BOOL)isEqual:(id)object
{
    if (![object isKindOfClass:[SearchHit class]])
        return NO;
    
    SearchHit *other = (SearchHit *)object;
    return other.hash == self.hash;
}

-(NSComparisonResult)compare:(SearchHit *)other
{
    return [self.match compare:other.match];
}

@end
