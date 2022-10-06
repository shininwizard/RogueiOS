import Foundation

class StateController: ObservableObject {
    private var state: GlobalState = GlobalState.Move
    private var bufferedState: GlobalState!
    @Published private var flashState: FlashState = FlashState.None
    public var hadAction: Bool = false
    
    @Published private var messages: [String] = [EMPTY_LINE, EMPTY_LINE, EMPTY_LINE]
    
    public func getState() -> GlobalState {
        return state
    }
    
    public func setState(state: GlobalState) {
        self.state = state
    }
    
    public func getBufferedState() -> GlobalState {
        return bufferedState
    }
    
    public func setBufferedState(state: GlobalState) {
        bufferedState = state
    }
    
    public func getFlashState() -> FlashState {
        return flashState
    }
    
    public func setFlashState(state: FlashState) {
        flashState = state
    }

    public func getMessages() -> [String] {
        return messages
    }
    
    public func clearMessages() {
        messages = [EMPTY_LINE, EMPTY_LINE, EMPTY_LINE]
    }
    
    public func addMessage(message: String) {
        for i in 1..<messages.count {
            messages[i - 1] = messages[i]
        }
        messages[messages.count - 1] = message
    }
    
    public func tap(buttonType: ButtonType, hero: HeroController, instance: InstanceController) {
        let button = ButtonController(button: ButtonUp(), hero: hero, instance: instance, state: self)

        switch buttonType {
            case .Up:
                button.set(button: ButtonUp())
            case .Down:
                button.set(button: ButtonDown())
            case .Left:
                button.set(button: ButtonLeft())
            case .Right:
                button.set(button: ButtonRight())
            case .Wait:
                button.set(button: ButtonWait())
            case .Home:
                button.set(button: ButtonHome())
            case .End:
                button.set(button: ButtonEnd())
            case .PgUp:
                button.set(button: ButtonPgUp())
            case .PgDn:
                button.set(button: ButtonPgDn())
            case .Action1:
                button.set(button: ButtonAction1())
            case .Action2:
                button.set(button: ButtonAction2())
            case .Action3:
                button.set(button: ButtonAction3())
            case .Action4:
                button.set(button: ButtonAction4())
            case .Action5:
                button.set(button: ButtonAction5())
            case .Action6:
                button.set(button: ButtonAction6())
        }
        
        button.tap(globalState: state)
    }
}
