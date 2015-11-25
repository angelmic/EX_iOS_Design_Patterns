#import "ViewController.h"
#import "LibraryAPI.h"
#import "Album+TableRepresentation.h"
#import "HorizontalScroller.h"
#import "AlbumView.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate, HorizontalScrollerDelegate>
{
    UITableView * dataTable;
    NSArray * allAlbums;
    NSDictionary * currentAlbumData;
    int currentAlbumIndex;
    HorizontalScroller *scroller;
    
    UIToolbar *toolbar;
    // We will use this array as a stack to push and pop operation for the undo option
    NSMutableArray *undoStack;
}

@end

@implementation ViewController

#pragma mark - LifeCycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(saveCurrentState) name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    self.view.backgroundColor = [UIColor colorWithRed:0.76f green:0.81f blue:0.87f alpha:1];
    currentAlbumIndex = 0;
    
    toolbar = [[UIToolbar alloc] init];
    UIBarButtonItem *undoItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemUndo target:self action:@selector(undoAction)];
    undoItem.enabled = NO;
    
    UIBarButtonItem *space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    UIBarButtonItem *delete = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteAlbum)];
    
    [toolbar setItems:@[undoItem,space,delete]];
    
    [self.view addSubview:toolbar];
    
    undoStack = [[NSMutableArray alloc] init];
    
    //2
    allAlbums = [[LibraryAPI shareInstance] getAlbums];
    
    [self loadPreviousState];
    
    //3
    //the uitableview that present the album data
    dataTable = [[UITableView alloc]initWithFrame:CGRectMake(0, 120, self.view.bounds.size.width, self.view.bounds.size.height-120) style:UITableViewStyleGrouped];
    dataTable.delegate = self;
    dataTable.dataSource = self;
    dataTable.backgroundView = nil;
    [self.view addSubview:dataTable];
    
    scroller = [[HorizontalScroller alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 120)];
    
    scroller.backgroundColor = [UIColor colorWithRed:0.24f green:0.35f blue:0.49f alpha:1];
    scroller.dddelegate      = self;
    
    [self.view addSubview:scroller];
    
    [self reloadScroller];
    
    [self showDataForAlbumAtIndex:currentAlbumIndex];
}

- (void)viewWillLayoutSubviews
{
    toolbar.frame   = CGRectMake(0, self.view.frame.size.height-44, self.view.frame.size.width, 44);
    dataTable.frame = CGRectMake(0, 130, self.view.frame.size.width, self.view.frame.size.height - 200);
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showDataForAlbumAtIndex:(int)albumIndex
{
    
    //防禦機制，確保albumIndex小於allAlbums的元素個數
    if (albumIndex < [allAlbums count]) {
        
        //取得專輯資料
        Album * album = allAlbums[albumIndex];
        
        //用字典的形式儲存album的資料
        currentAlbumData = [album tr_tableRepresentation];
        
    }else{
        
        currentAlbumData = nil;
        
    }
    
    //拿到了我們想要的資料後重新整理我們的tableView
    [dataTable reloadData];
}

#pragma mark - protocal
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [currentAlbumData[@"titles"] count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
    }
    
    cell.textLabel.text = [currentAlbumData[@"titles"] objectAtIndex:indexPath.row];
    cell.detailTextLabel.text = [currentAlbumData[@"values"] objectAtIndex:indexPath.row];
    
    return cell;
}

#pragma mark - Method
- (void)reloadScroller
{
    allAlbums = [[LibraryAPI shareInstance] getAlbums];
    
    if (currentAlbumIndex < 0)
        currentAlbumIndex = 0;
    else if (currentAlbumIndex >= allAlbums.count)
        currentAlbumIndex = (int)allAlbums.count-1;
    
    [scroller reload];
    
    [self showDataForAlbumAtIndex:currentAlbumIndex];
}

- (void)saveCurrentState
{
    // When the user leaves the app and then comes back again, he wants it to be in the exact same state
    // he left it. In order to do this we need to save the currently displayed album.
    // Since it's only one piece of information we can use NSUserDefaults.
    [[NSUserDefaults standardUserDefaults] setInteger:currentAlbumIndex forKey:@"currentAlbumIndex"];
    [[LibraryAPI shareInstance] saveAlbums];
}

- (void)loadPreviousState
{
    currentAlbumIndex = (int)[[NSUserDefaults standardUserDefaults] integerForKey:@"currentAlbumIndex"];
    [self showDataForAlbumAtIndex:currentAlbumIndex];
}

#pragma mark - Actions
- (void)addAlbum:(Album*)album atIndex:(int)index
{
    [[LibraryAPI shareInstance] addAblum:album atIndex:index];
    currentAlbumIndex = index;
    [self reloadScroller];
}

- (void)deleteAlbum
{
    if(currentAlbumIndex < 0)
        return;
    
    // 1
    Album *deletedAlbum = allAlbums[currentAlbumIndex];
    
    // 2
    NSMethodSignature *sig = [self methodSignatureForSelector:@selector(addAlbum:atIndex:)];
    NSInvocation *undoAction = [NSInvocation invocationWithMethodSignature:sig];
    
    [undoAction setTarget:self];
    [undoAction setSelector:@selector(addAlbum:atIndex:)];
    [undoAction setArgument:&deletedAlbum atIndex:2];
    [undoAction setArgument:&currentAlbumIndex atIndex:3];
    [undoAction retainArguments];
    
    // 3
    [undoStack addObject:undoAction];
    
    // 4
    [[LibraryAPI shareInstance] deleteAlbumAtIndex:currentAlbumIndex];
    [self reloadScroller];
    
    // 5
    [toolbar.items[0] setEnabled:YES];
}

- (void)undoAction
{
    if (undoStack.count > 0){
        NSInvocation *undoAction = [undoStack lastObject];
        [undoStack removeLastObject];
        [undoAction invoke];
    }
    
    if (undoStack.count == 0){
        [toolbar.items[0] setEnabled:NO];
    }
}

#pragma mark - HorizontalScrollerDelegate methods
- (NSInteger)initialViewIndexForHorizontalScroller:(HorizontalScroller *)scroller
{
    return currentAlbumIndex;
}

- (void)horizontalScroller:(HorizontalScroller *)scroller clickedViewAtIndex:(int)index
{
    currentAlbumIndex = index;
    [self showDataForAlbumAtIndex:index];
}

- (NSInteger)numberOfViewsForHorizontalScroller:(HorizontalScroller*)scroller
{
    return allAlbums.count;
}

- (UIView*)horizontalScroller:(HorizontalScroller*)scroller viewAtIndex:(int)index
{
    Album *album = allAlbums[index];
    return [[AlbumView alloc] initWithFrame:CGRectMake(0, 0, 100, 100) albumCover:album.coverUrl];
}

@end
