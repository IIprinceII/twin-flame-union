import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct TFWidgetEntry: TimelineEntry {
    let date: Date
    let moonEmoji: String
    let moonName: String
    let affirmation: String
}

// MARK: - Timeline Provider

struct TFWidgetProvider: TimelineProvider {

    private let affirmations = [
        "I am worthy of deep, unconditional love.",
        "My heart is open to divine connection.",
        "I trust the journey my soul has chosen.",
        "Love flows to me easily and effortlessly.",
        "I am aligned with my highest self.",
        "My twin flame journey is unfolding perfectly.",
        "I radiate love, light, and positive energy.",
        "I release all that no longer serves my heart.",
        "Every step I take leads me closer to union.",
        "I am whole, complete, and deeply loved.",
        "The universe is always working in my favour.",
        "My soul knows the way home.",
        "I welcome healing with an open heart.",
        "I am a magnet for divine love.",
        "My connection is sacred and eternal.",
    ]

    private func currentMoonPhase() -> (emoji: String, name: String) {
        var comps = DateComponents(); comps.year = 2000; comps.month = 1; comps.day = 6
        let ref = Calendar(identifier: .gregorian).date(from: comps) ?? Date()
        let days = Date().timeIntervalSince(ref) / 86400.0
        let cycle = 29.53058867
        let phase = ((days.truncatingRemainder(dividingBy: cycle)) / cycle * 8)
        let index = Int(phase) % 8
        let phases: [(String, String)] = [
            ("🌑","New Moon"),("🌒","Waxing Crescent"),("🌓","First Quarter"),("🌔","Waxing Gibbous"),
            ("🌕","Full Moon"),("🌖","Waning Gibbous"),("🌗","Last Quarter"),("🌘","Waning Crescent")
        ]
        return phases[index]
    }

    private func currentAffirmation() -> String {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return affirmations[dayOfYear % affirmations.count]
    }

    func placeholder(in context: Context) -> TFWidgetEntry {
        TFWidgetEntry(
            date: Date(),
            moonEmoji: "🌕",
            moonName: "Full Moon",
            affirmation: "I am worthy of deep, unconditional love."
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (TFWidgetEntry) -> Void) {
        let entry = TFWidgetEntry(
            date: Date(),
            moonEmoji: "🌕",
            moonName: "Full Moon",
            affirmation: "I am worthy of deep, unconditional love."
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TFWidgetEntry>) -> Void) {
        let moon = currentMoonPhase()
        let entry = TFWidgetEntry(
            date: Date(),
            moonEmoji: moon.emoji,
            moonName: moon.name,
            affirmation: currentAffirmation()
        )

        let tomorrow = Calendar.current.startOfDay(for: Date().addingTimeInterval(86400))
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        _ = tomorrow
        completion(timeline)
    }
}

// MARK: - Small Widget View

struct TFSmallWidgetView: View {
    let entry: TFWidgetEntry

    var body: some View {
        VStack(alignment: .center, spacing: 6) {
            Text(entry.moonEmoji)
                .font(.system(size: 36))

            Text(entry.moonName)
                .font(.caption2)
                .foregroundColor(.white.opacity(0.7))

            Text(entry.affirmation)
                .font(.system(size: 11, weight: .regular, design: .serif))
                .italic()
                .foregroundColor(Color(red: 0.98, green: 0.95, blue: 0.88))
                .multilineTextAlignment(.center)
                .lineLimit(2)

            Spacer(minLength: 0)

            Text("Twin Flame")
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.40))
                .tracking(1.2)
        }
        .padding(12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ContainerRelativeShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.06, green: 0.02, blue: 0.13),
                            Color(red: 0.12, green: 0.04, blue: 0.22)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}

// MARK: - Medium Widget View

struct TFMediumWidgetView: View {
    let entry: TFWidgetEntry

    var body: some View {
        HStack(spacing: 0) {
            // Left: moon info
            VStack(spacing: 6) {
                Text(entry.moonEmoji)
                    .font(.system(size: 42))
                Text(entry.moonName)
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity)

            // Vertical divider
            Rectangle()
                .fill(Color(red: 0.55, green: 0.30, blue: 0.80).opacity(0.5))
                .frame(width: 1)
                .padding(.vertical, 8)

            // Right: affirmation
            VStack(alignment: .leading, spacing: 5) {
                Text("Daily Affirmation")
                    .font(.system(size: 9, weight: .semibold))
                    .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.40))
                    .tracking(1.0)

                Text(entry.affirmation)
                    .font(.system(size: 12, weight: .regular, design: .serif))
                    .italic()
                    .foregroundColor(Color(red: 0.98, green: 0.95, blue: 0.88))
                    .multilineTextAlignment(.leading)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.leading, 12)
        }
        .padding(14)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            ContainerRelativeShape()
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.06, green: 0.02, blue: 0.13),
                            Color(red: 0.12, green: 0.04, blue: 0.22)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        )
    }
}

// MARK: - Widget

struct TFHomeWidget: Widget {
    let kind: String = "TFHomeWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: TFWidgetProvider()) { entry in
            TFHomeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Twin Flame")
        .description("Daily affirmation and moon phase.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct TFHomeWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    let entry: TFWidgetEntry

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            TFSmallWidgetView(entry: entry)
        case .systemMedium:
            TFMediumWidgetView(entry: entry)
        default:
            TFSmallWidgetView(entry: entry)
        }
    }
}
