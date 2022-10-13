import Foundation

class InteractionController {
    private var hero: HeroController
    private var instance: InstanceController
    private var state: StateController
    
    init(hero: HeroController, instance: InstanceController, state: StateController) {
        self.hero = hero
        self.instance = instance
        self.state = state
    }
    
    public func getHeroController() -> HeroController {
        return self.hero
    }
    
    public func getInstanceController() -> InstanceController {
        return self.instance
    }
    
    public func getStateController() -> StateController {
        return self.state
    }
    
    public func moveHero(mX: Int, mY: Int) {
        if hero.isParalyzed() && !hero.isParalyzeImmune() && !(mX == 0 && mY == 0) {
            state.setState(state: .Cancel)
            return
        }
        
        let newTileFace: String = instance.getTileFace(x: hero.actor.x + mX, y: hero.actor.y + mY)
        
        switch newTileFace {
            case PASS, CORPSE, CLIP:
                passThrough(mX: mX, mY: mY, oldTileFace: newTileFace)
            case DOOR:
                getDoor()
            case STASH:
                getStash()
            case CHEST:
                getChest(mX: mX, mY: mY)
            case VENDOR:
                getVendor()
            case WAYPOINT:
                getWaypoint()
            case STONE:
                getStone()
            case GATE:
                win()
            default:
                break
        }
        
        if instance.isMonster(tileFace: newTileFace) {
            if heroDamage(x: hero.actor.x + mX, y: hero.actor.y + mY, damageType: .Melee) {
                instance.setTileFace(x: hero.actor.x + mX, y: hero.actor.y + mY, ch: CORPSE)
            }
        }
    }
    
    public func moveMonsters() {
        var rX1: Int = -1, rY1: Int = -1, rX2: Int = -1, rY2: Int = -1
        
        for room in instance.getRooms() {
            if ((room.x1 + 1)...(room.x2 - 1)).contains(hero.actor.x) && ((room.y1 + 1)...(room.y2 - 1)).contains(hero.actor.y) {
                rX1 = room.x1 + 1
                rY1 = room.y1 + 1
                rX2 = room.x2 - 1
                rY2 = room.y2 - 1
                break
            }
        }
        
        for i in 0..<instance.getMonsters().count {
            if !instance.getMonsters()[i].isAlive {
                continue
            }
            
            if instance.isMonsterParalyzed(i: i) {
                instance.setMonsterParalyzeCounter(i: i, value: instance.getMonsters()[i].paralyzeTimer + 1)
                continue
            }
            
            var done: Bool = false
            
            if instance.isMonsterBlind(i: i) {
                instance.setMonsterBlindCounter(i: i, value: instance.getMonsters()[i].blindTimer + 1)
            }
            
            if ((rX1...rX2).contains(instance.getMonsters()[i].x) && (rY1...rY2).contains(instance.getMonsters()[i].y) || instance.getMonsters()[i].isPursuit) && !instance.isMonsterBlind(i: i) { // aggro
                if !instance.getMonsters()[i].isPursuit {
                    instance.setMonsterPursuitState(i: i, value: true)
                    if instance.getMonsters()[i].name == MonsterTypes[MonsterTypes.count - 1].name {
                        state.addMessage(message: "\"You shall not pass!\"")
                    }
                    continue
                }
                
                if instance.getMonsters()[i].face == "L" {
                    if Int.random(in: 0...99) < 50 {
                        for y in (hero.actor.y - 1)...(hero.actor.y + 1) {
                            for x in (hero.actor.x - 1)...(hero.actor.x + 1) {
                                if [PASS, CORPSE, CLIP].contains(instance.getTileFace(x: x, y: y)) {
                                    instance.flashTileFace(x: instance.getMonsters()[i].x, y: instance.getMonsters()[i].y, color: .Green, state: state)
                                    Thread.sleep(forTimeInterval: FLASH_DELAY)
                                    instance.setTileFace(x: instance.getMonsters()[i].x, y: instance.getMonsters()[i].y, ch: instance.getMonsters()[i].cell)
                                    instance.setMonsterCell(i: i, value: instance.getTileFace(x: x, y: y))
                                    instance.setTileFace(x: x, y: y, ch: instance.getMonsters()[i].face)
                                    instance.setMonsterLocation(i: i, x: x, y: y)
                                }
                            }
                        }
                    }
                }
                
                var miss: Bool = false
                
                if hero.actor.legs.name == "Boots of Evasion" {
                    if Int.random(in: 0...99) < 20 {
                        miss = true
                    }
                }
                
                for r in RangedTypes {
                    if instance.getMonsters()[i].ranged.name == r.name && r.name != EMPTY {
                        let result = connectXY(x1: instance.getMonsters()[i].x, y1: instance.getMonsters()[i].y, x2: hero.actor.x, y2: hero.actor.y, mode: .Clear)
                        if result.isConnected {
                            var damage: Int = monsterDamage(i: i, damageType: .Ranged)
                            
                            if damage < 0 {
                                damage = 0
                            }
                            
                            state.addMessage(message: "\(capitalizeFirst(string: instance.getMonsters()[i].name)) shoots you for \(damage) damage.")
                            
                            if miss {
                                state.addMessage(message: "You evade!")
                                done = true
                                break
                            }
                            
                            hero.actor.lifeBefore = hero.actor.lifeCurrent
                            hero.actor.lifeCurrent -= damage
                            instance.flashTileFace(x: instance.getMonsters()[i].x, y: instance.getMonsters()[i].y, color: .Red, state: state)
                            
                            if hero.actor.lifeCurrent <= 0 && !hero.isRingOfSacrificeEquipped(state: state) {
                                die()
                                return
                            }
                            
                            if instance.getMonsters()[i].face == "k" {
                                if Int.random(in: 0...99) < 30 && !hero.isParalyzed() && !hero.isParalyzeImmune() {
                                    hero.actor.paralyzeTimer = 0
                                    state.addMessage(message: "You are paralyzed!")
                                }
                            }
                            
                            if instance.getMonsters()[i].face == "W" {
                                if Int.random(in: 0...99) < 30 && !hero.isBlind() && !hero.isBlindImmune() {
                                    hero.actor.blindTimer = 0
                                    state.addMessage(message: "You are blinded!")
                                }
                            }
                            
                            done = true
                        }
                        
                        break
                    }
                }
                
                if done {
                    continue
                }
                
                for m in MeleeTypes {
                    if instance.getMonsters()[i].melee.name == m.name {
                        for y in (instance.getMonsters()[i].y - 1)...(instance.getMonsters()[i].y + 1) {
                            for x in (instance.getMonsters()[i].x - 1)...(instance.getMonsters()[i].x + 1) {
                                if instance.getTileFace(x: x, y: y) == hero.actor.face {
                                    var damage: Int = monsterDamage(i: i, damageType: .Melee)
                                    
                                    if damage < 0 {
                                        damage = 0
                                    }
                                    
                                    state.addMessage(message: "\(capitalizeFirst(string: instance.getMonsters()[i].name)) hits you for \(damage) damage.")
                                    
                                    if miss {
                                        state.addMessage(message: "You evade!")
                                        done = true
                                        break
                                    }
                                    
                                    hero.actor.lifeBefore = hero.actor.lifeCurrent
                                    hero.actor.lifeCurrent -= damage
                                    instance.flashTileFace(x: instance.getMonsters()[i].x, y: instance.getMonsters()[i].y, color: .Red, state: state)
                                    
                                    if hero.actor.lifeCurrent <= 0 && !hero.isRingOfSacrificeEquipped(state: state) {
                                        die()
                                        return
                                    }
                                    
                                    if instance.getMonsters()[i].face == "v" {
                                        instance.flashTileFace(x: instance.getMonsters()[i].x, y: instance.getMonsters()[i].y, color: .Blue, state: state)
                                        instance.setMonsterLife(i: i, value: instance.getMonsters()[i].lifeCurrent + Int(Double(damage) * 0.3))
                                    }
                                    
                                    if instance.getMonsters()[i].face == "G" {
                                        if Int.random(in: 0...99) < 20 && !hero.isParalyzed() && !hero.isParalyzeImmune() {
                                            hero.actor.paralyzeTimer = 0
                                            state.addMessage(message: "You are paralyzed!")
                                        }
                                    }
                                    
                                    if instance.getMonsters()[i].face == "E" {
                                        if Int.random(in: 0...99) < 20 && !hero.isBlind() && !hero.isBlindImmune() {
                                            hero.actor.blindTimer = 0
                                            state.addMessage(message: "You are blinded!")
                                        }
                                    }
                                    
                                    heroDamage(x: instance.getMonsters()[i].x, y: instance.getMonsters()[i].y, damageType: .Thorns)
                                    done = true
                                    break
                                }
                            }
                        }
                        
                        break
                    }
                }
                
                if done {
                    continue
                }
                
                var result = connectXY(x1: instance.getMonsters()[i].x, y1: instance.getMonsters()[i].y, x2: hero.actor.x, y2: hero.actor.y, mode: .Move)
                
                if result.isConnected {
                    result = connectXY(x1: instance.getMonsters()[i].x, y1: instance.getMonsters()[i].y, x2: hero.actor.x, y2: hero.actor.y, mode: .Path)
                } else {
                    result = findPath(x1: instance.getMonsters()[i].x, y1: instance.getMonsters()[i].y, x2: hero.actor.x, y2: hero.actor.y)
                }
                
                if [PASS, CORPSE, CLIP].contains(instance.getTileFace(x: result.nextX, y: result.nextY)) {
                    instance.setTileFace(x: instance.getMonsters()[i].x, y: instance.getMonsters()[i].y, ch: instance.getMonsters()[i].cell)
                    instance.setMonsterCell(i: i, value: instance.getTileFace(x: result.nextX, y: result.nextY))
                    instance.setTileFace(x: result.nextX, y: result.nextY, ch: instance.getMonsters()[i].face)
                    instance.setMonsterLocation(i: i, x: result.nextX, y: result.nextY)
                }
                
                done = true
            }
            
            if done {
                continue
            }
            
            let direction: Int = Int.random(in: 1...9) // prowler
            var mX: Int = 0, mY: Int = 0
            
            switch direction {
                case 4:
                    mX -= 1
                case 6:
                    mX += 1
                case 8:
                    mY -= 1
                case 2:
                    mY += 1
                case 1:
                    mX -= 1
                    mY += 1
                case 7:
                    mX -= 1
                    mY -= 1
                case 3:
                    mX += 1
                    mY += 1
                case 9:
                    mX += 1
                    mY -= 1
                default:
                    break
            }
            
            if [PASS, CORPSE, CLIP].contains(instance.getTileFace(x: instance.getMonsters()[i].x + mX, y: instance.getMonsters()[i].y + mY)) {
                instance.setTileFace(x: instance.getMonsters()[i].x, y: instance.getMonsters()[i].y, ch: instance.getMonsters()[i].cell)
                instance.setMonsterCell(i: i, value: instance.getTileFace(x: instance.getMonsters()[i].x + mX, y: instance.getMonsters()[i].y + mY))
                instance.setTileFace(x: instance.getMonsters()[i].x + mX, y: instance.getMonsters()[i].y + mY, ch: instance.getMonsters()[i].face)
                instance.setMonsterLocation(i: i, x: instance.getMonsters()[i].x + mX, y: instance.getMonsters()[i].y + mY)
            }
        }
    }
    
    private func findPath(x1: Int, y1: Int, x2: Int, y2: Int) -> (nextX: Int, nextY: Int, isConnected: Bool) {
        var queue: [[Int]] = []
        var done: Bool = false, stuck: Bool = false, reInit: Bool = false
        var steps: Int = 0
        
        queue.append([])
        queue[0].append(x2)
        queue[0].append(y2)
        queue[0].append(0)
        
        while !done {
            let queueLength: Int = queue.count
            var added: Bool = false
            
            for i in 0..<queueLength {
                if queue[i][2] < steps {
                    continue
                }
                
                let x: Int = queue[i][0], y: Int = queue[i][1]
                
                for j in (y - 1)...(y + 1) {
                    for k in (x - 1)...(x + 1) {
                        if k == x1 && j == y1 {
                            done = true
                            break
                        }
                        
                        if !stuck && ((j == y && k == x) || [WALL, CHEST, DOOR].contains(instance.getTileFace(x: k, y: j)) || instance.isMonster(tileFace: instance.getTileFace(x: k, y: j)) || inQueue(x: k, y: j , queue: queue)) {
                            continue
                        }
                        
                        if stuck && ((j == y && k == x) || [WALL, CHEST, DOOR].contains(instance.getTileFace(x: k, y: j)) || inQueue(x: k, y: j, queue: queue)) {
                            continue
                        }
                        
                        added = true
                        queue.append([])
                        queue[queue.count - 1].append(k)
                        queue[queue.count - 1].append(j)
                        queue[queue.count - 1].append(steps + 1)
                    }
                }
                
                if done {
                    break
                }
            }
            
            if !added && !done {
                stuck = true
            }
            
            if stuck && !reInit {
                reInit = true
                steps = -1
                queue.removeAll()
                queue.append([])
                queue[0].append(x2)
                queue[0].append(y2)
                queue[0].append(0)
            }
            
            steps += 1
        }
        
        var nextX: Int = x1, nextY: Int = y1
        
        for q in queue {
            if q[2] == steps - 1 && ((x1 - 1)...(x1 + 1)).contains(q[0]) && ((y1 - 1)...(y1 + 1)).contains(q[1]) {
                nextX = q[0]
                nextY = q[1]
            }
        }
        
        return (nextX: nextX, nextY: nextY, isConnected: stuck)
    }
    
