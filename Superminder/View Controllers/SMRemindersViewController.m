//
//  SMRemindersViewController.m
//  Superminder
//
//  Created by Bradley Ringel on 5/2/15.
//  Copyright (c) 2015 Bradley Ringel. All rights reserved.
//

#import "SMRemindersViewController.h"
#import "Lockbox.h"
#import "SMTrelloBoard.h"
#import "SMTrelloList.h"
#import "SMTrelloCard.h"
#import "SVProgressHUD.h"
#import "SMNewReminderViewController.h"
#import "SMCardCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "SMCloudKitClient.h"
#import "UIScrollView+EmptyDataSet.h"

@interface SMRemindersViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>

@property (strong, nonatomic) NSString *trelloKey;
@property (strong, nonatomic) NSDictionary *sectionReminderMap;
@property (strong, nonatomic) SMTrelloClient *trelloClient;
@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (weak, nonatomic) SMTrelloCard *selectedCard;
@property (nonatomic, readonly) BOOL anyCardsLoaded;

@end

static NSString *kNoDateCards = @"No Due Date";
static NSString *kOverdueCards = @"Overdue";
static NSString *kTodayCards = @"Today";
static NSString *kTomorrowCards = @"Tomorrow";
static NSString *kThisWeekCards = @"This Week";
static NSString *kNextWeekCards = @"Next Week";
static NSString *kThisMonthCards = @"This Month";
static NSString *kLaterCards = @"Later";

@implementation SMRemindersViewController

static NSString * const reuseIdentifier = @"SMCardCell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Register cell classes
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    self.tableView.estimatedRowHeight = 88;
    self.tableView.emptyDataSetDelegate = self;
    self.tableView.emptyDataSetSource = self;
    
    self.tableView.tableFooterView = [UIView new]; //trick to hide the empty table view rows
    
    self.sectionReminderMap = [self setupSectionReminderMap];
    
    [[SMCloudKitClient sharedClient] fetchAllRemindersWithCompletion:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.tableView reloadData];
        });
    }];
    self.trelloClient = [SMTrelloClient sharedClient];
    self.trelloClient.dataDelegate = self;
    self.trelloClient.progressDelegate = self;
    
    [self.trelloClient getCurrentUserInfo];
    [self.progressBar setProgress:0 animated:NO];
    self.progressBar.hidden = NO;
    [self.trelloClient getAllBoardDataForUser:self.trelloClient.currentUser];
    
//    [SVProgressHUD setForegroundColor:[UIColor colorWithRed:(56/256.0f) green:(167/256.0f) blue:(114/256.0f) alpha:1]];
//    [SVProgressHUD showWithStatus:@"Loading Reminders..."];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSDateFormatter *)dateFormatter{
    if(_dateFormatter == nil){
        _dateFormatter = [[NSDateFormatter alloc] init];
        _dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    }
    return _dateFormatter;
}

- (BOOL)anyCardsLoaded{
    BOOL anyCards = ([self.sectionReminderMap[kOverdueCards] count] != 0) ||
    ([self.sectionReminderMap[kTodayCards] count] != 0) ||
    ([self.sectionReminderMap[kTomorrowCards] count] != 0) ||
    ([self.sectionReminderMap[kThisWeekCards] count] != 0) ||
    ([self.sectionReminderMap[kNextWeekCards] count] != 0) ||
    ([self.sectionReminderMap[kThisMonthCards] count] != 0) ||
    ([self.sectionReminderMap[kLaterCards] count] != 0) ||
    ([self.sectionReminderMap[kNoDateCards] count] != 0);
    
    return anyCards;
}

#pragma mark - SMTrelloClientDelegate

- (void)allBoardsLoadedForUser:(SMTrelloUser *)user{
    dispatch_async(dispatch_get_main_queue(), ^{
        [SVProgressHUD showSuccessWithStatus:@"Loaded"];
        self.progressBar.hidden = YES;
        [self.progressBar setProgress:0 animated:NO];
    });
}

- (void)boardLoaded:(SMTrelloBoard *)board{
    NSMutableDictionary *mutableMap = [self.sectionReminderMap mutableCopy];
    [self insertBoard:board intoSectionReminderMap:mutableMap];
    
    self.sectionReminderMap = [mutableMap copy];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.tableView reloadData];
    });
}

