import Foundation

class InstanceController: ObservableObject {
    public let maxX: Int = 39
    public let maxY: Int = 19
    
    public let maxDepth: Int = 99
    @Published private var depth: Int = 0

    private var map: [[Tile]] = []
    private var buffer: [[String]] = []
    private var rooms: [Room] = []
    private var items: [Item] = []
    private var shop: [Item] = []
    private var monsters: [Actor] = []
    
    private var itemIndex: Int = -1
    @Published private var refresh: Bool = false
    
    public init() {
        for y in 0...maxY {
            map.append([])
            for _ in 0...maxX {
                map[y].append(Tile())
            }
        }
    }

    public func invalidate() {
        refresh = !refresh
    }

    public func addItem(item: Item) {
        items.append(item)
    }
    
    public func markItem(i: Int) {
        items[i].isMarked = true
    }
    
    public func removeMarkedItems() {
        items.removeAll(where: { $0.isMarked == true })
    }
    
    public func removeReferencedItems(reference: [Int]) {
        items = items.enumerated().filter({ !reference.contains($0.0) }).map { $0.1 }
    }

    public func getItems() -> [Item] {
        return items
    }
    
    public func setItems(value: [Item]) {
        items = value
    }
    
    public func removeItem(i: Int) {
        items.remove(at: i)
    }
    
    public func removeAllItems() {
        items.removeAll()
    }
    
