import SwiftUI

struct StatusView: View {
    @EnvironmentObject var hero: HeroController
    @EnvironmentObject var instance: InstanceController
    
    var body: some View {
        VStack {
            HStack {
                TextView(text: "Life: \(hero.actor.lifeCurrent)", color: Color(UIColor.lightGray))
                Spacer()
                TextView(text: setBlindText(hero: hero), color: Color.red)
                Spacer()
                TextView(text: "Depth: \(instance.getDepth())", color: Color(UIColor.lightGray))
            }
            HStack {
                TextView(text: "Armor: \(hero.actor.armor)", color: Color(UIColor.lightGray))
                Spacer()
                TextView(text: setParalyzeText(hero: hero), color: Color.red)
                Spacer()
                TextView(text: "Life Flask", color: setLifeFlaskColor(hero: hero))
            }
            HStack {
                TextView(text: "\(hero.actor.ranged.name != EMPTY ? hero.actor.ranged.name + " (\(hero.actor.ammo))" : "")", color: Color(UIColor.lightGray))
                Spacer()
                TextView(text: "Warp", color: setWarpColor(hero: hero))
            }
            HStack {
                TextView(text: "\(hero.actor.melee.name)", color: Color(UIColor.lightGray))
                Spacer()
            }
        }
    }
    
    struct TextView: View {
        let text: String
        let color: Color
        
        var body: some View {
            Text(text)
                .foregroundColor(color)
                .font(.system(size: 12, design: .monospaced)).bold()
        }
    }
    
    private func setBlindText(hero: HeroController) -> String {
        return hero.isBlind() ? "Blind" : ""
    }

    private func setParalyzeText(hero: HeroController) -> String {
        return hero.isParalyzed() ? "Paralyze" : ""
    }

    private func setLifeFlaskColor(hero: HeroController) -> Color {
        var lifeFlaskColor: Color = Color(UIColor.darkGray)
        let medpackCharge: Int = hero.getMedpackCharge()
        let medpackHealAmount: Int = hero.medpackHealAmount
        
        if medpackCharge > medpackHealAmount {
            lifeFlaskColor = Color(red: 0x2e/255, green: 0x64/255, blue: 0xfe/255)
        } else if medpackCharge == medpackHealAmount {
            lifeFlaskColor = Color(red: 0x04/255, green: 0x31/255, blue: 0xb4/255)
        }
        
        return lifeFlaskColor
    }
    
    private func setWarpColor(hero: HeroController) -> Color {
        return hero.canWarp() ? Color.green : Color(UIColor.darkGray)
    }
}

struct StatusView_Previews: PreviewProvider {
    static var previews: some View {
        StatusView()
            .environmentObject(HeroController())
            .environmentObject(InstanceController())
    }
}
