import AppKit

let size = NSSize(width: 1024, height: 1024)
let image = NSImage(size: size)

image.lockFocus()

let rect = NSRect(origin: .zero, size: size)
let tileRect = rect.insetBy(dx: 56, dy: 56)
let cornerRadius: CGFloat = 220
let backgroundPath = NSBezierPath(roundedRect: tileRect, xRadius: cornerRadius, yRadius: cornerRadius)

let topColor = NSColor(calibratedRed: 0.26, green: 0.76, blue: 1.00, alpha: 1.0)
let midColor = NSColor(calibratedRed: 0.08, green: 0.52, blue: 0.98, alpha: 1.0)
let bottomColor = NSColor(calibratedRed: 0.04, green: 0.32, blue: 0.90, alpha: 1.0)
let gradient = NSGradient(colors: [topColor, midColor, bottomColor])

gradient?.draw(in: backgroundPath, angle: -90)

let highlightPath = NSBezierPath(roundedRect: tileRect.insetBy(dx: 16, dy: 16),
                                 xRadius: cornerRadius - 10,
                                 yRadius: cornerRadius - 10)
let highlight = NSGradient(colors: [
    NSColor.white.withAlphaComponent(0.28),
    NSColor.white.withAlphaComponent(0.04)
])
highlight?.draw(in: highlightPath, angle: -90)

let borderPath = NSBezierPath(roundedRect: tileRect.insetBy(dx: 6, dy: 6),
                              xRadius: cornerRadius - 4,
                              yRadius: cornerRadius - 4)
NSColor.white.withAlphaComponent(0.22).setStroke()
borderPath.lineWidth = 6
borderPath.stroke()

let glyphShadow = NSShadow()
glyphShadow.shadowBlurRadius = 16
glyphShadow.shadowOffset = NSSize(width: 0, height: -3)
glyphShadow.shadowColor = NSColor.black.withAlphaComponent(0.22)

let glyphColor = NSColor(calibratedWhite: 0.99, alpha: 0.96)
let symbolConfig = NSImage.SymbolConfiguration(pointSize: 740, weight: .semibold)
    .applying(NSImage.SymbolConfiguration(paletteColors: [glyphColor]))
let symbol = NSImage(systemSymbolName: "puzzlepiece.fill", accessibilityDescription: nil)?
    .withSymbolConfiguration(symbolConfig)

if let symbol {
    let targetRect = tileRect.insetBy(dx: 150, dy: 150)
    let symbolSize = symbol.size
    let scale = min(targetRect.width / symbolSize.width, targetRect.height / symbolSize.height)
    let drawSize = NSSize(width: symbolSize.width * scale, height: symbolSize.height * scale)
    let drawRect = NSRect(
        x: rect.midX - drawSize.width / 2,
        y: rect.midY - drawSize.height / 2,
        width: drawSize.width,
        height: drawSize.height
    )
    NSGraphicsContext.current?.saveGraphicsState()
    glyphShadow.set()
    symbol.draw(in: drawRect)
    NSGraphicsContext.current?.restoreGraphicsState()
}

image.unlockFocus()

let rep = NSBitmapImageRep(data: image.tiffRepresentation!)
let pngData = rep?.representation(using: .png, properties: [:])
let outputURL = URL(fileURLWithPath: "Icon.png", relativeTo: URL(fileURLWithPath: FileManager.default.currentDirectoryPath))
try pngData?.write(to: outputURL)

print("Wrote \(outputURL.path)")
