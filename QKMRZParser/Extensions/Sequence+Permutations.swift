import Foundation

extension Sequence {
    func permutations(takeN: Int) -> [[Element]] {
        func _perm(_ currentArray: [Element]) -> [[Element]] {
            guard currentArray.count < takeN else {
                return [currentArray]
            }
            
            return flatMap { _perm(currentArray + [$0]) }
        }
        
        return _perm([])
    }
}
