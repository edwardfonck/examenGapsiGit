//
//  HistoryTableVC.m
//  ExamenGapsi
//
//  Created by Eduardo Fonseca on 13/01/18.
//  Copyright © 2018 Eduardo Fonseca. All rights reserved.
//

#import "HistoryTableVC.h"

@interface HistoryTableVC ()
@property (nonatomic,strong) NSMutableArray * arrHistory;
@end

@implementation HistoryTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    self.title = @"Historial";
    
    self.arrHistory = [NSMutableArray array];
    self.arrHistory = [[[NSUserDefaults standardUserDefaults]objectForKey:@"arrHistory"]mutableCopy];
    
    self.tableHistory.tableFooterView = [UIView new]; //like "Hide" footer section from tableView.
    
    [self.tableHistory setDelegate:self];
    [self.tableHistory setDataSource:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
      return self.arrHistory.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"historyCell" forIndexPath:indexPath];
    
    cell.textLabel.text = self.arrHistory[self.arrHistory.count>0? self.arrHistory.count-indexPath.row-1:0];
    cell.textLabel.textColor = [UIColor redColor];
    // Configure the cell...
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if(self.delegate != nil && [self.delegate respondsToSelector:@selector(HistorySelectedItem:)]){
        [self.navigationController popViewControllerAnimated:YES];
       [self.delegate HistorySelectedItem:self.arrHistory[self.arrHistory.count>0? self.arrHistory.count-indexPath.row-1:0]];
    }
    [self dismissViewControllerAnimated:YES completion:^{
    }];
    
}

// Swipe to delete.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self.arrHistory removeObjectAtIndex:self.arrHistory.count>0? self.arrHistory.count-indexPath.row-1:0];
        [[NSUserDefaults standardUserDefaults]setValue:self.arrHistory forKey:@"arrHistory"];
        
        NSLog(@"Arreglo Generado%@",self.arrHistory);
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

@end