    private func inQueue(x: Int, y: Int, queue: [[Int]]) -> Bool {
        for q in queue {
            if q[0] == x && q[1] == y {
                return true
            }
        }
        
        return false
    }
        
    private func monsterDamage(i: Int, damageType: DamageType) -> Int {
        var damage: Int = 0
        
        switch damageType {
            case .Ranged:
                for r in RangedTypes {
                    if instance.getMonsters()[i].ranged.name == r.name {
                        damage = Int.random(in: r.minDamage...r.maxDamage)
                        break
                    }
                }
            case .Melee:
                for m in MeleeTypes {
                    if instance.getMonsters()[i].melee.name == m.name {
                        damage = Int.random(in: m.minDamage...m.maxDamage)
                        if instance.getMonsters()[i].face == "D" {
                            if Int.random(in: 0...99) < 20 {
                                damage += Int.random(in: 16...18)
                                state.addMessage(message: "Acid breath!")
                            }
                        }
                        break
                    }
                }
            default:
                break
        }
        
        var calamity: Int = 1
        
        for ring in hero.actor.rings {
            if ring.name == "Calamity Ring" {
                calamity *= 2
            }
        }
        
        return (damage - hero.actor.armor / hero.actor.armorMitigation) * calamity
    }
    
    @discardableResult public func heroDamage(x: Int, y: Int, damageType: DamageType) -> Bool {
        var damageValue: Int = 0
        var i: Int = -1
        
        if damageType != .Thorns {
            state.clearMessages()
        }
        
        if damageType == .Ranged && hero.actor.ammo < 1 {
            state.addMessage(message: "No ammo left.")
            return false
        }
        
        if damageType == .Ranged && hero.actor.ranged.name == EMPTY {
            return false
        }
        
        for j in 0..<instance.getMonsters().count {
            if instance.getMonsters()[j].x == x && instance.getMonsters()[j].y == y && instance.getMonsters()[j].isAlive {
                i = j
                break
            }
        }
        
        var damageBoost: Int = 0
        
        switch damageType {
            case .Melee:
                damageValue = Int.random(in: hero.actor.melee.minDamage...hero.actor.melee.maxDamage)
                
                if hero.actor.melee.name == "Hammer of the Inferno" {
                    if Int.random(in: 0...99) < 25 {
                        damageValue += Int.random(in: 8...12)
                    }
                }
            
                if hero.actor.melee.name == MeleeTypes[0].name && hero.actor.gloves.name == "Vanquisher Mittens" {
                    damageValue += Int.random(in: 8...10)
                }
            
                for ring in hero.actor.rings {
                    if ring.name == "Warrior Ring" {
                        damageValue += Int.random(in: 5...10)
                    }
                }
            
                for ring in hero.actor.rings {
                    if ring.name == "Wolf Ring" {
                        damageBoost += Int(Double(damageValue) * 0.25)
                    }
                }
            
                damageValue += damageBoost
                damageBoost = 0
            
                for ring in hero.actor.rings {
                    if hero.actor.melee.name == MeleeTypes[0].name && ring.name == "Vanquisher Ring" {
                        damageBoost += damageValue * 5
                    }
                }
            
                damageValue += damageBoost
            case .Ranged:
                damageValue = Int.random(in: hero.actor.ranged.minDamage...hero.actor.ranged.maxDamage)
                
                for ring in hero.actor.rings {
                    if ring.name == "Quartz Ring" {
                        damageValue += Int.random(in: 5...10)
                    }
                }
            
                for ring in hero.actor.rings {
                    if ring.name == "Hawk Ring" {
                        damageBoost += Int(Double(damageValue) * 0.25)
                    }
                }
            
                damageValue += damageBoost
            case .Thorns:
                if hero.actor.chest.name == "Armor of Thorns" {
                    damageValue += Int.random(in: 10...12)
                }
            
                if hero.actor.head.name == "Helm of Thorns" {
                    damageValue += Int.random(in: 3...4)
                }
            
                if hero.actor.gloves.name == "Gauntlets of Thorns" {
                    damageValue += Int.random(in: 5...8)
                }
            
                if hero.actor.legs.name == "Leggings of Thorns" {
                    damageValue += Int.random(in: 2...3)
                }
            
                if damageValue == 0 {
                    return false
                }
        }
        
        instance.flashTileFace(x: hero.actor.x, y: hero.actor.y, color: .Red, state: state)
        
        if damageType == .Ranged {
            hero.actor.ammo -= 1
        }
        if damageType == .Ranged && hero.actor.ranged.name == "double rifle" && hero.actor.ammo > 0 {
            hero.actor.ammo -= 1
        }
        
        if x == hero.actor.x && y == hero.actor.y {
            damageValue -= hero.actor.armor / hero.actor.armorMitigation
            if damageValue < 0 {
                damageValue = 0
            }
            hero.actor.lifeBefore = hero.actor.lifeCurrent
            hero.actor.lifeCurrent -= damageValue
            state.addMessage(message: "You deal \(damageValue) damage to yourself.")
            if hero.actor.lifeCurrent <= 0 && !hero.isRingOfSacrificeEquipped(state: state) {
                die()
            }
            return false
        }
        
        if i < 0 {
            state.addMessage(message: "Pew.")
            return false
        }
        
        if instance.getMonsters()[i].face == "X" && damageType != .Thorns {
            if Int.random(in: 0...99) < 20 {
                damageValue -= hero.actor.armor / hero.actor.armorMitigation
                if damageValue < 0 {
                    damageValue = 0
                }
                hero.actor.lifeBefore = hero.actor.lifeCurrent
                hero.actor.lifeCurrent -= damageValue
                state.addMessage(message: "Reflect! You take \(damageValue) damage.")
                if hero.actor.lifeCurrent <= 0 && !hero.isRingOfSacrificeEquipped(state: state) {
                    die()
                }
                return false
            }
        }
        
        damageBoost = 0
        
        for ring in hero.actor.rings {
            if ring.name == "Dragon Ring" && damageType != .Thorns {
                damageBoost += Int(Double(damageValue) * 0.2)
            }
        }
        damageValue += damageBoost
        
        if hero.actor.head.name == "Great Lord Crown" && damageType != .Thorns {
            if Int.random(in: 0...99) < 10 {
                damageValue *= 2
            }
        }
        
        damageValue -= instance.getMonsters()[i].armor / instance.getMonsters()[i].armorMitigation
        
        if damageValue < 0 {
            damageValue = 0
        }
        
        var miss: Bool = false
        
        if instance.getMonsters()[i].face == "S" && damageType != .Thorns {
            if Int.random(in: 0...99) < 30 {
                miss = true
                state.addMessage(message: "You miss!")
            }
        }
        
        if hero.actor.head.name == "Crown of the Sun" && damageType != .Thorns && !miss {
            if Int.random(in: 0...99) < 20 {
                miss = true
                state.addMessage(message: "You miss!")
            }
        }
        
        if !miss {
            instance.setMonsterLife(i: i, value: instance.getMonsters()[i].lifeCurrent - damageValue)
            if damageType == .Thorns {
                state.addMessage(message: "\(capitalizeFirst(string: instance.getMonsters()[i].name)) takes \(damageValue) damage.")
            } else {
                state.addMessage(message: "You deal \(damageValue) damage to \(instance.getMonsters()[i].name).")
                
                if hero.actor.gloves.name == "Great Lord Bracelet" {
                    hero.actor.lifeCurrent += damageValue / 5
                }
                
                for ring in hero.actor.rings {
                    if ring.name == "Blood Ring" {
                        if Int.random(in: 0...99) < 10 {
                            instance.setMonsterLife(i: i, value: 0)
                        }
                    }
                }
            }
        }
        
        instance.setMonsterPursuitState(i: i, value: true)
        
        if instance.getMonsters()[i].lifeCurrent <= 0 {
            instance.setMonsterFace(i: i, value: CORPSE)
            instance.setMonsterAliveState(i: i, value: false)
            state.addMessage(message: "\(capitalizeFirst(string: instance.getMonsters()[i].name)) dies.")
            
            if damageType == .Thorns {
                instance.setTileFace(x: instance.getMonsters()[i].x, y: instance.getMonsters()[i].y, ch: CORPSE)
            }
            
            var rngBoost: Int = 0
            
            for ring in hero.actor.rings {
                if ring.name == "Cling Ring" {
                    hero.actor.lifeCurrent += 5
                }
                if ring.name == "Covetous Ring" {
                    rngBoost += 1
                }
            }
            
            switch Int.random(in: 0...(10 + rngBoost)) {
                case 0...4:
                    instance.addItem(item: Item(x: instance.getMonsters()[i].x, y: instance.getMonsters()[i].y, name: MiscTypes[0].name, amount: 1, tag: .Misc, price: 0, isMarked: false, isPointed: false, description: ""))
                case 5...9:
                    instance.addItem(item: Item(x: instance.getMonsters()[i].x, y: instance.getMonsters()[i].y, name: MiscTypes[1].name, amount: 1, tag: .Misc, price: 0, isMarked: false, isPointed: false, description: ""))
                case (10 + rngBoost):
                    instance.generateItem(x: instance.getMonsters()[i].x, y: instance.getMonsters()[i].y, mode: .Monster)
                default:
                    break
            }
            
            if instance.getMonsters()[i].name == MonsterTypes[MonsterTypes.count - 1].name {
                instance.addItem(item: Item(x: instance.getMonsters()[i].x, y: instance.getMonsters()[i].y, name: "keystone", amount: 1, tag: .Keystone, price: 1, isMarked: false, isPointed: false, description: ""))
            }
            
            return true
        } else {
            if damageType == .Thorns {
                return false
            }
            
            if hero.actor.chest.name == "Armor of the Glorious" {
                if Int.random(in: 0...99) < 10 {
                    instance.setMonsterParalyzeCounter(i: i, value: 0)
                    state.addMessage(message: "\(capitalizeFirst(string: instance.getMonsters()[i].name)) is paralyzed!")
                }
            }
            
            if hero.actor.chest.name == "Armor of the Sun" {
                if Int.random(in: 0...99) < 20 {
                    if !hero.isBlind() && !hero.isBlindImmune() {
                        hero.actor.blindTimer = 0
                        state.addMessage(message: "The light shines!")
                    }
                }
            }
            
            if hero.actor.head.name == "Crown of Dusk" {
                if Int.random(in: 0...99) < 10 {
                    instance.setMonsterBlindCounter(i: i, value: 0)
                    state.addMessage(message: "\(capitalizeFirst(string: instance.getMonsters()[i].name)) is blinded!")
                }
            }
            
            if hero.actor.melee.name == "Sword of the Abyss" && damageType == .Melee {
                if Int.random(in: 0...99) < 15 {
                    var didWarp: Bool = false
                    
                    for room in instance.getRooms() {
                        if ((room.x1 + 1)...(room.x2 - 1)).contains(instance.getMonsters()[i].x) && ((room.y1 + 1)...(room.y2 - 1)).contains(instance.getMonsters()[i].y) {
                            warp(x1: room.x1, y1: room.y1, x2: room.x2, y2: room.y2, tX: instance.getMonsters()[i].x, tY: instance.getMonsters()[i].y)
                            didWarp = true
                            break
                        }
                    }
                    
                    if !didWarp {
                        warp(x1: instance.getMonsters()[i].x, y1: instance.getMonsters()[i].y, x2: instance.getMonsters()[i].x, y2: instance.getMonsters()[i].y, tX: instance.getMonsters()[i].x, tY: instance.getMonsters()[i].y)
                    }
                }
            }
            
            if hero.actor.melee.name == "Scythe of the Gravelord" && damageType == .Melee {
                if Int.random(in: 0...99) < 20 {
                    instance.setMonsterLife(i: i, value: instance.getMonsters()[i].lifeCurrent - Int(Double(instance.getMonsters()[i].lifeCurrent) * 0.3))
                    
                    if instance.getMonsters()[i].lifeCurrent <= 0 {
                        instance.setMonsterLife(i: i, value: 1)
                    }
                    
                    state.addMessage(message: "\(capitalizeFirst(string: instance.getMonsters()[i].name)) shivers!")
                }
            }
            
            if hero.actor.ranged.name == "Long Bow of the Dark" && damageType == .Ranged {
                if Int.random(in: 0...99) < 10 {
                    instance.setMonsterBlindCounter(i: i, value: 0)
                    state.addMessage(message: "\(capitalizeFirst(string: instance.getMonsters()[i].name)) is blinded!")
                }
            }
        }
        
        return false
    }
    
