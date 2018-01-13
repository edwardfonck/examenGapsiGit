//
//  HistoryTableVC.h
//  ExamenGapsi
//
//  Created by Eduardo Fonseca on 13/01/18.
//  Copyright © 2018 Eduardo Fonseca. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HistoryListDelegate <NSObject>
@required
-(void)HistorySelectedItem:(NSString*)selectedItem;
@end

@interface HistoryTableVC : UITableViewController
@property(nonatomic,weak) IBOutlet UITableView *tableHistory;
@property (nonatomic,strong) id<HistoryListDelegate> delegate;

@end
