//
//  ListaProductosVC.h
//  ExamenGapsi
//
//  Created by Eduardo Fonseca on 13/01/18.
//  Copyright © 2018 Eduardo Fonseca. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HistoryTableVC.h"

@interface ListaProductosVC : UIViewController<UISearchBarDelegate,UICollectionViewDelegate,UICollectionViewDataSource>
@property(nonatomic,weak) IBOutlet UISearchBar * searchBar;
@property(nonatomic,weak) IBOutlet UICollectionView * collectionProducts;


@end

