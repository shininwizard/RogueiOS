import Foundation

protocol ButtonAction {
    func tap(globalState: GlobalState, interaction: InteractionController)
}

class ButtonController {
    private var button: ButtonAction
    private var hero: HeroController
    private var instance: InstanceController
    private var state: StateController
    private var interaction: InteractionController
    
    init(button: ButtonAction, hero: HeroController, instance: InstanceController, state: StateController) {
        self.button = button
        self.hero = hero
        self.instance = instance
        self.state = state
        self.interaction = InteractionController(hero: hero, instance: instance, state: state)
    }
    
    public func set(button: ButtonAction) {
        self.button = button
    }

    public func tap(globalState: GlobalState) {
        if globalState != .End {
            if ![GlobalState.Heal, GlobalState.Warp, GlobalState.Ring, GlobalState.Chest, GlobalState.Info].contains(globalState) {
                state.clearMessages()
            }
            
            button.tap(globalState: globalState, interaction: interaction)
            
            if state.getState() == .Move || (state.getState() == .Cancel && state.hadAction) {
                if hero.isBlind() {
                    hero.actor.blindTimer += 1
                }
                if hero.isParalyzed() {
                    hero.actor.paralyzeTimer += 1
                }
                if !hero.canWarp() {
                    hero.setWarpCounter(value: hero.getWarpCounter() + 1)
                    if hero.actor.legs.name == "Boots of the Explorer" {
                        hero.setWarpCounter(value: hero.getWarpCounter() + 1)
                    }
                }
                for ring in hero.actor.rings {
                    if ring.name == "Blood Ring" {
                        hero.actor.lifeBefore = hero.actor.lifeCurrent
                        hero.actor.lifeCurrent -= 10
                        if hero.actor.lifeCurrent <= 0 && !hero.isRingOfSacrificeEquipped(state: state) {
                            interaction.die()
                            instance.revealRoom(hero: hero)
                            instance.invalidate()
                            return
                        }
                    }
                }
                state.hadAction = false
                interaction.moveMonsters()
            }
            
            if state.getState() == .Cancel {
                state.setState(state: .Move)
            }
            
            instance.revealRoom(hero: hero)
            instance.invalidate()
        }
    }
}

class ButtonUp: ButtonAction {
    func tap(globalState: GlobalState, interaction: InteractionController) {
        switch globalState {
            case .Move:
                interaction.moveHero(mX: 0, mY: -1)
            case .Inspect:
                interaction.moveTileHighlight(mX: 0, mY: -1)
            case .Target:
                interaction.highlightLine(mX: 0, mY: -1)
            case .StashTab1, .Inventory:
                interaction.moveItemPointer(items: &interaction.getHeroController().actor.inventory, pX: -1)
            case .StashTab2:
                interaction.moveItemPointer(items: &interaction.getHeroController().actor.stash, pX: -1)
            case .Shop, .Waypoint, .Ground, .Equipment:
                var shop: [Item] = interaction.getInstanceController().getShopItems()
                interaction.moveItemPointer(items: &shop, pX: -1)
                interaction.getInstanceController().setShopItems(items: shop)
            default:
                break
        }
    }
}

class ButtonDown: ButtonAction {
    func tap(globalState: GlobalState, interaction: InteractionController) {
        switch globalState {
            case .Move:
                interaction.moveHero(mX: 0, mY: 1)
            case .Inspect:
                interaction.moveTileHighlight(mX: 0, mY: 1)
            case .Target:
                interaction.highlightLine(mX: 0, mY: 1)
            case .StashTab1, .Inventory:
                interaction.moveItemPointer(items: &interaction.getHeroController().actor.inventory, pX: 1)
            case .StashTab2:
                interaction.moveItemPointer(items: &interaction.getHeroController().actor.stash, pX: 1)
            case .Shop, .Waypoint, .Ground, .Equipment:
                var shop: [Item] = interaction.getInstanceController().getShopItems()
                interaction.moveItemPointer(items: &shop, pX: 1)
                interaction.getInstanceController().setShopItems(items: shop)
            default:
                break
        }
    }
}

class ButtonLeft: ButtonAction {
    func tap(globalState: GlobalState, interaction: InteractionController) {
        switch globalState {
            case .Move:
                interaction.moveHero(mX: -1, mY: 0)
            case .Inspect:
                interaction.moveTileHighlight(mX: -1, mY: 0)
            case .Target:
                interaction.highlightLine(mX: -1, mY: 0)
            case .StashTab2:
                interaction.getStateController().setState(state: .StashTab1)
                interaction.displayStashItems()
            default:
                break
        }
    }
}

