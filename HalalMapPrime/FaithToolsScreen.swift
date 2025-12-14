import SwiftUI

/// شاشة أدوات المسلم:
/// - أوقات الصلاة (Placeholder حالياً)
/// - الأذان والتنبيهات (Placeholder)
//  - رمضان (Placeholder: إمساكية/سحور/إفطار)
//  - حاسبة الزكاة (Placeholder)
struct FaithToolsScreen: View {

    @EnvironmentObject var lang: LanguageManager

    @State private var selectedCity: String = ""
    @State private var showQiblaInfo: Bool = false
    @State private var showZakatCalculator: Bool = false
    @State private var showAdhanInfo: Bool = false
    @State private var showRamadanInfo: Bool = false

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    var body: some View {
        NavigationStack {
            List {

                // 1) أوقات الصلاة
                Section(header: Text(L("أوقات الصلاة", "Prayer times"))) {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField(
                            L("اكتب مدينتك (مثال: Brooklyn, NY)", "Enter your city (e.g. Brooklyn, NY)"),
                            text: $selectedCity
                        )
                        .textInputAutocapitalization(.words)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(L("اليوم", "Today"))
                                .font(.subheadline.bold())

                            ForEach(samplePrayerTimes, id: \.name) { p in
                                HStack {
                                    Text(p.name)
                                    Spacer()
                                    Text(p.time)
                                        .foregroundColor(.secondary)
                                }
                                .font(.footnote)
                            }
                        }
                        .padding(.top, 4)
                    }
                    .padding(.vertical, 4)
                }

                // 2) الأذان والتنبيهات
                Section(header: Text(L("الأذان والتنبيهات", "Adhan & reminders"))) {
                    Button {
                        showAdhanInfo = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "bell.badge.fill")
                                .foregroundColor(.orange)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(L("إعدادات الأذان", "Adhan settings"))
                                    .font(.headline)
                                Text(L("تنبيهات الصلاة، الصمت وقت الصلاة، وإعدادات الموقع.", "Prayer reminders, silent mode during prayer, and location settings."))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // 3) رمضان والإمساكية
                Section(header: Text(L("رمضان والإمساكية", "Ramadan & Imsakiyah"))) {
                    Button {
                        showRamadanInfo = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "moonphase.waning.crescent")
                                .foregroundColor(.teal)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(L("إمساكية رمضان", "Ramadan Imsakiyah"))
                                    .font(.headline)
                                Text(L("سحور/إمساك/إفطار حسب مدينتك.", "Suhoor/Imsak/Iftar based on your city."))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // 4) اتجاه القبلة
                Section(header: Text(L("اتجاه القبلة", "Qibla direction"))) {
                    Button {
                        showQiblaInfo = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "location.north.line.fill")
                                .foregroundColor(.green)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(L("بوصلة القبلة", "Qibla compass"))
                                    .font(.headline)
                                Text(L("استخدم البوصلة لمعرفة اتجاه القبلة من موقعك.", "Use the compass to find Qibla from your location."))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // 5) حاسبة الزكاة
                Section(header: Text(L("زكاة المال", "Zakat calculator"))) {
                    Button {
                        showZakatCalculator = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "percent")
                                .foregroundColor(.yellow)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(L("حاسبة الزكاة", "Zakat calculator"))
                                    .font(.headline)
                                Text(L("احسب مقدار الزكاة الواجبة على مدخراتك بسهولة.", "Calculate the zakat due on your savings easily."))
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // 6) أدوات إضافية
                Section(header: Text(L("أدوات إضافية", "More tools"))) {
                    Label(L("التقويم الهجري والمواسم", "Hijri calendar & seasons"), systemImage: "calendar")
                        .foregroundColor(.secondary)

                    Label(L("تنبيهات العشر الأواخر", "Last 10 nights reminders"), systemImage: "sparkles")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(L("أدوات المسلم", "Faith tools"))
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showQiblaInfo) {
                QiblaInfoSheet()
                    .environmentObject(lang)
            }
            .sheet(isPresented: $showZakatCalculator) {
                ZakatInfoSheet()
                    .environmentObject(lang)
            }
            .sheet(isPresented: $showAdhanInfo) {
                AdhanInfoSheet()
                    .environmentObject(lang)
            }
            .sheet(isPresented: $showRamadanInfo) {
                RamadanInfoSheet()
                    .environmentObject(lang)
            }
        }
    }

    private var samplePrayerTimes: [(name: String, time: String)] {
        [
            (L("الفجر", "Fajr"),   "05:30"),
            (L("الظهر", "Dhuhr"),  "12:10"),
            (L("العصر", "Asr"),    "15:30"),
            (L("المغرب", "Maghrib"), "16:45"),
            (L("العشاء", "Isha"),  "18:10")
        ]
    }
}

// MARK: - Sheets

struct QiblaInfoSheet: View {
    @EnvironmentObject var lang: LanguageManager
    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text(L(
                    "في الإصدارات القادمة، سنضيف بوصلة تفاعلية لتحديد اتجاه القبلة بدقة من موقعك.",
                    "In future versions, we will add an interactive compass to show Qibla from your location."
                ))
                .font(.body)

                Text(L(
                    "حالياً يمكنك استخدام أي تطبيق بوصلة موثوق أو خرائط لمعرفة اتجاه مكة.",
                    "For now, you can use any reliable compass or maps app to find the direction of Makkah."
                ))
                .font(.footnote)
                .foregroundColor(.secondary)

                Spacer()
            }
            .padding()
            .navigationTitle(L("اتجاه القبلة", "Qibla direction"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct ZakatInfoSheet: View {
    @EnvironmentObject var lang: LanguageManager
    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text(L(
                    "في الإصدارات القادمة، ستتمكن من إدخال مدخراتك وحساب مقدار الزكاة بدقة.",
                    "In future versions, you will be able to enter your savings and calculate your zakat precisely."
                ))
                .font(.body)

                Text(L(
                    "القاعدة العامة: 2.5٪ من المال الذي حال عليه الحول وتجاوز نصاب الزكاة.",
                    "General rule: 2.5% of savings that reached the minimum nisab and one lunar year has passed."
                ))
                .font(.footnote)
                .foregroundColor(.secondary)

                Spacer()
            }
            .padding()
            .navigationTitle(L("زكاة المال", "Zakat basics"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AdhanInfoSheet: View {
    @EnvironmentObject var lang: LanguageManager
    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text(L(
                    "سنضيف قريباً إعدادات كاملة للأذان والتنبيهات، بما في ذلك اختيار صوت الأذان والاهتزاز وتنبيهات قبل الصلاة.",
                    "Soon we will add full adhan & reminder settings, including adhan sound, vibration, and pre-prayer reminders."
                ))
                .font(.body)

                Text(L(
                    "حالياً هذه صفحة تمهيدية حتى نربطها بـ API أو حسابات دقيقة حسب المدينة.",
                    "For now this is a placeholder until we connect accurate calculations/APIs per city."
                ))
                .font(.footnote)
                .foregroundColor(.secondary)

                Spacer()
            }
            .padding()
            .navigationTitle(L("الأذان والتنبيهات", "Adhan & reminders"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct RamadanInfoSheet: View {
    @EnvironmentObject var lang: LanguageManager
    private func L(_ ar: String, _ en: String) -> String { lang.isArabic ? ar : en }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text(L(
                    "قريباً سنضيف إمساكية رمضان حسب مدينتك: وقت الإمساك، السحور، والإفطار مع تنبيهات.",
                    "Soon we’ll add Ramadan Imsakiyah based on your city: Imsak, Suhoor, and Iftar with reminders."
                ))
                .font(.body)

                Text(L(
                    "الفكرة: تختار مدينتك مرة واحدة، والتطبيق يعرض لك جدول رمضان كامل.",
                    "Idea: choose your city once, and the app shows the full Ramadan schedule."
                ))
                .font(.footnote)
                .foregroundColor(.secondary)

                Spacer()
            }
            .padding()
            .navigationTitle(L("رمضان والإمساكية", "Ramadan & Imsakiyah"))
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct FaithToolsScreen_Previews: PreviewProvider {
    static var previews: some View {
        FaithToolsScreen()
            .environmentObject(LanguageManager())
    }
}
