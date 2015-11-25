#import "LibraryAPI.h"
#import "PersistencyManager.h"
#import "HTTPClient.h"

@interface LibraryAPI ()
{
    PersistencyManager * persistencyManager;
    HTTPClient * httpClient;
    BOOL isOnline;
}

@end

@implementation LibraryAPI

#pragma mark - LifeCycle
+(LibraryAPI*)shareInstance
{
    static LibraryAPI * _shareInstance = nil;
    
    static dispatch_once_t oncePredicate;
    
    dispatch_once(&oncePredicate, ^{
        NSLog(@"LibraryAPI New!!");
        
        _shareInstance = [[LibraryAPI alloc]init];
        
    });
    
    return _shareInstance;
}

-(id)init{
    self = [super init];
    if (self) {
        persistencyManager = [[PersistencyManager alloc]init];
        httpClient = [[HTTPClient alloc]init];
        isOnline = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(downloadImage:)
                                                     name:@"BLDownloadImageNotification"
                                                   object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Method
-(NSArray *)getAlbums{
    return [persistencyManager getAlbums];
}

-(void)addAblum:(Album *)album atIndex:(int)index{
    [persistencyManager addAlbum:album atIndex:index];
    //if (isOnline) {
    //    [httpClient postRequest:@"/api/addAlbum" body:[album description]];
   // }
}

-(void)deleteAlbumAtIndex:(int)index{
    [persistencyManager deleteAlbumAtIndex:index];
    if (isOnline) {
        [httpClient postRequest:@"/api/deleteAlbum" body:[@(index) description]];
    }
}

-(void)saveAlbums
{
    [persistencyManager saveAlbums];
}

#pragma mark - NotificationCenter
- (void)downloadImage:(NSNotification*)notification
{
    // 1
    UIImageView *imageView = notification.userInfo[@"imageView"];
    NSString *coverUrl     = notification.userInfo[@"coverUrl"];
    
    // 2
    //imageView.image = [persistencyManager getImage:[coverUrl lastPathComponent]];
    imageView.image = nil;
    
    if (imageView.image == nil){
        
        // 3
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            UIImage *image = [httpClient downloadImage:coverUrl];
            
            // 4
            dispatch_sync(dispatch_get_main_queue(), ^{
                imageView.image = image;
                [persistencyManager saveImage:image filename:[coverUrl lastPathComponent]];
            });
        });
    }    
}

@end
