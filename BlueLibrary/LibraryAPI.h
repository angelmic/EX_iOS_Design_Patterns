#import <Foundation/Foundation.h>
#import "Album.h"

@interface LibraryAPI : NSObject

#pragma mark - Init
+(LibraryAPI*)shareInstance;

#pragma mark - Method
-(NSArray *)getAlbums;
-(void)addAblum:(Album*)album atIndex:(int)index;
-(void)deleteAlbumAtIndex:(int)index;
-(void)saveAlbums;

@end
