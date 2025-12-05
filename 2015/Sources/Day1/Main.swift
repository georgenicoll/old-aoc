import Core
import Foundation

@main
struct Day1 {
    static func main() {
        let content = try! readEntireFile(getSourceFileSibling(#filePath, "Files/input.txt"))
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
