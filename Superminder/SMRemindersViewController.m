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
#import "SVProgressHUD.h"
#import "SMNewReminderViewController.h"

@interface SMRemindersViewController ()

@property (strong, nonatomic) NSString *trelloKey;
@property (strong, nonatomic) NSDictionary *sectionReminderMap;
@property (strong, nonatomic) SMTrelloClient *trelloClient;

@end

static NSString *kNoDateCards = @"No Due Date";
static NSString *kTodayCards = @"Today";
static NSString *kTomorrowCards = @"Tomorrow";
static NSString *kThisWeekCards = @"This Week";
static NSString *kNextWeekCards = @"Next Week";
static NSString *kThisMonthCards = @"This Month";
static NSString *kLaterCards = @"Later";

@implementation SMRemindersViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    self.trelloClient = [SMTrelloClient sharedClient];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserverForName:kAllBoardsLoadFinished object:nil queue:[NSOperationQueue mainQueue] usingBlock:^(NSNotification *note) {
        __weak typeof(self) weakSelf = self;
        [weakSelf buildSectionReminderMap];
        [weakSelf.tableView reloadData];
        [SVProgressHUD showSuccessWithStatus:@"Loaded"];
    }];
    
    [self.trelloClient getCurrentUserInfo];
    [self.trelloClient getAllBoardDataForUser:self.trelloClient.currentUser];
    
//    [SVProgressHUD setForegroundColor:[UIColor colorWithRed:(56/256.0f) green:(167/256.0f) blue:(114/256.0f) alpha:1]];
//    [SVProgressHUD showWithStatus:@"Loading Reminders..."];
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
    if([segue.identifier isEqualToString:@"addNewReminderFromCard"]){
        NSIndexPath *selectedRow = [self.tableView indexPathForSelectedRow];
        SMTrelloCard *selectedCard = [[self.sectionReminderMap objectForKey:[self tableView:nil titleForHeaderInSection:selectedRow.section]] objectAtIndex:selectedRow.row];
        SMNewReminderViewController *newReminderController = (SMNewReminderViewController *)segue.destinationViewController;
        newReminderController.card = selectedCard;
        newReminderController.reminder = selectedCard.linkedReminder;
    }
}

#pragma mark - <UITableViewDataSource>

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    
    return self.sectionReminderMap.count;
}

//- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView{
//    
//}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return kTodayCards;
        case 1:
            return kTomorrowCards;
        case 2:
            return kThisWeekCards;
        case 3:
            return kNextWeekCards;
        case 4:
            return kThisMonthCards;
        case 5:
            return kLaterCards;
        case 6:
            return kNoDateCards;
        default:
            return @"";
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return [[self.sectionReminderMap objectForKey:kTodayCards] count];
        case 1:
            return [[self.sectionReminderMap objectForKey:kTomorrowCards] count];
        case 2:
            return [[self.sectionReminderMap objectForKey:kThisWeekCards] count];
        case 3:
            return [[self.sectionReminderMap objectForKey:kNextWeekCards] count];
        case 4:
            return [[self.sectionReminderMap objectForKey:kThisMonthCards] count];
        case 5:
            return [[self.sectionReminderMap objectForKey:kLaterCards] count];
        case 6:
            return [[self.sectionReminderMap objectForKey:kNoDateCards] count];
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    SMTrelloCard *currentCard;
    switch (indexPath.section) {
        case 0:
            currentCard = [[self.sectionReminderMap objectForKey:kTodayCards] objectAtIndex:indexPath.row];
            break;
        case 1:
            currentCard = [[self.sectionReminderMap objectForKey:kTomorrowCards] objectAtIndex:indexPath.row];
            break;
        case 2:
            currentCard = [[self.sectionReminderMap objectForKey:kThisWeekCards] objectAtIndex:indexPath.row];
            break;
        case 3:
            currentCard = [[self.sectionReminderMap objectForKey:kNextWeekCards] objectAtIndex:indexPath.row];
            break;
        case 4:
            currentCard = [[self.sectionReminderMap objectForKey:kThisMonthCards] objectAtIndex:indexPath.row];
            break;
        case 5:
            currentCard = [[self.sectionReminderMap objectForKey:kLaterCards] objectAtIndex:indexPath.row];
            break;
        case 6:
            currentCard = [[self.sectionReminderMap objectForKey:kNoDateCards] objectAtIndex:indexPath.row];
            break;
        default:
            break;
    }
    cell.textLabel.text = currentCard.name;
    return cell;
}
#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self performSegueWithIdentifier:@"addNewReminderFromCard" sender:self.tableView];
}

