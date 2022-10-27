import Foundation

let EMPTY = "empty"

let RangedTypes: [Weapon] = [
    Weapon(name: EMPTY, minDamage: 0, maxDamage: 0, tier: 0, description: ""),
    Weapon(name: "short bow", minDamage: 8, maxDamage: 12, tier: 1, description: ""),
    Weapon(name: "reflex bow", minDamage: 9, maxDamage: 15, tier: 1, description: ""),
    Weapon(name: "composite bow", minDamage: 9, maxDamage: 17, tier: 3, description: ""),
    Weapon(name: "black bow", minDamage: 13, maxDamage: 21, tier: 4, description: ""),
    Weapon(name: "light crossbow", minDamage: 7, maxDamage: 17, tier: 2, description: ""),
    Weapon(name: "heavy crossbow", minDamage: 10, maxDamage: 20, tier: 4, description: ""),
    Weapon(name: "sniper crossbow", minDamage: 19, maxDamage: 21, tier: 5, description: ""),
    Weapon(name: "pistol", minDamage: 8, maxDamage: 14, tier: 1, description: ""),
    Weapon(name: "revolver", minDamage: 6, maxDamage: 20, tier: 2, description: ""),
    Weapon(name: "rifle", minDamage: 10, maxDamage: 18, tier: 4, description: ""),
    Weapon(name: "musket", minDamage: 12, maxDamage: 20, tier: 5, description: ""),
    Weapon(name: "double rifle", minDamage: 20, maxDamage: 24, tier: 5, description: ""),
    Weapon(name: "elephant gun", minDamage: 24, maxDamage: 30, tier: 6, description: ""),
    Weapon(name: "shotgun", minDamage: 23, maxDamage: 37, tier: 7, description: ""),
    Weapon(name: "Long Bow of the Dark", minDamage: 21, maxDamage: 35, tier: 10, description: "Chance to blind target"), //  10%
    Weapon(name: "Hand Cannon", minDamage: 50, maxDamage: 50, tier: 10, description: "It's heavy")
]

let AmmoTypes: [Ammo] = [
    Ammo(name: EMPTY, weapon: EMPTY, quantity: 0, price: 0),
    Ammo(name: "arrows", weapon: " bow", quantity: 10, price: 5),
    Ammo(name: "crossbow bolts", weapon: "crossbow", quantity: 8, price: 5),
    Ammo(name: "pistol bullets", weapon: "pistol", quantity: 12, price: 5),
    Ammo(name: "revolver bullets", weapon: "revolver", quantity: 10, price: 5),
    Ammo(name: "lead balls", weapon: "musket", quantity: 10, price: 6),
    Ammo(name: "rifle rounds", weapon: "rifle", quantity: 10, price: 7),
    Ammo(name: "big bullets", weapon: "elephant gun", quantity: 8, price: 10),
    Ammo(name: "shotgun shells", weapon: "shotgun", quantity: 8, price: 10),
    Ammo(name: "cannon balls", weapon: "Hand Cannon", quantity: 4, price: 20)
]

