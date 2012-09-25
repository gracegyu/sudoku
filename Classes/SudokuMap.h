//
//  SudokuMap.h
//  sudoku
//
//  Created by Raymond on 9/24/12.
//
//

#import <Foundation/Foundation.h>

#define MAXMAPSIZE  9

@interface SudokuMap : NSObject
{
    NSInteger   size;                   // 4,5,6,7,8,9
    NSInteger	map[MAXMAPSIZE][MAXMAPSIZE];
}

@property NSInteger     size;

- (SudokuMap*) initWithSize:(NSInteger)size;
- (NSInteger*) getMap;
- (NSInteger) getMapNum:(NSInteger)x y:(NSInteger)y;


@end
