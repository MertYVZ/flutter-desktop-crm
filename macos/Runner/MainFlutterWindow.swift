import Cocoa
import FlutterMacOS

class MainFlutterWindow: NSWindow {
  override func awakeFromNib() {
    let flutterViewController = FlutterViewController()
    let launchBackground = NSColor(
      calibratedRed: 0.956,
      green: 0.961,
      blue: 0.969,
      alpha: 1.0
    )

    self.backgroundColor = launchBackground
    flutterViewController.view.wantsLayer = true
    flutterViewController.view.layer?.backgroundColor = launchBackground.cgColor

    self.contentViewController = flutterViewController
    self.setContentSize(NSSize(width: 1024, height: 717))
    self.center()

    RegisterGeneratedPlugins(registry: flutterViewController)

    super.awakeFromNib()
    _applyMinimumSize()
  }

  private func _applyMinimumSize() {
    let minimum = NSSize(width: 720, height: 500)
    contentMinSize = minimum
    minSize = minimum
  }
}
