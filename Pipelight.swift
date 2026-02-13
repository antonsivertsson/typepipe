import Cocoa

var placeholder = ""
let args = CommandLine.arguments
if let pIndex = args.firstIndex(of: "-p"), args.count > pIndex + 1 {
    placeholder = args[pIndex + 1]
}

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
        NSApp.terminate(nil)
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {

    var window: SpotlightWindow!
    var textField: NSTextField!

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.regular)
        setupMenu()

        let width: CGFloat = 620
        let height: CGFloat = 64
        let screenFrame = NSScreen.main?.frame ?? .zero

        window = SpotlightWindow(
            contentRect: NSRect(x: screenFrame.midX - width/2, y: screenFrame.midY - height/2,
                width: width,
                height: height
            ),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )

        window.isOpaque = false
        window.backgroundColor = .clear
        window.level = .floating
        window.collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]

        let contentView = NSVisualEffectView(frame: window.contentRect(forFrameRect: window.frame))
        contentView.material = .hudWindow
        contentView.state = .active
        contentView.blendingMode = .behindWindow
        contentView.wantsLayer = true
        contentView.layer?.cornerRadius = 14
        contentView.layer?.masksToBounds = true

        let overlay = NSView(frame: contentView.bounds)
        overlay.wantsLayer = true
        overlay.layer?.cornerRadius = 14
        overlay.layer?.backgroundColor = NSColor.black.withAlphaComponent(0.25).cgColor
        overlay.layer?.masksToBounds = true

        contentView.addSubview(overlay)
        window.contentView = contentView

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

        // Focus the text field immediately
        window.makeKeyAndOrderFront(nil)
        window.makeFirstResponder(textField)

        NSApp.activate(ignoringOtherApps: true)
    }

    @objc func submit() {
        let input = textField.stringValue
        print(input)           // goes to stdout
        fflush(stdout)
        NSApp.terminate(nil)
    }
}

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run()
