//
//  ProductItemCollVCell.h
//  ExamenGapsi
//
//  Created by Eduardo Fonseca on 13/01/18.
//  Copyright © 2018 Eduardo Fonseca. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProductItemCollVCell : UICollectionViewCell
@property(nonatomic,weak) IBOutlet UIImageView * imgProduct;
@property(nonatomic,weak) IBOutlet UILabel * lblDesc;
@property(nonatomic,weak) IBOutlet UILabel * lblPrice;
@property(nonatomic,weak) IBOutlet UILabel * lblLocation;
@end
