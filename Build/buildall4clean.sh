#!/bin/sh

xcodebuild  -project ../sudokuall.xcodeproj  -scheme "sudoku6free" clean 
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "sudoku6paid" clean 
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "sudoku7free" clean 
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "sudoku9free" clean 
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "sudoku9paid" clean 
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "gtsudoku6free" clean 
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "gtsudoku6paid" clean 
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "gtsudoku9free" clean 
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "gtsudoku9paid" clean 

