import Core
import Foundation
import RegexBuilder

struct Box {
    let l: Int
    let w: Int
    let h: Int
}

private func paperNeededForBox(_ box: Box) -> Int {
    let lwArea = box.l * box.w
    let whArea = box.w * box.h
    let hlArea = box.h * box.l
    let minArea = [lwArea, whArea, hlArea].min()!
    return 2 * lwArea + 2 * whArea + 2 * hlArea + minArea
}

private func ribbonNeededForBox(_ box: Box) -> Int {
    let lwFacePerimeter = 2 * box.l + 2 * box.w
    let whFacePerimeter = 2 * box.w + 2 * box.h
    let hlFacePerimeter = 2 * box.h + 2 * box.l
    let minWrapLength = [lwFacePerimeter, whFacePerimeter, hlFacePerimeter].min()!
    let bowLength = box.l * box.w * box.h
    return minWrapLength + bowLength
}

@main
struct Main {
    static func main() {
        let content = try! readEntireFile(getSourceFileSibling(#filePath, "Files/input.txt"))
        // let content = try! readEntireFile(getSourceFileSibling(#filePath, "example.txt"))
        let regex = /(?<l>\d+)x(?<w>\d+)x(?<h>\d+)/
        let boxes = content.matches(of: regex).map { match in
            Box(l: Int(match.l)!, w: Int(match.w)!, h: Int(match.h)!)
        }
        let paperNeeded = boxes.reduce(into: 0){ (sum, box) in
            sum += paperNeededForBox(box)
        }
        print(paperNeeded)
        let ribbonNeeded = boxes.reduce(into: 0){ (sum, box) in
            sum += ribbonNeededForBox(box)
        }
        print(ribbonNeeded)
    }
}