let MeleeTypes: [Weapon] = [
    Weapon(name: "fists", minDamage: 4, maxDamage: 6, tier: 0, description: ""),
    Weapon(name: "bandit knife", minDamage: 6, maxDamage: 8, tier: 1, description: ""),
    Weapon(name: "iron claw", minDamage: 5, maxDamage: 9, tier: 1, description: ""),
    Weapon(name: "beast claw", minDamage: 6, maxDamage: 10, tier: 1, description: ""),
    Weapon(name: "dagger", minDamage: 8, maxDamage: 10, tier: 1, description: ""),
    Weapon(name: "hunter axe", minDamage: 7, maxDamage: 11, tier: 1, description: ""),
    Weapon(name: "reinforced club", minDamage: 7, maxDamage: 13, tier: 2, description: ""),
    Weapon(name: "short sword", minDamage: 9, maxDamage: 11, tier: 2, description: ""),
    Weapon(name: "morning star", minDamage: 8, maxDamage: 12, tier: 3, description: ""),
    Weapon(name: "large club", minDamage: 8, maxDamage: 14, tier: 3, description: ""),
    Weapon(name: "notched whip", minDamage: 10, maxDamage: 14, tier: 3, description: ""),
    Weapon(name: "long sword", minDamage: 14, maxDamage: 16, tier: 3, description: ""),
    Weapon(name: "blacksmith hammer", minDamage: 13, maxDamage: 17, tier: 4, description: ""),
    Weapon(name: "bastard sword", minDamage: 16, maxDamage: 18, tier: 4, description: ""),
    Weapon(name: "moonlight sword", minDamage: 17, maxDamage: 19, tier: 4, description: ""),
    Weapon(name: "silver sword", minDamage: 15, maxDamage: 21, tier: 5, description: ""),
    Weapon(name: "battle axe", minDamage: 16, maxDamage: 20, tier: 5, description: ""),
    Weapon(name: "great mace", minDamage: 14, maxDamage: 22, tier: 5, description: ""),
    Weapon(name: "ghost blade", minDamage: 17, maxDamage: 21, tier: 5, description: ""),
    Weapon(name: "crystal sword", minDamage: 18, maxDamage: 22, tier: 6, description: ""),
    Weapon(name: "dark sword", minDamage: 17, maxDamage: 23, tier: 6, description: ""),
    Weapon(name: "claymore", minDamage: 19, maxDamage: 23, tier: 6, description: ""),
    Weapon(name: "holy blade", minDamage: 20, maxDamage: 26, tier: 7, description: ""),
    Weapon(name: "obsidian sword", minDamage: 21, maxDamage: 27, tier: 7, description: ""),
    Weapon(name: "chaos blade", minDamage: 20, maxDamage: 30, tier: 7, description: ""),
    Weapon(name: "Sword of the Abyss", minDamage: 30, maxDamage: 34, tier: 10, description: "Chance to warp enemy away"), // 15%
    Weapon(name: "Hammer of the Inferno", minDamage: 25, maxDamage: 35, tier: 10, description: "Chance of additional damage"), // 25% for additional 8-12 damage
    Weapon(name: "Scythe of the Gravelord", minDamage: 30, maxDamage: 40, tier: 10, description: "Chance to reduce enemy's life") // 20% chance to reduce enemy's life by 30%
]

