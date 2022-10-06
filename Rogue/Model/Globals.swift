import Foundation

enum GlobalState {
    case Move, Target, Inspect, Shop, Inventory, StashTab1, StashTab2, Info, Equipment, Ring, Pickup, Ground, Warp, Heal, Waypoint, Chest, Cancel, End
}

enum FlashState {
    case None, Red, Green, Blue, White
}

enum ButtonType {
    case Left, Right, Up, Down, Home, End, PgUp, PgDn, Wait, Action1, Action2, Action3, Action4, Action5, Action6
}

enum ItemTag: Codable {
    case Ranged, Melee, Equip, Flash, Home, Ammo, Flask, Waypoint, Keystone, LifeOrb, GoldCache, Misc
}

enum EquipType: Codable {
    case Empty, Chest, Head, Gloves, Legs, Ring
}

enum RingType {
    case Left, Right
}

enum ItemGenerationMode {
    case Chest, Monster
}

enum DamageType {
    case Ranged, Melee, Thorns
}

enum ConnectMode {
    case Highlight, Attack, Clear, Move, Path
}

let WALL = "\u{2593}"
let PASS = "\u{2e}"
let SPACE = "\u{20}"
let DOOR = "\u{2b}"
let CORPSE = "\u{25}"
let CHEST = "\u{2583}"
let CLIP = "\u{21}"
let WAYPOINT = "\u{5e}"
let VENDOR = "\u{24}"
let STASH = "\u{2584}"
let STONE = "\u{2a}"
let GATE = "\u{27}"

let STATE_FILENAME = "RogueState"
let EMPTY_LINE = String(repeating: SPACE, count: 40)
let FLASH_DELAY = 0.1
