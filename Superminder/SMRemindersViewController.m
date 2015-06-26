//
//  SMRemindersViewController.m
//  Superminder
//
//  Created by Bradley Ringel on 5/2/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import "SMRemindersViewController.h"
#import "Lockbox.h"
#import "SMTrelloClient.h"
#import "SMTrelloBoard.h"
#import "SMTrelloList.h"
#import "SMTrelloCard.h"

@interface SMRemindersViewController ()

@property (strong, nonatomic) NSString *trelloKey;
@property (strong, nonatomic) NSDictionary *sectionReminderMap;
@property (strong, nonatomic) SMTrelloClient *trelloClient;

@end

@implementation SMRemindersViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kNeedsReauthentication object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        __weak typeof(self) weakSelf = self;
        [weakSelf performSegueWithIdentifier:@"showLoginScreen" sender:weakSelf];
    }];
    // Do any additional setup after loading the view.
    self.trelloKey = [Lockbox stringForKey:kTrelloUserKey];
    if(!self.trelloKey){
        [self performSegueWithIdentifier:@"showLoginScreen" sender:self];
    }
    
    [[NSNotificationCenter defaultCenter] addObserverForName:kAllBoardsLoadFinished object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        __weak typeof(self) weakSelf = self;
        [weakSelf buildSectionReminderMap];
        [weakSelf.tableView reloadData];
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

#pragma mark - <UITableViewDataSource>

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
}

//- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView{
//    
//}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    int count = 0;
    for (SMTrelloBoard *board in [[[SMTrelloClient sharedClient] currentUser] boards]) {
        for (SMTrelloList *list in board.lists){
            count += list.cards.count;
        }
    }
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    cell.textLabel.text = [NSString stringWithFormat:@"%ld,%ld",indexPath.section, (long)indexPath.row];
    return cell;
}
#pragma mark - <UITableViewDelegate>

#pragma mark - 

- (void)buildSectionReminderMap{
    NSMutableDictionary *mutableMap = [[NSMutableDictionary alloc] init];
    [mutableMap setObject:[[NSMutableArray alloc] init] forKey:@"Today"];
    [mutableMap setObject:[[NSMutableArray alloc] init] forKey:@"Tomorrow"];
    [mutableMap setObject:[[NSMutableArray alloc] init] forKey:@"This Week"];
    [mutableMap setObject:[[NSMutableArray alloc] init] forKey:@"Next Week"];
    [mutableMap setObject:[[NSMutableArray alloc] init] forKey:@"This Month"];
    [mutableMap setObject:[[NSMutableArray alloc] init] forKey:@"Later"];
    [mutableMap setObject:[[NSMutableArray alloc] init] forKey:@"No Due Date"];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *thisWeekComponents = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    thisWeekComponents.day += 7;
    NSDateComponents *nextWeekComponents = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    nextWeekComponents.day += 14;
    NSDateComponents *thisMonthComponents = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    thisMonthComponents.month += 1;
    
    NSComparisonResult thisWeekResult, nextWeekResult, thisMonthResult;
    for(SMTrelloBoard *board in self.trelloClient.currentUser.boards){
        for(SMTrelloList *list in board.lists){
            for(SMTrelloCard *card in list.cards){
                thisWeekResult = [cal compareDate:card.dueDate toDate:[cal dateFromComponents:thisWeekComponents] toUnitGranularity:NSCalendarUnitDay];
                nextWeekResult = [cal compareDate:card.dueDate toDate:[cal dateFromComponents:nextWeekComponents] toUnitGranularity:NSCalendarUnitDay];
                thisMonthResult = [cal compareDate:card.dueDate toDate:[cal dateFromComponents:thisMonthComponents] toUnitGranularity:NSCalendarUnitDay];
                if(card.dueDate == nil){
                    [[mutableMap objectForKey:@"No Due Date"] addObject:card];
                }
                else if([cal isDateInToday:card.dueDate]){
                    [[mutableMap objectForKey:@"Today"] addObject:card];
                }
                else if([cal isDateInTomorrow:card.dueDate]){
                    [[mutableMap objectForKey:@"Tomorrow"] addObject:card];
                }
                else if(thisWeekResult == NSOrderedSame || thisWeekResult == NSOrderedDescending){
                    [[mutableMap objectForKey:@"This Week"] addObject:card];
                }
                else if(nextWeekResult == NSOrderedSame || nextWeekResult == NSOrderedDescending){
                    [[mutableMap objectForKey:@"Next Week"] addObject:card];
                }
                else if(thisMonthResult == NSOrderedSame || thisMonthResult == NSOrderedDescending){
                    [[mutableMap objectForKey:@"This Month"] addObject:card];
                }
                else{
                    [[mutableMap objectForKey:@"Later"] addObject:card];
                }
            }
        }
    }
    
    self.sectionReminderMap = [mutableMap copy];
}
@end