    public func generateItem(x: Int, y: Int, mode: ItemGenerationMode) {
        var rng: Int = Int.random(in: 0...906), moRng: Int = 0
        var itemTier: Int = 0
        
        switch depth {
            case 01...10: itemTier = 1
            case 11...20: itemTier = 2
            case 21...30: itemTier = 3
            case 31...40: itemTier = 4
            case 41...50: itemTier = 5
            case 51...60: itemTier = 6
            case 61...70: itemTier = 7
            case 71...80: itemTier = 8
            case 81...maxDepth: itemTier = 9
            default: break
        }
        
        while mode == .Monster && (453...759).contains(rng) {
            rng = Int.random(in: 0...906)
        }
        
        switch rng {
            case 0...150:
                moRng = Int.random(in: 1..<RangedTypes.count)
                while RangedTypes[moRng].tier > itemTier {
                    moRng = Int.random(in: 1..<RangedTypes.count)
                }
                addItem(item: Item(x: x, y: y, name: RangedTypes[moRng].name, amount: 1, tag: ItemTag.Ranged, price: 0, isMarked: false, isPointed: false, description: RangedTypes[moRng].description))
            case 151...301:
                moRng = Int.random(in: 1..<MeleeTypes.count)
                while MeleeTypes[moRng].tier > itemTier {
                    moRng = Int.random(in: 1..<MeleeTypes.count)
                }
                addItem(item: Item(x: x, y: y, name: MeleeTypes[moRng].name, amount: 1, tag: ItemTag.Melee, price: 0, isMarked: false, isPointed: false, description: MeleeTypes[moRng].description))
            case 302...452:
                moRng = Int.random(in: 1..<AmmoTypes.count)
                addItem(item: Item(x: x, y: y, name: AmmoTypes[moRng].name, amount: AmmoTypes[moRng].quantity, tag: ItemTag.Ammo, price: 0, isMarked: false, isPointed: false, description: ""))
            case 453...603:
                addItem(item: Item(x: x, y: y, name: "orb of life", amount: 1, tag: ItemTag.LifeOrb, price: 0, isMarked: false, isPointed: false, description: ""))
            case 604...759:
                addItem(item: Item(x: x, y: y, name: "gold cache", amount: 1, tag: ItemTag.GoldCache, price: 0, isMarked: false, isPointed: false, description: ""))
            case 760...903:
                moRng = Int.random(in: 1..<EquipTypes.count)
                while EquipTypes[moRng].tier > itemTier {
                    moRng = Int.random(in: 1..<EquipTypes.count)
                }
                addItem(item: Item(x: x, y: y, name: EquipTypes[moRng].name, amount: 1, tag: ItemTag.Equip, price: 0, isMarked: false, isPointed: false, description: EquipTypes[moRng].description))
            case 904:
                moRng = Int.random(in: 1..<EquipTypes.count)
                while EquipTypes[moRng].type != EquipType.Ring {
                    moRng = Int.random(in: 1..<EquipTypes.count)
                }
                addItem(item: Item(x: x, y: y, name: EquipTypes[moRng].name, amount: 1, tag: ItemTag.Equip, price: 0, isMarked: false, isPointed: false, description: EquipTypes[moRng].description))
            case 905:
                let uRng: Int = Int.random(in: 0...5)
                switch uRng {
                    case 0:
                        moRng = Int.random(in: 1..<EquipTypes.count)
                        while EquipTypes[moRng].type != EquipType.Head && EquipTypes[moRng].tier != 10 {
                            moRng = Int.random(in: 1..<EquipTypes.count)
                        }
                        addItem(item: Item(x: x, y: y, name: EquipTypes[moRng].name, amount: 1, tag: ItemTag.Equip, price: 0, isMarked: false, isPointed: false, description: EquipTypes[moRng].description))
                    case 1:
                        moRng = Int.random(in: 1..<EquipTypes.count)
                        while EquipTypes[moRng].type != EquipType.Chest && EquipTypes[moRng].tier != 10 {
                            moRng = Int.random(in: 1..<EquipTypes.count)
                        }
                        addItem(item: Item(x: x, y: y, name: EquipTypes[moRng].name, amount: 1, tag: ItemTag.Equip, price: 0, isMarked: false, isPointed: false, description: EquipTypes[moRng].description))
                    case 2:
                        moRng = Int.random(in: 1..<EquipTypes.count)
                        while EquipTypes[moRng].type != EquipType.Gloves && EquipTypes[moRng].tier != 10 {
                            moRng = Int.random(in: 1..<EquipTypes.count)
                        }
                        addItem(item: Item(x: x, y: y, name: EquipTypes[moRng].name, amount: 1, tag: ItemTag.Equip, price: 0, isMarked: false, isPointed: false, description: EquipTypes[moRng].description))
                    case 3:
                        moRng = Int.random(in: 1..<EquipTypes.count)
                        while EquipTypes[moRng].type != EquipType.Legs && EquipTypes[moRng].tier != 10 {
                            moRng = Int.random(in: 1..<EquipTypes.count)
                        }
                        addItem(item: Item(x: x, y: y, name: EquipTypes[moRng].name, amount: 1, tag: ItemTag.Equip, price: 0, isMarked: false, isPointed: false, description: EquipTypes[moRng].description))
                    case 4:
                        moRng = Int.random(in: 1..<RangedTypes.count)
                        while RangedTypes[moRng].tier != 10 {
                            moRng = Int.random(in: 1..<RangedTypes.count)
                        }
                        addItem(item: Item(x: x, y: y, name: RangedTypes[moRng].name, amount: 1, tag: ItemTag.Ranged, price: 0, isMarked: false, isPointed: false, description: RangedTypes[moRng].description))
                    case 5:
                        moRng = Int.random(in: 1..<MeleeTypes.count)
                        while MeleeTypes[moRng].tier != 10 {
                            moRng = Int.random(in: 1..<MeleeTypes.count)
                        }
                        addItem(item: Item(x: x, y: y, name: MeleeTypes[moRng].name, amount: 1, tag: ItemTag.Melee, price: 0, isMarked: false, isPointed: false, description: MeleeTypes[moRng].description))
                    default:
                        break
                }
            case 906:
                addItem(item: Item(x: x, y: y, name: "homeward scroll", amount: 1, tag: ItemTag.Home, price: 0, isMarked: false, isPointed: false, description: ""))
            default:
                break
        }
    }
    
    public func getItemIndex() -> Int {
        return itemIndex
    }
    
    public func setItemIndex(i: Int) {
        itemIndex = i
    }
    
    public func getShopItems() -> [Item] {
        return shop
    }

    public func setShopItems(items: [Item]) {
        shop = items
    }

    public func addShopItem(item: Item) {
        shop.append(item)
    }
    
    public func removeShopItem(i: Int) {
        shop.remove(at: i)
    }
    
    public func removeAllShopItems() {
        shop.removeAll()
    }

    public func getDepth() -> Int {
        return depth
    }
    
    public func setDepth(depth: Int) {
        self.depth = depth
    }
    
    public func getTile(x: Int, y: Int) -> Tile {
        return map[y][x]
    }

    public func setTile(x: Int, y: Int, tile: Tile) {
        map[y][x] = tile
    }

    public func getTileFace(x: Int, y: Int) -> String {
        return map[y][x].ch
    }

    public func setTileFace(x: Int, y: Int, ch: String) {
        map[y][x].ch = ch
    }
    