- (void)updateProgressValue:(float)percentage{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.progressBar setProgress:percentage animated:YES];
    });
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([segue.identifier isEqualToString:@"addNewReminderFromCard"]){
        SMNewReminderViewController *newReminderController = (SMNewReminderViewController *)[segue.destinationViewController topViewController];
        SMReminder *reminder = [[SMCloudKitClient sharedClient] reminderForCardID:self.selectedCard.cardID];
        newReminderController.card = self.selectedCard;
        newReminderController.reminder = reminder;
        self.tableView.editing = NO;
    }
}

#pragma mark - <UITableViewDataSource>

- (NSInteger) numberOfSectionsInTableView:(UITableView *)tableView{
    
    if(self.anyCardsLoaded){
        return self.sectionReminderMap.count;
    }
    else{
        return 0;
    }
}

//- (NSArray *) sectionIndexTitlesForTableView:(UITableView *)tableView{
//    
//}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return kOverdueCards;
        case 1:
            return kTodayCards;
        case 2:
            return kTomorrowCards;
        case 3:
            return kThisWeekCards;
        case 4:
            return kNextWeekCards;
        case 5:
            return kThisMonthCards;
        case 6:
            return kLaterCards;
        case 7:
            return kNoDateCards;
        default:
            return @"";
    }
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    switch (section) {
        case 0:
            return [[self.sectionReminderMap objectForKey:kOverdueCards] count];
        case 1:
            return [[self.sectionReminderMap objectForKey:kTodayCards] count];
        case 2:
            return [[self.sectionReminderMap objectForKey:kTomorrowCards] count];
        case 3:
            return [[self.sectionReminderMap objectForKey:kThisWeekCards] count];
        case 4:
            return [[self.sectionReminderMap objectForKey:kNextWeekCards] count];
        case 5:
            return [[self.sectionReminderMap objectForKey:kThisMonthCards] count];
        case 6:
            return [[self.sectionReminderMap objectForKey:kLaterCards] count];
        case 7:
            return [[self.sectionReminderMap objectForKey:kNoDateCards] count];
        default:
            return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    SMCardCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    SMTrelloCard *currentCard;
    switch (indexPath.section) {
        case 0:
            currentCard = [[self.sectionReminderMap objectForKey:kOverdueCards] objectAtIndex:indexPath.row];
            break;
        case 1:
            currentCard = [[self.sectionReminderMap objectForKey:kTodayCards] objectAtIndex:indexPath.row];
            break;
        case 2:
            currentCard = [[self.sectionReminderMap objectForKey:kTomorrowCards] objectAtIndex:indexPath.row];
            break;
        case 3:
            currentCard = [[self.sectionReminderMap objectForKey:kThisWeekCards] objectAtIndex:indexPath.row];
            break;
        case 4:
            currentCard = [[self.sectionReminderMap objectForKey:kNextWeekCards] objectAtIndex:indexPath.row];
            break;
        case 5:
            currentCard = [[self.sectionReminderMap objectForKey:kThisMonthCards] objectAtIndex:indexPath.row];
            break;
        case 6:
            currentCard = [[self.sectionReminderMap objectForKey:kLaterCards] objectAtIndex:indexPath.row];
            break;
        case 7:
            currentCard = [[self.sectionReminderMap objectForKey:kNoDateCards] objectAtIndex:indexPath.row];
            break;
        default:
            break;
    }
    
    cell.cardTitleLabel.text = currentCard.name;
    cell.listNameLabel.text = currentCard.list.name;
    SMReminder *cardReminder = [[SMCloudKitClient sharedClient] reminderForCardID:currentCard.cardID];
    
    if(cardReminder != nil && cardReminder.reminderDate != nil){
        cell.dueDateInfoLabel.text = [NSString stringWithFormat:@"Reminder: %@", [self.dateFormatter stringFromDate:cardReminder.reminderDate]];
    }
    else if(currentCard.dueDate != nil){
        cell.dueDateInfoLabel.text = [NSString stringWithFormat:@"Due: %@", [self.dateFormatter stringFromDate:currentCard.dueDate]];
    }
    else{
        cell.dueDateInfoLabel.text = @"No Due Date";
    }
    if(currentCard.list.board.backgroundColor != nil){
        cell.boardBackgroundImageView.hidden = YES;
        cell.boardColorView.hidden = NO;
        cell.boardColorView.backgroundColor = currentCard.list.board.backgroundColor;
    }
    else{
        cell.boardBackgroundImageView.hidden = NO;
        cell.boardColorView.hidden = YES;
        [cell.boardBackgroundImageView sd_setImageWithURL:currentCard.list.board.backgroundImageURL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
        }];
    }
    
    return cell;
}
#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

