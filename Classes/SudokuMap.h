//
//  SudokuMap.h
//  sudoku
//
//  Created by Raymond on 9/24/12.
//
//

#import <Foundation/Foundation.h>

#define MAXMAPSIZE  9
#define SIZE_9      9
#define SIZE_6      6

@interface SudokuMap : NSObject
{
    NSInteger   size;                   // 4,5,6,7,8,9
    NSInteger	map[MAXMAPSIZE][MAXMAPSIZE];
}

@property NSInteger     size;

- (SudokuMap*) initWithSize:(NSInteger)size;
- (NSInteger*) getMap;
- (NSInteger) getMapNum:(NSInteger)x y:(NSInteger)y;
- (BOOL) isSameMap:(NSInteger)x y:(NSInteger)y x2:(NSInteger)x2 y2:(NSInteger)y2;


@end
