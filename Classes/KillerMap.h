//
//  KillerMap.h
//  sudokuall
//
//  Created by Raymond on 10/23/12.
//
//

#import <Foundation/Foundation.h>
#import "SudokuMap.h"

enum CAGE_SIGN {
	CS_PLUS = 0,
	CS_MINUS,
	CS_MULTIPLE,
	CS_DIVIDE
};

typedef enum CAGE_SIGN CAGE_SIGN;

typedef struct KillerCage
{
	NSInteger x0;	// 합계를 표시할 위치
	NSInteger y0;
	NSInteger sum;	// + - x / result
	CAGE_SIGN sign;	// 0+ 1- 2x 3/
} KillerCage;


@interface KillerMap : NSObject

{
    NSInteger   size;							// 6,9
    NSInteger	map[MAXMAPSIZE][MAXMAPSIZE];
    NSInteger	color[MAXMAPSIZE][MAXMAPSIZE];	// 0~6
	KillerCage	cage[MAXMAPSIZE*MAXMAPSIZE/2];
	
	BOOL		tempColor[7];
}

@property NSInteger     size;

- (id) initWithMap:(KillerMap*)source;
- (id) initWithSize:(NSInteger)sizeMap;
- (NSInteger) getCageNumber:(NSInteger)x yPos:(NSInteger)y;	// from map
- (NSInteger) getColor:(NSInteger)x yPos:(NSInteger)y;		// from color
- (NSInteger) getCageCount;
- (NSInteger*) getMapArray;
- (NSInteger*) getColorArray;
- (KillerCage*) getCageArray;				
- (KillerCage*) getCageData:(NSInteger)num;				// from cell
- (void) saveData;
- (id) initWithSaveData;
+ (void) getNumsPipe:(char*)str	size:(NSInteger)size nums:(NSInteger*)nums;
+ (void) setNumsPipe:(NSString *)str	size:(NSInteger)size nums:(NSInteger*)nums;
+ (NSString*) getSign:(CAGE_SIGN)cs;
+ (void) setNumsPipeSize:(NSString *)str	size:(NSInteger)size nums:(NSInteger*)nums;
+ (void) getNumsPipe:(char*)str	size:(NSInteger)size nums:(NSInteger*)nums;


@end
