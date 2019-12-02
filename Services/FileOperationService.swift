//
//  FileOperationService.swift
//  servT
//
//  Created by Nikolas Omelianov on 30.11.2019.
//  Copyright © 2019 Nikolas Omelianov. All rights reserved.
//

import Foundation

class FileOperationService {
    
    enum Directory {
        case documents
        case tmp
        
        var filePath: URL? {
            switch self {
            case .documents:
                return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
            case .tmp:
                return URL(fileURLWithPath: "/tmp/")
            }
        }
    }
    
    func writeToFile(text: String, name: String, directory: Directory) -> URL? {
        var result: URL?
        guard let fileURL = directory.filePath?.appendingPathComponent(name) else { return result }
        try? text.write(to: fileURL, atomically: false, encoding: .utf8)
        result = fileURL

        return result
    }
    
    func removeFile(path: URL) {
        try? FileManager.default.removeItem(at: path)
    }
    
    func runBashScript(with argument: String){
        let path = "/bin/bash"
        let arguments = [argument]
        let task = Process.launchedProcess(launchPath: path, arguments: arguments)
        task.waitUntilExit()
    }
}

