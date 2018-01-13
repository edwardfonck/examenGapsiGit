//
//  ListaProductosVC.m
//  ExamenGapsi
//
//  Created by Eduardo Fonseca on 13/01/18.
//  Copyright © 2018 Eduardo Fonseca. All rights reserved.
//

#import "ListaProductosVC.h"
#import "UIImageView+WebCache.h"
#import "MKAnnotationView+WebCache.h"
#import "ProductItemCollVCell.h"


#define URLWS @"https://www.liverpool.com.mx/tienda/?s=%@&d3106047a194921c01969dfdec083925=json"
@interface ListaProductosVC ()<HistoryListDelegate>
{
    int numberOfRecords;
    NSMutableDictionary * jsonResponse;
    NSString * SearchingText;
    
}
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView * activity;
@property (nonatomic,weak) IBOutlet UILabel * lblSearchDesc;
@property (nonatomic,weak) IBOutlet UILabel * lblNumberResults;
@end

@implementation ListaProductosVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    jsonResponse = [NSMutableDictionary dictionary];
    
    // Do any additional setup after loading the view, typically from a nib.
    [_activity setHidden:YES];
    [self.lblNumberResults setHidden:YES];
    numberOfRecords = 0;
}

-(void)viewWillDisappear:(BOOL)animated{
    self.searchBar.text = @"";
    [self.searchBar resignFirstResponder];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -Call Web Service

-(void)callWebService:(NSString*)SearchText{
    [self.activity setHidden:NO];
    [self.activity startAnimating];
    
    NSString* stringURL =[NSString stringWithFormat:URLWS,SearchText];
    NSString* webStringURL = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSURL* url = [NSURL URLWithString:webStringURL];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [NSURLConnection sendAsynchronousRequest:request
                                       queue:[NSOperationQueue mainQueue]
                           completionHandler:^(NSURLResponse *response,
                                               NSData *data, NSError *connectionError)
     {
         [self.activity setHidden:YES];
         [self.activity stopAnimating];
         if (data.length > 0 && connectionError == nil)
         {
             // self.item.title = @"Json Cargado correctamente";
             jsonResponse = [NSMutableDictionary dictionary];
             jsonResponse = [NSJSONSerialization JSONObjectWithData:data
                                                            options:0
                                                              error:NULL];
             NSLog(@"Json Recibido: %@",jsonResponse);
             if(jsonResponse != nil){
                 
                 NSArray * items =  jsonResponse[@"contents"][0][@"mainContent"][3][@"contents"][0][@"records"];
                 
                 NSString * TotalItems =jsonResponse[@"contents"][0][@"mainContent"][3][@"contents"][0][@"totalNumRecs"];
                 
                 numberOfRecords = (int)[items count];
                 
                 NSString * message = items.count>0? @"Resultados para": @"No hay resultados para";
                 self.lblSearchDesc.text = [ NSString stringWithFormat:@"%@ %@",message, SearchingText ];
                 
                 [self.lblNumberResults setHidden:items.count>0? NO:YES];
                 
                 self.lblNumberResults.text = [NSString stringWithFormat:@"%i/%@",(int)[items count],TotalItems];
                 
                 [self.collectionProducts reloadData];
                 [self.collectionProducts layoutIfNeeded];
                 
                 if(items.count>0){
                     dispatch_async(dispatch_get_main_queue(), ^{
                         NSIndexPath * indexPath =  [NSIndexPath indexPathForRow:0 inSection:0];
                         [self.collectionProducts scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
                     });
                 }
             }
         }else{
             self.lblSearchDesc.text = @"Error al obtener información, intente más tarde";
         }
     }];
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return numberOfRecords;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterCurrencyStyle];
    
    ProductItemCollVCell * cell = (ProductItemCollVCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"productCell" forIndexPath:indexPath];
    
    
    NSString * priceStr = [ NSString stringWithFormat:@"%@",jsonResponse[@"contents"][0][@"mainContent"][3][@"contents"][0][@"records"][indexPath.row][@"attributes"][@"sku.sale_Price"][0]];
    
    cell.lblDesc.text =  [NSString stringWithFormat:@"%@",jsonResponse[@"contents"][0][@"mainContent"][3][@"contents"][0][@"records"][indexPath.row][@"attributes"][@"product.displayName"][0]];
    cell.lblPrice.text = [formatter stringFromNumber:[NSNumber numberWithDouble:[priceStr doubleValue]]];
    cell.lblLocation.text =  [[NSString stringWithFormat:@"%@",jsonResponse[@"contents"][0][@"mainContent"][3][@"contents"][0][@"records"][indexPath.row][@"attributes"][@"isAvailabilityShop"][0]] boolValue]==true?@"Tienda":@"Online";
    
    [cell.imgProduct sd_setImageWithURL:[NSURL URLWithString:[ NSString stringWithFormat:@"%@",jsonResponse[@"contents"][0][@"mainContent"][3][@"contents"][0][@"records"][indexPath.row][@"attributes"][@"sku.thumbnailImage"][0]]] placeholderImage:[UIImage imageNamed:@"placeholderProd"] options:SDWebImageRetryFailed];
    cell.imgProduct.contentMode = UIViewContentModeScaleAspectFit;
    
    return cell;
}

#pragma mark - SearchBar Delegate

-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    [searchBar resignFirstResponder];
    SearchingText = searchBar.text;
    if(searchBar.text.length >2){
        self.lblNumberResults.text = [NSString stringWithFormat:@"Buscando %@...",SearchingText];
        [self addToHistory:searchBar.text];
        [self callWebService:searchBar.text];
        
    }else{
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"Aviso" message:searchBar.text.length ==0?@"Debes ingresar algún termino de búsqueda":@"El termino de búsqueda de ser mayor a 2 caracteres" preferredStyle:UIAlertControllerStyleAlert];
        
        [self presentViewController:alert animated:YES completion:nil];
        [self performSelector:@selector(dismissAlert) withObject:nil afterDelay:2.0];
        
    }
}