let EquipTypes: [Equip] = [
    Equip(name: EMPTY, type: EquipType.Empty, armorValue: 0, tier: 0, description: ""),
    
    Equip(name: "sweaty clothes", type: EquipType.Chest, armorValue: 1, tier: 1, description: ""),
    Equip(name: "sorcerer cloak", type: EquipType.Chest, armorValue: 4, tier: 1, description: ""),
    Equip(name: "cloth robe", type: EquipType.Chest, armorValue: 5, tier: 1, description: ""),
    Equip(name: "noble dress", type: EquipType.Chest, armorValue: 6, tier: 1, description: ""),
    Equip(name: "wanderer coat", type: EquipType.Chest, armorValue: 7, tier: 1, description: ""),
    Equip(name: "graveguard robe", type: EquipType.Chest, armorValue: 8, tier: 1, description: ""),
    Equip(name: "witch cloak", type: EquipType.Chest, armorValue: 9, tier: 1, description: ""),
    Equip(name: "cleric robe", type: EquipType.Chest, armorValue: 10, tier: 2, description: ""),
    Equip(name: "crimson robe", type: EquipType.Chest, armorValue: 11, tier: 2, description: ""),
    Equip(name: "holy robe", type: EquipType.Chest, armorValue: 12, tier: 2, description: ""),
    Equip(name: "maiden dress", type: EquipType.Chest, armorValue: 13, tier: 3, description: ""),
    Equip(name: "mage coat", type: EquipType.Chest, armorValue: 14, tier: 3, description: ""),
    Equip(name: "thief robe", type: EquipType.Chest, armorValue: 15, tier: 3, description: ""),
    Equip(name: "hunter cloak", type: EquipType.Chest, armorValue: 16, tier: 3, description: ""),
    Equip(name: "moonlight robe", type: EquipType.Chest, armorValue: 17, tier: 4, description: ""),
    Equip(name: "long coat", type: EquipType.Chest, armorValue: 18, tier: 4, description: ""),
    Equip(name: "black cloak", type: EquipType.Chest, armorValue: 19, tier: 4, description: ""),
    Equip(name: "shadow garb", type: EquipType.Chest, armorValue: 20, tier: 4, description: ""),
    Equip(name: "leather armor", type: EquipType.Chest, armorValue: 21, tier: 4, description: ""),
    Equip(name: "chain armor", type: EquipType.Chest, armorValue: 22, tier: 5, description: ""),
    Equip(name: "iron armor", type: EquipType.Chest, armorValue: 23, tier: 5, description: ""),
    Equip(name: "steel armor", type: EquipType.Chest, armorValue: 24, tier: 5, description: ""),
    Equip(name: "knight armor", type: EquipType.Chest, armorValue: 25, tier: 6, description: ""),
    Equip(name: "silver armor", type: EquipType.Chest, armorValue: 26, tier: 6, description: ""),
    Equip(name: "paladin armor", type: EquipType.Chest, armorValue: 30, tier: 6, description: ""),
    Equip(name: "crystal armor", type: EquipType.Chest, armorValue: 35, tier: 7, description: ""),
    Equip(name: "dark armor", type: EquipType.Chest, armorValue: 45, tier: 7, description: ""),
    Equip(name: "bone armor", type: EquipType.Chest, armorValue: 50, tier: 7, description: ""),
    Equip(name: "Armor of the Glorious", type: EquipType.Chest, armorValue: 120, tier: 10, description: "Chance to paralyze enemy"), // 10%
    Equip(name: "Armor of the Sun", type: EquipType.Chest, armorValue: 200, tier: 10, description: "Chance to get blind on attack"), // 20%
    Equip(name: "Armor of Thorns", type: EquipType.Chest, armorValue: 75, tier: 10, description: "Enemy takes damage on attack"), // 10-12 damage
    
    Equip(name: "cloth hood", type: EquipType.Head, armorValue: 3, tier: 1, description: ""),
    Equip(name: "wanderer hood", type: EquipType.Head, armorValue: 4, tier: 1, description: ""),
    Equip(name: "witch hat", type: EquipType.Head, armorValue: 5, tier: 1, description: ""),
    Equip(name: "hunter hat", type: EquipType.Head, armorValue: 6, tier: 1, description: ""),
    Equip(name: "maiden hood", type: EquipType.Head, armorValue: 7, tier: 1, description: ""),
    Equip(name: "mage hat", type: EquipType.Head, armorValue: 8, tier: 1, description: ""),
    Equip(name: "sorcerer hat", type: EquipType.Head, armorValue: 9, tier: 1, description: ""),
    Equip(name: "black hood", type: EquipType.Head, armorValue: 10, tier: 2, description: ""),
    Equip(name: "priest hat", type: EquipType.Head, armorValue: 11, tier: 2, description: ""),
    Equip(name: "thief hood", type: EquipType.Head, armorValue: 12, tier: 2, description: ""),
    Equip(name: "madman hood", type: EquipType.Head, armorValue: 13, tier: 2, description: ""),
    Equip(name: "chain helm", type: EquipType.Head, armorValue: 14, tier: 3, description: ""),
    Equip(name: "iron helm", type: EquipType.Head, armorValue: 15, tier: 3, description: ""),
    Equip(name: "steel helm", type: EquipType.Head, armorValue: 16, tier: 3, description: ""),
    Equip(name: "cleric helm", type: EquipType.Head, armorValue: 17, tier: 4, description: ""),
    Equip(name: "knight helm", type: EquipType.Head, armorValue: 18, tier: 4, description: ""),
    Equip(name: "guardian helm", type: EquipType.Head, armorValue: 19, tier: 4, description: ""),
    Equip(name: "crystal helm", type: EquipType.Head, armorValue: 20, tier: 4, description: ""),
    Equip(name: "moonlight crown", type: EquipType.Head, armorValue: 21, tier: 4, description: ""),
    Equip(name: "royal helm", type: EquipType.Head, armorValue: 22, tier: 5, description: ""),
    Equip(name: "paladin helm", type: EquipType.Head, armorValue: 23, tier: 5, description: ""),
    Equip(name: "silver mask", type: EquipType.Head, armorValue: 24, tier: 5, description: ""),
    Equip(name: "dark mask", type: EquipType.Head, armorValue: 25, tier: 6, description: ""),
    Equip(name: "shadow mask", type: EquipType.Head, armorValue: 26, tier: 6, description: ""),
    Equip(name: "bone mask", type: EquipType.Head, armorValue: 27, tier: 7, description: ""),
    Equip(name: "Crown of Dusk", type: EquipType.Head, armorValue: 30, tier: 10, description: "Chance to blind enemy"), // 10%
    Equip(name: "Crown of the Sun", type: EquipType.Head, armorValue: 50, tier: 10, description: "Chance to miss an attack"), // 20%
    Equip(name: "Great Lord Crown", type: EquipType.Head, armorValue: 40, tier: 10, description: "Chance to double attack damage"), // 10%
    Equip(name: "Helm of Thorns", type: EquipType.Head, armorValue: 35, tier: 10, description: "Enemy takes damage on attack"), // 3-4 damage
    
    Equip(name: "wanderer gloves", type: EquipType.Gloves, armorValue: 3, tier: 1, description: ""),
    Equip(name: "surgical gloves", type: EquipType.Gloves, armorValue: 4, tier: 1, description: ""),
    Equip(name: "leather gloves", type: EquipType.Gloves, armorValue: 5, tier: 1, description: ""),
    Equip(name: "hunter gloves", type: EquipType.Gloves, armorValue: 6, tier: 1, description: ""),
    Equip(name: "thief gloves", type: EquipType.Gloves, armorValue: 7, tier: 1, description: ""),
    Equip(name: "cleric gauntlets", type: EquipType.Gloves, armorValue: 8, tier: 1, description: ""),
    Equip(name: "antiquated gloves", type: EquipType.Gloves, armorValue: 9, tier: 1, description: ""),
    Equip(name: "sorcerer gauntlets", type: EquipType.Gloves, armorValue: 10, tier: 2, description: ""),
    Equip(name: "mage gauntlets", type: EquipType.Gloves, armorValue: 11, tier: 2, description: ""),
    Equip(name: "maiden gloves", type: EquipType.Gloves, armorValue: 12, tier: 2, description: ""),
    Equip(name: "silver gauntlets", type: EquipType.Gloves, armorValue: 14, tier: 3, description: ""),
    Equip(name: "moonlight gloves", type: EquipType.Gloves, armorValue: 15, tier: 3, description: ""),
    Equip(name: "paladin gauntlets", type: EquipType.Gloves, armorValue: 16, tier: 3, description: ""),
    Equip(name: "iron gauntlets", type: EquipType.Gloves, armorValue: 17, tier: 4, description: ""),
    Equip(name: "steel gauntlets", type: EquipType.Gloves, armorValue: 18, tier: 4, description: ""),
    Equip(name: "knight gauntlets", type: EquipType.Gloves, armorValue: 19, tier: 4, description: ""),
    Equip(name: "crimson gloves", type: EquipType.Gloves, armorValue: 20, tier: 4, description: ""),
    Equip(name: "crystal gauntlets", type: EquipType.Gloves, armorValue: 21, tier: 4, description: ""),
    Equip(name: "guardian gauntlets", type: EquipType.Gloves, armorValue: 22, tier: 5, description: ""),
    Equip(name: "bone encrusted gloves", type: EquipType.Gloves, armorValue: 23, tier: 5, description: ""),
    Equip(name: "dark gauntlets", type: EquipType.Gloves, armorValue: 25, tier: 6, description: ""),
    Equip(name: "shadow gauntlets", type: EquipType.Gloves, armorValue: 27, tier: 7, description: ""),
    Equip(name: "Great Lord Bracelet", type: EquipType.Gloves, armorValue: 30, tier: 10, description: "Melee damage leeched as life"), // 20% leech
    Equip(name: "Vanquisher Mittens", type: EquipType.Gloves, armorValue: 40, tier: 10, description: "Additional bare-handed damage"), // 8-10 damage
    Equip(name: "Gauntlets of Thorns", type: EquipType.Gloves, armorValue: 35, tier: 10, description: "Enemy takes damage on attack"), // 5-8 damage
    
    Equip(name: "sorcerer boots", type: EquipType.Legs, armorValue: 4, tier: 1, description: ""),
    Equip(name: "mage boots", type: EquipType.Legs, armorValue: 5, tier: 1, description: ""),
    Equip(name: "wanderer boots", type: EquipType.Legs, armorValue: 6, tier: 1, description: ""),
    Equip(name: "maiden skirt", type: EquipType.Legs, armorValue: 7, tier: 1, description: ""),
    Equip(name: "witch waistcloth", type: EquipType.Legs, armorValue: 8, tier: 1, description: ""),
    Equip(name: "black tights", type: EquipType.Legs, armorValue: 9, tier: 1, description: ""),
    Equip(name: "leather boots", type: EquipType.Legs, armorValue: 10, tier: 2, description: ""),
    Equip(name: "hunter trousers", type: EquipType.Legs, armorValue: 11, tier: 2, description: ""),
    Equip(name: "cleric leggings", type: EquipType.Legs, armorValue: 12, tier: 2, description: ""),
    Equip(name: "chain leggings", type: EquipType.Legs, armorValue: 13, tier: 2, description: ""),
    Equip(name: "crimson waistcloth", type: EquipType.Legs, armorValue: 14, tier: 3, description: ""),
    Equip(name: "guardian leggings", type: EquipType.Legs, armorValue: 15, tier: 3, description: ""),
    Equip(name: "thief tights", type: EquipType.Legs, armorValue: 16, tier: 3, description: ""),
    Equip(name: "moonlight waistcloth", type: EquipType.Legs, armorValue: 17, tier: 4, description: ""),
    Equip(name: "iron leggings", type: EquipType.Legs, armorValue: 18, tier: 4, description: ""),
    Equip(name: "steel leggings", type: EquipType.Legs, armorValue: 19, tier: 4, description: ""),
    Equip(name: "knight leggings", type: EquipType.Legs, armorValue: 20, tier: 4, description: ""),
    Equip(name: "silver leggings", type: EquipType.Legs, armorValue: 21, tier: 4, description: ""),
    Equip(name: "paladin leggings", type: EquipType.Legs, armorValue: 22, tier: 5, description: ""),
    Equip(name: "crystal leggings", type: EquipType.Legs, armorValue: 23, tier: 5, description: ""),
    Equip(name: "dark leggings", type: EquipType.Legs, armorValue: 24, tier: 5, description: ""),
    Equip(name: "shadow leggings", type: EquipType.Legs, armorValue: 25, tier: 6, description: ""),
    Equip(name: "bone leggings", type: EquipType.Legs, armorValue: 27, tier: 7, description: ""),
    Equip(name: "Boots of the Explorer", type: EquipType.Legs, armorValue: 35, tier: 10, description: "Double warp recharge speed"),
    Equip(name: "Boots of Evasion", type: EquipType.Legs, armorValue: 30, tier: 10, description: "Chance to evade an attack"), // 20%
    Equip(name: "Leggings of Thorns", type: EquipType.Legs, armorValue: 32, tier: 10, description: "Enemy takes damage on attack"), // 2-3 damage
    
    Equip(name: "Dragon Ring", type: EquipType.Ring, armorValue: 0, tier: 10, description: "Boost attack damage"), // 20%
    Equip(name: "Blood Ring", type: EquipType.Ring, armorValue: 0, tier: 10, description: "Chance to instantly kill target"), // 10% chance, wearer loses 10 life each turn
    Equip(name: "Hawk Ring", type: EquipType.Ring, armorValue: 0, tier: 10, description: "Boost ranged weapon damage"), // 25%
    Equip(name: "Wolf Ring", type: EquipType.Ring, armorValue: 0, tier: 10, description: "Boost melee weapon damage"), // 25%
    Equip(name: "Calamity Ring", type: EquipType.Ring, armorValue: 0, tier: 10, description: "Double damage taken"),
    Equip(name: "Covetous Ring", type: EquipType.Ring, armorValue: 0, tier: 10, description: "Increase item discovery"), // 50%
    Equip(name: "Gold Ring", type: EquipType.Ring, armorValue: 0, tier: 10, description: "Increase gold acquisition"), // 50%
    Equip(name: "Stone Ring", type: EquipType.Ring, armorValue: 30, tier: 10, description: "Additional armor"),
    Equip(name: "Cling Ring", type: EquipType.Ring, armorValue: 0, tier: 10, description: "Gain life from fallen enemies"), // 5 life after each kill
    Equip(name: "Ring of Sacrifice", type: EquipType.Ring, armorValue: 0, tier: 10, description: "Prevent lethal damage"), // one time use, ring breaks
    Equip(name: "Ancient Ring", type: EquipType.Ring, armorValue: 0, tier: 10, description: "Flask restores additional life"), // 50 life per use
    Equip(name: "Quartz Ring", type: EquipType.Ring, armorValue: 0, tier: 10, description: "Add damage to ranged attacks"), // 5-10 damage
    Equip(name: "Warrior Ring", type: EquipType.Ring, armorValue: 0, tier: 10, description: "Add damage to melee attacks"), // 5-10 damage
    Equip(name: "Redeye Ring", type: EquipType.Ring, armorValue: 0, tier: 10, description: "Wearer is immune to blind"),
    Equip(name: "Silver Ring", type: EquipType.Ring, armorValue: 0, tier: 10, description: "Wearer is immune to paralyze"),
    Equip(name: "Vanquisher Ring", type: EquipType.Ring, armorValue: 0, tier: 10, description: "Increase bare-handed damage") // 500%
]