    private func passThrough(mX: Int, mY: Int, oldTileFace: String) {
        instance.setTileFace(x: hero.actor.x, y: hero.actor.y, ch: hero.actor.cell)
        hero.actor.cell = oldTileFace
        hero.actor.x += mX
        hero.actor.y += mY
        instance.setTileFace(x: hero.actor.x, y: hero.actor.y, ch: hero.actor.face)
        
        if hero.isBlind() && [CORPSE, CLIP].contains(oldTileFace) {
            state.addMessage(message: "Ouch.")
        }
        
        if !hero.isBlind() {
            autoPickup()
            checkTileItems(x: hero.actor.x, y: hero.actor.y)
        }
    }
    
    private func getDoor() {
        if instance.getDepth() == instance.maxDepth {
            for item in hero.actor.inventory {
                if item.name == "keystone" {
                    instance.setDepth(depth: 0)
                    hero.setWarpCounter(value: hero.getWarpCounter() + 1)
                    state.setState(state: .Cancel)
                    hero.actor.x = 1
                    hero.actor.y = instance.maxY - 1
                    instance.createTown(hero: hero)
                    state.addMessage(message: "You've been sent back.")
                    return
                }
            }
            state.addMessage(message: "The fog is too thick.")
            return
        }
        
        instance.setDepth(depth: instance.getDepth() + 1)
        hero.setWarpCounter(value: hero.getWarpCounter() + 1)
        state.setState(state: .Cancel)
        instance.createNew(hero: hero)
    }
    
    private func getStash() {
        if hero.isBlind() {
            state.addMessage(message: "Bump.")
            return
        }
        
        state.setState(state: .StashTab1)
        instance.bufferMap()
        displayStashItems()
    }
    
    private func getChest(mX: Int, mY: Int) {
        state.addMessage(message: "There is a chest.")
        
        var itemIndex: Int = -1
        
        for j in 0..<instance.getItems().count {
            if instance.getItems()[j].x == hero.actor.x + mX && instance.getItems()[j].y == hero.actor.y + mY {
                itemIndex = j
                break
            }
        }
        
        if itemIndex < 0 {
            state.addMessage(message: "It's empty.")
            state.setState(state: .Cancel)
            return
        }
        
        if hero.isBlind() {
            state.addMessage(message: "You can't tell what's inside.")
            state.setState(state: .Cancel)
            return
        }
        
        instance.setItemIndex(i: itemIndex)
        state.addMessage(message: "You see \(instance.getItems()[itemIndex].amount) \(instance.getItems()[itemIndex].name) inside.")
        state.addMessage(message: "Would you like to pick that up?")
        state.setState(state: .Chest)
    }
    
    public func openChest() {
        let itemIndex: Int = instance.getItemIndex()
        var found: Bool = false
        var weapon: String = "", ammoName: String = "", ammoQuantity: Int = 0
        
        if hero.actor.inventory.count >= hero.inventoryCapacity && ![ItemTag.LifeOrb, ItemTag.GoldCache].contains(instance.getItems()[itemIndex].tag) {
            if instance.getItems()[itemIndex].tag == .Ammo {
                for ammo in AmmoTypes {
                    if instance.getItems()[itemIndex].name == ammo.name && hero.actor.ranged.name.lowercased().contains(ammo.weapon.lowercased()) {
                        found = true
                        break
                    }
                }
                
                if !found {
                    for item in hero.actor.inventory {
                        if instance.getItems()[itemIndex].name == item.name {
                            found = true
                            break
                        }
                    }
                }
            }
            
            if instance.getItems()[itemIndex].tag == .Ranged {
                if instance.getItems()[itemIndex].name == hero.actor.ranged.name {
                    found = true
                }
                
                if !found {
                    for ammo in AmmoTypes {
                        if instance.getItems()[itemIndex].name.lowercased().contains(ammo.weapon.lowercased()) {
                            ammoName = ammo.name
                            weapon = ammo.weapon
                            break
                        }
                    }
                }
                
                var gotWeapon: Bool = false, gotAmmo: Bool = false
                
                for item in hero.actor.inventory {
                    if item.name == weapon {
                        gotWeapon = true
                    }
                    if item.name == ammoName {
                        gotAmmo = true
                    }
                }
                
                if gotWeapon && gotAmmo {
                    found = true
                }
            }
            
            if !found {
                state.addMessage(message: "Can't carry any more.")
                return
            }
            
            found = false
        }
        
        if hero.actor.inventory.count == hero.inventoryCapacity - 1 && instance.getItems()[itemIndex].tag == .Ranged {
            if instance.getItems()[itemIndex].name == hero.actor.ranged.name {
                found = true
            }
            
            if !found {
                for ammo in AmmoTypes {
                    if instance.getItems()[itemIndex].name.lowercased().contains(ammo.weapon.lowercased()) {
                        ammoName = ammo.name
                        weapon = ammo.weapon
                        break
                    }
                }
                
                for item in hero.actor.inventory {
                    if item.name == ammoName {
                        found = true
                        break
                    }
                }
            }
            
            if hero.actor.ranged.name.lowercased().contains(weapon.lowercased()) {
                found = true
            }
            
            if !found {
                state.addMessage(message: "Can't carry any more.")
                return
            }
            
            found = false
        }
        
        state.clearMessages()
        
        switch instance.getItems()[itemIndex].tag {
            case .Ranged:
                for ammo in AmmoTypes {
                    if instance.getItems()[itemIndex].name.lowercased().contains(ammo.weapon.lowercased()) {
                        ammoName = ammo.name
                        weapon = ammo.weapon
                        ammoQuantity = ammo.quantity
                        break
                    }
                }
            
                if instance.getItems()[itemIndex].name == hero.actor.ranged.name {
                    hero.actor.ammo += ammoQuantity
                    found = true
                }
            
                if !found && hero.actor.ranged.name.lowercased().contains(weapon.lowercased()) {
                    hero.actor.ammo += ammoQuantity
                    hero.actor.inventory.append(Item(x: 0, y: 0, name: instance.getItems()[itemIndex].name, amount: 1, tag: .Ranged, price: 0, isMarked: false, isPointed: false, description: instance.getItems()[itemIndex].description))
                    state.addMessage(message: "Acquired \(instance.getItems()[itemIndex].name).")
                    found = true
                }
            
                if !found {
                    for item in hero.actor.inventory {
                        if instance.getItems()[itemIndex].name == item.name {
                            for i in 0..<hero.actor.inventory.count {
                                if hero.actor.inventory[i].name == ammoName {
                                    hero.actor.inventory[i].amount += ammoQuantity
                                    found = true
                                    break
                                }
                            }
                            if !found {
                                hero.actor.inventory.append(Item(x: 0, y: 0, name: ammoName, amount: ammoQuantity, tag: .Ammo, price: 0, isMarked: false, isPointed: false, description: ""))
                                found = true
                            }
                            break
                        }
                    }
                }
                
                if found {
                    state.addMessage(message: "Extracted \(ammoQuantity) \(ammoName).")
                }
            
                if !found {
                    hero.actor.inventory.append(Item(x: 0, y: 0, name: instance.getItems()[itemIndex].name, amount: 1, tag: .Ranged, price: 0, isMarked: false, isPointed: false, description: instance.getItems()[itemIndex].description))
                    state.addMessage(message: "Acquired \(instance.getItems()[itemIndex].name).")
                    
                    for i in 0..<hero.actor.inventory.count {
                        if hero.actor.inventory[i].name == ammoName {
                            hero.actor.inventory[i].amount += ammoQuantity
                            found = true
                            break
                        }
                    }
                    
                    if !found {
                        hero.actor.inventory.append(Item(x: 0, y: 0, name: ammoName, amount: ammoQuantity, tag: .Ammo, price: 0, isMarked: false, isPointed: false, description: ""))
                    }
                    
                    state.addMessage(message: "It's loaded with \(ammoQuantity) \(ammoName).")
                }
            case .Ammo:
                for ammo in AmmoTypes {
                    if instance.getItems()[itemIndex].name == ammo.name {
                        weapon = ammo.weapon
                        break
                    }
                }
            
                if hero.actor.ranged.name.lowercased().contains(weapon.lowercased()) {
                    hero.actor.ammo += instance.getItems()[itemIndex].amount
                    found = true
                }
            
                if !found {
                    for i in 0..<hero.actor.inventory.count {
                        if hero.actor.inventory[i].name == instance.getItems()[itemIndex].name {
                            hero.actor.inventory[i].amount += instance.getItems()[itemIndex].amount
                            found = true
                            break
                        }
                    }
                }
            
                if !found {
                    hero.actor.inventory.append(Item(x: 0, y: 0, name: instance.getItems()[itemIndex].name, amount: instance.getItems()[itemIndex].amount, tag: .Ammo, price: 0, isMarked: false, isPointed: false, description: ""))
                }
            
                state.addMessage(message: "Acquired \(instance.getItems()[itemIndex].amount) \(instance.getItems()[itemIndex].name).")
            case .Equip, .Melee:
                hero.actor.inventory.append(Item(x: 0, y: 0, name: instance.getItems()[itemIndex].name, amount: 1, tag: instance.getItems()[itemIndex].tag, price: 0, isMarked: false, isPointed: false, description: instance.getItems()[itemIndex].description))
                state.addMessage(message: "Acquired \(instance.getItems()[itemIndex].name).")
            case .Home, .Flash:
                for i in 0..<hero.actor.inventory.count {
                    if hero.actor.inventory[i].name == instance.getItems()[itemIndex].name {
                        hero.actor.inventory[i].amount += instance.getItems()[itemIndex].amount
                        found = true
                        break
                    }
                }
            
                if !found {
                    hero.actor.inventory.append(Item(x: 0, y: 0, name: instance.getItems()[itemIndex].name, amount: instance.getItems()[itemIndex].amount, tag: instance.getItems()[itemIndex].tag, price: 0, isMarked: false, isPointed: false, description: ""))
                }
            
                state.addMessage(message: "Acquired \(instance.getItems()[itemIndex].amount) \(instance.getItems()[itemIndex].name).")
            case .LifeOrb:
                hero.actor.lifeCurrent += hero.orbOfLifeValue
                state.addMessage(message: "Gained \(hero.orbOfLifeValue) life.")
            case .GoldCache:
                var goldBoost: Int = 0
            
                for ring in hero.actor.rings {
                    if ring.name == "Gold Ring" {
                        goldBoost += hero.goldCacheValue / 2
                    }
                }
                
                hero.actor.gold += (hero.goldCacheValue + goldBoost)
                state.addMessage(message: "Gained \(hero.goldCacheValue + goldBoost) gold.")
            default:
                break
        }
        
        instance.removeItem(i: itemIndex)
        state.setState(state: .Move)
    }
    
    private func getVendor() {
        if hero.isBlind() {
            state.addMessage(message: "\"You alright?\"")
            return
        }
        
        state.addMessage(message: "Shopkeeper greets you.")
        state.addMessage(message: "\"Take a look at my fine wares.\"")
        state.setState(state: .Shop)
        instance.bufferMap()
        displayShopItems()
    }
    
    private func getWaypoint() {
        if hero.isBlind() {
            return
        }
        
        state.setState(state: .Waypoint)
        instance.bufferMap()
        showWaypoint()
    }
    
    private func getStone() {
        if hero.isBlind() {
            state.addMessage(message: "Bump.")
            return
        }
        
        openGate()
    }
    
