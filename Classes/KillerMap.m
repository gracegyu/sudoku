//
//  KillerMap.m
//  sudokuall
//
//  Created by Raymond on 10/23/12.
//
//

#import "KillerMap.h"
#import "LogItem.h"
#import "Constants.h"


#define kKillerMap		@"killermap2"


@implementation KillerMap

@synthesize size;
/*
- (void)dealloc {
	[super dealloc];    // Crash (SDSDKNINEF-11102)
                        // 4   SUDOKU9Free  0x00136ad5 -[KillerMap dealloc] (KillerMap.m:23)
}
*/
- (id) initWithMap:(KillerMap*)source
{
	if (!(self = [super init]))
		return nil;
	
	size = source.size;
	memcpy(map,		[source getMapArray],	sizeof(map));
	memcpy(color,	[source getColorArray], sizeof(color));
	memcpy(cage,	[source getCageArray],	sizeof(cage));
	
	return self;
}

- (id) initWithSize:(NSInteger)sizeMap randomFill:(BOOL)randomFill
{
	if (!(self = [super init]))
		return nil;

	
    DAssert(sizeMap <= SIZE_9 && sizeMap >= SIZE_6, @"sizeMap=%ld", (long)sizeMap);
    
	size = sizeMap;
    if (size > MAXMAPSIZE)
        return nil;
	
	memset(map, -1, sizeof(map));
	memset(color, -1, sizeof(color));
	memset(cage, -1, sizeof(cage));
	NSInteger num=0;
    
    if (randomFill) {
        while ([self FillRandomMap:num] == YES)
        {
            num++;
        }
    }
	cage[num].x0 = -1;
	cage[num].y0 = -1;
//	[self printMap];
	
	return self;
}


- (void) printMap
{
#ifdef DEBUG
	for (int y=0; y<size; y++)
	{
		if (y%GRIDY == 0)
		{
			LogIt(@"----------------------------  -------------------\n");
		}
		for (int x=0; x<size; x++)
		{
			if (x%GRIDX==0)
			{
				LogIt(@"|");
			} else {
				LogIt(@" ");
			}

			if (map[x][y] < 0)
			{
				LogIt(@" .");
			} else {
				LogIt(@"%.2d", map[x][y]);
			}
		}
		LogIt(@"|  ");
		
		for (int x=0; x<size; x++)
		{
			if (x%GRIDX==0)
			{
				LogIt(@"|");
			} else {
				LogIt(@" ");
			}
			
			if (color[x][y] < 0)
			{
				LogIt(@".");
			} else {
				LogIt(@"%d", color[x][y]);
			}
		}
		LogIt(@"|");

		LogIt(@"\n");
	}
	LogIt(@"---------------------------  -------------------\n");
	
	int num = 0;
	if (cage[0].sum < 0)
	{
		DLog(@"cage[0].sum = %ld", (long)cage[0].sum);
	}
	while (cage[num].x0 >= 0 && cage[num].y0 >= 0)
	{
		LogIt(@"(#%d:%d,%d=%d) ", num, cage[num].x0, cage[num].y0, cage[num].sum);
		num++;
	}
	LogIt(@"\n");
#endif
	
}

#define POSS_2  66
#define POSS_3  95



- (NSInteger) GetRandomBlockSize
{
	NSInteger Rand = ((unsigned int)arc4random()) % 100;
	
	if (Rand < POSS_2)
		return 2;
	if (Rand < POSS_3)
		return 3;
	return 4;
}

