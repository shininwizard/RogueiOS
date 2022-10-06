import Foundation

class HeroController: ObservableObject {
    let orbOfLifeValue: Int = 30
    let goldCacheValue: Int = 50
    let inventoryCapacity: Int = 12
    
    private var progression: Int = 1
    
    let medpackCapacity: Int = 200
    let medpackHealAmount: Int = 100
    private var medpackCharge: Int = 200
    
    let warpDelay: Int = 300
    @Published private var warpCounter: Int = 300
    
    @Published private var winCondition: Bool = false

    @Published var actor: Actor = Actor()
    
    public func getWinCondition() -> Bool {
        return winCondition
    }
    
    public func setWinCondition(state: Bool) {
        winCondition = state
    }
    
    public func getWarpCounter() -> Int {
        return warpCounter
    }
    
    public func setWarpCounter(value: Int) {
        warpCounter = value
    }
    
    public func getMedpackCharge() -> Int {
        return medpackCharge
    }
    
    public func setMedpackCharge(value: Int) {
        medpackCharge = value
    }
    
    public func getProgression() -> Int {
        return progression
    }
    
    public func setProgression(value: Int) {
        progression = value
    }
    
    public func isBlind() -> Bool {
        return actor.blindTimer < actor.blindDuration
    }

    public func isBlindImmune() -> Bool {
        for r in actor.rings {
            if r.name == "Redeye Ring" {
                return true
            }
        }
        
        return false
    }

    public func isParalyzed() -> Bool {
        return actor.paralyzeTimer < actor.paralyzeDuration
    }
    
    public func isParalyzeImmune() -> Bool {
        for r in actor.rings {
            if r.name == "Silver Ring" {
                return true
            }
        }
        
        return false
    }
    
    public func canWarp() -> Bool {
        return warpCounter >= warpDelay
    }
    
    public func isRingOfSacrificeEquipped(state: StateController) -> Bool {
        for r in 0..<actor.rings.count {
            if actor.rings[r].name == "Ring of Sacrifice" {
                actor.lifeCurrent = actor.lifeBefore
                state.addMessage(message: "You die...")
                state.addMessage(message: "Revive! Ring of Sacrifice shatters.")
                actor.rings.remove(at: r)
                return true
            }
        }
        
        return false
    }
}