    public func flashTileFace(x: Int, y: Int, color: FlashState, state: StateController) {
        markTile(x: x, y: y)
        state.setFlashState(state: color)
        invalidate()
        DispatchQueue.main.asyncAfter(deadline: .now() + FLASH_DELAY) {
            if state.getState() != .End {
                self.clearMapMarks()
                state.setFlashState(state: .None)
            }
            self.invalidate()
        }
    }

    public func markTile(x: Int, y: Int) {
        map[y][x].isMarked = true
    }
    
    public func markArea(x1: Int, y1: Int, x2: Int, y2: Int, isMarked: Bool) {
        for i in y1...y2 {
            for j in x1...x2 {
                map[i][j].isMarked = isMarked
            }
        }
    }

    public func clearMapMarks() {
        for i in 0...maxY {
            for j in 0...maxX {
                map[i][j].isMarked = false
            }
        }
    }

    public func highlightTile(x: Int, y: Int) {
        map[y][x].isHighlighted = true
    }
        
    public func getHighlightedTilePosition() -> (x: Int, y: Int)? {
        for i in 0...maxY {
            for j in 0...maxX {
                if map[i][j].isHighlighted {
                    return (x: j, y: i)
                }
            }
        }
        
        return nil
    }
    
    public func clearMapHighlights() {
        for i in 0...maxY {
            for j in 0...maxX {
                map[i][j].isHighlighted = false
            }
        }
    }
    
    public func frameTile(x: Int, y: Int) {
        map[y][x].isFrame = true
    }
    
    public func clearMapFrame() {
        for i in 0...maxY {
            for j in 0...maxX {
                map[i][j].isFrame = false
            }
        }
    }
    
    public func getMonsters() -> [Actor] {
        return monsters
    }
    
    public func setMonsters(value: [Actor]) {
        monsters = value
    }
    
    public func getSortedMonsters(hero: HeroController) -> [Actor] {
        var sortedMonsters: [Actor] = []
        
        for m in monsters {
            if m.isAlive {
                sortedMonsters.append(m)
            }
        }
        
        if sortedMonsters.count > 1 {
            for i in 0..<sortedMonsters.count {
                for j in 0..<sortedMonsters.count - i - 1 {
                    if abs(sortedMonsters[j].x - hero.actor.x) + abs(sortedMonsters[j].y - hero.actor.y) > abs(sortedMonsters[j + 1].x - hero.actor.x) + abs(sortedMonsters[j + 1].y - hero.actor.y) {
                        sortedMonsters.swapAt(j, j + 1)
                    }
                }
            }
        }
        
        return sortedMonsters
    }
    
    public func addMonster(actor: Actor) {
        monsters.append(actor)
    }
    
    public func removeMonster(i: Int) {
        monsters.remove(at: i)
    }
    
    public func removeAllMonsters() {
        monsters.removeAll()
    }
    
    public func isMonster(tileFace: String) -> Bool {
        return tileFace.first?.isLetter == true && tileFace.first?.isASCII == true
    }
    
    public func setMonsterLocation(i: Int, x: Int, y: Int) {
        monsters[i].x = x
        monsters[i].y = y
    }
    
    public func setMonsterFace(i: Int, value: String) {
        monsters[i].face = value
    }

    public func setMonsterCell(i: Int, value: String) {
        monsters[i].cell = value
    }

    public func setMonsterLife(i: Int, value: Int) {
        monsters[i].lifeCurrent = value
    }

    public func isMonsterBlind(i: Int) -> Bool {
        return monsters[i].blindTimer < monsters[i].blindDuration
    }
    
    public func setMonsterBlindCounter(i: Int, value: Int) {
        monsters[i].blindTimer = value
    }

    public func isMonsterParalyzed(i: Int) -> Bool {
        return monsters[i].paralyzeTimer < monsters[i].paralyzeDuration
    }
    
    public func setMonsterParalyzeCounter(i: Int, value: Int) {
        monsters[i].paralyzeTimer = value
    }
    
    public func setMonsterPursuitState(i: Int, value: Bool) {
        monsters[i].isPursuit = value
    }

    public func setMonsterAliveState(i: Int, value: Bool) {
        monsters[i].isAlive = value
    }

    public func getMap() -> [[Tile]] {
        return map
    }
    
    public func setMap(value: [[Tile]]) {
        map = value
    }
    