    public func win() {
        state.addMessage(message: "You escape!")
        state.setState(state: .End)
        hero.setWinCondition(state: true)
        hero.actor.face = PASS
        instance.setTileFace(x: hero.actor.x, y: hero.actor.y, ch: hero.actor.face)
        drawFrame(x1: 11, y1: 8, x2: 27, y2: 10, header: "", footer: "")
        writeText(x: 13, y: 9, text: "V I C T O R Y")
        instance.markArea(x1: 13, y1: 9, x2: 26, y2: 9, isMarked: true)
        deleteState()
    }

    public func die() {
        state.addMessage(message: "You die...")
        state.setState(state: .End)
        hero.actor.face = CORPSE
        hero.actor.isAlive = false
        instance.setTileFace(x: hero.actor.x, y: hero.actor.y, ch: hero.actor.face)
        drawFrame(x1: 11, y1: 8, x2: 27, y2: 10, header: "", footer: "")
        writeText(x: 17, y: 9, text: "R I P")
        instance.clearMapMarks()
        instance.markArea(x1: 13, y1: 9, x2: 26, y2: 9, isMarked: true)
        deleteState()
    }
    
    private func deleteState() {
        if FileManager.default.fileExists(atPath: stateFileURL.path) {
            try! FileManager.default.removeItem(at: stateFileURL)
        }
    }
    
    public func selectTarget() {
        if hero.actor.ranged.name == EMPTY {
            return
        }
        
        state.setState(state: .Target)
        
        let sortedMonsters: [Actor] = instance.getSortedMonsters(hero: hero)
        var locked: Bool = false

        if sortedMonsters.count > 0 && !hero.isBlind() {
            for m in sortedMonsters {
                let result = connectXY(x1: m.x, y1: m.y, x2: hero.actor.x, y2: hero.actor.y, mode: .Clear)
                
                if result.isConnected && instance.getMap()[m.y][m.x].isRevealed {
                    locked = true
                    hero.actor.dX = m.x - hero.actor.x
                    hero.actor.dY = m.y - hero.actor.y
                    connectXY(x1: hero.actor.x, y1: hero.actor.y, x2: hero.actor.x + hero.actor.dX, y2: hero.actor.y + hero.actor.dY, mode: .Highlight)
                    break
                }
            }
        }
        
        if !locked {
            instance.highlightTile(x: hero.actor.x, y: hero.actor.y)
        }
        
        state.addMessage(message: "Select a target to shoot. (\(getTileInfo(x: hero.actor.x + hero.actor.dX, y: hero.actor.y + hero.actor.dY)))")
    }
    
    @discardableResult private func connectXY(x1: Int, y1: Int, x2: Int, y2: Int, mode: ConnectMode) -> (nextX: Int, nextY: Int, isConnected: Bool) {
        let deltaX: Int = abs(x2 - x1)
        let deltaY: Int = abs(y2 - y1)
        let signX: Int = x1 < x2 ? 1 : -1
        let signY: Int = y1 < y2 ? 1 : -1
        var error: Int = deltaX - deltaY
        var cX: Int = x1, cY: Int = y1
        
        while cX != x2 || cY != y2 {
            if mode == .Highlight {
                instance.highlightTile(x: cX, y: cY)
            }
            
            let error2: Int = error * 2
            
            if error2 > -deltaY {
                error -= deltaY
                cX += signX
            }
            if error2 < deltaX {
                error += deltaX
                cY += signY
            }
            
            if mode == .Attack && ([WALL, DOOR, VENDOR].contains(instance.getTileFace(x: cX, y: cY)) || instance.isMonster(tileFace: instance.getTileFace(x: cX, y: cY))) {
                if instance.getTileFace(x: cX, y: cY) == VENDOR {
                    instance.flashTileFace(x: hero.actor.x, y: hero.actor.y, color: .Red, state: state)
                    state.addMessage(message: "\"You crazy!\"")
                    state.addMessage(message: "Shopkeeper ducks.")
                    return (nextX: cX, nextY: cY, isConnected: true)
                }
                if heroDamage(x: cX, y: cY, damageType: .Ranged) {
                    instance.setTileFace(x: cX, y: cY, ch: CORPSE)
                }
                return (nextX: cX, nextY: cY, isConnected: true)
            }
            
            if mode == .Clear && ([WALL, DOOR].contains(instance.getTileFace(x: cX, y: cY)) || instance.isMonster(tileFace: instance.getTileFace(x: cX, y: cY))) {
                return (nextX: cX, nextY: cY, isConnected: false)
            }
            
            if mode == .Move && ([WALL, DOOR, CHEST].contains(instance.getTileFace(x: cX, y: cY)) || instance.isMonster(tileFace: instance.getTileFace(x: cX, y: cY))) {
                return (nextX: cX, nextY: cY, isConnected: false)
            }
            
            if mode == .Path {
                return (nextX: cX, nextY: cY, isConnected: true)
            }
        }
        
        if mode == .Attack {
            heroDamage(x: cX, y: cY, damageType: .Ranged)
        }
        
        if mode == .Highlight {
            instance.highlightTile(x: cX, y: cY)
        }
        
        return (nextX: cX, nextY: cY, isConnected: true)
    }
    
    public func highlightLine(mX: Int, mY: Int) {
        if (0...instance.maxX).contains(hero.actor.x + hero.actor.dX + mX) {
            hero.actor.dX += mX
        }
        if (0...instance.maxY).contains(hero.actor.y + hero.actor.dY + mY) {
            hero.actor.dY += mY
        }
        
        instance.clearMapHighlights()
        state.clearMessages()
        state.addMessage(message: "Select a target to shoot. (\(getTileInfo(x: hero.actor.x + hero.actor.dX, y: hero.actor.y + hero.actor.dY)))")
        connectXY(x1: hero.actor.x, y1: hero.actor.y, x2: hero.actor.x + hero.actor.dX, y2: hero.actor.y + hero.actor.dY, mode: .Highlight)
    }
    
    public func shoot() {
        connectXY(x1: hero.actor.x, y1: hero.actor.y, x2: hero.actor.x + hero.actor.dX, y2: hero.actor.y + hero.actor.dY, mode: .Attack)
        instance.clearMapHighlights()
        hero.actor.dX = 0
        hero.actor.dY = 0
        if state.getState() != .End {
            state.setState(state: .Move)
        }
    }
    
    public func switchTarget() {
        var j: Int = 0, k: Int = 0
        let sortedMonsters: [Actor] = instance.getSortedMonsters(hero: hero)
        
        if sortedMonsters.count > 0 {
            for i in 0..<sortedMonsters.count {
                if sortedMonsters[i].x == hero.actor.x + hero.actor.dX && sortedMonsters[i].y == hero.actor.y + hero.actor.dY {
                    j = i
                    break
                }
            }
            j = j == sortedMonsters.count - 1 ? 0 : j + 1
            
            var locked: Bool = false
            
            for i in j..<sortedMonsters.count {
                let result = connectXY(x1: sortedMonsters[i].x, y1: sortedMonsters[i].y, x2: hero.actor.x, y2: hero.actor.y, mode: .Clear)
                if result.isConnected && instance.getMap()[sortedMonsters[i].y][sortedMonsters[i].x].isRevealed {
                    k = i
                    locked = true
                    break
                }
            }
            
            if !locked {
                for i in 0..<sortedMonsters.count {
                    let result = connectXY(x1: sortedMonsters[i].x, y1: sortedMonsters[i].y, x2: hero.actor.x, y2: hero.actor.y, mode: .Clear)
                    if result.isConnected && instance.getMap()[sortedMonsters[i].y][sortedMonsters[i].x].isRevealed {
                        k = i
                        locked = true
                        break
                    }
                }
            }
            
            if locked {
                hero.actor.dX = sortedMonsters[k].x - hero.actor.x
                hero.actor.dY = sortedMonsters[k].y - hero.actor.y
            }
        }
        
        instance.clearMapHighlights()
        connectXY(x1: hero.actor.x, y1: hero.actor.y, x2: hero.actor.x + hero.actor.dX, y2: hero.actor.y + hero.actor.dY, mode: .Highlight)
        state.addMessage(message: "Select a target to shoot. (\(getTileInfo(x: hero.actor.x + hero.actor.dX, y: hero.actor.y + hero.actor.dY)))")
    }
    
    public func cancelTarget() {
        instance.clearMapHighlights()
        state.clearMessages()
        hero.actor.dX = 0
        hero.actor.dY = 0
        state.setState(state: .Cancel)
    }

    private func autoPickup() {
        var bloodVialValue: Int = 0, goldCoinValue: Int = 0
        
        for m in MiscTypes {
            switch m.name {
                case "blood vial":
                    bloodVialValue = m.value
                case "gold coin":
                    goldCoinValue = m.value
                default:
                    break
            }
        }
        
        for i in 0..<instance.getItems().count {
            if instance.getItems()[i].x == hero.actor.x && instance.getItems()[i].y == hero.actor.y && instance.getItems()[i].tag == .Misc {
                switch instance.getItems()[i].name {
                    case "blood vial":
                        hero.actor.lifeCurrent += bloodVialValue
                        instance.markItem(i: i)
                        state.addMessage(message: "Picked up blood vial. (+\(bloodVialValue) life)")
                    case "gold coin":
                        var goldBoost: Int = 0
                        
                        for ring in hero.actor.rings {
                            if ring.name == "Gold Ring" {
                                goldBoost += goldCoinValue / 2
                            }
                        }
                    
                        hero.actor.gold += (goldCoinValue + goldBoost)
                        instance.markItem(i: i)
                        state.addMessage(message: "Picked up \(goldCoinValue + goldBoost) gold.")
                    default:
                        break
                }
            }
        }
        
        instance.removeMarkedItems()
    }

    private func checkTileItems(x: Int, y: Int) {
        if hero.actor.cell == PASS {
            return
        }
        
        for item in instance.getItems() {
            if item.x == x && item.y == y {
                state.addMessage(message: "You see something on the ground.")
                state.addMessage(message: "Do you want to check it out?")
                state.setState(state: .Pickup)
                state.hadAction = true
                break
            }
        }
    }
    
    public func confirmPickup() {
        var items: [Item] = instance.getShopItems()
        
        if items.count < 1 {
            for i in 0..<instance.getItems().count {
                if instance.getItems()[i].x == hero.actor.x && instance.getItems()[i].y == hero.actor.y {
                    items.append(Item(x: instance.getItems()[i].x, y: instance.getItems()[i].y, name: instance.getItems()[i].name, amount: instance.getItems()[i].amount, tag: instance.getItems()[i].tag, price: 0, isMarked: false, isPointed: false, description: instance.getItems()[i].description, reference: i))
                }
            }
            
            addItemPointer(items: &items)
            instance.setShopItems(items: items)
            instance.bufferMap()
        }
        
        state.clearMessages()
        drawFrame(x1: 3, y1: 2, x2: 36, y2: 17, header: "Pick up item(s)", footer: "")
        listItems(x: 5, y: 4, items: items)
        
        state.setState(state: .Ground)
    }
    
