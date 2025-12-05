import Core
#if canImport(CryptoKit)
import CryptoKit
#elseif canImport(Crypto)
import Crypto
#endif
import Foundation

private func findHashMatch(content: String, _ check: ([UnsafeRawBufferPointer.Element]) -> Bool) -> Int {
    var i = 0
    while true {
        let candidateString = "\(content)\(i)".utf8
        let hash = Insecure.MD5.hash(data: Data(candidateString))
        let bytes = hash.withUnsafeBytes { Array($0) }
        if check(bytes) {
            return i
        }
        if i % 500000 == 0 {
            print(i)
        }
        i += 1
    }
}

@main
struct Main {
    static func main() {
        // let file = getSourceFileSibling(#filePath, "Files/example.txt")
        let file = getSourceFileSibling(#filePath, "Files/input.txt")
        let content = try! readEntireFile(file)

        let part1 = findHashMatch(content: content) { bytes in
            // First 5 hex must be 0
            return bytes[0] == 0 && bytes[1] == 0 && bytes[2] >> 4 == 0
        }
        print(part1)

        let part2 = findHashMatch(content: content) { bytes in
            // First 6 hex must be 0
            return bytes[0] == 0 && bytes[1] == 0 && bytes[2] == 0
        }
        print(part2)
    }
}
