// SPDX-License-Identifier: GPL-3.0-only
import AppKit

/// Drawing text directly avoids NSTextField's cell insets eating into the physical notch height.
@MainActor
final class CompactMeterRowView: NSView {
    let provider: MeterAgent
    var displayTitle: String
    private(set) var percentText = "--%"
    private(set) var timeText = "--H"

    init(provider: MeterAgent) {
        self.provider = provider
        displayTitle = provider.title
        super.init(frame: .zero)
        setAccessibilityElement(true)
        setAccessibilityRole(.staticText)
    }

    required init?(coder: NSCoder) { nil }

    func update(percent: String, time: String) {
        percentText = percent
        timeText = time
        setAccessibilityLabel(L("%1$@, %2$@, %3$@", displayTitle, percent, time))
        needsDisplay = true
    }

    // Empty attributed strings can report a default line height, so omit absent countdowns from fitting.
    private func strings(size: CGFloat) -> (NSAttributedString, NSAttributedString?) {
        (NSAttributedString(string: percentText, attributes: [.font: AppFont.ubuntuMonoBold(size), .foregroundColor: NSColor.white]),
         timeText.isEmpty ? nil : NSAttributedString(string: timeText, attributes: [.font: AppFont.ubuntuMono(size), .foregroundColor: NSColor.white.withAlphaComponent(0.65)]))
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        let gap: CGFloat = timeText.isEmpty ? 0 : 8
        // Amounts and quota values share a ceiling, independent of countdown presence or pin count.
        var fontSize: CGFloat = 10.5
        var text = strings(size: fontSize)
        // Fit both dimensions so larger glyphs cannot cross row or camera boundaries.
        while fontSize > 5 && (max(text.0.size().height, text.1?.size().height ?? 0) > bounds.height
            || text.0.size().width + (text.1?.size().width ?? 0) + gap > bounds.width) {
            fontSize -= 0.25
            text = strings(size: fontSize)
        }
        text.0.draw(at: NSPoint(x: 0, y: (bounds.height - text.0.size().height) / 2))
        if let time = text.1 {
            time.draw(at: NSPoint(x: bounds.width - time.size().width, y: (bounds.height - time.size().height) / 2))
        }
    }

    override func mouseDown(with event: NSEvent) { nextResponder?.mouseDown(with: event) }
}