    public func pickupMarkedItems() {
        let items: [Item] = instance.getShopItems()
        var markedItemCount: Int = 0, ammoFoundCount: Int = 0
        
        for item in items {
            if item.isMarked {
                markedItemCount += 1
                if item.tag == .Ammo {
                    for i in hero.actor.inventory {
                        if i.name == item.name {
                            ammoFoundCount += 1
                            break
                        }
                    }
                }
            }
        }
        
        if markedItemCount == 0 {
            return
        }
        
        if markedItemCount - ammoFoundCount + hero.actor.inventory.count > hero.inventoryCapacity {
            instance.revertMap()
            instance.clearMapFrame()
            instance.clearMapMarks()
            instance.removeAllShopItems()
            state.setState(state: .Move)
            state.addMessage(message: "You're carrying too much.")
            return
        }
        
        for item in items {
            if !item.isMarked {
                continue
            }
            
            var found: Bool = false, itemName: String = ""
            
            switch item.tag {
                case .Ranged, .Melee, .Equip, .Keystone:
                    hero.actor.inventory.append(Item(x: 0, y: 0, name: item.name, amount: 1, tag: item.tag, price: 0, isMarked: false, isPointed: false, description: item.description))
                    state.addMessage(message: "Picked up \(item.name).")
                    state.hadAction = true
                case .Home, .Flash:
                    for i in 0..<hero.actor.inventory.count {
                        if hero.actor.inventory[i].name == item.name {
                            hero.actor.inventory[i].amount += item.amount
                            found = true
                        }
                    }
                    if !found {
                        hero.actor.inventory.append(Item(x: 0, y: 0, name: item.name, amount: item.amount, tag: item.tag, price: 0, isMarked: false, isPointed: false, description: item.description))
                    }
                    
                    itemName = item.name
                    if item.amount > 1 {
                        itemName += "s"
                    }
                    state.addMessage(message: "Picked up \(item.amount) \(itemName).")
                    state.hadAction = true
                case .Ammo:
                    var weapon: String = ""
                    
                    for ammo in AmmoTypes {
                        if ammo.name == item.name {
                            weapon = ammo.weapon
                            break
                        }
                    }
                
                    if hero.actor.ranged.name.lowercased().contains(weapon.lowercased()) {
                        hero.actor.ammo += item.amount
                        found = true
                    }
                
                    if !found {
                        for i in 0..<hero.actor.inventory.count {
                            if hero.actor.inventory[i].name == item.name {
                                hero.actor.inventory[i].amount += item.amount
                                found = true
                                break
                            }
                        }
                    }
                
                    if !found {
                        hero.actor.inventory.append(Item(x: 0, y: 0, name: item.name, amount: item.amount, tag: ItemTag.Ammo, price: 0, isMarked: false, isPointed: false, description: item.description))
                    }
                
                    itemName = item.name
                    if item.amount == 1 {
                        itemName = String(itemName.dropLast(1))
                    }
                    state.addMessage(message: "Picked up \(item.amount) \(itemName).")
                    state.hadAction = true
                default:
                    break
            }
        }
        
        var referencedItems: [Int] = []
        
        for i in 0..<instance.getShopItems().count {
            if instance.getShopItems()[i].isMarked {
                referencedItems.append(instance.getShopItems()[i].reference)
            }
        }
        instance.removeReferencedItems(reference: referencedItems)
        
        if hero.actor.cell != CORPSE {
            hero.actor.cell = PASS
            for i in 0..<instance.getItems().count {
                if instance.getItems()[i].x == hero.actor.x && instance.getItems()[i].y == hero.actor.y {
                    hero.actor.cell = hero.actor.cell != CORPSE ? CLIP : CORPSE
                    break
                }
            }
        }
        
        instance.revertMap()
        instance.clearMapFrame()
        instance.clearMapMarks()
        instance.removeAllShopItems()
        state.setState(state: .Move)
    }

    public func inspectTile() {
        state.clearMessages()
        instance.highlightTile(x: hero.actor.x, y: hero.actor.y)
        state.addMessage(message: "Select a target to examine. (\(getTileInfo(x: hero.actor.x, y: hero.actor.y)))")
        state.setState(state: .Inspect)
    }
    
    private func getTileInfo(x: Int, y: Int) -> String {
        if !instance.getMap()[y][x].isRevealed {
            return "unrevealed"
        }
        if hero.isBlind() {
            return "???"
        }
        
        let tileFace: String = instance.getTileFace(x: x, y: y)
        
        if instance.isMonster(tileFace: tileFace) {
            for m in MonsterTypes {
                if tileFace == m.face {
                    return m.name
                }
            }
        }
        
        switch tileFace {
            case WALL:
                return "wall"
            case PASS:
                return "floor"
            case SPACE:
                return "unrevealed"
            case DOOR:
                return "black fog"
            case CORPSE:
                return "dead body"
            case CHEST:
                return "chest"
            case CLIP:
                return "item pile"
            case WAYPOINT:
                return "device"
            case VENDOR:
                return "shopkeeper"
            case STASH:
                return "stash"
            case STONE:
                return "stone"
            case GATE:
                return "gate"
            case hero.actor.face:
                return "yourself"
            default:
                return "no info"
        }
    }
    
    public func moveTileHighlight(mX: Int, mY: Int) {
        if let highlightedTilePosition = instance.getHighlightedTilePosition() {
            let x: Int = highlightedTilePosition.x
            let y: Int = highlightedTilePosition.y
        
            instance.clearMapHighlights()
            state.clearMessages()
            
            let newX: Int = (0...instance.maxX).contains(x + mX) ? x + mX : x
            let newY: Int = (0...instance.maxY).contains(y + mY) ? y + mY : y
            
            state.addMessage(message: "Select a target to examine. (\(getTileInfo(x: newX, y: newY)))")
            instance.highlightTile(x: newX, y: newY)
        }
    }
    
    public func showHighlightedTileInfo() {
        if let highlightedTilePosition = instance.getHighlightedTilePosition() {
            let x: Int = highlightedTilePosition.x
            let y: Int = highlightedTilePosition.y
            
            instance.clearMapHighlights()
            state.clearMessages()
            
            if !instance.getMap()[y][x].isRevealed {
                state.addMessage(message: "Unrevealed spot.")
                return
            }
            
            let tileFace: String = instance.getTileFace(x: x, y: y)
            
            if instance.isMonster(tileFace: tileFace) {
                for m in MonsterTypes {
                    if tileFace == m.face {
                        var damage: String = "", damageType: String = ""
                        
                        state.addMessage(message: "\(capitalizeFirst(string: m.name)).")
                        
                        for w in RangedTypes {
                            if w.name == m.weapon {
                                damageType = "ranged"
                                damage = w.minDamage == w.maxDamage ? "\(w.minDamage)" : "\(w.minDamage)-\(w.maxDamage)"
                                break
                            }
                        }
                        
                        if damageType.isEmpty {
                            for w in MeleeTypes {
                                if w.name == m.weapon {
                                    damageType = "melee"
                                    damage = w.minDamage == w.maxDamage ? "\(w.minDamage)" : "\(w.minDamage)-\(w.maxDamage)"
                                    break
                                }
                            }
                        }
                        
                        state.addMessage(message: "Damage: \(damage) (\(damageType))")
                        
                        if !m.description.isEmpty {
                            state.addMessage(message: "\(m.description)")
                        }
                    }
                }
                
                return
            }
            
            switch tileFace {
                case WALL:
                    state.addMessage(message: "It's a wall.")
                case PASS:
                    state.addMessage(message: "It's a floor.")
                case SPACE:
                    state.addMessage(message: "Unrevealed spot.")
                case DOOR:
                    state.addMessage(message: "Black fog passage.")
                case CORPSE:
                    state.addMessage(message: "A dead body.")
                case CHEST:
                    state.addMessage(message: "A treasure chest!")
                case CLIP:
                    state.addMessage(message: "Something you dropped.")
                case WAYPOINT:
                    state.addMessage(message: "A strange device.")
                case VENDOR:
                    state.addMessage(message: "Shopkeeper Grindstead. He wants your gold.")
                case STASH:
                    state.addMessage(message: "Your private stash.")
                case STONE:
                    state.addMessage(message: "Human-sized stone with engraved writings.")
                case GATE:
                    state.addMessage(message: "Some massive gate.")
                case hero.actor.face:
                    state.addMessage(message: "\(hero.actor.name). Loaded with power.")
                default:
                    state.addMessage(message: "No info.")
            }
        }
    }
    
    public func useWarpCrystal() {
        state.clearMessages()
        
        if hero.canWarp() {
            var didWarp: Bool = false
            
            for room in instance.getRooms() {
                if ((room.x1 + 1)...(room.x2 - 1)).contains(hero.actor.x) && ((room.y1 + 1)...(room.y2 - 1)).contains(hero.actor.y) {
                    warp(x1: room.x1, y1: room.y1, x2: room.x2, y2: room.y2, tX: hero.actor.x, tY: hero.actor.y)
                    didWarp = true
                    break
                }
            }
            
            if !didWarp {
                warp(x1: hero.actor.x, y1: hero.actor.y, x2: hero.actor.x, y2: hero.actor.y, tX: hero.actor.x, tY: hero.actor.y)
            }
            
            instance.revealRoom(hero: hero)
        } else {
            state.addMessage(message: "Still recharging.")
        }
        
        state.setState(state: .Cancel)
    }
    
    private func warp(x1: Int, y1: Int, x2: Int, y2: Int, tX: Int, tY: Int) {
        var x: Int = 0, y: Int = 0
        
        while true {
            var done: Bool = false
            
            x = Int.random(in: 1..<instance.maxX)
            y = Int.random(in: 1..<instance.maxY)
            
            if instance.getTileFace(x: x, y: y) != PASS {
                continue
            }
            if ((x1 + 1)...(x2 - 1)).contains(x) && ((y1 + 1)...(y2 - 1)).contains(y) {
                continue
            }
            
            for room in instance.getRooms() {
                if ((room.x1 + 1)...(room.x2 - 1)).contains(x) && ((room.y1 + 1)...(room.y2 - 1)).contains(y) {
                    if room.x1 == x1 && room.y1 == y1 && room.x2 == x2 && room.y2 == y2 {
                        continue
                    }
                    done = true
                    break
                }
            }
            
            if done {
                break
            }
        }
        
        if tX == hero.actor.x && tY == hero.actor.y {
            instance.flashTileFace(x: hero.actor.x, y: hero.actor.y, color: .Green, state: state)
            instance.setTileFace(x: hero.actor.x, y: hero.actor.y, ch: hero.actor.cell)
            hero.actor.x = x
            hero.actor.y = y
            hero.actor.cell = PASS
            instance.setTileFace(x: hero.actor.x, y: hero.actor.y, ch: hero.actor.face)
            hero.setWarpCounter(value: 0)
            return
        }
        
        for i in 0..<instance.getMonsters().count {
            if tX == instance.getMonsters()[i].x && tY == instance.getMonsters()[i].y {
                instance.flashTileFace(x: instance.getMonsters()[i].x, y: instance.getMonsters()[i].y, color: .Green, state: state)
                instance.setTileFace(x: instance.getMonsters()[i].x, y: instance.getMonsters()[i].y, ch: instance.getMonsters()[i].cell)
                instance.setMonsterLocation(i: i, x: x, y: y)
                instance.setMonsterCell(i: i, value: PASS)
                instance.setTileFace(x: instance.getMonsters()[i].x, y: instance.getMonsters()[i].y, ch: instance.getMonsters()[i].face)
            }
        }
    }
    
    public func useLifeFlask() {
        if hero.getMedpackCharge() >= hero.medpackHealAmount {
            hero.setMedpackCharge(value: hero.getMedpackCharge() - hero.medpackHealAmount)
            instance.flashTileFace(x: hero.actor.x, y: hero.actor.y, color: .Blue, state: state)
            
            var boostHeal: Int = 0
            
            for r in hero.actor.rings {
                if r.name == "Ancient Ring" {
                    boostHeal += hero.medpackHealAmount / 2
                }
            }
            hero.actor.lifeCurrent += hero.medpackHealAmount + boostHeal
            
            state.clearMessages()
            state.addMessage(message: "Gained \(hero.medpackHealAmount + boostHeal) life.")
        } else {
            state.clearMessages()
            state.addMessage(message: "Your flask is empty.")
        }
        
        state.setState(state: .Move)
    }
    
    private func openGate() {
        var found: Bool = false
        
        for i in 0..<hero.actor.inventory.count {
            if hero.actor.inventory[i].name == "keystone" {
                found = true
                hero.actor.inventory.remove(at: i)
                state.addMessage(message: "The gate is open.")
                instance.openGateRoom()
                break
            }
        }
        
        if !found {
            state.addMessage(message: "\"l16NqdRQz6yNm9ixt37q4hRaMLSPLEWdYFuZcY5MAQli\"")
            state.addMessage(message: "You see a keyhole on the side.")
        }
    }
    
    public func enterDungeon() {
        state.addMessage(message: "Survive the dungeon and escape!")
        state.setState(state: .Cancel)
        
        for i in 0..<instance.getShopItems().count {
            if instance.getShopItems()[i].isPointed {
                instance.setDepth(depth: i * 10 + 1)
                break
            }
        }
        
        instance.removeAllShopItems()
        instance.clearMapFrame()
        hero.setWarpCounter(value: hero.getWarpCounter() + 1)
        instance.createNew(hero: hero)
    }
    
    private func showWaypoint() {
        if instance.getShopItems().count < 1 {
            for i in 0...hero.getProgression() {
                if i % 10 == 1 {
                    instance.addShopItem(item: Item(x: 0, y: 0, name: i < 10 ? "\(i)" : "\(i)", amount: 0, tag: ItemTag.Waypoint, price: 0, isMarked: false, isPointed: false, description: ""))
                }
            }
        }

        drawFrame(x1: 3, y1: 2, x2: 36, y2: 16, header: "Destination", footer: "")
        
        var waypoints: [Item] = instance.getShopItems()
        
        addItemPointer(items: &waypoints)
        instance.setShopItems(items: waypoints)
        listItems(x: 5, y: 4, items: waypoints)
    }
    