class ButtonRight: ButtonAction {
    func tap(globalState: GlobalState, interaction: InteractionController) {
        switch globalState {
            case .Move:
                interaction.moveHero(mX: 1, mY: 0)
            case .Inspect:
                interaction.moveTileHighlight(mX: 1, mY: 0)
            case .Target:
                interaction.highlightLine(mX: 1, mY: 0)
            case .StashTab1:
                interaction.getStateController().setState(state: .StashTab2)
                interaction.displayStashItems()
            default:
                break
        }
    }
}

class ButtonWait: ButtonAction {
    func tap(globalState: GlobalState, interaction: InteractionController) {
        switch globalState {
            case .Move:
                interaction.moveHero(mX: 0, mY: 0)
            default:
                break
        }
    }
}

class ButtonHome: ButtonAction {
    func tap(globalState: GlobalState, interaction: InteractionController) {
        switch globalState {
            case .Move:
                interaction.moveHero(mX: -1, mY: -1)
            case .Inspect:
                interaction.moveTileHighlight(mX: -1, mY: -1)
            case .Target:
                interaction.highlightLine(mX: -1, mY: -1)
            default:
                break
        }
    }
}

class ButtonEnd: ButtonAction {
    func tap(globalState: GlobalState, interaction: InteractionController) {
        switch globalState {
            case .Move:
                interaction.moveHero(mX: -1, mY: 1)
            case .Inspect:
                interaction.moveTileHighlight(mX: -1, mY: 1)
            case .Target:
                interaction.highlightLine(mX: -1, mY: 1)
            default:
                break
        }
    }
}

class ButtonPgUp: ButtonAction {
    func tap(globalState: GlobalState, interaction: InteractionController) {
        switch globalState {
            case .Move:
                interaction.moveHero(mX: 1, mY: -1)
            case .Inspect:
                interaction.moveTileHighlight(mX: 1, mY: -1)
            case .Target:
                interaction.highlightLine(mX: 1, mY: -1)
            default:
                break
        }
    }
}

class ButtonPgDn: ButtonAction {
    func tap(globalState: GlobalState, interaction: InteractionController) {
        switch globalState {
            case .Move:
                interaction.moveHero(mX: 1, mY: 1)
            case .Inspect:
                interaction.moveTileHighlight(mX: 1, mY: 1)
            case .Target:
                interaction.highlightLine(mX: 1, mY: 1)
            default:
                break
        }
    }
}

class ButtonAction1: ButtonAction {
    func tap(globalState: GlobalState, interaction: InteractionController) {
        switch globalState {
            case .Move:
                if interaction.getHeroController().isParalyzed() && !interaction.getHeroController().isParalyzeImmune() {
                    interaction.getStateController().setState(state: .Cancel)
                    return
                }
                interaction.getStateController().setState(state: .Heal)
                interaction.getStateController().addMessage(message: "Use life flask?")
            case .Inventory:
                if interaction.getHeroController().isParalyzed() && !interaction.getHeroController().isParalyzeImmune() {
                    return
                }
                interaction.equipItem()
            case .Ground:
                var items: [Item] = interaction.getInstanceController().getShopItems()
                interaction.markPointedItem(items: &items)
                interaction.getInstanceController().setShopItems(items: items)
            case .Ring:
                interaction.equipRing(ringType: .Left)
            default:
                break
        }
    }
}

class ButtonAction2: ButtonAction {
    func tap(globalState: GlobalState, interaction: InteractionController) {
        switch globalState {
            case .Move:
                if interaction.getHeroController().isParalyzed() && !interaction.getHeroController().isParalyzeImmune() {
                    interaction.getStateController().setState(state: .Cancel)
                    return
                }
                interaction.selectTarget()
            case .Target:
                interaction.shoot()
            case .StashTab1, .StashTab2, .Shop, .Inventory, .Equipment, .Ground:
                interaction.showPointedItemInfo()
            case .Chest:
                interaction.showChestItemInfo()
            case .Ring:
                interaction.equipRing(ringType: .Right)
            default:
                break
        }
    }
}

