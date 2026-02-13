import Cocoa

var placeholder = ""
let args = CommandLine.arguments
if let pIndex = args.firstIndex(of: "-p"), args.count > pIndex + 1 {
    placeholder = args[pIndex + 1]
}
let animationsEnabled = CommandLine.arguments.contains("-a")

// Hidden menu to allow copy, paste, select and cut functionality in text field
func setupMenu() {
    let mainMenu = NSMenu()

    let appMenuItem = NSMenuItem()
    mainMenu.addItem(appMenuItem)

    let appMenu = NSMenu()
    appMenuItem.submenu = appMenu

    appMenu.addItem(
        withTitle: "Quit",
        action: #selector(NSApplication.terminate(_:)),
        keyEquivalent: "q"
    )

    let editMenuItem = NSMenuItem()
    mainMenu.addItem(editMenuItem)

    let editMenu = NSMenu(title: "Edit")
    editMenuItem.submenu = editMenu

    editMenu.addItem(
        withTitle: "Cut",
        action: #selector(NSText.cut(_:)),
        keyEquivalent: "x"
    )
    editMenu.addItem(
        withTitle: "Copy",
        action: #selector(NSText.copy(_:)),
        keyEquivalent: "c"
    )
    editMenu.addItem(
        withTitle: "Paste",
        action: #selector(NSText.paste(_:)),
        keyEquivalent: "v"
    )
    editMenu.addItem(
        withTitle: "Select All",
        action: #selector(NSText.selectAll(_:)),
        keyEquivalent: "a"
    )

    NSApp.mainMenu = mainMenu
}

class SpotlightWindow: NSWindow {
    override var canBecomeKey: Bool { true }
    override var canBecomeMain: Bool { true }

    override func cancelOperation(_ sender: Any?) {
        (NSApp.delegate as? AppDelegate)?.animateOutAndQuit()
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    var window: SpotlightWindow!
    var textField: NSTextField!

    func animateOutAndQuit() {
        if animationsEnabled == false {
            NSApp.terminate(nil)
            return
        }
        guard let contentView = window.contentView else {
            NSApp.terminate(nil)
            return
        }

        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.5
            contentView.animator().alphaValue = 0
        }

        let spring = CASpringAnimation(keyPath: "transform")
        spring.fromValue = CATransform3DIdentity
        spring.toValue = CATransform3DMakeScale(0.6, 0.6, 1)

        spring.mass = 1
        spring.stiffness = 260
        spring.damping = 22
        spring.initialVelocity = 10
        spring.duration = spring.settlingDuration

        contentView.layer?.add(spring, forKey: "popOut")

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            NSApp.terminate(nil)
        }
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        setupMenu()

        let width: CGFloat = 620
        let height: CGFloat = 64
        let padding: CGFloat = 20
        let screenFrame = NSScreen.main?.frame ?? .zero

        let windowWidth = width + padding * 2
        let windowHeight = height + padding * 2

        window = SpotlightWindow(
            contentRect: NSRect(x: screenFrame.midX - width/2, y: ( screenFrame.midY*1.2 ) - height/2,
                width: windowWidth,
                height: windowHeight
            ),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        let rootView = NSView(
            frame: NSRect(x: 0, y: 0, width: windowWidth, height: windowHeight)
        )
        rootView.wantsLayer = true
        rootView.layer?.backgroundColor = NSColor.clear.cgColor

        let contentView = NSVisualEffectView(frame: NSRect(x: 0, y: 0, width: width, height: height))
        contentView.material = .hudWindow
        contentView.state = .active
        contentView.blendingMode = .behindWindow
        contentView.wantsLayer = true
        contentView.layer?.cornerRadius = 14
        contentView.layer?.masksToBounds = true
        contentView.alphaValue = animationsEnabled ? 0 : 1

        let overlay = NSView(frame: contentView.bounds)
        overlay.wantsLayer = true
        overlay.layer?.cornerRadius = 14
        overlay.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.25).cgColor
        overlay.layer?.masksToBounds = true

        contentView.addSubview(overlay)

        textField = NSTextField(frame: NSRect(x: 20, y: 14, width: width - 40, height: 36))
        textField.isBordered = true
        textField.isEditable = true
        textField.isSelectable = true
        textField.isBezeled = false
        textField.allowsEditingTextAttributes = false
        textField.focusRingType = .none
        textField.backgroundColor = .clear
        textField.font = .systemFont(ofSize: 24)
        textField.placeholderString = placeholder
        textField.target = self
        textField.action = #selector(submit)

        contentView.addSubview(textField)

        rootView.addSubview(contentView)
        window.contentView = rootView

        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(textField)

        NSApp.activate(ignoringOtherApps: true)

        if animationsEnabled {
            DispatchQueue.main.async {
                NSAnimationContext.runAnimationGroup { context in
                    context.duration = 0.15
                    contentView.animator().alphaValue = 1
                }
                let spring = CASpringAnimation(keyPath: "transform")
                spring.fromValue = CATransform3DMakeScale(0.6, 0.6, 1)
                spring.toValue = CATransform3DIdentity
                spring.mass = 1
                spring.stiffness = 320
                spring.damping = 26
                spring.initialVelocity = 10
                spring.duration = spring.settlingDuration

                contentView.layer?.add(spring, forKey: "popIn")
            }
        }
    }

    @objc func submit() {
        // Make text not be highlighted when submitted
        textField.isSelectable = false
        window.makeFirstResponder(nil)

        let input = textField.stringValue
        print(input)
        fflush(stdout)
        animateOutAndQuit()
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