    private func displayShopItems() {
        if instance.getShopItems().count < 1 {
            instance.addShopItem(item: Item(x: 0, y: 0, name: "flash bomb", amount: 1, tag: ItemTag.Flash, price: 200, isMarked: false, isPointed: true, description: ""))
            instance.addShopItem(item: Item(x: 0, y: 0, name: "homeward scroll", amount: 1, tag: ItemTag.Home, price: 300, isMarked: false, isPointed: false, description: ""))
            instance.addShopItem(item: Item(x: 0, y: 0, name: "life flask refill", amount: 1, tag: ItemTag.Flask, price: 500, isMarked: false, isPointed: false, description: ""))
            for a in AmmoTypes {
                if a.name != EMPTY {
                    instance.addShopItem(item: Item(x: 0, y: 0, name: a.name, amount: a.quantity, tag: ItemTag.Ammo, price: a.price, isMarked: false, isPointed: false, description: ""))
                }
            }
        }
        
        drawFrame(x1: 3, y1: 2, x2: 36, y2: 17, header: "For sale", footer: "Gold: \(hero.actor.gold)")
        
        var shop: [Item] = instance.getShopItems()
        
        addItemPointer(items: &shop)
        instance.setShopItems(items: shop)
        listItems(x: 5, y: 4, items: instance.getShopItems())
    }
    
    public func buyItem() {
        for item in instance.getShopItems() {
            if item.isPointed {
                if (item.price * item.amount) <= hero.actor.gold {
                    var found: Bool = false
                    
                    switch item.tag {
                        case ItemTag.Flash, ItemTag.Home:
                            for i in 0..<hero.actor.inventory.count {
                                if hero.actor.inventory[i].name == item.name { // found in inventory
                                    hero.actor.inventory[i].amount += item.amount
                                    found = true
                                }
                            }
                        case ItemTag.Flask:
                            if hero.getMedpackCharge() < hero.medpackCapacity {
                                hero.setMedpackCharge(value: hero.medpackCapacity)
                                found = true
                            } else {
                                state.addMessage(message: "Your flask is full.")
                                return
                            }
                        case ItemTag.Ammo:
                            var weapon: String = ""
                        
                            for a in AmmoTypes {
                                if item.name == a.name {
                                    weapon = a.weapon
                                }
                            }
                            if hero.actor.ranged.name.lowercased().contains(weapon.lowercased()) { // ammo for equipped gun?
                                hero.actor.ammo += item.amount
                                found = true
                            } else {
                                for i in 0..<hero.actor.inventory.count {
                                    if hero.actor.inventory[i].name == item.name { // found in inventory
                                        hero.actor.inventory[i].amount += item.amount
                                        found = true
                                        break
                                    }
                                }
                            }
                        default:
                            break
                    }
                    
                    if !found {
                        if hero.actor.inventory.count < hero.inventoryCapacity {
                            hero.actor.inventory.append(Item(x: 0, y: 0, name: item.name, amount: item.amount, tag: item.tag, price: item.price, isMarked: false, isPointed: false, description: item.description))
                            found = true
                        } else {
                            state.addMessage(message: "Your inventory is full.")
                            break
                        }
                    }
                    
                    if found {
                        state.addMessage(message: "\"Thank you kindly.\"")
                        state.addMessage(message: "Purchased \(item.amount) \(item.name).")
                        hero.actor.gold -= (item.price * item.amount)
                        drawFrame(x1: 3, y1: 2, x2: 36, y2: 17, header: "For sale", footer: "Gold: \(hero.actor.gold)")
                        listItems(x: 5, y: 4, items: instance.getShopItems())
                        state.hadAction = true
                    }
                } else {
                    state.addMessage(message: "You can't afford it.")
                }
                
                break
            }
        }
    }
    
    public func displayInventoryItems() {
        drawFrame(x1: 3, y1: 2, x2: 36, y2: 17, header: "Inventory", footer: "Gold: \(hero.actor.gold)")
        addItemPointer(items: &hero.actor.inventory)
        
        if hero.actor.inventory.count < 1 {
            writeText(x: 5, y: 4, text: "Nothing here.")
        } else {
            listItems(x: 5, y: 4, items: hero.actor.inventory)
        }
    }
    
    public func dropItem() {
        if hero.actor.inventory.count < 1 {
            return
        }
        
        var name: String = ""
        var amount: Int = 0
        var tag: ItemTag = .Home
        
        for i in 0..<hero.actor.inventory.count {
            if hero.actor.inventory[i].isPointed {
                name = hero.actor.inventory[i].name
                amount = hero.actor.inventory[i].amount
                tag = hero.actor.inventory[i].tag
                
                instance.addItem(item: Item(x: hero.actor.x, y: hero.actor.y, name: name, amount: amount, tag: tag, price: 0, isMarked: false, isPointed: false, description: hero.actor.inventory[i].description))
                
                hero.actor.inventory.remove(at: i)
                
                break
            }
        }
        
        if hero.actor.cell != CORPSE {
            hero.actor.cell = CLIP
        }
        
        switch tag {
            case .Ammo, .Flash, .Home:
                if amount == 1 && tag == .Ammo {
                    name = String(name.dropLast(1))
                }
                if amount > 1 && [ItemTag.Flash, ItemTag.Home].contains(tag) {
                    name += "s"
                }
                state.addMessage(message: "Dropped \(amount) \(name).")
            default:
                state.addMessage(message: "Dropped \(name).")
        }
        
        instance.revertMap()
        instance.clearMapFrame()
        removeItemPointer(items: &hero.actor.inventory)
        state.setState(state: .Move)
    }
    