    public func getRooms() -> [Room] {
        return rooms
    }
    
    public func setRooms(value: [Room]) {
        rooms = value
    }
    
    public func appendRoom(room: Room) {
        rooms.append(room)
    }
    
    public func addRoomToMap(x1: Int, y1: Int, x2: Int, y2: Int) {
        for i in x1...x2 {
            for j in y1...y2 {
                if i == x1 || i == x2 || j == y1 || j == y2 {
                    map[j][i].ch = WALL
                } else {
                    map[j][i].ch = PASS
                }
            }
        }
    }

    public func emptyMap() {
        for i in 0...maxY {
            for j in 0...maxX {
                map[i][j].ch = SPACE
                map[i][j].isRevealed = false
                map[i][j].isMarked = false
                map[i][j].isHighlighted = false
            }
        }
    }
    
    public func bufferMap() {
        buffer = []
        for y in 0...maxY {
            buffer.append([])
            for x in 0...maxX {
                buffer[y].append(getTileFace(x: x, y: y))
            }
        }
    }
    
    public func getBufferedMap() -> [[Tile]] {
        var bufferedMap: [[Tile]] = []
        
        for y in 0...maxY {
            bufferedMap.append([])
            for x in 0...maxX {
                bufferedMap[y].append(Tile())
                bufferedMap[y][x].ch = buffer[y][x]
                bufferedMap[y][x].isRevealed = map[y][x].isRevealed
            }
        }
        
        return bufferedMap
    }
    
    public func revertMap() {
        for y in 0...maxY {
            for x in 0...maxX {
                setTileFace(x: x, y: y, ch: buffer[y][x])
            }
        }
    }

    public func revealArea(x1: Int, y1: Int, x2: Int, y2: Int) {
        for i in y1...y2 {
            for j in x1...x2 {
                map[i][j].isRevealed = true
            }
        }
    }
    
    public func revealRoom(hero: HeroController) {
        revealArea(x1: hero.actor.x - 1, y1: hero.actor.y - 1, x2: hero.actor.x + 1, y2: hero.actor.y + 1)
        
        for i in 0..<rooms.count {
            if ((rooms[i].x1 + 1)...(rooms[i].x2 - 1)).contains(hero.actor.x) && ((rooms[i].y1 + 1)...(rooms[i].y2 - 1)).contains(hero.actor.y) {
                revealArea(x1: rooms[i].x1, y1: rooms[i].y1, x2: rooms[i].x2, y2: rooms[i].y2)
                rooms[i].isRevealed = true
            }
        }
    }

    public func createNew(hero: HeroController) {
        var columnCount: Int = 0
        
        emptyMap()
        removeAllItems()
        removeAllMonsters()

        columnCount = generateMap()
        connectRooms()
        hero.actor.cell = PASS
        positionHero(hero: hero)
        
        let exitCoords = positionExit(columnCount: columnCount)
        
        if hero.getProgression() < depth {
            hero.setProgression(value: depth)
        }
        
        if depth % 10 == 0 && depth < maxDepth {
            var iX: Int = 0, iY: Int = 0
            
            if columnCount % 2 == 1 {
                iX = exitCoords.x + 1
                iY = exitCoords.y + 1
            } else {
                iX = exitCoords.x + 1
                iY = exitCoords.y - 1
            }
            
            items.append(Item(x: iX, y: iY, name: "flash bomb", amount: 1, tag: .Flash, price: 0, isMarked: false, isPointed: false, description: ""))
            map[iY][iX].ch = CHEST
        }
        
        generateChests()
        generateMonsters(hero: hero)
    }
    
    private func generateMap() -> Int {
        rooms.removeAll()
        
        var x1: Int = 0, y1: Int = 0, x2: Int = 0, y2: Int = 0
        var rX: Int = 0, rY: Int = 0
        var tempX: Int = 0
        var columnCount: Int = 0
        
        while true {
            x1 = rX
            y1 = rY
            x2 = rX + Int.random(in: 4..<maxX / 2)
            y2 = rY + Int.random(in: 4..<maxY)
            
            if x2 > maxX {
                x2 = maxX
            }
            if y2 > maxY {
                y2 = maxY
            }
            if x2 > tempX {
                tempX = x2
            }
            if y2 <= maxY - 6 {
                rY = y2 + 2
            } else {
                rY = 0
                columnCount += 1
            }
            if x2 <= maxX - 6 && rY == 0 {
                rX = tempX + 2
            }
            
            appendRoom(room: Room(x1: x1, y1: y1, x2: x2, y2: y2))
            addRoomToMap(x1: x1, y1: y1, x2: x2, y2: y2)
            
            if tempX > maxX - 6 && y2 > maxY - 6 {
                break
            }
        }
        
        return columnCount
    }
    
