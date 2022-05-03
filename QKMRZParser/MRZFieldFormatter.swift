//
//  MRZFieldFormatter.swift
//  QKMRZParser
//
//  Created by Matej Dorcak on 14/10/2018.
//

import Foundation
import Algorithms

class MRZFieldFormatter {
    let ocrCorrection: Bool
    
    fileprivate let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(abbreviation: "GMT+0:00")
        return formatter
    }()
    
    init(ocrCorrection: Bool) {
        self.ocrCorrection = ocrCorrection
    }
    
    // MARK: Main
    func field(_ fieldType: MRZFieldType, from string: String, at startIndex: Int, length: Int, checkDigitFollows: Bool = false) -> MRZField {
        let endIndex = (startIndex + length)
        var rawValue = string.substring(startIndex, to: (endIndex - 1))
        var checkDigit = checkDigitFollows ? string.substring(endIndex, to: endIndex) : nil
        
        if ocrCorrection {
            rawValue = correct(rawValue, fieldType: fieldType, checkDigit: checkDigit)
            checkDigit = (checkDigit == nil) ? nil : correct(checkDigit!, fieldType: fieldType, checkDigit: checkDigit)
        }
        
        return MRZField(value: format(rawValue, as: fieldType), rawValue: rawValue, checkDigit: checkDigit)
    }
    
    func format(_ string: String, as fieldType: MRZFieldType) -> Any? {
        switch fieldType {
        case .names:
            return names(from: string)
        case .birthdate:
            return birthdate(from: string)
        case .sex:
            return sex(from: string)
        case .expiryDate:
            return expiryDate(from: string)
        case .documentType, .documentNumber, .countryCode, .nationality, .personalNumber, .optionalData, .hash:
            return text(from: string)
        }
    }
    
    func correct(_ string: String, fieldType: MRZFieldType, checkDigit: String?) -> String {
        switch fieldType {
        case .birthdate, .expiryDate, .hash: // TODO: Check correction of dates (month & day)
            return replaceLetters(in: string)
        case .names, .documentType, .countryCode, .nationality: // TODO: Check documentType, countryCode and nationality against possible (allowed) values
            return replaceDigits(in: string)
        case .sex: // TODO: Improve correction (take into account "M" & "<" too)
            return string.replace("P", with: "F")
        case .documentNumber:
            if let checkDigit = checkDigit {
                return replaceZerosAndOs(in: string, checkDigit: checkDigit)
            } else {
                return string
            }
        default:
            return string
        }
    }
    
    // MARK: Value Formatters
    private func names(from string: String) -> (primary: String, secondary: String) {
        let identifiers = string.trimmingFillers().components(separatedBy: "<<").map({ $0.replace("<", with: " ") })
        let secondaryID = identifiers.indices.contains(1) ? identifiers[1] : ""
        return (primary: identifiers[0], secondary: secondaryID)
    }
    
    private func sex(from string: String) -> String? {
        switch string {
        case "M": return "MALE"
        case "F": return "FEMALE"
        case "<": return "UNSPECIFIED" // X
        default: return nil
        }
    }
    
    private func birthdate(from string: String) -> Date? {
        guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)) else {
            return nil
        }

        let calendar = Calendar(identifier: .gregorian)
        let currentYear = calendar.component(.year, from: Date()) - 2000
        let parsedYear = Int(string.substring(0, to: 1))!
        let centennial = (parsedYear > currentYear) ? "19" : "20"
        
        return dateFormatter.date(from: centennial + string)
    }
    
    private func expiryDate(from string: String) -> Date? {
        guard CharacterSet.decimalDigits.isSuperset(of: CharacterSet(charactersIn: string)) else {
            return nil
        }
        
        let parsedYear = Int(string.substring(0, to: 1))!
        let centennial = (parsedYear >= 70) ? "19" : "20"
        
        return dateFormatter.date(from: centennial + string)
    }
    
    private func text(from string: String) -> String {
        return string.trimmingFillers().replace("<", with: " ")
    }
    
    // MARK: Utils
    private func replaceDigits(in string: String) -> String {
        return string
            .replace("0", with: "O")
            .replace("1", with: "I")
            .replace("2", with: "Z")
            .replace("8", with: "B")
    }
    
    private func replaceZerosAndOs(in string: String, checkDigit: String) -> String {
        if MRZField.isValueValid(string, checkDigit: checkDigit) {
            return string
        } else {
            var positions = [String.Index]()
            let characters = [Character("0"), Character("O")]
            
            for index in string.indices {
                if characters.contains(string[index]) {
                    positions.append(index)
                }
            }
            
            let pairs = product(positions, characters)
            let permutations = pairs.permutations(ofCount: positions.count)
            
            for permutation in permutations {
                var s = string
                
                permutation.forEach { (index, char) in
                    let starIndex = s.index(index, offsetBy: 0)
                    let endIndex = s.index(index, offsetBy: 1)
                    
                    s = s.replacingCharacters(in: starIndex..<endIndex, with: "\(char)")
                }
                
                if MRZField.isValueValid(s, checkDigit: checkDigit) {
                    return s
                }
            }
            
            return string
        }
    }
    
    private func replaceLetters(in string: String) -> String {
        return string
            .replace("O", with: "0")
            .replace("Q", with: "0")
            .replace("U", with: "0")
            .replace("D", with: "0")
            .replace("I", with: "1")
            .replace("Z", with: "2")
            .replace("B", with: "8")
    }
}