-(void)dismissAlert{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)addToHistory:(NSString*)searchText{
    
    NSMutableArray * arrHistorySaved = [NSMutableArray array];
    arrHistorySaved = [[NSUserDefaults standardUserDefaults]objectForKey:@"arrHistory"]? [[[NSUserDefaults standardUserDefaults]objectForKey:@"arrHistory"] mutableCopy]: [NSMutableArray array];
    
    for (NSString* historystr in arrHistorySaved){
        
        if([[historystr uppercaseString] isEqualToString:[searchText uppercaseString]])//Si el termino de búsqueda ya se ha repetido, elimina el item para que sea la ultima búsqueda.
        {
            [arrHistorySaved removeObject:historystr];
            break;
        }
    }
    
    [arrHistorySaved addObject:searchText];
    [[NSUserDefaults standardUserDefaults]setValue:arrHistorySaved forKey:@"arrHistory"];
    
    NSLog(@"Arreglo Generado%@",arrHistorySaved);
    
}

#pragma mark <UICollectionFlowLayoutDelegate>
- (CGSize)collectionView:(UICollectionView *)collectionView
                  layout:(UICollectionViewLayout *)collectionViewLayout
  sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat height = self.view.frame.size.height;
    CGFloat width  = self.view.frame.size.width;
    // in case you you want the cell to be 40% of your controllers view
    if([[UIDevice currentDevice]userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
        return CGSizeMake(width*0.485,height*0.35);
    else
        return CGSizeMake(width*0.32,height*0.23);
}
// Dynamic width & height

//For top/bottom/left/right padding method
- (UIEdgeInsets)collectionView:(UICollectionView*)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 0, 1);
}

- (CGFloat)collectionView:(UICollectionView *) collectionView layout:(UICollectionViewLayout *)collectionViewLayout
minimumInteritemSpacingForSectionAtIndex:(NSInteger) section
{
    return 1.0;
}

#pragma mark Segue methods and delegates (HistoryDelegateMethod)

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    HistoryTableVC * historyVC = [segue destinationViewController];
    historyVC.delegate = self;
}

- (void)HistorySelectedItem:(NSString *)selectedItem {
    SearchingText = selectedItem;
    [self addToHistory:selectedItem];
    self.lblSearchDesc.text = [NSString stringWithFormat:@"Buscando %@...",selectedItem];
    [self callWebService:selectedItem];
}



@end