    private func connectRooms() {
        var pX: Int = 0, pY: Int = 0, cX: Int = 0, tX: Int = 0
        
        pX = 2
        pY = maxY
        
        while true {
            while pY > 5 { // bottom -> top sequence
                while map[pY][pX].ch != WALL {
                    pY -= 1
                }
                while pY > 0 && map[pY - 1][pX].ch == PASS {
                    pY -= 1
                }
                if map[pY][pX].ch == PASS { // (pY, pX - 2) = top left corner
                    pY -= 1
                }
                
                if pY < 6 {
                    break
                }
                
                cX = pX
                
                while map[pY][cX].ch == WALL && cX < maxX {
                    cX += 1
                }
                
                if map[pY][cX].ch != WALL { // (pY, cX) = top right passable
                    cX -= 3
                } else {
                    cX -= 2
                }
                
                while !(map[pY + 1][cX + 1].ch == PASS && map[pY + 1][cX].ch == PASS && map[pY + 1][cX - 1].ch == PASS && map[pY - 3][cX + 1].ch == PASS && map[pY - 3][cX].ch == PASS && map[pY - 3][cX - 1].ch == PASS) {
                    cX -= 1 // looking for connectable spot
                }
                
                map[pY][cX].ch = PASS
                map[pY - 1][cX].ch = PASS
                map[pY - 2][cX].ch = PASS
                map[pY - 1][cX - 1].ch = WALL
                map[pY - 1][cX + 1].ch = WALL
                pY -= 2
                
                while map[pY - 1][pX].ch == PASS && pY > 0 {
                    pY -= 1
                }
                if map[pY][pX].ch == PASS { // (pY, pX) = top left passable
                    pY -= 1
                }
                
                if pY < 6 {
                    break
                }
                
                map[pY][pX].ch = PASS
                map[pY - 1][pX].ch = PASS
                map[pY - 2][pX].ch = PASS
                map[pY - 1][pX - 1].ch = WALL
                map[pY - 1][pX + 1].ch = WALL
                pY -= 2
            }
            
            pY = 0
            
            while map[pY][pX].ch == WALL && pX < maxX { // left -> right sequence
                pX += 1
            }
            if map[pY][pX].ch != WALL { // rightmost wall
                pX -= 1
            }
            
            if pX > maxX - 6 {
                break
            }
            
            cX = pX + 1
            
            while map[pY][cX].ch != WALL && cX < maxX { // (pY, cX) = next set of rooms top left
                cX += 1
            }
            
            if map[pY][cX].ch != WALL {
                break
            }
            
            map[pY + 2][pX].ch = PASS
            for i in (pX + 1)...(cX - 1) {
                map[pY + 1][i].ch = WALL
                map[pY + 2][i].ch = PASS
                map[pY + 3][i].ch = WALL
            }
            map[pY + 2][cX].ch = PASS
            
            pX = cX + 2
            pY = 0
            cX = pX
            while pY < maxY - 5 { // top -> bottom sequence
                while map[pY][cX].ch == WALL && cX < maxX {
                    cX += 1
                }
                if map[pY][cX].ch != WALL { // right wall
                    cX -= 1
                }
                
                while map[pY][cX].ch == WALL && pY < maxY {
                    pY += 1
                }
                if map[pY][cX].ch != WALL { // (pY, cX) = bottom right corner
                    pY -= 1
                }
                
                if pY > maxY - 6 {
                    break
                }
                
                cX -= 2 // possible passable (rightmost)
                
                while !(map[pY - 1][cX + 1].ch == PASS && map[pY - 1][cX].ch == PASS && map[pY - 1][cX - 1].ch == PASS && map[pY + 3][cX + 1].ch == PASS && map[pY + 3][cX].ch == PASS && map[pY + 3][cX - 1].ch == PASS) {
                    cX -= 1 // (pY + 1, cX) = connectable spot
                }
                
                map[pY][cX].ch = PASS
                map[pY + 1][cX].ch = PASS
                map[pY + 2][cX].ch = PASS
                map[pY + 1][cX - 1].ch = WALL
                map[pY + 1][cX + 1].ch = WALL
                pY += 2
                
                while map[pY][pX - 2].ch == WALL && pY < maxY {
                    pY += 1
                }
                if map[pY][pX - 2].ch != WALL { // bottom wall
                    pY -= 1
                }
                
                if pY > maxY - 6 {
                    break
                }
                
                map[pY][pX].ch = PASS
                map[pY + 1][pX].ch = PASS
                map[pY + 2][pX].ch = PASS
                map[pY + 1][pX - 1].ch = WALL
                map[pY + 1][pX + 1].ch = WALL
                pY += 2
                cX = pX + 1
            }
            
            pY = 0
            tX = pX - 2
            while map[pY][pX].ch == WALL && pX < maxX { // right -> left sequence
                pX += 1
            }
            
            if pX > maxX - 5 {
                break
            }
            
            while map[pY][pX].ch != WALL && pX < maxX {
                pX += 1
            }
            
            if pX > maxX - 4 {
                break
            }
            
            if map[pY][pX].ch != WALL { // next set
                pX -= 1
            }
            pY = maxY
            
            while map[pY][pX].ch != WALL { // (pY, pX) = bottom left corner
                pY -= 1
            }
            
            pY -= 2 // (pY, pX) = passable spot
            cX = pX - 2 // (pY, cX) = ~possible~ previous set passable spot
            
            while true {
                while map[pY][cX].ch != WALL && cX > tX { // previous set right wall
                    cX -= 1
                }
                
                if cX == tX {
                    pY -= 1
                    cX = pX - 2
                    continue
                }
                
                if map[pY - 1][pX + 1].ch == PASS && map[pY][pX + 1].ch == PASS && map[pY + 1][pX + 1].ch == PASS && map[pY - 1][cX - 1].ch == PASS && map[pY][cX - 1].ch == PASS && map[pY + 1][cX - 1].ch == PASS && map[pY - 1][cX + 1].ch == SPACE && map[pY][cX + 1].ch == SPACE && map[pY + 1][cX + 1].ch == SPACE {
                    map[pY][cX].ch = PASS
                    for i in (cX + 1)...(pX - 1) {
                        map[pY - 1][i].ch = WALL
                        map[pY][i].ch = PASS
                        map[pY + 1][i].ch = WALL
                    }
                    map[pY][pX].ch = PASS
                    break
                }
                
                pY -= 1
                cX = pX - 2
            }
            
            pX += 2
            pY = maxY
        }
    }
    
