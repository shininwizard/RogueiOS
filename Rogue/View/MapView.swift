import SwiftUI

struct MapView: View {
    @EnvironmentObject var instance: InstanceController
    
    var body: some View {
        GeometryReader { geometry in
            LazyVGrid(columns: [GridItem(.flexible(minimum: 0))], spacing: 0) {
                ForEach(0..<instance.getMap().count, id: \.self) { y in
                    LazyHGrid(rows: [GridItem(.flexible(minimum: 0))], spacing: 0) {
                        ForEach(0..<instance.getMap()[y].count, id: \.self) { x in
                            if instance.getTile(x: x, y: y).isRevealed || instance.getTile(x: x, y: y).isFrame {
                                ElementView(x: x, y: y, element: instance.getTile(x: x, y: y), geometry: geometry)
                            } else {
                                ElementView(x: x, y: y, element: Tile(ch: SPACE, isRevealed: false, isHighlighted: false), geometry: geometry)
                            }
                        }
                    }
                }
            }
        }
    }
}

struct ElementView: View {
    @EnvironmentObject var instance: InstanceController
    @EnvironmentObject var hero: HeroController
    @EnvironmentObject var state: StateController
    let x, y: Int
    let element: Tile
    let geometry: GeometryProxy
    
    var body: some View {
        Text(getDisplayElement(element: element))
            .font(.system(size: geometry.size.width * 0.039, design: .monospaced))
            .foregroundColor(setForegroundColor(element: element))
            .background(element.isHighlighted ? Color(UIColor.blue) : Color(UIColor.black))
            .frame(minWidth: 0, maxWidth: .infinity)
            .frame(minHeight: 0, maxHeight: .infinity)
            .id(UUID())
    }
    
    private func getDisplayElement(element: Tile) -> String {
        if hero.isBlind() && !([WALL, PASS, CORPSE, SPACE, DOOR, hero.actor.face].contains(element.ch)) {
            return PASS
        } else {
            return element.ch
        }
    }
    
    private func setForegroundColor(element: Tile) -> Color {
        if !hero.actor.isAlive && element.isMarked {
            return Color.red
        }
        if element.isMarked {
            switch state.getFlashState() {
                case .Red:
                    return Color.red
                case .Green:
                    return Color.green
                case .Blue:
                    return Color(UIColor.systemBlue)
                case .White:
                    return Color.white
                default:
                    return Color(UIColor.systemGreen)
            }
        }
        if element.isFrame {
            return Color.white
        }
        if hero.isBlind() && !([WALL, PASS, CORPSE, SPACE, DOOR, hero.actor.face].contains(element.ch)) {
            if isElementInCurrentRoom() {
                return Color.white
            }
            return Color(UIColor.darkGray)
        }
        switch element.ch {
            case STASH, CHEST:
                return Color.yellow
            case CLIP:
                return Color(UIColor.systemTeal)
            case CORPSE:
                return Color.red
            case VENDOR:
                return Color.green
            case WAYPOINT:
                return Color(UIColor.cyan)
            case STONE:
                return Color(UIColor.magenta)
            case MonsterTypes[MonsterTypes.count - 1].face:
                return Color(UIColor.magenta)
            default:
                if isElementInCurrentRoom() {
                    return Color.white
                }
                return Color(UIColor.darkGray)
        }
    }
    
    private func isElementInCurrentRoom() -> Bool {
        var x1: Int = -1, y1: Int = -1, x2: Int = -1, y2: Int = -1
        
        for room in instance.getRooms() {
            if ((room.x1 + 1)...(room.x2 - 1)).contains(hero.actor.x) && ((room.y1 + 1)...(room.y2 - 1)).contains(hero.actor.y) {
                x1 = room.x1
                x2 = room.x2
                y1 = room.y1
                y2 = room.y2
                break
            }
        }
        
        if (x1...x2).contains(x) && (y1...y2).contains(y) {
            return true
        }
        
        return false
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
            .environmentObject(InstanceController())
    }
}
