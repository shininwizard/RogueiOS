import SwiftUI

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @EnvironmentObject var hero: HeroController
    @EnvironmentObject var instance: InstanceController
    @EnvironmentObject var state: StateController

    var body: some View {
        ZStack {
            Color.black
            VStack {
                MessageView()
                MapView()
                StatusView()
                ButtonView()
                HStack {
                    Text("1.0.26.3")
                        .font(.system(size: 8))
                        .foregroundColor(.gray)
                    Spacer()
                }
            }
        }.onAppear() {
            if !loadState() {
                initInstance()
            }
        }.onDisappear() {
            saveState()
        }.onChange(of: scenePhase) { phase in
            if phase == .background {
                saveState()
            }
        }.ignoresSafeArea()
    }
    
    private func initInstance() {
        hero.actor.face = "@"
        hero.actor.name = "Bill Gilbert"
        hero.actor.lifeCurrent = 100
        hero.actor.lifeBefore = hero.actor.lifeCurrent
        hero.actor.armor = 1
        hero.actor.gold = 0
        hero.actor.ranged = RangedTypes[1]
        hero.actor.ammo = AmmoTypes[1].quantity
        hero.actor.melee = MeleeTypes[0]
        hero.actor.head = EquipTypes[0]
        hero.actor.chest = EquipTypes[1]
        hero.actor.legs = EquipTypes[0]
        hero.actor.gloves = EquipTypes[0]
        hero.actor.rings.append(EquipTypes[0])
        hero.actor.rings.append(EquipTypes[0])
        hero.actor.isAlive = true
        hero.actor.blindTimer = hero.actor.blindDuration
        hero.actor.paralyzeTimer = hero.actor.paralyzeDuration
        hero.actor.cell = PASS
        hero.actor.x = 1
        hero.actor.y = instance.maxY - 1
        hero.actor.stash.append(Item(x: 0, y: 0, name: "homeward scroll", amount: 1, tag: ItemTag.Home, price: 0, isMarked: false, isPointed: false, description: ""))
        instance.createTown(hero: hero)
        state.addMessage(message: "The guilty pay the price.")
    }
    
    private func saveState() {
        if hero.actor.lifeCurrent > 0 && !hero.getWinCondition() {
            var map: [[Tile]] = instance.getMap()
            
            for i in 0...instance.maxY {
                for j in 0...instance.maxX {
                    map[i][j].isMarked = false
                    map[i][j].isHighlighted = false
                    map[i][j].isFrame = false
                }
            }
            
            if [.Shop, .Inventory, .StashTab1, .StashTab2, .Info, .Equipment, .Ring, .Ground, .Waypoint].contains(state.getState()) {
                map = instance.getBufferedMap()
            }
            
            let saveData: SaveData = SaveData(depth: instance.getDepth(), progression: hero.getProgression(), medpackCharge: hero.getMedpackCharge(), warpCounter: hero.getWarpCounter(), hero: hero.actor, map: map, rooms: instance.getRooms(), items: instance.getItems(), monsters: instance.getMonsters())
            
            if let encodedData = try? JSONEncoder().encode(saveData) {
                do {
                    try encodedData.write(to: stateFileURL)
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
    
    private func loadState() -> Bool {
        if FileManager.default.fileExists(atPath: stateFileURL.path) {
            do {
                let encodedData = try Data(contentsOf: stateFileURL)
                
                if let saveData = try? JSONDecoder().decode(SaveData.self, from: encodedData) {
                    instance.setDepth(depth: saveData.depth)
                    hero.actor = saveData.hero
                    hero.setProgression(value: saveData.progression)
                    hero.setMedpackCharge(value: saveData.medpackCharge)
                    hero.setWarpCounter(value: saveData.warpCounter)
                    instance.setMap(value: saveData.map)
                    instance.setRooms(value: saveData.rooms)
                    instance.setItems(value: saveData.items)
                    instance.setMonsters(value: saveData.monsters)
                    
                    return true
                }
            } catch {
                print(error.localizedDescription)
            }
        }
        
        return false
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
                .environmentObject(HeroController())
                .environmentObject(InstanceController())
                .environmentObject(StateController())
        }
    }
}
