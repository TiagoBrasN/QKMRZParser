import Foundation

extension Array {
    func permutations() -> [[Element]] {
        return permutations(ofCount: count)
    }
    
    func permutations(ofCount count: Int) -> [[Element]] {
        return permutations(count)
    }
    
    private func permutations(_ n: Int) -> [[Element]] {
        guard count > 0 else { return [] }
        
        var copy = self
        var perms = [[Element]]()
        
        func permutations(_ n: Int, _ a: inout Array<Element>) {
            if n == 1 {
                perms.append(a)
                return
            }
            
            for i in 0..<(n - 1) {
                permutations(n - 1, &a)
                a.swapAt(n - 1, (n % 2 == 1) ? 0 : i)
            }
            
            permutations(n - 1, &a)
        }
        
        permutations(n, &copy)
        
        return perms
    }
    
    func product<E>(with other: [E]) -> [(Element, E)] {
        var output = [(Element, E)]()
        
        for el1 in self {
            for el2 in other {
                output.append((el1, el2))
            }
        }
        
        return output
    }
}