- (NSArray *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    self.selectedCard = [[self.sectionReminderMap objectForKey:[self tableView:tableView titleForHeaderInSection:indexPath.section]] objectAtIndex:indexPath.row];
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Add\nReminder" handler:^(UITableViewRowAction *action, NSIndexPath *indexPath) {
        [self performSegueWithIdentifier:@"addNewReminderFromCard" sender:self];
    }];
    
    UITableViewRowAction *editAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"Edit\nReminder" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self performSegueWithIdentifier:@"addNewReminderFromCard" sender:self];
    }];
    
    UITableViewRowAction *deleteReminderAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"Remove\nReminder" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        //do something here
    }];
    SMReminder *reminder = [[SMCloudKitClient sharedClient] reminderForCardID:self.selectedCard.cardID];
    if(reminder == nil){
        return @[action];
    }
    else{
        return @[deleteReminderAction, editAction];
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
}

#pragma mark - DZNEmptyDataSetSource

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView{
    NSString *text = @"Loading Reminders";
    NSDictionary *attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0f],
                                 NSForegroundColorAttributeName: [UIColor darkGrayColor]};
    
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIColor *)backgroundColorForEmptyDataSet:(UIScrollView *)scrollView{
    return [UIColor colorWithRed:0.8144 green:0.8144 blue:0.8144 alpha:1.0];
}

#pragma mark - DZNEmptyDataSetDelegate

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView{
    return !self.anyCardsLoaded;
}

#pragma mark -

- (NSDictionary *)setupSectionReminderMap {
    NSMutableDictionary *mutableMap = [[NSMutableDictionary alloc] init];
    [mutableMap setObject:[[NSMutableArray alloc] init] forKeyedSubscript:kOverdueCards];
    [mutableMap setObject:[[NSMutableArray alloc] init] forKey:kTodayCards];
    [mutableMap setObject:[[NSMutableArray alloc] init] forKey:kTomorrowCards];
    [mutableMap setObject:[[NSMutableArray alloc] init] forKey:kThisWeekCards];
    [mutableMap setObject:[[NSMutableArray alloc] init] forKey:kNextWeekCards];
    [mutableMap setObject:[[NSMutableArray alloc] init] forKey:kThisMonthCards];
    [mutableMap setObject:[[NSMutableArray alloc] init] forKey:kLaterCards];
    [mutableMap setObject:[[NSMutableArray alloc] init] forKey:kNoDateCards];
    return [mutableMap copy];
}

- (void)insertBoard:(SMTrelloBoard *)board intoSectionReminderMap:(NSMutableDictionary *)mutableMap {
    
    NSComparisonResult thisWeekResult, nextWeekResult, thisMonthResult, pastResult;
    NSCalendar *cal = [NSCalendar currentCalendar];
    NSDateComponents *thisWeekComponents = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    thisWeekComponents.day += 7;
    NSDateComponents *nextWeekComponents = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    nextWeekComponents.day += 14;
    NSDateComponents *thisMonthComponents = [cal components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
    thisMonthComponents.month += 1;
    for(SMTrelloList *list in board.lists){
        for(SMTrelloCard *card in list.cards){
            if(card.dueDate == nil || card.dueDate == (NSDate *)[NSNull null]){
                [[mutableMap objectForKey:kNoDateCards] addObject:card];
                continue;
            }
            pastResult = [cal compareDate:[NSDate date] toDate:card.dueDate toUnitGranularity:NSCalendarUnitDay];
            thisWeekResult = [cal compareDate:[cal dateFromComponents:thisWeekComponents] toDate:card.dueDate toUnitGranularity:NSCalendarUnitDay];
            nextWeekResult = [cal compareDate:[cal dateFromComponents:nextWeekComponents] toDate:card.dueDate toUnitGranularity:NSCalendarUnitDay];
            thisMonthResult = [cal compareDate:[cal dateFromComponents:thisMonthComponents] toDate:card.dueDate toUnitGranularity:NSCalendarUnitDay];
            if(pastResult == NSOrderedDescending){
                [[mutableMap objectForKey:kOverdueCards] addObject:card];
            }
            else if([cal isDateInToday:card.dueDate]){
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

- (void)buildSectionReminderMap{
    
    NSMutableDictionary *mutableMap = [self.sectionReminderMap mutableCopy];
    
    for(SMTrelloBoard *board in self.trelloClient.currentUser.boards){
        [self insertBoard:board intoSectionReminderMap:mutableMap];
    }
    
    self.sectionReminderMap = [mutableMap copy];
}
@end
