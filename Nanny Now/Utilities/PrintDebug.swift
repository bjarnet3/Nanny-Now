//
//  PrintDebug.swift
//  Nanny Now
//
//  Created by Bjarne Tvedten on 29.11.2017.
//  Copyright © 2017 Digital Mood. All rights reserved.
//

import Foundation
public var disablePrint = false

fileprivate var printCount = [String:Int]()
fileprivate var printCountTotal = 0

/// Logs the message to the console with extra information, e.g. file name, method name and line number
///
/// To make it work you must set the "DEBUG" symbol, set it in the "Swift Compiler - Custom Flags" section, "Other Swift Flags" line.
/// You add the DEBUG symbol with the -D DEBUG entry.
public func printDebug(object: Any, functionName: String = #function, fileName: String = #file, lineNumber: Int = #line) {
    // Have an issue? Please visit : https://github.com/InderKumarRathore/SwiftLog
    // and file a bug
    if !disablePrint {
        printCountTotal += 1
        #if DEBUG
        print("printDebug")
        let className = (fileName as NSString).lastPathComponent
        print("class: <\(className)>")
        print("func:  \(functionName) line: #\(lineNumber)")
        print("info:  \(object)\n")
        print("prints: \(printCountTotal)")
        #endif
    }
}

/// https://stackoverflow.com/questions/41974883/how-to-print-out-the-method-name-and-line-number-in-swift
public func printTrack(_ message: String, file: String = #file, function: String = #function, line: Int = #line ) {
    if !disablePrint {
        printCountTotal += 1
        let fileName = (file as NSString).lastPathComponent
        print("printTrack: \(message) called from \(function) \(fileName):\(line)")
    }
}

/// printLog
public func printLog(message: String, file: String = #function, function: String = #file, line: Int = #line, column: Int = #column) {
    if !disablePrint {
        printCountTotal += 1
        print("printLog: \(file) : \(function) : \(line) : \(column) - \(message)")
    }
}

/// printLine
public func printLine(_ any : Any? = nil, line: Int = #line) {
    if !disablePrint {
        printCountTotal += 1
        if let value = any {
            print("printLine: #\(line) \(value)")
        } else {
            print("printLine: #\(line)")
        }
    }
}

public func printFunc(_ any : Any? = nil, file: String = #file, function: String = #function, line: Int = #line) {
    if !disablePrint {
        printCountTotal += 1
        let fileName = (file as NSString).lastPathComponent
        
        let thisKey = "\(fileName)-\(line)"
        var thisValue = 1
        for (key,val) in printCount {
            if key == thisKey {
                thisValue += val
            }
        }
        printCount.updateValue(thisValue, forKey: thisKey)
        if let value = any {
            if thisValue == 1 {
                print("\(function) (\(thisValue)) - \(value) - \(fileName) #\(line)")
            } else {
                print("\(function) (\(thisValue)) - \(value)")
            }
        } else if thisValue == 1 {
            print("\(function) (\(thisValue)) - \(fileName) #\(line)")
        } else {
            print("\(function) (\(thisValue))")
        }
    }
}

public func printCount(_ any : Any? = nil, file: String = #file, function: String = #function, line: Int = #line) {
    if !disablePrint {
        printCountTotal += 1
        let fileName = (file as NSString).lastPathComponent
        let thisKey = "\(fileName)-\(line)"
        var thisValue = 1
        for (key,val) in printCount {
            if key == thisKey {
                thisValue += val
            }
        }
        printCount.updateValue(thisValue, forKey: thisKey)
        if let value = any {
            if thisValue == 1 {
                print("\(value) (\(thisValue)) - (\(function) \(fileName) #\(line)) total (\(printCountTotal))")
            } else {
                print("\(value) (\(thisValue)) total (\(printCountTotal))")
            }
        } else if thisValue == 1 {
            print("\(function) (\(thisValue)) - \(fileName) #\(line) total (\(printCountTotal))")
        } else {
            print("\(function) (\(thisValue)) total (\(printCountTotal))")
        }
    }
}

/// **println** is print with line **before** and **after** print ;-)
public func println(_ any : Any? = nil) {
    if !disablePrint {
        printCountTotal += 1
        print("-------- println --------")
        if let value = any {
            print("\(#line) \(value)")
        } else {
            print("\(#line)")
        }
        print("-------- println --------")
    }
}
