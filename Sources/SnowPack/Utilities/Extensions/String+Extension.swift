import Foundation

public extension String {
    func trimmingLeadingAndTrailingSpaces(using characterSet: CharacterSet = .whitespacesAndNewlines) -> String {
        return trimmingCharacters(in: characterSet)
    }

    func deletingPrefix(_ prefix: String) -> String {
        guard self.hasPrefix(prefix) else { return self }
        return String(self.dropFirst(prefix.count))
    }
    
    func removingNonStandardCharacters() -> String {
        let acceptableCharacters: Set<Character> =
        Set("abcdefghijklmnopqrstuvwxyz ABCDEFGHIJKLKMNOPQRSTUVWXYZ1234567890+-*=(),.:!_1234567890")
        return String(filter {acceptableCharacters.contains($0) })
    }
    
    func removingNonNumberCharacters() -> String {
        let acceptableCharacters: CharacterSet = .decimalDigits
        return String(self.unicodeScalars.filter({ acceptableCharacters.contains($0) })) //this bs b y i h8 CharacterSet
    }
    
    func removing(characters: Character...) -> String {
        let unacceptableCharacters = Set<Character>(characters)
        return String(filter { !unacceptableCharacters.contains($0) })
    }
    
    func levenshteinDistanceTo(_ str2: String) -> Int {
        let str1 = self
        let str1Length = str1.count
        let str2Length = str2.count
        
        if str1Length == 0 {
            return str2Length
        }
        
        if str2Length == 0 {
            return str1Length
        }
        
        var distanceMatrix = Array(repeating: Array(repeating: 0, count: str2Length + 1), count: str1Length + 1)
        
        for i in 0...str1Length {
            distanceMatrix[i][0] = i
        }
        
        for j in 0...str2Length {
            distanceMatrix[0][j] = j
        }
        
        let str1Array = Array(str1)
        let str2Array = Array(str2)
        
        for i in 1...str1Length {
            for j in 1...str2Length {
                let cost = str1Array[i - 1] == str2Array[j - 1] ? 0 : 1
                distanceMatrix[i][j] = Swift.min(
                    distanceMatrix[i - 1][j] + 1,
                    distanceMatrix[i][j - 1] + 1,
                    distanceMatrix[i - 1][j - 1] + cost
                )
            }
        }
        
        return distanceMatrix[str1Length][str2Length]
    }
    
    static func friendlyBigNumber(from number: Double) -> String {
        let thousands = number/1000
        let millions = number/1000000
        if number >= 1000 && number < 1000000{
            return("\(Int(floor(thousands)))k")
        } else if number > 1000000{
            return ("\(Int(floor(millions)))M")
        } else{
            return ("\(Int(number))")
        }
    }
    
    static func randomUsername() -> String {
        randomString(length: 16)
    }
    
    static func randomString(length: Int) -> String {
      let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
      return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func widthOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.width
    }

    func heightOfString(usingFont font: UIFont) -> CGFloat {
        let fontAttributes = [NSAttributedString.Key.font: font]
        let size = self.size(withAttributes: fontAttributes)
        return size.height
    }

    func sizeOfString(usingFont font: UIFont) -> CGSize {
        let fontAttributes = [NSAttributedString.Key.font: font]
        return self.size(withAttributes: fontAttributes)
    }
}
