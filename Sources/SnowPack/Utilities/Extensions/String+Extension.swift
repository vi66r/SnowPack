import Foundation

extension String {
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
}
