import SwiftUI

/// شاشة أدوات المسلم:
/// - أوقات الصلاة (لاحقاً نربطها بمكتبة أو API)
/// - اتجاه القبلة
/// - حاسبة الزكاة
/// - أدوات إضافية في المستقبل
struct FaithToolsScreen: View {

    @EnvironmentObject var lang: LanguageManager

    @State private var selectedCity: String = ""
    @State private var showQiblaInfo: Bool = false
    @State private var showZakatCalculator: Bool = false

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    var body: some View {
        NavigationStack {
            List {

                // 1) أوقات الصلاة
                Section(
                    header: Text(L("أوقات الصلاة", "Prayer times"))
                ) {
                    VStack(alignment: .leading, spacing: 8) {
                        TextField(
                            L("اكتب مدينتك (مثال: Brooklyn, NY)", "Enter your city (e.g. Brooklyn, NY)"),
                            text: $selectedCity
                        )
                        .textInputAutocapitalization(.words)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(L("اليوم", "Today"))
                                .font(.subheadline.bold())

                            // لاحقاً نستبدل هذه القيم بقيم حقيقية من API
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

                // 2) اتجاه القبلة
                Section(
                    header: Text(L("اتجاه القبلة", "Qibla direction"))
                ) {
                    Button {
                        showQiblaInfo = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "location.north.line.fill")
                                .foregroundColor(.green)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(L("بوصلة القبلة", "Qibla compass"))
                                    .font(.headline)
                                Text(
                                    L(
                                        "استخدم البوصلة لمعرفة اتجاه القبلة من موقعك.",
                                        "Use the compass to find Qibla from your location."
                                    )
                                )
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // 3) حاسبة الزكاة
                Section(
                    header: Text(L("زكاة المال", "Zakat calculator"))
                ) {
                    Button {
                        showZakatCalculator = true
                    } label: {
                        HStack(spacing: 10) {
                            Image(systemName: "washer.fill")
                                .rotationEffect(.degrees(90))
                                .foregroundColor(.yellow)
                            VStack(alignment: .leading, spacing: 4) {
                                Text(L("حاسبة الزكاة", "Zakat calculator"))
                                    .font(.headline)
                                Text(
                                    L(
                                        "احسب مقدار الزكاة الواجبة على مدخراتك بسهولة.",
                                        "Calculate the zakat due on your savings easily."
                                    )
                                )
                                .font(.caption)
                                .foregroundColor(.secondary)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }

                // 4) قسم إضافي لمزايا مستقبلية
                Section(
                    header: Text(L("أدوات إضافية", "More tools"))
                ) {
                    Label(
                        L("التقويم الهجري والمواسم", "Hijri calendar & seasons"),
                        systemImage: "calendar"
                    )
                    .foregroundColor(.secondary)

                    Label(
                        L("تنبيهات رمضان والعشر الأواخر", "Ramadan & last 10 nights reminders"),
                        systemImage: "moonphase.waning.crescent")
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
        }
    }

    // نموذج بسيط لمواقيت الصلاة (بدون حساب حقيقي حالياً)
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

// شاشات بسيطة مؤقتة للقبلة والزكاة – نطوّرها لاحقاً

struct QiblaInfoSheet: View {
    @EnvironmentObject var lang: LanguageManager
    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text(
                    L(
                        "في الإصدارات القادمة، سنضيف بوصلة تفاعلية لتحديد اتجاه القبلة بدقة من موقعك.",
                        "In future versions, we will add an interactive compass to show Qibla from your location."
                    )
                )
                .font(.body)

                Text(
                    L(
                        "حالياً يمكنك استخدام أي تطبيق بوصلة موثوق أو خرائط لمعرفة اتجاه مكة.",
                        "For now, you can use any reliable compass or maps app to find the direction of Makkah."
                    )
                )
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
    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 12) {
                Text(
                    L(
                        "في الإصدارات القادمة، ستتمكن من إدخال مدخراتك وحساب مقدار الزكاة بدقة.",
                        "In future versions, you will be able to enter your savings and calculate your zakat precisely."
                    )
                )
                .font(.body)

                Text(
                    L(
                        "القاعدة العامة: 2.5٪ من المال الذي حال عليه الحول وتجاوز نصاب الزكاة.",
                        "General rule: 2.5% of savings that reached the minimum nisab and one lunar year has passed."
                    )
                )
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

struct FaithToolsScreen_Previews: PreviewProvider {
    static var previews: some View {
        FaithToolsScreen()
            .environmentObject(LanguageManager())
    }
}