    public func useItem() {
        if hero.actor.inventory.count < 1 {
            return
        }
        
        for i in 0..<hero.actor.inventory.count {
            if hero.actor.inventory[i].isPointed {
                switch hero.actor.inventory[i].tag {
                    case .Flash:
                        hero.actor.inventory[i].amount -= 1
                        if hero.actor.inventory[i].amount <= 0 {
                            hero.actor.inventory.remove(at: i)
                        }
                    
                        instance.revertMap()
                        instance.clearMapFrame()
                        removeItemPointer(items: &hero.actor.inventory)
                        
                        var rX1: Int = 0, rY1: Int = 0, rX2: Int = 0, rY2: Int = 0
                        
                        for room in instance.getRooms() {
                            if ((room.x1 + 1)...(room.x2 - 1)).contains(hero.actor.x) && ((room.y1 + 1)...(room.y2 - 1)).contains(hero.actor.y) {
                                rX1 = room.x1 + 1
                                rY1 = room.y1 + 1
                                rX2 = room.x2 - 1
                                rY2 = room.y2 - 1
                                break
                            }
                        }
                    
                        instance.bufferMap()
                    
                        if rX1 == 0 {
                            for j in (hero.actor.y - 1)...(hero.actor.y + 1) {
                                for k in (hero.actor.x - 1)...(hero.actor.x + 1) {
                                    for m in 0..<instance.getMonsters().count {
                                        if instance.getMonsters()[m].x == k && instance.getMonsters()[m].y == j {
                                            instance.setMonsterBlindCounter(i: m, value: 0)
                                            if instance.getTileFace(x: k, y: j) != WALL {
                                                instance.setTileFace(x: k, y: j, ch: "\u{2588}")
                                                instance.markTile(x: k, y: j)
                                                state.setFlashState(state: .White)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    
                        if rX1 > 0 {
                            for m in 0..<instance.getMonsters().count {
                                if (rX1...rX2).contains(instance.getMonsters()[m].x) && (rY1...rY2).contains(instance.getMonsters()[m].y) && instance.getMonsters()[m].isAlive {
                                    instance.setMonsterBlindCounter(i: m, value: 0)
                                }
                            }
                            for j in rY1...rY2 {
                                for k in rX1...rX2 {
                                    instance.setTileFace(x: k, y: j, ch: "\u{2588}")
                                }
                            }
                            instance.markArea(x1: rX1, y1: rY1, x2: rX2, y2: rY2, isMarked: true)
                            state.setFlashState(state: .White)
                        }
                    
                        instance.invalidate()
                        DispatchQueue.main.asyncAfter(deadline: .now() + FLASH_DELAY) {
                            self.instance.clearMapMarks()
                            self.state.setFlashState(state: .None)
                            self.state.setState(state: .Move)
                            self.instance.revertMap()
                            self.instance.invalidate()
                        }
                    case .Home:
                        hero.actor.inventory[i].amount -= 1
                        if hero.actor.inventory[i].amount <= 0 {
                            hero.actor.inventory.remove(at: i)
                        }
                    
                        instance.clearMapFrame()
                        removeItemPointer(items: &hero.actor.inventory)
                        instance.revertMap()
                        instance.flashTileFace(x: hero.actor.x, y: hero.actor.y, color: .Green, state: state)
                        state.clearMessages()
                        hero.actor.cell = PASS
                        hero.actor.x = 1
                        hero.actor.y = instance.maxY - 1
                        if hero.actor.lifeCurrent < 100 {
                            hero.actor.lifeCurrent = 100
                        }
                        instance.setDepth(depth: 0)
                        state.setState(state: .Move)
                        instance.createTown(hero: hero)
                        instance.invalidate()
                    default:
                        break
                }
                
                break
            }
        }
    }
    
    public func equipItem() {
        if hero.actor.inventory.count < 1 {
            return
        }
        
        var selectedItem: Item = Item(x: 0, y: 0, name: EMPTY, amount: 0, tag: .Home, price: 0, isMarked: false, isPointed: false, description: "")
        var selectedIndex: Int = -1
        
        for i in 0..<hero.actor.inventory.count {
            if hero.actor.inventory[i].isPointed {
                selectedItem = Item(x: hero.actor.inventory[i].x, y: hero.actor.inventory[i].y, name: hero.actor.inventory[i].name, amount: hero.actor.inventory[i].amount, tag: hero.actor.inventory[i].tag, price: 0, isMarked: false, isPointed: false, description: hero.actor.inventory[i].description)
                selectedIndex = i
                break
            }
        }

        if [ItemTag.Home, ItemTag.Flash, ItemTag.Ammo].contains(selectedItem.tag) {
            return
        }

        if hero.actor.inventory.count == hero.inventoryCapacity && selectedItem.tag == .Ranged {
            var ammoName: String = ""
            var found: Bool = false
            
            for ammo in AmmoTypes {
                if selectedItem.name.lowercased().contains(ammo.weapon.lowercased()) {
                    ammoName = ammo.name
                    break
                }
            }
            
            for item in hero.actor.inventory {
                if item.name == ammoName {
                    found = true
                    break
                }
            }
            
            if !found && hero.actor.ammo > 0 {
                instance.revertMap()
                instance.clearMapFrame()
                removeItemPointer(items: &hero.actor.inventory)
                state.setState(state: .Move)
                state.addMessage(message: "You're carrying too much.")
                return
            }
        }
        
        switch selectedItem.tag {
            case .Melee:
                for m in MeleeTypes {
                    if m.name == selectedItem.name {
                        if hero.actor.melee.name == MeleeTypes[0].name {
                            hero.actor.inventory.remove(at: selectedIndex)
                        } else {
                            hero.actor.inventory[selectedIndex] = Item(x: 0, y: 0, name: hero.actor.melee.name, amount: 1, tag: .Melee, price: 0, isMarked: false, isPointed: true, description: hero.actor.melee.description)
                        }
                        hero.actor.melee = m
                        state.addMessage(message: "\(capitalizeFirst(string: m.name)) equipped.")
                        break
                    }
                }
            case .Ranged:
                hero.actor.inventory[selectedIndex] = Item(x: 0, y: 0, name: hero.actor.ranged.name, amount: 1, tag: .Ranged, price: 0, isMarked: false, isPointed: true, description: hero.actor.ranged.description)
                
                for r in RangedTypes {
                    if r.name == selectedItem.name {
                        hero.actor.ranged = r
                        state.addMessage(message: "\(capitalizeFirst(string: r.name)) equipped.")
                        break
                    }
                }
                
                var swapAmmo: String = "", swapAmount: Int = 0, ammoName: String = "", ammoPrice: Int = 0
                var found: Bool = false
            
                for ammo in AmmoTypes {
                    if selectedItem.name.lowercased().contains(ammo.weapon.lowercased()) {
                        swapAmmo = ammo.name
                    }
                    if hero.actor.inventory[selectedIndex].name.lowercased().contains(ammo.weapon.lowercased()) {
                        ammoName = ammo.name
                        ammoPrice = ammo.price
                    }
                }
                
                if swapAmmo != ammoName {
                    for i in 0..<hero.actor.inventory.count {
                        if hero.actor.inventory[i].name == swapAmmo {
                            found = true
                            swapAmount = hero.actor.inventory[i].amount
                            if hero.actor.ammo < 1 {
                                hero.actor.inventory.remove(at: i)
                            } else {
                                hero.actor.inventory[i] = Item(x: 0, y: 0, name: ammoName, amount: hero.actor.ammo, tag: .Ammo, price: ammoPrice, isMarked: false, isPointed: false, description: "")
                            }
                            break
                        }
                    }
                    
                    if !found && hero.actor.ammo > 0 {
                        hero.actor.inventory.append(Item(x: 0, y: 0, name: ammoName, amount: hero.actor.ammo, tag: .Ammo, price: ammoPrice, isMarked: false, isPointed: false, description: ""))
                    }
                    
                    hero.actor.ammo = swapAmount
                    hero.actor.inventory.removeAll(where: {$0.name == EMPTY})
                } else {
                    for i in 0..<hero.actor.inventory.count {
                        if hero.actor.inventory[i].name == swapAmmo {
                            hero.actor.ammo += hero.actor.inventory[i].amount
                            hero.actor.inventory.remove(at: i)
                            break
                        }
                    }
                }
            case .Equip:
                for e in EquipTypes {
                    if selectedItem.name == e.name {
                        var equipName: String = EMPTY, equipDescription: String = "", equipArmorValue: Int = 0
                        
                        switch e.type {
                            case .Head:
                                equipName = hero.actor.head.name
                                equipDescription = hero.actor.head.description
                                equipArmorValue = hero.actor.head.armorValue
                                hero.actor.head = e
                            case .Chest:
                                equipName = hero.actor.chest.name
                                equipDescription = hero.actor.chest.description
                                equipArmorValue = hero.actor.chest.armorValue
                                hero.actor.chest = e
                            case .Gloves:
                                equipName = hero.actor.gloves.name
                                equipDescription = hero.actor.gloves.description
                                equipArmorValue = hero.actor.gloves.armorValue
                                hero.actor.gloves = e
                            case .Legs:
                                equipName = hero.actor.legs.name
                                equipDescription = hero.actor.legs.description
                                equipArmorValue = hero.actor.legs.armorValue
                                hero.actor.legs = e
                            case .Ring:
                                state.addMessage(message: "Select a ring slot.")
                                state.setState(state: .Ring)
                                return
                            default:
                                break
                        }
                        
                        hero.actor.armor += e.armorValue - equipArmorValue
                        state.addMessage(message: "\(capitalizeFirst(string: selectedItem.name)) equipped.")
                        
                        for i in 0..<hero.actor.inventory.count {
                            if hero.actor.inventory[i].name == selectedItem.name {
                                if equipName != EMPTY {
                                    hero.actor.inventory[i] = Item(x: 0, y: 0, name: equipName, amount: 1, tag: .Equip, price: 0, isMarked: false, isPointed: true, description: equipDescription)
                                } else {
                                    hero.actor.inventory.remove(at: i)
                                }
                                break
                            }
                        }
                    }
                }
            default:
                break
        }
        
        instance.revertMap()
        instance.clearMapFrame()
        removeItemPointer(items: &hero.actor.inventory)
        state.setState(state: .Move)
    }
    
    public func equipRing(ringType: RingType) {
        var selectedName: String = "", selectedIndex: Int = -1
        var equippedName: String = "", equippedDescription: String = "", equippedArmorValue: Int = 0, equippedIndex: Int = -1
        
        for i in 0..<hero.actor.inventory.count {
            if hero.actor.inventory[i].isPointed {
                selectedName = hero.actor.inventory[i].name
                selectedIndex = i
                break
            }
        }
        
        for e in EquipTypes {
            if e.name == selectedName {
                switch ringType {
                    case .Left:
                        equippedIndex = 0
                    case .Right:
                        equippedIndex = 1
                }
                
                equippedName = hero.actor.rings[equippedIndex].name
                equippedDescription = hero.actor.rings[equippedIndex].description
                equippedArmorValue = hero.actor.rings[equippedIndex].armorValue
                hero.actor.rings[equippedIndex] = e
                hero.actor.armor += e.armorValue - equippedArmorValue
                state.clearMessages()
                state.addMessage(message: "\(capitalizeFirst(string: selectedName)) equipped.")
                
                if equippedName != EMPTY {
                    hero.actor.inventory[selectedIndex] = Item(x: 0, y: 0, name: equippedName, amount: 1, tag: .Equip, price: 0, isMarked: false, isPointed: true, description: equippedDescription)
                } else {
                    hero.actor.inventory.remove(at: selectedIndex)
                }

                break
            }
        }
        
        instance.revertMap()
        instance.clearMapFrame()
        removeItemPointer(items: &hero.actor.inventory)
        state.setState(state: .Move)
    }
    
    public func displayStashItems() {
        var items: [Item] = []
        var tX: Int = 0, tY: Int = 0
        
        if state.getState() == .StashTab2 {
            tX = 1
            tY = 1
        }
        
        switch state.getState() {
            case .StashTab1:
                addItemPointer(items: &hero.actor.inventory)
                items = hero.actor.inventory
                drawFrame(x1: 4, y1: 3, x2: 37, y2: 17, header: "Stash", footer: "< Inventory")
                drawFrame(x1: 3, y1: 2, x2: 36, y2: 16, header: "Inventory", footer: "Stash >")
            case .StashTab2:
                addItemPointer(items: &hero.actor.stash)
                items = hero.actor.stash
                drawFrame(x1: 3, y1: 2, x2: 36, y2: 16, header: "Inventory", footer: "Stash >")
                drawFrame(x1: 4, y1: 3, x2: 37, y2: 17, header: "Stash", footer: "< Inventory")
            default:
                break
        }
        
        if items.count < 1 {
            writeText(x: 5 + tX, y: 4 + tY, text: "Nothing here.")
        } else {
            listItems(x: 5, y: 4, items: items)
        }
    }
    
    public func displayEquipment() {
        if instance.getShopItems().count < 1 {
            instance.addShopItem(item: Item(x: 0, y: 0, name: hero.actor.head.name, amount: 1, tag: .Equip, price: 0, isMarked: false, isPointed: false, description: hero.actor.head.description))
            instance.addShopItem(item: Item(x: 0, y: 0, name: hero.actor.chest.name, amount: 1, tag: .Equip, price: 0, isMarked: false, isPointed: false, description: hero.actor.chest.description))
            instance.addShopItem(item: Item(x: 0, y: 0, name: hero.actor.gloves.name, amount: 1, tag: .Equip, price: 0, isMarked: false, isPointed: false, description: hero.actor.gloves.description))
            instance.addShopItem(item: Item(x: 0, y: 0, name: hero.actor.legs.name, amount: 1, tag: .Equip, price: 0, isMarked: false, isPointed: false, description: hero.actor.legs.description))
            for ring in hero.actor.rings {
                instance.addShopItem(item: Item(x: 0, y: 0, name: ring.name, amount: 1, tag: .Equip, price: 0, isMarked: false, isPointed: false, description: ring.description))
            }
            instance.addShopItem(item: Item(x: 0, y: 0, name: hero.actor.ranged.name, amount: 1, tag: .Ranged, price: 0, isMarked: false, isPointed: false, description: hero.actor.ranged.description))
            instance.addShopItem(item: Item(x: 0, y: 0, name: hero.actor.melee.name, amount: 1, tag: .Melee, price: 0, isMarked: false, isPointed: false, description: hero.actor.melee.description))
        }
        
        var items: [Item] = instance.getShopItems()
        
        addItemPointer(items: &items)
        instance.setShopItems(items: items)
        
        drawFrame(x1: 3, y1: 4, x2: 36, y2: 15, header: "Equipment", footer: "")
        listItems(x: 5, y: 4, items: items)
    }
    
    public func unequipItem() {
        let items: [Item] = instance.getShopItems()
        var position: Int = -1, ammoAmout: Int = 0, ammoName: String = ""
        var item: Item = Item(x: 0, y: 0, name: EMPTY, amount: 1, tag: .Misc, price: 0, isMarked: false, isPointed: false, description: "")
        var action: String = "Removed"
        
        for i in 0..<items.count {
            if items[i].isPointed {
                position = i
                break
            }
        }
        
        switch position {
            case 0:
                item = Item(x: 0, y: 0, name: hero.actor.head.name, amount: 1, tag: .Equip, price: 0, isMarked: false, isPointed: false, description: hero.actor.head.description)
                hero.actor.head = EquipTypes[0]
            case 1:
                item = Item(x: 0, y: 0, name: hero.actor.chest.name, amount: 1, tag: .Equip, price: 0, isMarked: false, isPointed: false, description: hero.actor.chest.description)
                hero.actor.chest = EquipTypes[0]
            case 2:
                item = Item(x: 0, y: 0, name: hero.actor.gloves.name, amount: 1, tag: .Equip, price: 0, isMarked: false, isPointed: false, description: hero.actor.gloves.description)
                hero.actor.gloves = EquipTypes[0]
            case 3:
                item = Item(x: 0, y: 0, name: hero.actor.legs.name, amount: 1, tag: .Equip, price: 0, isMarked: false, isPointed: false, description: hero.actor.legs.description)
                hero.actor.legs = EquipTypes[0]
            case 4...(4 + hero.actor.rings.count - 1):
                item = Item(x: 0, y: 0, name: hero.actor.rings[position - 4].name, amount: 1, tag: .Equip, price: 0, isMarked: false, isPointed: false, description: hero.actor.rings[position - 4].description)
                hero.actor.rings[position - 4] = EquipTypes[0]
            case 4 + hero.actor.rings.count:
                item = Item(x: 0, y: 0, name: hero.actor.ranged.name, amount: 1, tag: .Ranged, price: 0, isMarked: false, isPointed: false, description: hero.actor.ranged.description)
                for ammo in AmmoTypes {
                    if hero.actor.ranged.name.lowercased().contains(ammo.weapon.lowercased()) {
                        ammoName = ammo.name
                        break
                    }
                }
                hero.actor.ranged = RangedTypes[0]
                ammoAmout = hero.actor.ammo
                hero.actor.ammo = 0
            case 5 + hero.actor.rings.count:
                item = Item(x: 0, y: 0, name: hero.actor.melee.name, amount: 1, tag: .Melee, price: 0, isMarked: false, isPointed: false, description: hero.actor.melee.description)
                hero.actor.melee = MeleeTypes[0]
            default:
                break
        }
        
        if item.name == EMPTY || item.name == MeleeTypes[0].name {
            return
        }
        
        if item.tag == .Equip {
            for e in EquipTypes {
                if item.name == e.name {
                    hero.actor.armor -= e.armorValue
                    break
                }
            }
        }
        
        if hero.actor.inventory.count == hero.inventoryCapacity || (item.tag == .Ranged && hero.actor.inventory.count >= hero.inventoryCapacity - 1) {
            action = "Dropped"
            item.x = hero.actor.x
            item.y = hero.actor.y
            
            instance.addItem(item: item)
            if item.tag == .Ranged && ammoAmout > 0 {
                instance.addItem(item: Item(x: hero.actor.x, y: hero.actor.y, name: ammoName, amount: ammoAmout, tag: .Ammo, price: 0, isMarked: false, isPointed: false, description: ""))
            }
            
            if hero.actor.cell != CORPSE {
                hero.actor.cell = CLIP
            }
        }
        
        if action == "Removed" {
            hero.actor.inventory.append(item)
            
            var found: Bool = false
            
            if item.tag == .Ranged && ammoAmout > 0 {
                for i in 0..<hero.actor.inventory.count {
                    if hero.actor.inventory[i].name == ammoName {
                        hero.actor.inventory[i].amount += ammoAmout
                        found = true
                        break
                    }
                }
                
                if !found {
                    hero.actor.inventory.append(Item(x: 0, y: 0, name: ammoName, amount: ammoAmout, tag: .Ammo, price: 0, isMarked: false, isPointed: false, description: ""))
                }
            }
        }
        
        if item.tag == .Ranged && ammoAmout > 0 {
            if ammoAmout == 1 {
                ammoName = String(ammoName.dropLast(1))
            }
            state.addMessage(message: "\(action) \(item.name) and \(ammoAmout) \(ammoName).")
        } else {
            state.addMessage(message: "\(action) \(item.name).")
        }
                
        instance.revertMap()
        instance.clearMapFrame()
        instance.removeAllShopItems()
        state.setState(state: .Move)
    }
    
    private func listItems(x: Int, y: Int, items: [Item]) {
        var iY: Int = y, tX: Int = 0, tY: Int = 0, pX: Int = 0
        var slot: String = ""
        
        if state.getState() == .StashTab2 {
            tX = 1
            tY = 1
        }
        
        if state.getState() == .Equipment {
            tY = 2
        }
        
        instance.clearMapMarks()
        
        for i in 0..<items.count {
            if items[i].isPointed {
                pX = 1
            } else {
                pX = 0
            }
            
            if items[i].isMarked {
                instance.markArea(x1: x + tX + pX, y1: iY + tY, x2: 35, y2: iY + tY, isMarked: true)
            }
            
            if state.getState() == .Equipment {
                switch i {
                    case 0:
                        slot = "Head"
                    case 1:
                        slot = "Chest"
                    case 2:
                        slot = "Gloves"
                    case 3:
                        slot = "Legs"
                    case 4...(4 + hero.actor.rings.count - 1):
                        slot = i == 4 ? "Left ring" : "Right ring"
                    case 4 + hero.actor.rings.count:
                        slot = "Ranged"
                    case 5 + hero.actor.rings.count:
                        slot = "Melee"
                    default:
                        break
                }
            }
            
            writeText(x: x + tX, y: iY + tY, text: (items[i].isPointed ? ">" : " ") + (!slot.isEmpty ? "\(slot): " : "") + (items[i].name != EMPTY ? items[i].name : "") + ([ItemTag.Ammo, ItemTag.Flash, ItemTag.Home].contains(items[i].tag) ? " (\(items[i].amount))" : "") + (state.getState() == .Shop ? " - \(items[i].price * items[i].amount)g" : ""))
            
            iY += 1
        }
    }
    
    private func addItemPointer(items: inout [Item]) {
        if items.count > 0 {
            var found: Bool = false
            
            for item in items {
                if item.isPointed {
                    found = true
                    break
                }
            }
            
            if !found {
                items[0].isPointed = true
            }
        }
    }
    
    public func removeItemPointer(items: inout [Item]) {
        for i in 0..<items.count {
            items[i].isPointed = false
        }
    }
    
    public func moveItemPointer(items: inout [Item], pX: Int) {
        if items.count > 0 {
            for i in 0..<items.count {
                if (items[i].isPointed) && (((pX < 0) && ((i + pX) >= 0)) || ((pX > 0) && ((i + pX) < items.count))) {
                    items[i].isPointed = false
                    items[i + pX].isPointed = true
                    break
                } else if items[i].isPointed && pX < 0 && i == 0 {
                    items[i].isPointed = false
                    items[items.count - 1].isPointed = true
                    break
                } else if items[i].isPointed && pX > 0 && i == (items.count - 1) {
                    items[i].isPointed = false
                    items[0].isPointed = true
                    break
                }
            }
            
            listItems(x: 5, y: 4, items: items)
        }
    }
    
    public func markPointedItem(items: inout [Item]) {
        if items.count > 0 {
            for i in 0..<items.count {
                if items[i].isPointed {
                    items[i].isMarked = !items[i].isMarked
                    break
                }
            }
            
            listItems(x: 5, y: 4, items: items)
        }
    }
    
    public func moveStashInventoryItem() {
        switch state.getState() {
            case .StashTab1:
                hero.actor.stash = moveItemToDestinationTab(currentItems: &hero.actor.inventory, destinationItems: &hero.actor.stash)
            case .StashTab2:
                hero.actor.inventory = moveItemToDestinationTab(currentItems: &hero.actor.stash, destinationItems: &hero.actor.inventory)
            default:
                break
        }
        
        displayStashItems()
    }
    
    private func moveItemToDestinationTab(currentItems: inout [Item], destinationItems: inout [Item]) -> [Item] {
        if currentItems.count > 0 {
            var pointedIndex: Int = 0
            var destinationName: String = ""
            
            if state.getState() == .StashTab1 {
                destinationName = "stash"
            } else {
                destinationName = "inventory"
            }
            
            for i in 0..<currentItems.count {
                if currentItems[i].isPointed {
                    pointedIndex = i
                    
                    var found: Bool = false
                    var itemName: String = currentItems[i].name
                    
                    if [ItemTag.Ammo, ItemTag.Flash, ItemTag.Home].contains(currentItems[i].tag) {
                        if (currentItems[i].amount > 1) && [ItemTag.Flash, ItemTag.Home].contains(currentItems[i].tag) { // plural
                            itemName += "s"
                        }
                        if (currentItems[i].amount == 1) && currentItems[i].tag == ItemTag.Ammo { // singular
                            itemName = String(itemName.dropLast(1))
                        }
                        
                        for x in 0..<destinationItems.count {
                            if destinationItems[x].name == currentItems[i].name { // found in destination
                                state.addMessage(message: "\(currentItems[i].amount) \(itemName) added to \(destinationName).")
                                destinationItems[x].amount += currentItems[i].amount
                                currentItems[i].isPointed = false
                                currentItems.remove(at: i)
                                found = true
                                break
                            }
                        }
                    }

                    if !found {
                        if destinationItems.count >= hero.inventoryCapacity {
                            state.addMessage(message: "Your \(destinationName) is full.")
                            break
                        }
                        if [ItemTag.Ammo, ItemTag.Flash, ItemTag.Home].contains(currentItems[i].tag) {
                            state.addMessage(message: "\(currentItems[i].amount) \(itemName) moved to \(destinationName).")
                        } else {
                            state.addMessage(message: "\(capitalizeFirst(string: itemName)) moved to \(destinationName).")
                        }
                        state.hadAction = true
                    } else {
                        break
                    }

                    currentItems[i].isPointed = false
                    destinationItems.append(currentItems[i])
                    currentItems.remove(at: i)
                    break
                }
            }
            
            if pointedIndex == currentItems.count {
                pointedIndex = currentItems.count - 1
            }
            if currentItems.count > 0 {
                currentItems[pointedIndex].isPointed = true
            }
            
            clearFrame(x1: 4, y1: 3, x2: 35, y2: 15)
        }
        
        return destinationItems
    }
    
    private func writeText(x: Int, y: Int, text: String) {
        for i in 0..<text.count {
            instance.setTileFace(x: x + i, y: y, ch: String(Array(text)[i]))
        }
    }
    
    private func clearFrame(x1: Int, y1: Int, x2: Int, y2: Int) {
        for y in y1...y2 {
            for x in x1...x2 {
                instance.setTileFace(x: x, y: y, ch: SPACE)
            }
        }
    }
    
    private func drawFrame(x1: Int, y1: Int, x2: Int, y2: Int, header: String, footer: String) {
        for y in y1...y2 {
            for x in x1...x2 {
                instance.frameTile(x: x, y: y)
                if x == x1 && y == y1 {
                    instance.setTileFace(x: x, y: y, ch: "\u{259b}")
                } else if x == x1 && y == y2 {
                    instance.setTileFace(x: x, y: y, ch: "\u{2599}")
                } else if x == x2 && y == y1 {
                    instance.setTileFace(x: x, y: y, ch: "\u{259c}")
                } else if x == x2 && y == y2 {
                    instance.setTileFace(x: x, y: y, ch: "\u{259f}")
                } else if x == x1 {
                    instance.setTileFace(x: x, y: y, ch: "\u{258f}")
                } else if x == x2 {
                    instance.setTileFace(x: x, y: y, ch: "\u{2595}")
                } else if y == y1 {
                    instance.setTileFace(x: x, y: y, ch: "\u{2594}")
                } else if y == y2 {
                    instance.setTileFace(x: x, y: y, ch: "\u{2581}")
                } else {
                    instance.setTileFace(x: x, y: y, ch: SPACE)
                }
            }
        }
        
        let header = header.count > 0 ? " " + header + " " : ""
        let footer = footer.count > 0 ? " " + footer + " " : ""
        let hX = ((x2 - x1) / 2) - (header.count / 2) + 3
        let fX = ((x2 - x1) / 2) - (footer.count / 2) + 3
        writeText(x: hX, y: y1, text: header)
        writeText(x: fX, y: y2, text: footer)
    }
    
    public func showPointedItemInfo() {
        var items: [Item] = []
        
        switch state.getState() {
            case .StashTab1, .Inventory:
                items = hero.actor.inventory
            case .StashTab2:
                items = hero.actor.stash
            case .Shop, .Equipment, .Ground:
                items = instance.getShopItems()
            default:
                break
        }
        
        for item in items {
            if item.isPointed && ![ItemTag.Flask, ItemTag.Ammo, ItemTag.Keystone].contains(item.tag) {
                state.setBufferedState(state: state.getState())
                state.setState(state: .Info)
                showItemInfo(item: item)
            }
        }
    }
    
    public func showChestItemInfo() {
        instance.bufferMap()
        state.setBufferedState(state: state.getState())
        state.setState(state: .Info)
        showItemInfo(item: instance.getItems()[instance.getItemIndex()])
    }
    
    private func capitalizeFirst(string: String) -> String {
        return string.count > 0 ? string.prefix(1).capitalized + string.dropFirst() : string
    }
    
    private func showItemInfo(item: Item) {
        var minDamage: Int = 0, maxDamage: Int = 0
        var armor: Int = 0
        var type: EquipType = .Empty

        if item.name == EMPTY || [ItemTag.LifeOrb, ItemTag.GoldCache].contains(item.tag) {
            state.setState(state: state.getBufferedState())
            return
        }
        
        switch item.tag {
            case ItemTag.Melee:
                for m in MeleeTypes {
                    if m.name == item.name {
                        minDamage = m.minDamage
                        maxDamage = m.maxDamage
                        break
                    }
                }
            case ItemTag.Ranged:
                for r in RangedTypes {
                    if r.name == item.name {
                        minDamage = r.minDamage
                        maxDamage = r.maxDamage
                        break
                    }
                }
            case ItemTag.Equip:
                for e in EquipTypes {
                    if e.name == item.name {
                        armor = e.armorValue
                        type = e.type
                        break
                    }
                }
            default:
                break
        }
        
        var tY: Int = 0
        
        if state.getBufferedState() == .Equipment {
            tY = 2
        }
        
        if !item.description.isEmpty && type != EquipType.Ring {
            instance.markArea(x1: 3, y1: 5 + tY, x2: 36, y2: 9 + tY, isMarked: false)
            drawFrame(x1: 3, y1: 5 + tY, x2: 36, y2: 9 + tY, header: "Item info", footer: "")
        } else {
            instance.markArea(x1: 3, y1: 5 + tY, x2: 36, y2: 8 + tY, isMarked: false)
            drawFrame(x1: 3, y1: 5 + tY, x2: 36, y2: 8 + tY, header: "Item info", footer: "")
        }
        
        writeText(x: 5, y: 6 + tY, text: capitalizeFirst(string: item.name))
        
        var infoText: String = ""
        
        switch item.tag {
            case ItemTag.Ranged, ItemTag.Melee:
                infoText = "Damage: " + (minDamage == maxDamage ? "\(minDamage)" : "\(minDamage)-\(maxDamage)")
            case ItemTag.Equip:
                if type != EquipType.Ring {
                    infoText = "Armor value: \(armor) (\(String(describing: type).lowercased()))"
                }
            case ItemTag.Flash:
                infoText = "Blind enemies in room (\(hero.actor.blindDuration) turns)"
            case ItemTag.Home:
                infoText = "Sends you back to your room"
            default:
                break
        }
        writeText(x: 5, y: 7 + tY, text: infoText)
        
        if !item.description.isEmpty {
            if type == EquipType.Ring {
                tY -= 1
            }
            writeText(x: 5, y: 8 + tY, text: item.description)
        }
    }
    
    public func closeItemInfo() {
        let bufferedState = state.getBufferedState()
        
        state.setState(state: bufferedState)
        
        switch bufferedState {
            case .StashTab1, .StashTab2:
                displayStashItems()
            case .Shop:
                displayShopItems()
            case .Ground:
                confirmPickup()
            case .Inventory:
                displayInventoryItems()
            case .Equipment:
                displayEquipment()
            case .Chest:
                instance.revertMap()
                instance.clearMapFrame()
            default:
                break
        }
    }
}