- (BOOL) FillRandomMap:(NSInteger) num
{
	NSInteger xPos = -1, yPos = -1;
	int i;
	
	for (i = 0; i < size*size; i++)
	{
		if (map[i%size][i/size] == -1)	// 첫번쨰 빈칸 발견
		{
			xPos = i%size;	
			yPos = i/size;
			break;
		}
	}
	if (i == size*size)
		return NO;	// finished
	
	
	NSInteger sizeBlock = [self GetRandomBlockSize];	// 2~4
	memset(tempColor, 0, sizeof(tempColor));
	
	cage[num].x0 = xPos;
	cage[num].y0 = yPos;
	cage[num].sign = CS_PLUS;
	
	
	//DLog(@"sizeBlock=%d", sizeBlock);
	
	for (i = 0; i<sizeBlock; i++)
	{
		map[xPos][yPos] = num;
		//DLog(@"Set(%d,%d)->%d", xPos, yPos, num);
		[self FindNeighborColor:xPos yPos:yPos];
		
		if (![self findNeighborPosition:&xPos pY:&yPos])
		{
			break; // 갖힌 셀
		}
	}
	
	[self SetCageColor:num];
	
	
	return YES;
}

- (void) FindNeighborColor:(NSInteger)xPos yPos:(NSInteger)yPos
{
	if (xPos - 1 >= 0 && color[xPos-1][yPos] >= 0)
	{
		//DLog(@"FindNeighborColor(%d,%d)-%d", xPos-1, yPos, color[xPos-1][yPos]);
		tempColor[color[xPos-1][yPos]] = YES;
	}
	if (xPos + 1 < size && color[xPos+1][yPos] >= 0)
	{
		//DLog(@"FindNeighborColor(%d,%d)-%d", xPos+1, yPos, color[xPos+1][yPos]);
		tempColor[color[xPos+1][yPos]] = YES;
	}
	if (yPos - 1 >= 0 && color[xPos][yPos-1] >= 0)
	{
		//DLog(@"FindNeighborColor(%d,%d)-%d", xPos, yPos-1, color[xPos][yPos-1]);
		tempColor[color[xPos][yPos-1]] = YES;
	}
	if (yPos + 1 < size && color[xPos][yPos+1] >= 0)
	{
		//DLog(@"FindNeighborColor(%d,%d)-%d", xPos, yPos+1, color[xPos][yPos+1]);
		tempColor[color[xPos][yPos+1]] = YES;
	}	
}


- (BOOL) findNeighborPosition:(NSInteger*)pX pY:(NSInteger*)pY
{
	NSInteger countNum = 0;
	sXY	xy[4];
	
	if (*pX - 1 >= 0 && map[*pX-1][*pY] == -1)
	{
		xy[countNum].x = *pX-1;
		xy[countNum].y = *pY;
		countNum++;
	}
	if (*pX + 1 < size && map[*pX+1][*pY] == -1)
	{
		xy[countNum].x = *pX+1;
		xy[countNum].y = *pY;
		countNum++;
	}
	if (*pY - 1 >= 0 && map[*pX][*pY-1] == -1)
	{
		xy[countNum].x = *pX;
		xy[countNum].y = *pY-1;
		countNum++;
	}
	if (*pY + 1 < size && map[*pX][*pY+1] == -1)
	{
		xy[countNum].x = *pX;
		xy[countNum].y = *pY+1;
		countNum++;
	}
	
	if (countNum == 0)
	{
		//DLog(@"countNum == 0");
		return NO; // 막힌 셀
	}
	NSInteger numRand = (((unsigned int)arc4random()) % countNum);
	
	*pX = xy[numRand].x;
	*pY = xy[numRand].y;

	return YES;	
}

- (void) SetCageColor:(NSInteger)num
{
	NSInteger countNeighborColor=0;
	NSInteger countAvailColor=0;
	NSInteger nowColor=-1;
	
	for (int i=0; i<sizeof(tempColor); i++)
	{
		if (tempColor[i] == YES)
		{
			countNeighborColor++;
		}
	}
	
	countAvailColor = sizeof(tempColor)-1 - countNeighborColor;

	if (countAvailColor <= 0)
	{
		//DLog(@"###########");
		//DAssert(countAvailColor>0, @"##########");
		nowColor = 6;
	} else {
		
		NSInteger numRand = (((unsigned int)arc4random()) % countAvailColor);
		
		for (int i=0; i<sizeof(tempColor); i++)
		{
			if (tempColor[i] == NO)
			{
				if (numRand == 0)
				{
					nowColor = i;
					break;
				} else {
					numRand--;
				}
			}
		}
	}
	
	DAssert(nowColor >= 0, @"##########");
	
	for (int y=0; y<size; y++)
	{
		for (int x=0; x<size; x++)
		{
			if (map[x][y] == num)
			{
				color[x][y] = nowColor;
			}
		}
	}
}

