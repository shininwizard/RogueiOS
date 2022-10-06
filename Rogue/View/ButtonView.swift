import SwiftUI

struct ButtonView: View {
    var body: some View {
        HStack {
            ArrowButtonsView().padding(.horizontal, 4)
            ActionButtonsView().padding(.horizontal, 4)
        }
    }
    
    struct ArrowButtonsView: View {
        @EnvironmentObject var hero: HeroController
        @EnvironmentObject var instance: InstanceController
        @EnvironmentObject var state: StateController

        var body: some View {
            VStack {
                HStack {
                    Button(action: {
                        buttonTap(buttonType: ButtonType.Home)
                    }) {
                        Image("home")
                    }
                    Button(action: {
                        buttonTap(buttonType: ButtonType.Up)
                    }) {
                        Image("up")
                    }
                    Button(action: {
                        buttonTap(buttonType: ButtonType.PgUp)
                    }) {
                        Image("pgup")
                    }
                }
                HStack {
                    Button(action: {
                        buttonTap(buttonType: ButtonType.Left)
                    }) {
                        Image("left")
                    }
                    Button(action: {
                        buttonTap(buttonType: ButtonType.Wait)
                    }) {
                        Image("wait")
                    }
                    Button(action: {
                        buttonTap(buttonType: ButtonType.Right)
                    }) {
                        Image("right")
                    }
                }
                HStack {
                    Button(action: {
                        buttonTap(buttonType: ButtonType.End)
                    }) {
                        Image("end")
                    }
                    Button(action: {
                        buttonTap(buttonType: ButtonType.Down)
                    }) {
                        Image("down")
                    }
                    Button(action: {
                        buttonTap(buttonType: ButtonType.PgDn)
                    }) {
                        Image("pgdn")
                    }
                }
            }
        }
        
        private func buttonTap(buttonType: ButtonType) {
            state.tap(buttonType: buttonType, hero: hero, instance: instance)
        }
    }

    struct ActionButtonsView: View {
        @EnvironmentObject var hero: HeroController
        @EnvironmentObject var instance: InstanceController
        @EnvironmentObject var state: StateController

        var body: some View {
            VStack {
                HStack {
                    Button(action: {
                        buttonTap(buttonType: ButtonType.Action1)
                    }) {
                        Image(setActionButton1Image(state: state.getState()))
                    }
                    Button(action: {
                        buttonTap(buttonType: ButtonType.Action2)
                    }) {
                        Image(setActionButton2Image(state: state.getState()))
                    }
                }
                HStack {
                    Button(action: {
                        buttonTap(buttonType: ButtonType.Action3)
                    }) {
                        Image(setActionButton3Image(state: state.getState()))
                    }
                    Button(action: {
                        buttonTap(buttonType: ButtonType.Action4)
                    }) {
                        Image(setActionButton4Image(state: state.getState()))
                    }
                }
                HStack {
                    Button(action: {
                        buttonTap(buttonType: ButtonType.Action5)
                    }) {
                        Image(setActionButton5Image(state: state.getState()))
                    }
                    Button(action: {
                        buttonTap(buttonType: ButtonType.Action6)
                    }) {
                        Image(setActionButton6Image(state: state.getState()))
                    }
                }
            }
        }

        private func buttonTap(buttonType: ButtonType) {
            state.tap(buttonType: buttonType, hero: hero, instance: instance)
        }
        
        private func setActionButton1Image(state: GlobalState) -> String {
            switch state {
                case .Move:
                    return "medpack"
                case .Inventory:
                    return "equip"
                case .Ring:
                    return "leftbutt"
                case .Ground:
                    return "select"
                default:
                    return "button"
            }
        }

        private func setActionButton2Image(state: GlobalState) -> String {
            switch state {
                case .Move, .Target:
                    return "shoot"
                case .Inventory, .Equipment, .StashTab1, .StashTab2, .Shop, .Ground, .Chest:
                    return "info"
                case .Ring:
                    return "rightbutt"
                default:
                    return "button"
            }
        }

        private func setActionButton3Image(state: GlobalState) -> String {
            switch state {
                case .Move:
                    return "warp"
                case .Inventory:
                    return "use"
                case .Equipment:
                    return "remove"
                default:
                    return "button"
            }
        }

        private func setActionButton4Image(state: GlobalState) -> String {
            switch state {
                case .Move:
                    return "inspect"
                case .Target:
                    return "swtch"
                case .StashTab1, .StashTab2:
                    return "move"
                case .Shop:
                    return "buy"
                case .Pickup, .Ground, .Waypoint, .Warp, .Heal, .Chest, .Inspect:
                    return "confirm"
                default:
                    return "button"
            }
        }

        private func setActionButton5Image(state: GlobalState) -> String {
            switch state {
                case .Move:
                    return "inventory"
                case .Inventory:
                    return "drop"
                default:
                    return "button"
            }
        }

        private func setActionButton6Image(state: GlobalState) -> String {
            switch state {
                case .Move:
                    return "equip"
                case .End:
                    return "button"
                default:
                    return "cancel"
            }
        }
    }
}

struct ButtonView_Previews: PreviewProvider {
    static var previews: some View {
        ButtonView()
            .environmentObject(HeroController())
            .environmentObject(InstanceController())
            .environmentObject(StateController())
    }
}