#pragma mark - 

- (void)buildSectionReminderMap{
    NSMutableDictionary *mutableMap = [[NSMutableDictionary alloc] init];
    [mutableMap setObject:[[NSMutableArray alloc] init] forKey:kTodayCards];
    [mutableMap setObject:[[NSMutableArray alloc] init] forKey:kTomorrowCards];
    [mutableMap setObject:[[NSMutableArray alloc] init] forKey:kThisWeekCards];
    [mutableMap setObject:[[NSMutableArray alloc] init] forKey:kNextWeekCards];
    [mutableMap setObject:[[NSMutableArray alloc] init] forKey:kThisMonthCards];
    [mutableMap setObject:[[NSMutableArray alloc] init] forKey:kLaterCards];
    [mutableMap setObject:[[NSMutableArray alloc] init] forKey:kNoDateCards];
    
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *thisWeekComponents = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    thisWeekComponents.day += 7;
    NSDateComponents *nextWeekComponents = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    nextWeekComponents.day += 14;
    NSDateComponents *thisMonthComponents = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    thisMonthComponents.month += 1;
    
    NSComparisonResult thisWeekResult, nextWeekResult, thisMonthResult, pastResult;
    for(SMTrelloBoard *board in self.trelloClient.currentUser.boards){
        for(SMTrelloList *list in board.lists){
            for(SMTrelloCard *card in list.cards){
                if(card.dueDate == nil || card.dueDate == [NSNull null]){
                    [[mutableMap objectForKey:kNoDateCards] addObject:card];
                    continue;
                }
                pastResult = [cal compareDate:[NSDate date] toDate:card.dueDate toUnitGranularity:NSCalendarUnitDay];
                if(pastResult == NSOrderedDescending){
                    //TODO: in the board fetch request, switch to cards=open to get rid of archived cards, and then we can also have a "past due" section
                    continue; //skip dates in the past for now.
                }
                thisWeekResult = [cal compareDate:[cal dateFromComponents:thisWeekComponents] toDate:card.dueDate toUnitGranularity:NSCalendarUnitDay];
                nextWeekResult = [cal compareDate:[cal dateFromComponents:nextWeekComponents] toDate:card.dueDate toUnitGranularity:NSCalendarUnitDay];
                thisMonthResult = [cal compareDate:[cal dateFromComponents:thisMonthComponents] toDate:card.dueDate toUnitGranularity:NSCalendarUnitDay];
                if([cal isDateInToday:card.dueDate]){
                    [[mutableMap objectForKey:kTodayCards] addObject:card];
                }
                else if([cal isDateInTomorrow:card.dueDate]){
                    [[mutableMap objectForKey:kTomorrowCards] addObject:card];
                }
                else if(thisWeekResult == NSOrderedSame || thisWeekResult == NSOrderedDescending){
                    [[mutableMap objectForKey:kThisWeekCards] addObject:card];
                }
                else if(nextWeekResult == NSOrderedSame || nextWeekResult == NSOrderedDescending){
                    [[mutableMap objectForKey:kNextWeekCards] addObject:card];
                }
                else if(thisMonthResult == NSOrderedSame || thisMonthResult == NSOrderedDescending){
                    [[mutableMap objectForKey:kThisMonthCards] addObject:card];
                }
                else{
                    [[mutableMap objectForKey:kLaterCards] addObject:card];
                }
            }
        }
    }
    
    self.sectionReminderMap = [mutableMap copy];
}
@end
