#!/bin/sh

xcodebuild  -project ../sudokuall.xcodeproj  -scheme "sudoku6free" archive
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "sudoku6paid" archive
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "sudoku9free" archive
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "sudoku9paid" archive
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "gtsudoku6free" archive
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "gtsudoku6paid" archive
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "gtsudoku9free" archive
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "gtsudoku9paid" archive