class ButtonAction3: ButtonAction {
    func tap(globalState: GlobalState, interaction: InteractionController) {
        switch globalState {
            case .Move:
                if interaction.getHeroController().isParalyzed() && !interaction.getHeroController().isParalyzeImmune() {
                    interaction.getStateController().setState(state: .Cancel)
                    return
                }
                interaction.getStateController().setState(state: .Warp)
                interaction.getStateController().addMessage(message: "Use warp crystal?")
            case .Inventory:
                if interaction.getHeroController().isParalyzed() && !interaction.getHeroController().isParalyzeImmune() {
                    return
                }
                interaction.useItem()
            case .Equipment:
                if interaction.getHeroController().isParalyzed() && !interaction.getHeroController().isParalyzeImmune() {
                    return
                }
                interaction.unequipItem()
            default:
                break
        }
    }
}

class ButtonAction4: ButtonAction {
    func tap(globalState: GlobalState, interaction: InteractionController) {
        switch globalState {
            case .StashTab1, .StashTab2:
                interaction.moveStashInventoryItem()
            case .Shop:
                interaction.buyItem()
            case .Waypoint:
                interaction.enterDungeon()
            case .Heal:
                interaction.useLifeFlask()
            case .Warp:
                interaction.useWarpCrystal()
            case .Move:
                if interaction.getHeroController().isBlind() && !interaction.getHeroController().isBlindImmune() {
                    interaction.getStateController().setState(state: .Cancel)
                    return
                }
                interaction.inspectTile()
            case .Inspect:
                interaction.showHighlightedTileInfo()
                interaction.getStateController().setState(state: .Cancel)
            case .Target:
                interaction.switchTarget()
            case .Pickup:
                interaction.confirmPickup()
            case .Ground:
                interaction.pickupMarkedItems()
            case .Chest:
                interaction.openChest()
            default:
                break
        }
    }
}

class ButtonAction5: ButtonAction {
    func tap(globalState: GlobalState, interaction: InteractionController) {
        switch globalState {
            case .Move:
                if interaction.getHeroController().isBlind() && !interaction.getHeroController().isBlindImmune() {
                    interaction.getStateController().setState(state: .Cancel)
                    return
                }
                interaction.getStateController().setState(state: .Inventory)
                interaction.getInstanceController().bufferMap()
                interaction.displayInventoryItems()
            case .Inventory:
                if interaction.getHeroController().isParalyzed() && !interaction.getHeroController().isParalyzeImmune() {
                    return
                }
                interaction.dropItem()
            default:
                break
        }
    }
}

class ButtonAction6: ButtonAction {
    func tap(globalState: GlobalState, interaction: InteractionController) {
        switch globalState {
            case .Move:
                if interaction.getHeroController().isBlind() && !interaction.getHeroController().isBlindImmune() {
                    interaction.getStateController().setState(state: .Cancel)
                    return
                }
                interaction.getInstanceController().bufferMap()
                interaction.getStateController().setState(state: .Equipment)
                interaction.displayEquipment()
            case .StashTab1, .StashTab2, .Inventory:
                interaction.getInstanceController().revertMap()
                interaction.getInstanceController().clearMapFrame()
                interaction.removeItemPointer(items: &interaction.getHeroController().actor.inventory)
                interaction.removeItemPointer(items: &interaction.getHeroController().actor.stash)
                interaction.getStateController().setState(state: .Cancel)
            case .Ring:
                interaction.getStateController().clearMessages()
                interaction.getStateController().setState(state: .Inventory)
            case .Shop:
                interaction.getStateController().addMessage(message: "\"See you around.\"")
                interaction.getInstanceController().revertMap()
                interaction.getInstanceController().clearMapFrame()
                interaction.getInstanceController().removeAllShopItems()
                interaction.getStateController().setState(state: .Cancel)
            case .Waypoint, .Ground, .Equipment:
                interaction.getInstanceController().clearMapMarks()
                interaction.getInstanceController().revertMap()
                interaction.getInstanceController().clearMapFrame()
                interaction.getInstanceController().removeAllShopItems()
                interaction.getStateController().setState(state: .Cancel)
            case .Info:
                interaction.closeItemInfo()
            case .Heal, .Warp, .Pickup, .Chest:
                interaction.getStateController().clearMessages()
                interaction.getStateController().setState(state: .Cancel)
            case .Inspect:
                interaction.getInstanceController().clearMapHighlights()
                interaction.getStateController().clearMessages()
                interaction.getStateController().setState(state: .Cancel)
            case .Target:
                interaction.cancelTarget()
            default:
                break
        }
    }
}