let MonsterTypes: [Monster] = [
    Monster(face: "r", name: "giant rat", life: 10, armor: 0, weapon: "bandit knife", tier: 1, description: ""),
    Monster(face: "m", name: "molerat", life: 10, armor: 10, weapon: "dagger", tier: 1, description: ""),
    Monster(face: "b", name: "giant bat", life: 8, armor: 0, weapon: "hunter axe", tier: 1, description: ""),
    Monster(face: "i", name: "wisp", life: 10, armor: 0, weapon: "musket", tier: 1, description: ""),
    Monster(face: "c", name: "scavenger", life: 13, armor: 0, weapon: "pistol", tier: 1, description: ""),
    Monster(face: "w", name: "warg", life: 14, armor: 0, weapon: "beast claw", tier: 1, description: ""),
    
    Monster(face: "h", name: "ghost", life: 14, armor: 10, weapon: "revolver", tier: 2, description: ""),
    Monster(face: "z", name: "zombie", life: 15, armor: 0, weapon: "reinforced club", tier: 2, description: ""),
    Monster(face: "g", name: "ghoul", life: 15, armor: 10, weapon: "short sword", tier: 2, description: ""),
    Monster(face: "s", name: "skeleton", life: 14, armor: 10, weapon: "morning star", tier: 2, description: ""),

    Monster(face: "a", name: "revenant", life: 17, armor: 20, weapon: "notched whip", tier: 3, description: ""),
    Monster(face: "f", name: "shadowfolk", life: 15, armor: 20, weapon: "large club", tier: 3, description: ""),
    Monster(face: "n", name: "minecrawler", life: 17, armor: 10, weapon: "rifle", tier: 3, description: ""),
    Monster(face: "k", name: "skeleton mage", life: 18, armor: 20, weapon: "heavy crossbow", tier: 3, description: "Chance to paralyze."), // 30%

    Monster(face: "o", name: "gargoyle", life: 20, armor: 20, weapon: "notched whip", tier: 4, description: ""),
    Monster(face: "e", name: "werewolf", life: 23, armor: 10, weapon: "long sword", tier: 4, description: ""),
    Monster(face: "v", name: "vampire", life: 25, armor: 20, weapon: "bastard sword", tier: 4, description: "Leeches life."), // 30%
    Monster(face: "p", name: "shapeshifter", life: 21, armor: 10, weapon: "double rifle", tier: 4, description: ""),

    Monster(face: "C", name: "chimera", life: 27, armor: 20, weapon: "blacksmith hammer", tier: 5, description: ""),
    Monster(face: "A", name: "salamander", life: 26, armor: 10, weapon: "moonlight sword", tier: 5, description: ""),
    Monster(face: "W", name: "witch", life: 25, armor: 10, weapon: "sniper crossbow", tier: 5, description: "Chance to blind."), // 30%

    Monster(face: "S", name: "succubus", life: 30, armor: 20, weapon: "silver sword", tier: 6, description: "Chance to avoid hits."), // 30%
    Monster(face: "I", name: "incubus", life: 32, armor: 10, weapon: "battle axe", tier: 6, description: ""),
    Monster(face: "U", name: "undead", life: 32, armor: 10, weapon: "great mace", tier: 6, description: ""),

    Monster(face: "T", name: "stone golem", life: 35, armor: 20, weapon: "great mace", tier: 7, description: ""),
    Monster(face: "N", name: "iron golem", life: 37, armor: 20, weapon: "battle axe", tier: 7, description: ""),
    Monster(face: "M", name: "demon", life: 40, armor: 20, weapon: "ghost blade", tier: 7, description: ""),
    Monster(face: "B", name: "shadow beast", life: 42, armor: 20, weapon: "crystal sword", tier: 7, description: ""),
    
    Monster(face: "O", name: "shadow warrior", life: 43, armor: 20, weapon: "dark sword", tier: 8, description: ""),
    Monster(face: "H", name: "shadow lord", life: 45, armor: 20, weapon: "elephant gun", tier: 8, description: ""),
    Monster(face: "D", name: "swamp dragon", life: 50, armor: 20, weapon: "dark sword", tier: 8, description: "Chance of additional damage."), // 20% for 16-18 damage
    Monster(face: "G", name: "stone dragon", life: 50, armor: 30, weapon: "claymore", tier: 8, description: "Chance to paralyze."), // 20%
    
    Monster(face: "E", name: "bone dragon", life: 55, armor: 20, weapon: "holy blade", tier: 9, description: "Chance to blind."), // 20%
    Monster(face: "K", name: "seeker", life: 55, armor: 10, weapon: "shotgun", tier: 9, description: ""),
    Monster(face: "R", name: "lurker", life: 53, armor: 20, weapon: "obsidian sword", tier: 9, description: ""),
    Monster(face: "L", name: "demon lord", life: 60, armor: 20, weapon: "chaos blade", tier: 9, description: "Chance to warp next to you."), // 50%

    Monster(face: "X", name: "Sentinel", life: 255, armor: 10, weapon: "Hand Cannon", tier: 255, description: "Chance to reflect damage.") // 20%
]

let MiscTypes: [Misc] = [
    Misc(name: "blood vial", value: 10),
    Misc(name: "gold coin", value: 5)
]

let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
let stateFileURL = URL(fileURLWithPath: STATE_FILENAME, relativeTo: directoryURL)
