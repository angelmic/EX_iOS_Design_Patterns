#import "Album+TableRepresentation.h"

@implementation Album (TableRepresentation)

-(NSDictionary *)tr_tableRepresentation{
    return @{@"titles":@[@"Artist"  ,@"Album"   ,@"Genre" ,@"Year"],
             @"values":@[self.artist,self.title,self.genre,self.year]};
}

@end