    private func positionHero(hero: HeroController) {
        var pX: Int = 1, pY: Int = maxY
        
        while map[pY][pX].ch != PASS {
            pY -= 1
        }
        
        hero.actor.x = pX
        hero.actor.y = pY
        map[pY][pX].ch = hero.actor.face
    }
    
    private func positionExit(columnCount: Int) -> (x: Int, y: Int) {
        var pX: Int = maxX, pY: Int = 0
        
        if columnCount % 2 == 1 {
            while map[pY][pX].ch != WALL {
                pX -= 1
            }
            pX -= 2
        } else {
            while map[pY][pX].ch != WALL {
                pX -= 1
            }
            while map[pY][pX].ch == WALL {
                pX -= 1
            }
            
            pX += 1 // (pY, pX) = last set of rooms top left
            pY = maxY
            
            while map[pY][pX].ch != WALL {
                pY -= 1 // bottom left
            }
            while map[pY][pX].ch == WALL && pX < maxX {
                pX += 1
            }
            
            if map[pY][pX].ch != WALL {
                pX -= 3
            } else {
                pX -= 2
            }
        }
        
        map[pY][pX].ch = DOOR
        
        return (x: pX, y: pY)
    }
    
    private func generateChests() {
        var i: Int = 0, chestCount: Int = 2
        let rng: Int = Int.random(in: 0..<100)
        
        if rng < 10 {
            chestCount = 1
        }
        if rng > 90 {
            chestCount = 3
        }
        
        while i < chestCount {
            let x: Int = Int.random(in: 1..<maxX)
            let y: Int = Int.random(in: 1..<maxY)
            var goodPlace: Bool = true
            
            for j in 0..<rooms.count {
                if ((rooms[j].x1 + 1)...(rooms[j].x2 - 1)).contains(x) && ((rooms[j].y1 + 1)...(rooms[j].y2 - 1)).contains(y) && getTileFace(x: x, y: y) == PASS {
                    for cX in (x - 1)...(x + 1) {
                        for cY in (y - 1)...(y + 1) {
                            if getTileFace(x: cX, y: cY) == DOOR {
                                goodPlace = false
                            }
                        }
                    }
                    if goodPlace {
                        setTileFace(x: x, y: y, ch: CHEST)
                        generateItem(x: x, y: y, mode: .Chest)
                    }
                }
            }
            
            if getTileFace(x: x, y: y) == CHEST {
                i += 1
            }
        }
    }
    
