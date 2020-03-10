//
//  ViewController.m
//  DiffableOneBehindDemo
//
//  Created by Hamming, Tom on 3/10/20.
//  Copyright © 2020 Hamming, Tom. All rights reserved.
//

#import "ViewController.h"
#import "SearchHit.h"

@interface ViewController ()
@property (strong) UITableViewDiffableDataSource<NSString *, SearchHit *> *dataSource;
@property (strong) NSArray<NSString *> *names;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.names = @[@"Tom", @"Thomas", @"Joe", @"Joseph", @"Ian", @"David", @"Dave", @"Bruce", @"Adam", @"Stacy", @"Ben", @"Benjamin", @"Ghent"];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    self.dataSource = [[UITableViewDiffableDataSource alloc] initWithTableView:self.tableView cellProvider:^UITableViewCell * _Nullable(UITableView *tableView, NSIndexPath *indexPath, SearchHit *hit) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
        NSMutableAttributedString *attr = [[NSMutableAttributedString alloc] initWithString:hit.title];
        for (RangeContainer *rng in hit.match.ranges)
        {
            [attr addAttribute:NSBackgroundColorAttributeName value:[UIColor lightGrayColor] range:rng.range];
        }
        cell.textLabel.attributedText = attr;
        return cell;
    }];
}

-(void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    NSMutableArray<SearchHit *> *arr = [NSMutableArray array];
    if (searchText.length > 0)
    {
        NSMutableSet<SearchHit *> *hits = [NSMutableSet set];
        for (NSString *n in self.names)
        {
            StringMatch *match = [StringMatch matchForSearchString:searchText inTitle:n caseSensitive:NO];
            if (match)
            {
                SearchHit *hit = [[SearchHit alloc] init];
                hit.match = match;
                hit.title = n;
                [hits addObject:hit];
            }
        }
        
        [arr addObjectsFromArray:hits.allObjects];
        [arr sortUsingSelector:@selector(compare:)];
    }
    
    NSDiffableDataSourceSnapshot<NSString *, SearchHit *> *snap = [[NSDiffableDataSourceSnapshot alloc] init];
    [snap appendSectionsWithIdentifiers:@[@""]];
    [snap appendItemsWithIdentifiers:arr];
    [snap reloadItemsWithIdentifiers:arr];
    
    //Change YES to NO here to fix the one-behind issue
    [self.dataSource applySnapshot:snap animatingDifferences:YES];
}

@end
