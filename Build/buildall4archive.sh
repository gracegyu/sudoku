#!/bin/sh

xcodebuild  -project ../sudokuall.xcodeproj  -scheme "sudoku6free" clean archive
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "sudoku6paid" clean archive
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "sudoku9free" clean archive
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "sudoku9paid" clean archive

xcodebuild  -project ../sudokuall.xcodeproj  -scheme "calcudoku6free" clean archive
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "calcudoku6paid" clean archive
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "calcudoku9free" clean archive
xcodebuild  -project ../sudokuall.xcodeproj  -scheme "calcudoku9paid" clean archive

