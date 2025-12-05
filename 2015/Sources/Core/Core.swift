import Foundation

public enum FileError: Error {
    case fileNotFound
}

public func getSourceFileSibling(_ sourceFilePath: StaticString, _ fileName: String) -> String {
    let directory = URL(fileURLWithPath: String(describing: sourceFilePath))
        .deletingLastPathComponent()
    let file = directory.appendingPathComponent(fileName)
    return file.path
}

public func readEntireFile(_ path: String) throws -> String {
    guard let fileHandle = FileHandle(forReadingAtPath: path) else {
        throw FileError.fileNotFound
    }
    defer {
        fileHandle.closeFile()
    }
    let data = fileHandle.readDataToEndOfFile()
    return String(data: data, encoding: .utf8)!
}
