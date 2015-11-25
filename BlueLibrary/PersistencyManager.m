#import "PersistencyManager.h"

@interface PersistencyManager ()
{
    //an array of all albums;
    NSMutableArray * albums;
}

@end

@implementation PersistencyManager

#pragma mark - LifeCycle
- (id)init
{
    self = [super init];
    if (self) {
        
        NSData *data = [NSData dataWithContentsOfFile:[NSHomeDirectory() stringByAppendingString:@"/Documents/albums.bin"]];
        albums = [NSKeyedUnarchiver unarchiveObjectWithData:data];

        if (albums == nil){
            albums = [NSMutableArray arrayWithArray:
                      @[[[Album alloc] initWithTitle:@"Best of Bowie" artist:@"David Bowie" coverUrl:@"https://upload.wikimedia.org/wikipedia/en/2/29/Best_of_bowie.jpg" year:@"1992"],
                        [[Album alloc] initWithTitle:@"It's My Life" artist:@"No Doubt" coverUrl:@"http://www.gtp.tw/cover/rrDqUCfI2a0fjIwqznJe.jpg" year:@"2003"],
                        [[Album alloc] initWithTitle:@"Nothing Like The Sun" artist:@"Sting" coverUrl:@"http://staff.endo.ch/600xabfb23d029d27eee193a2f014765f0fd.jpg?album=Sting%20-%20Nothing%20Like%20The%20Sun" year:@"1999"],
                        [[Album alloc] initWithTitle:@"Staring at the Sun" artist:@"U2" coverUrl:@"http://ecx.images-amazon.com/images/I/51MKVSXVKHL.jpg" year:@"2000"],
                        [[Album alloc] initWithTitle:@"American Pie" artist:@"Madonna" coverUrl:@"https://i1.sndcdn.com/artworks-000022582366-xe4dzo-t500x500.jpg" year:@"2000"]]];
            
            [self saveAlbums];
        }
        
    }
    return self;
}

#pragma mark - Method
-(NSArray *)getAlbums
{
    return albums;
}

-(void)addAlbum:(Album *)album atIndex:(int)index
{
    if ([albums count]>=index) {
        [albums insertObject:album atIndex:index];
    }else{
        [albums addObject:album];
    }
}

-(void)deleteAlbumAtIndex:(int)index
{
    [albums removeObjectAtIndex:index];
}

- (void)saveImage:(UIImage*)image filename:(NSString*)filename
{
    filename = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", filename];
    NSData *data = UIImagePNGRepresentation(image);
    
    [data writeToFile:filename atomically:YES];
}

- (UIImage*)getImage:(NSString*)filename
{
    filename = [NSHomeDirectory() stringByAppendingFormat:@"/Documents/%@", filename];
    NSData *data = [NSData dataWithContentsOfFile:filename];
    
    return [UIImage imageWithData:data];
}

- (void)saveAlbums
{
    NSString *filename = [NSHomeDirectory() stringByAppendingString:@"/Documents/albums.bin"];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:albums];
    [data writeToFile:filename atomically:YES];
}

@end