    private func generateMonsters(hero: HeroController) {
        var x: Int = 0, y: Int = 0
        var rX1: Int = 0, rY1: Int = 0, rX2: Int = 0, rY2: Int = 0
        
        for i in 0..<rooms.count {
            if ((rooms[i].x1 + 1)...(rooms[i].x2 - 1)).contains(hero.actor.x) && ((rooms[i].y1 + 1)...(rooms[i].y2 - 1)).contains(hero.actor.y) {
                rX1 = rooms[i].x1 + 1
                rY1 = rooms[i].y1 + 1
                rX2 = rooms[i].x2 - 1
                rY2 = rooms[i].y2 - 1
                break
            }
        }
        
        for _ in 0..<rooms.count + (depth / 5) {
            while map[y][x].ch != PASS {
                x = Int.random(in: 1..<maxX)
                y = Int.random(in: 1..<maxY)
            }
            
            var maxToughness: Int = 0
            
            switch depth {
                case 01...10:
                    maxToughness = 1
                case 11...20:
                    maxToughness = 2
                case 21...30:
                    maxToughness = 3
                case 31...40:
                    maxToughness = 4
                case 41...50:
                    maxToughness = 5
                case 51...60:
                    maxToughness = 6
                case 61...70:
                    maxToughness = 7
                case 71...80:
                    maxToughness = 8
                case 81...90:
                    maxToughness = 9
                case 91...maxDepth:
                    maxToughness = 10
                default:
                    break
            }
            
            var k: Int = Int.random(in: 0..<MonsterTypes.count)
            
            while MonsterTypes[k].tier > maxToughness {
                k = Int.random(in: 0..<MonsterTypes.count)
            }
            
            var monster: Actor = Actor()
            
            monster.x = x
            monster.y = y
            monster.face = MonsterTypes[k].face
            monster.name = MonsterTypes[k].name
            monster.lifeCurrent = MonsterTypes[k].life
            monster.lifeBefore = monster.lifeCurrent
            monster.armor = MonsterTypes[k].armor
            monster.ranged = RangedTypes[0]
            for r in RangedTypes {
                if MonsterTypes[k].weapon == r.name {
                    monster.ranged = r
                    break
                }
            }
            monster.melee = MeleeTypes[0]
            for m in MeleeTypes {
                if MonsterTypes[k].weapon == m.name {
                    monster.melee = m
                    break
                }
            }
            monster.isPursuit = (rX1...rX2).contains(x) && (rY1...rY2).contains(y)
            monster.blindTimer = monster.blindDuration
            monster.paralyzeTimer = monster.paralyzeDuration
            monster.isAlive = true
            monster.cell = PASS
            
            monsters.append(monster)
            setTileFace(x: x, y: y, ch: monster.face)
        }
        
        if depth == maxDepth { // final boss
            while map[y][x].ch != PASS {
                x = Int.random(in: 1..<maxX)
                y = Int.random(in: 1..<maxY)
            }
            
            var monster: Actor = Actor()
            
            monster.x = x
            monster.y = y
            monster.face = MonsterTypes[MonsterTypes.count - 1].face
            monster.name = MonsterTypes[MonsterTypes.count - 1].name
            monster.lifeCurrent = MonsterTypes[MonsterTypes.count - 1].life
            monster.lifeBefore = monster.lifeCurrent
            monster.armor = MonsterTypes[MonsterTypes.count - 1].armor
            monster.ranged = RangedTypes[0]
            for r in RangedTypes {
                if MonsterTypes[MonsterTypes.count - 1].weapon == r.name {
                    monster.ranged = r
                    break
                }
            }
            monster.melee = MeleeTypes[0]
            for m in MeleeTypes {
                if MonsterTypes[MonsterTypes.count - 1].weapon == m.name {
                    monster.melee = m
                    break
                }
            }
            monster.isPursuit = false
            monster.blindTimer = monster.blindDuration
            monster.paralyzeTimer = monster.paralyzeDuration
            monster.isAlive = true
            monster.cell = PASS
            
            monsters.append(monster)
            setTileFace(x: x, y: y, ch: monster.face)
        }
    }
    
