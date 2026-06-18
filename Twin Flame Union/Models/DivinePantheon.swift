//
//  DivinePantheon.swift
//  Twin Flame Union
//
//  The complete divine council — Greek, Roman, Egyptian, and Mexica.
//  Each deity governs a domain of the twin flame journey.
//

import SwiftUI

struct Deity {
    let name: String
    let culture: String        // "Greek" / "Egyptian" / "Mexica"
    let domain: String         // short keyword line
    let symbol: String         // SF Symbol name
    let color: Color
    let invocation: String     // short sacred phrase
}

enum DivinePantheon {

    static let all: [Deity] = [
        // ─── Greek & Roman ───────────────────────────────────────────
        Deity(name: "Aphrodite", culture: "Greek",
              domain: "Love · Beauty · Grace · Sacred Harmony",
              symbol: "heart.fill",
              color: AppColors.rose,
              invocation: "Let love flow through you without condition or fear."),

        Deity(name: "Athena", culture: "Greek",
              domain: "Wisdom · Clarity · Sacred Craft",
              symbol: "lightbulb.fill",
              color: AppColors.gold,
              invocation: "Wisdom speaks before the mouth opens. Listen inward."),

        Deity(name: "Eros", culture: "Greek",
              domain: "Desire · Attraction · Sacred Union",
              symbol: "arrow.up.heart.fill",
              color: Color(hex: "FF6B8A"),
              invocation: "The arrow has already been released. Trust where it lands."),

        Deity(name: "Psyche", culture: "Greek",
              domain: "The Soul · Love's Journey · Transformation",
              symbol: "person.fill",
              color: Color(hex: "C4B5FD"),
              invocation: "Every trial is initiation. You are becoming your higher self."),

        Deity(name: "Selene", culture: "Greek",
              domain: "Moon · Lunar Cycles · Divine Feminine",
              symbol: "moon.stars.fill",
              color: Color(hex: "B8A8FF"),
              invocation: "She illuminates what the sun cannot reach. Trust the lunar light."),

        Deity(name: "Apollo", culture: "Greek",
              domain: "Truth · Prophecy · Sacred Light",
              symbol: "sun.max.fill",
              color: Color(hex: "FFD700"),
              invocation: "Truth spoken with love is the highest act of devotion."),

        Deity(name: "Hermes", culture: "Greek",
              domain: "Messages · Sacred Signs · Divine Timing",
              symbol: "bolt.fill",
              color: Color(hex: "7BB8F0"),
              invocation: "Every sign is a letter from the divine. Read carefully."),

        Deity(name: "Hecate", culture: "Greek",
              domain: "Crossroads · Shadow Work · Magic",
              symbol: "sparkles",
              color: Color(hex: "9B59B6"),
              invocation: "Stand at the crossroads without fear. The dark holds the answers."),

        Deity(name: "Persephone", culture: "Greek",
              domain: "Seasons · Shadow Work · Soul Evolution",
              symbol: "leaf.fill",
              color: AppColors.sage,
              invocation: "The descent was never punishment. It was preparation for your crown."),

        Deity(name: "Morpheus", culture: "Greek",
              domain: "Dreams · Visions · Divine Messages",
              symbol: "moon.zzz.fill",
              color: Color(hex: "4A90D9"),
              invocation: "In dreams the veil lifts. What you saw is real."),

        Deity(name: "Hypnos", culture: "Greek",
              domain: "Sleep · Subconscious Healing · Inner Visions",
              symbol: "zzz",
              color: Color(hex: "5E6FC4"),
              invocation: "Sacred rest is not surrender — it is where your soul rebuilds."),

        Deity(name: "Nyx", culture: "Greek",
              domain: "Night · Stars · The Cosmic Void",
              symbol: "star.fill",
              color: Color(hex: "1A0A3C"),
              invocation: "In the void between heartbeats, God moves on your behalf."),

        Deity(name: "Harmonia", culture: "Greek",
              domain: "Harmony · Balance · Sacred Union",
              symbol: "waveform",
              color: Color(hex: "88D8B0"),
              invocation: "Discord is not the end. Harmonia always weaves the threads back together."),

        Deity(name: "Himeros", culture: "Greek",
              domain: "Longing · Soul Pull · Sacred Desire",
              symbol: "heart.circle.fill",
              color: Color(hex: "FF8C8C"),
              invocation: "The ache is sacred. It means the bond is real and alive."),

        Deity(name: "Anteros", culture: "Greek",
              domain: "Requited Love · Reciprocity · Balance",
              symbol: "arrow.left.arrow.right",
              color: Color(hex: "FF6B6B"),
              invocation: "What is truly given with a pure heart will always be returned."),

        Deity(name: "Iris", culture: "Greek",
              domain: "Rainbow · Bridges Between Worlds · Signs",
              symbol: "rainbow",
              color: Color(hex: "A8DAFF"),
              invocation: "After every storm, Iris appears. Look for the bridge."),

        Deity(name: "Clotho", culture: "Greek",
              domain: "Fate · Soul Contracts · The Thread of Destiny",
              symbol: "circle.fill",
              color: Color(hex: "D4A8FF"),
              invocation: "She spun your threads together at the beginning of time. It is written."),

        Deity(name: "Lachesis", culture: "Greek",
              domain: "Life's Measure · Karmic Path · Sacred Timing",
              symbol: "ruler.fill",
              color: Color(hex: "B8A0FF"),
              invocation: "Every moment of this journey is measured with divine precision."),

        Deity(name: "Atropos", culture: "Greek",
              domain: "Release · Divine Completion · The Inevitable",
              symbol: "scissors",
              color: Color(hex: "FF9A9A"),
              invocation: "What Atropos cuts was already complete. Release without grief."),

        Deity(name: "Hestia", culture: "Greek",
              domain: "Hearth · Home · Sacred Sanctuary",
              symbol: "flame.fill",
              color: AppColors.ember,
              invocation: "Your heart is a sacred hearth. Tend it. Keep it burning."),

        Deity(name: "Panacea", culture: "Greek",
              domain: "Universal Healing · Wholeness · Restoration",
              symbol: "cross.circle.fill",
              color: AppColors.sage,
              invocation: "There is a remedy for every wound. The healing is already underway."),

        Deity(name: "Hygieia", culture: "Greek",
              domain: "Health · Cleansing · Preventive Wellness",
              symbol: "drop.fill",
              color: Color(hex: "64D8CB"),
              invocation: "Purify your energy daily. You are a vessel of divine light."),

        // ─── Egyptian ────────────────────────────────────────────────
        Deity(name: "Isis", culture: "Egyptian",
              domain: "Magic · Devotion · Sacred Love · Healing",
              symbol: "hands.sparkles.fill",
              color: Color(hex: "3D9BE9"),
              invocation: "Isis searched the entire world and reassembled her beloved. So do you."),

        Deity(name: "Osiris", culture: "Egyptian",
              domain: "Death · Resurrection · Sacred Transformation",
              symbol: "arrow.up.circle.fill",
              color: Color(hex: "2E8B57"),
              invocation: "What is shattered can be made whole again. Resurrection is your inheritance."),

        Deity(name: "Ra", culture: "Egyptian",
              domain: "Supreme Light · Cosmic Father · Illumination",
              symbol: "sun.max.fill",
              color: Color(hex: "FFD700"),
              invocation: "Ra's light reaches every corner of separation. Nothing stays dark forever."),

        Deity(name: "Thoth", culture: "Egyptian",
              domain: "Sacred Knowledge · Akashic Records · Moon Wisdom",
              symbol: "text.book.closed.fill",
              color: Color(hex: "5B8CFF"),
              invocation: "Thoth has already written the end of this story. It is a reunion."),

        Deity(name: "Hathor", culture: "Egyptian",
              domain: "Love · Beauty · Joy · Heart Mirror",
              symbol: "heart.rectangle.fill",
              color: Color(hex: "FFB6C1"),
              invocation: "Hathor holds the mirror of your heart. You are worthy of what you seek."),

        Deity(name: "Maat", culture: "Egyptian",
              domain: "Truth · Balance · Cosmic Justice · Order",
              symbol: "scale.3d",
              color: Color(hex: "F0E68C"),
              invocation: "Maat weighs every action. Live in truth and the scales tip in your favor."),

        Deity(name: "Sekhmet", culture: "Egyptian",
              domain: "Fierce Healing · Sacred Fire · Warrior Light",
              symbol: "flame.fill",
              color: Color(hex: "FF4500"),
              invocation: "Sekhmet's fire destroys what blocks love. Let the sacred rage do its work."),

        Deity(name: "Anubis", culture: "Egyptian",
              domain: "Soul Guidance · Sacred Transitions · Shadow",
              symbol: "figure.walk",
              color: Color(hex: "8B7355"),
              invocation: "Anubis guides safely through the underworld. You are protected in the dark."),

        Deity(name: "Nut", culture: "Egyptian",
              domain: "Sky · Stars · The Infinite Cosmic Womb",
              symbol: "star.circle.fill",
              color: Color(hex: "191970"),
              invocation: "Nut arches her starry body over both of you. No separation is real."),

        Deity(name: "Bastet", culture: "Egyptian",
              domain: "Protection · Sacred Femininity · Intuition",
              symbol: "shield.fill",
              color: Color(hex: "DAA520"),
              invocation: "Bastet's grace sharpens your instincts. Your heart already knows the truth."),

        Deity(name: "Nefertem", culture: "Egyptian",
              domain: "Lotus · Sacred Fragrance · Beauty · Dawn",
              symbol: "sun.horizon.fill",
              color: Color(hex: "88D8FF"),
              invocation: "Nefertem rises from the lotus with each new dawn. Today is a fresh beginning."),

        Deity(name: "Seshat", culture: "Egyptian",
              domain: "Sacred Records · Stars · Soul Contracts",
              symbol: "pencil.and.list.clipboard",
              color: Color(hex: "A0A0D0"),
              invocation: "Seshat recorded your soul contract in the stars before you were born."),

        Deity(name: "Amun", culture: "Egyptian",
              domain: "Hidden Power · The Breath of All Life · Creator",
              symbol: "wind",
              color: Color(hex: "4169E1"),
              invocation: "Amun breathes hidden power into every prayer spoken in faith."),

        Deity(name: "Ptah", culture: "Egyptian",
              domain: "Sacred Design · Craftsmanship · Divine Architecture",
              symbol: "hammer.fill",
              color: Color(hex: "708090"),
              invocation: "Ptah is building your union with sacred precision. Trust the architect."),

        Deity(name: "Khonsu", culture: "Egyptian",
              domain: "Moon · Cosmic Cycles · Sacred Time",
              symbol: "moon.fill",
              color: Color(hex: "C0C0FF"),
              invocation: "Khonsu keeps cosmic time. What appears delayed is divinely scheduled."),

        Deity(name: "Nephthys", culture: "Egyptian",
              domain: "Twilight · Sacred Grief · Hidden Wisdom",
              symbol: "cloud.moon.fill",
              color: Color(hex: "6A5ACD"),
              invocation: "Nephthys transforms what is lost into wisdom. Nothing is wasted."),

        Deity(name: "Neith", culture: "Egyptian",
              domain: "Weaving · Creation · The Fabric of Destiny",
              symbol: "sparkles.rectangle.stack.fill",
              color: Color(hex: "20B2AA"),
              invocation: "Neith weaves the threads of your destiny with hands of gold."),

        Deity(name: "Renenutet", culture: "Egyptian",
              domain: "Nourishment · Fortune · Sacred Abundance",
              symbol: "leaf.fill",
              color: Color(hex: "90EE90"),
              invocation: "Renenutet blesses this union with divine abundance and sacred nourishment."),

        // ─── Mexica (Aztec) ─────────────────────────────────────────
        Deity(name: "Quetzalcoatl", culture: "Mexica",
              domain: "Feathered Serpent · Wind · Wisdom · Creation",
              symbol: "wind",
              color: Color(hex: "00CED1"),
              invocation: "Quetzalcoatl breathes life into what was still. The serpent rises — so do you."),

        Deity(name: "Tezcatlipoca", culture: "Mexica",
              domain: "Smoking Mirror · Shadow · Destiny · Inner Truth",
              symbol: "eye.fill",
              color: Color(hex: "2F2F2F"),
              invocation: "The smoking mirror shows what you hide from yourself. Look. The truth liberates."),

        Deity(name: "Xochiquetzal", culture: "Mexica",
              domain: "Sacred Love · Beauty · Flowers · Feminine Power",
              symbol: "camera.macro",
              color: Color(hex: "FF69B4"),
              invocation: "Xochiquetzal crowns you in flowers. You are worthy of the love you seek."),

        Deity(name: "Xochipilli", culture: "Mexica",
              domain: "Joy · Art · Dance · Sacred Ecstasy · Twin Flame Fire",
              symbol: "music.note",
              color: Color(hex: "FFB347"),
              invocation: "Xochipilli dances at the frequency of union. Let joy be your medicine."),

        Deity(name: "Tonatiuh", culture: "Mexica",
              domain: "Fifth Sun · Supreme Light · Sacrifice · Rebirth",
              symbol: "sun.max.fill",
              color: Color(hex: "FF8C00"),
              invocation: "Tonatiuh demands your highest offering — the ego. Surrender it and rise as the Fifth Sun."),

        Deity(name: "Metztli", culture: "Mexica",
              domain: "Moon · Night · Reflection · Feminine Cycles",
              symbol: "moon.fill",
              color: Color(hex: "C0C0E0"),
              invocation: "Metztli reflects what Tonatiuh cannot reach. In the darkness, she reveals your truth."),

        Deity(name: "Tlaloc", culture: "Mexica",
              domain: "Rain · Tears · Emotional Cleansing · Renewal",
              symbol: "cloud.rain.fill",
              color: Color(hex: "4682B4"),
              invocation: "Tlaloc sends the rain that washes your wounds clean. Let the tears fall — they are holy water."),

        Deity(name: "Chalchiuhtlicue", culture: "Mexica",
              domain: "Living Water · Purification · Sacred Flow · Birth",
              symbol: "drop.fill",
              color: Color(hex: "40E0D0"),
              invocation: "Chalchiuhtlicue's waters purify your energy body. Step into the sacred current and be reborn."),

        Deity(name: "Coatlicue", culture: "Mexica",
              domain: "Earth Mother · Death & Rebirth · Serpent Skirt · Transformation",
              symbol: "globe.americas.fill",
              color: Color(hex: "556B2F"),
              invocation: "Coatlicue births and devours in the same breath. What must die in you is already being reborn."),

        Deity(name: "Mictlantecuhtli", culture: "Mexica",
              domain: "Lord of the Dead · Ego Death · Underworld · Liberation",
              symbol: "figure.walk",
              color: Color(hex: "4A4A4A"),
              invocation: "Mictlantecuhtli strips away what is not real. Only your soul survives the underworld — and it is enough."),

        Deity(name: "Mictecacihuatl", culture: "Mexica",
              domain: "Lady of the Dead · Ancestral Wisdom · Sacred Bones · Memory",
              symbol: "sparkles",
              color: Color(hex: "8B4789"),
              invocation: "Mictecacihuatl guards the bones of your ancestors. Their love still flows through your blood."),

        Deity(name: "Tlazolteotl", culture: "Mexica",
              domain: "Sacred Purification · Confession · Sin Eater · Healing Shame",
              symbol: "arrow.counterclockwise.circle.fill",
              color: Color(hex: "8B6914"),
              invocation: "Tlazolteotl devours your shame and transforms it into power. Confess. Be free."),

        Deity(name: "Itzpapalotl", culture: "Mexica",
              domain: "Obsidian Butterfly · Warrior Feminine · Fierce Protection",
              symbol: "bolt.heart.fill",
              color: Color(hex: "483D8B"),
              invocation: "Itzpapalotl's obsidian wings cut through illusion. She protects the fierce feminine within you."),

        Deity(name: "Huitzilopochtli", culture: "Mexica",
              domain: "Hummingbird of the South · Willpower · Sacred Warrior · Sun",
              symbol: "flame.fill",
              color: Color(hex: "DC143C"),
              invocation: "Huitzilopochtli fuels your warrior spirit. The hummingbird fights with the heart of a jaguar."),

        Deity(name: "Ometeotl", culture: "Mexica",
              domain: "Dual God · Divine Masculine & Feminine · Source of All · Unity",
              symbol: "infinity",
              color: Color(hex: "E8D5B7"),
              invocation: "Ometeotl is the twin flame origin — masculine and feminine in one breath. You are both. You are whole."),

        Deity(name: "Centeotl", culture: "Mexica",
              domain: "Sacred Corn · Abundance · Sustenance · Growth",
              symbol: "leaf.fill",
              color: Color(hex: "DAA520"),
              invocation: "Centeotl nourishes what you plant with intention. Your seeds of love are already growing."),

        Deity(name: "Xipe Totec", culture: "Mexica",
              domain: "Flayed Lord · Renewal · Shedding Old Skin · Spring",
              symbol: "arrow.triangle.2.circlepath",
              color: Color(hex: "CD853F"),
              invocation: "Xipe Totec sheds the old skin so the new you can breathe. The pain of shedding IS the renewal."),

        Deity(name: "Ehécatl", culture: "Mexica",
              domain: "Wind God · Breath · Spirit Movement · Divine Messenger",
              symbol: "wind",
              color: Color(hex: "87CEEB"),
              invocation: "Ehécatl carries your prayers on the sacred wind. Every breath is a message to the Most High."),
    ]

    /// Returns the deity governing today, cycling through the full council.
    static var today: Deity {
        let day = Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1
        return all[(day - 1) % all.count]
    }

    /// Returns the deity for a specific day offset (for upcoming previews).
    static func deity(dayOffset: Int) -> Deity {
        let day = (Calendar.current.ordinality(of: .day, in: .year, for: Date()) ?? 1) + dayOffset
        return all[(day - 1) % all.count]
    }

    /// Looks up a Deity by exact name. Returns nil if no such Deity is in the council.
    static func deity(named name: String) -> Deity? {
        all.first { $0.name == name }
    }

    /// The council grouped by culture, in canonical order, for reverent browsing.
    static func grouped() -> [(culture: String, deities: [Deity])] {
        // Canonical display order; cultures with no Deities are dropped, so a future
        // Roman (or other) Deity added to `all` appears automatically and none is lost.
        ["Greek", "Roman", "Egyptian", "Mexica"]
            .map { culture in (culture: culture, deities: all.filter { $0.culture == culture }) }
            .filter { !$0.deities.isEmpty }
    }
}