- (NSInteger) getCageNumber:(NSInteger)x yPos:(NSInteger)y
{
	return map[x][y];
}	// from map

// 해당 Cell이 몇칸으로 구성된 Cell인가?
- (NSInteger) getCageNumberCount:(NSInteger)x yPos:(NSInteger)y
{
    NSInteger num = map[x][y];
    NSInteger count = 0;

    for (int y=0; y<size; y++)
    {
        for (int x=0; x<size; x++)
        {
            if (map[x][y] == num)
            {
                count++;
            }
        }
    }
    return count;
    
}



- (NSInteger) getColor:(NSInteger)x yPos:(NSInteger)y
{
	return color[x][y];
}	// from color

- (KillerCage*) getCageData:(NSInteger)num
{
	return cage[num].x0 >= 0 && cage[num].y0 >= 0 ? &(cage[num]) : NULL;
}	// from cell


- (NSInteger) getCageCount
{
	int num = 0;
	while (cage[num].x0 >= 0 && cage[num].y0 >= 0)
	{
		num++;
	}
	return num;
}





- (void) saveData
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    BOOL bRet;
	char zStrMap[MAXMAPSIZE*MAXMAPSIZE*4 * 20] = "";     // for safe
	char zStrColor[MAXMAPSIZE*MAXMAPSIZE*4 * 20] = "";   // for safe
	char zStrCage[MAXMAPSIZE*MAXMAPSIZE*4 * 20] = "";    // for safe
	
    DLog(@"[self getCageCount]=%ld", (long)[self getCageCount]);
	DAssert([self getCageCount] > 10, @"[self getCageCount]=%ld", (long)[self getCageCount]);
	
    DLog(@"sizeof(KillerCage) = %ld", sizeof(KillerCage));
    DLog(@"sizeof(NSInteger) = %ld", sizeof(NSInteger));
    
    
	[KillerMap getNumsPipeSize:zStrMap		size:MAXMAPSIZE*MAXMAPSIZE	nums:&map[0][0]];
	[KillerMap getNumsPipeSize:zStrColor	size:MAXMAPSIZE*MAXMAPSIZE	nums:&color[0][0]];
	bRet = [KillerMap getNumsPipe:zStrCage		size:[self getCageCount]*sizeof(KillerCage)/sizeof(NSInteger)
										nums:(NSInteger*)&cage[0]];
    if (bRet == NO)
        return; // data error
	//DLog(@"zStrCage(%s)", zStrCage);
	
//	DAssert(strlen(zStrMap) >= MAXMAPSIZE*MAXMAPSIZE*2-1, @"strlen(zStrMap)=%zd", strlen(zStrMap));
//	DAssert(strlen(zStrColor) >= MAXMAPSIZE*MAXMAPSIZE*2-1, @"strlen(zStrColor)=%zd", strlen(zStrColor));
//	DAssert(strlen(zStrCage) >= [self getCageCount]*3*2, @"strlen(zStrCage)=%zd", strlen(zStrCage));
	
	NSString *str = [NSString stringWithFormat:
					 @"%ld,%s,%s,%s",
					 (long)size,
					 zStrMap,
					 zStrColor,
					 zStrCage];
	
	DLog(@"saveData KillerMap(%@)", str);
	//[self printMap];
	
	[defaults setObject:str forKey:kKillerMap];
    [defaults synchronize];
}

