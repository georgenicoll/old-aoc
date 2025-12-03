import Foundation

enum FileError: Error {
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

@main
struct Day1 {
    static func main() {
        let content = try! readEntireFile(getSourceFileSibling(#filePath, "input.txt"))
        var floor = 0
        var basementIndex = 0
        for (i, c) in content.enumerated() {
            if c == "(" {
                floor += 1
            }
            if c == ")" {
                floor -= 1
            }
            if basementIndex == 0 && floor == -1 {
                basementIndex = i + 1
            }
        }
        print(floor)
        print(basementIndex)
    }
}