    public func createTown(hero: HeroController) {
        emptyMap()
        rooms.removeAll()
        removeAllMonsters()
        removeAllItems()
        
        appendRoom(room: Room(x1: 0, y1: 0, x2: maxX / 3, y2: maxY / 3))
        appendRoom(room: Room(x1: 0, y1: maxY - maxY / 3, x2: maxX / 3, y2: maxY))
        appendRoom(room: Room(x1: maxX - maxX / 3, y1: 0, x2: maxX, y2: maxY / 3))
        appendRoom(room: Room(x1: maxX - maxX / 3, y1: maxY - maxY / 3, x2: maxX, y2: maxY))
        addRoomToMap(x1: 0, y1: 0, x2: maxX / 3, y2: maxY / 3)
        addRoomToMap(x1: 0, y1: maxY - maxY / 3, x2: maxX / 3, y2: maxY)
        addRoomToMap(x1: maxX - maxX / 3, y1: 0, x2: maxX, y2: maxY / 3)
        addRoomToMap(x1: maxX - maxX / 3, y1: maxY - maxY / 3, x2: maxX, y2: maxY)
        
        var mY: Int = maxY - 1, mX: Int = 2
        
        while map[mY][mX].ch != WALL {
            mY -= 1 // bottom left room top wall
        }
        map[mY][mX].ch = PASS
        map[mY][maxX - 2].ch = PASS
        
        while map[mY][mX].ch != WALL { // bottom -> top
            map[mY][mX - 1].ch = WALL
            map[mY][mX].ch = PASS
            map[mY][mX + 1].ch = WALL
            map[mY][maxX - 1].ch = WALL
            map[mY][maxX - 2].ch = PASS
            map[mY][maxX - 3].ch = WALL
            mY -= 1
        }
        map[mY][mX].ch = PASS
        map[mY][maxX - 2].ch = PASS
        mX = 1
        mY = 2
        while map[mY][mX].ch != WALL {
            mX += 1 // top left room right wall
        }
        map[mY][mX].ch = PASS
        map[maxY - 3][mX].ch = PASS
        while map[mY][mX].ch != WALL { // left -> right
            map[mY - 1][mX].ch = WALL
            map[mY][mX].ch = PASS
            map[mY + 1][mX].ch = WALL
            map[maxY - 1][mX].ch = WALL
            map[maxY - 2][mX].ch = PASS
            map[maxY - 3][mX].ch = WALL
            mX += 1
        }
        map[mY][mX].ch = PASS
        map[maxY - 2][mX].ch = PASS
        revealArea(x1: 0, y1: 0, x2: maxX, y2: maxY)
        
        map[hero.actor.y][hero.actor.x].ch = hero.actor.face
        map[1][1].ch = WALL
        map[1][3].ch = WALL
        map[3][1].ch = WALL
        map[3][3].ch = WALL
        map[2][2].ch = VENDOR
        map[maxY - 1][2].ch = STASH
        map[2][maxX - 2].ch = WAYPOINT
        map[maxY - 1][maxX - 1].ch = STONE
    }
    
    public func openGateRoom() {
        appendRoom(room: Room(x1: maxX / 3 + 1, y1: maxY - (maxY / 3) * 2, x2: (maxX / 3) * 2 - 1, y2: maxY - maxY / 3 - 1, isRevealed: true))
        addRoomToMap(x1: maxX / 3 + 1, y1: maxY - (maxY / 3) * 2, x2: (maxX / 3) * 2 - 1, y2: maxY - maxY / 3 - 1)
        
        var pX: Int = maxX / 2, pY: Int = maxY - 4
        
        map[pY + 1][pX].ch = PASS
        map[pY + 1][pX + 1].ch = PASS
        while map[pY][pX].ch != WALL {
            map[pY][pX - 1].ch = WALL
            map[pY][pX].ch = PASS
            map[pY][pX + 1].ch = PASS
            map[pY][pX + 2].ch = WALL
            pY -= 1
        }
        map[pY][pX].ch = PASS
        map[pY][pX + 1].ch = PASS
        while map[pY][pX].ch == PASS {
            pY -= 1
        }
        map[pY][pX].ch = GATE
        map[pY][pX + 1].ch = GATE
    }
}