- (id) initWithSaveData
{
	if (!(self = [super init]))
		return nil;

	
	memset(map, -1, sizeof(map));
	memset(color, -1, sizeof(color));
	memset(cage, -1, sizeof(cage));
	
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	NSString *str = (NSString*)[defaults stringForKey:kKillerMap];
	if (str == nil) {
		DLog(@"loadData Failed");
		return nil;
	}
	//DLog(@"initWithSaveData KillerMap(%@)", str);
	
	NSArray *listItems = [str componentsSeparatedByString:@","];

	size = [[listItems objectAtIndex:0] integerValue];
	[KillerMap setNumsPipeSize:[listItems objectAtIndex:1] size:MAXMAPSIZE*MAXMAPSIZE	nums:&map[0][0]];
	[KillerMap setNumsPipeSize:[listItems objectAtIndex:2] size:MAXMAPSIZE*MAXMAPSIZE	nums:&color[0][0]];
	[KillerMap setNumsPipe:[listItems objectAtIndex:3] size:MAXMAPSIZE*MAXMAPSIZE/2*sizeof(KillerCage)	nums:(NSInteger*)&cage[0]];

    // load 된 데이터가 잘못 된 경우
    if ([self getCageCount] < 10)
    {
        DLog(@"loadData Failed");
        return nil;
    }
    
    
	//[self printMap];

	return self;
}

// size만큼 무조건 세팅
+ (void) getNumsPipeSize:(char*)str	size:(NSInteger)size nums:(NSInteger*)nums
{
	NSInteger num;
	
    for (int i=0; i<size; i++)
    {
		num = nums[i];
		if (num < 0)
		{
			*str++ = '-';
			num = -num;
		}
		if (num >= 10)
			*str++ = ('0' + num/10);
		*str++ = ('0' + num%10);
		if (i+1 < size)
			*str++ = '|';
    }
    
    
	*str = '\0';
}

// size만큼 무조건 세팅
+ (void) setNumsPipeSize:(NSString *)str	size:(NSInteger)size nums:(NSInteger*)nums
{
	NSArray *listItems = [str componentsSeparatedByString:@"|"];
	
	for (int i=0; i<size && i<listItems.count; i++)		// 호환을 위해서 사용하지 않는 메모도 저장하고 가져온다.
	{
		nums[i] = [[listItems objectAtIndex:i] integerValue];
	}
}



+ (BOOL) getNumsPipe:(char*)str	size:(NSInteger)size nums:(NSInteger*)nums
{
   
	for (int i=0; i<size; i++)
    {
		if (nums[i] < 0)
		{
			if (i>0)
				*(str-1) = '\0';
			break;
		}
		sprintf(str, "%ld", (long)nums[i]);
		str += strlen(str);                     // Crash
		if (i+1 < size)
			*str++ = '|';
    }
    
	*str = '\0';
    return YES;
}

+ (void) setNumsPipe:(NSString *)str	size:(NSInteger)size nums:(NSInteger*)nums
{
	NSArray *listItems = [str componentsSeparatedByString:@"|"];
	
	for (int i=0; i<size && i<listItems.count; i++)		// 호환을 위해서 사용하지 않는 메모도 저장하고 가져온다.
	{
		nums[i] = [[listItems objectAtIndex:i] integerValue];
	}
}

- (NSInteger*) getMapArray
{
	return (NSInteger*) map;
}
- (NSInteger*) getColorArray
{
	return (NSInteger*) color;
}
- (KillerCage*) getCageArray
{
	return (KillerCage*) cage;
}

+ (NSString*) getSign:(CAGE_SIGN)cs
{
	static NSString* arraySign[4] = {
		@"+",       //@"\uFF0B",
		@"\uFF0D",  //@"-",   //
		@"\u00D7",
		@"÷"
	};
	
	//DAssert(cs >= 0 && cs < 4, @"getSign should be 0 <= cs < 4");
	
	return arraySign[cs];
	
}

@end
