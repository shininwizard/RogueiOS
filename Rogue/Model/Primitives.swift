import Foundation

struct Tile: Hashable, Identifiable, Codable {
    private(set) var id = UUID()
    var ch: String = SPACE
    var isRevealed: Bool = false
    var isHighlighted: Bool = false
    var isMarked: Bool = false
    var isFrame: Bool = false
}

struct Room: Codable {
    let x1, y1, x2, y2: Int
    var isRevealed: Bool = false
}

struct Weapon: Codable {
    let name: String
    let minDamage, maxDamage: Int
    let tier: Int
    let description: String
}

struct Ammo {
    let name: String
    let weapon: String
    let quantity: Int
    let price: Int
}

struct Misc {
    let name: String
    let value: Int
}

struct Equip: Codable {
    let name: String
    let type: EquipType
    let armorValue: Int
    let tier: Int
    let description: String
}

struct Item: Codable {
    var x, y: Int
    let name: String
    var amount: Int
    let tag: ItemTag
    let price: Int
    var isMarked: Bool
    var isPointed: Bool
    let description: String
    var reference: Int = -1
}

struct Monster {
    let face: String
    let name: String
    let life: Int
    let armor: Int
    let weapon: String
    let tier: Int
    let description: String
}

struct Actor: Codable {
    private(set) var blindDuration: Int = 3
    private(set) var paralyzeDuration: Int = 3
    private(set) var armorMitigation: Int = 10

    var x: Int = 0, y: Int = 0, dX: Int = 0, dY: Int = 0
    var face: String = ""
    var name: String = ""
    var lifeCurrent: Int = 0, lifeBefore: Int = 0
    var armor: Int = 0
    var ranged: Weapon = Weapon(name: "", minDamage: 0, maxDamage: 0, tier: 0, description: "")
    var melee: Weapon = Weapon(name: "", minDamage: 0, maxDamage: 0, tier: 0, description: "")
    var head: Equip = Equip(name: "", type: EquipType.Head, armorValue: 0, tier: 0, description: "")
    var chest: Equip = Equip(name: "", type: EquipType.Chest, armorValue: 0, tier: 0, description: "")
    var gloves: Equip = Equip(name: "", type: EquipType.Gloves, armorValue: 0, tier: 0, description: "")
    var legs: Equip = Equip(name: "", type: EquipType.Legs, armorValue: 0, tier: 0, description: "")
    var rings: [Equip] = []
    var inventory: [Item] = [], stash: [Item] = []
    var gold: Int = 0, ammo: Int = 0
    var blindTimer: Int = 0, paralyzeTimer: Int = 0
    var cell: String = ""
    var isAlive: Bool = false
    var isPursuit: Bool = false
}

struct SaveData: Codable {
    let depth: Int
    let progression: Int
    let medpackCharge: Int
    let warpCounter: Int
    let hero: Actor
    let map: [[Tile]]
    let rooms: [Room]
    let items: [Item]
    let monsters: [Actor]
}
