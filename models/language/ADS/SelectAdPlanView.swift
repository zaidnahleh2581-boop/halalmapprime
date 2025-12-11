import SwiftUI

/// شاشة اختيار باقة الإعلان (يومي / أسبوعي / شهري)
struct SelectAdPlanView: View {

    @EnvironmentObject var lang: LanguageManager

    @State private var showAlert: Bool = false
    @State private var selectedPlanMessage: String = ""
    @State private var isSubmitting: Bool = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    // العنوان
                    VStack(alignment: .leading, spacing: 4) {
                        Text(lang.isArabic ? "اختر باقة الإعلان" : "Select Your Ad Plan")
                            .font(.title2)
                            .fontWeight(.semibold)

                        Text(
                            lang.isArabic
                            ? "اختر مدة ودرجة ظهور إعلانك في التطبيق."
                            : "Choose how long and how strong your ad will appear in the app."
                        )
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 8)

                    // نص تعريفي
                    Text(
                        lang.isArabic
                        ? "اختر مدة ظهور إعلانك داخل التطبيق. جميع عمليات الدفع لاحقاً ستتم بأمان من خلال Apple In-App Purchase، وحالياً نحفظ طلب الباقة في النظام."
                        : "Pick how long your ad will run. Payments will later be handled securely via Apple In-App Purchase; for now we store your plan request in the system."
                    )
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                    // كروت الباقات
                    VStack(spacing: 12) {
                        dailyPlanCard
                        weeklyPlanCard
                        monthlyPlanCard
                    }
                    .padding(.top, 4)

                    // مقارنة بسيطة
                    comparisonSection

                    // ملاحظة أخيرة
                    footerNote
                }
                .padding()
            }
            .navigationTitle(lang.isArabic ? "اختيار الباقة" : "Choose a Plan")
            .navigationBarTitleDisplayMode(.inline)
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text(lang.isArabic ? "تم تسجيل الطلب" : "Plan saved"),
                    message: Text(selectedPlanMessage),
                    dismissButton: .default(Text(lang.isArabic ? "حسناً" : "OK"))
                )
            }
        }
    }
}

// MARK: - Components

private extension SelectAdPlanView {

    // MARK: - أزرار الباقات (كل واحد يستدعي createPaidOrder)

    var dailyPlanCard: some View {
        planCard(
            planType: .daily,
            titleAR: "إعلان يومي",
            titleEN: "Daily Ad",
            subtitleAR: "$4.99 / اليوم (مثال)",
            subtitleEN: "$4.99 / day (example)",
            descriptionAR: "ظهور إعلانك لمدة ٢٤ ساعة في الأماكن المميزة داخل التطبيق والخريطة.",
            descriptionEN: "Your ad appears for 24 hours in highlighted spots across the app and map.",
            bulletsAR: [
                "مناسب للعروض السريعة أو الافتتاحات.",
                "تفعيل فوري بعد الاعتماد.",
                "ظهور جيد ضمن نظام التدوير (Rotation)."
            ],
            bulletsEN: [
                "Great for quick promos or grand openings.",
                "Instant activation after approval.",
                "Good visibility in the rotation system."
            ],
            accentColor: Color(.systemYellow)
        )
    }

    var weeklyPlanCard: some View {
        planCard(
            planType: .weekly,
            titleAR: "إعلان أسبوعي (الأكثر اختياراً)",
            titleEN: "Weekly Ad (Most popular)",
            subtitleAR: "$14.99 / الأسبوع (مثال)",
            subtitleEN: "$14.99 / week (example)",
            descriptionAR: "ظهور إعلانك لمدة ٧ أيام متواصلة مع ترتيب أعلى في نتائج الإعلانات.",
            descriptionEN: "Your ad appears for 7 days with higher ranking in ad placements.",
            bulletsAR: [
                "مناسب للمطاعم والخدمات التي ترغب في ثبات الظهور.",
                "أولوية أعلى من الإعلان اليومي.",
                "قيمة أفضل مقابل السعر."
            ],
            bulletsEN: [
                "Perfect for restaurants and services that want steady visibility.",
                "Higher priority than daily ads.",
                "Better value for money."
            ],
            accentColor: Color(.systemBlue)
        )
    }

    var monthlyPlanCard: some View {
        planCard(
            planType: .monthly,
            titleAR: "إعلان شهري (مميز)",
            titleEN: "Monthly Ad (Premium)",
            subtitleAR: "$49.99 / الشهر (مثال)",
            subtitleEN: "$49.99 / month (example)",
            descriptionAR: "أقوى ظهور للإعلان داخل التطبيق مع أولوية عالية في تدوير البانرات.",
            descriptionEN: "Maximum visibility inside the app with top priority in banner rotation.",
            bulletsAR: [
                "أفضل خيار لأصحاب الأعمال الذين يريدون حضوراً دائماً.",
                "أعلى أولوية بين جميع الإعلانات.",
                "ظهور مستمر لمدة ٣٠ يوماً."
            ],
            bulletsEN: [
                "Best choice for businesses that want constant presence.",
                "Highest priority among all ad types.",
                "Continuous visibility for 30 days."
            ],
            accentColor: Color(.systemGreen)
        )
    }

    // MARK: - الكرت العام

    func planCard(
        planType: PaidAdPlanType,
        titleAR: String,
        titleEN: String,
        subtitleAR: String,
        subtitleEN: String,
        descriptionAR: String,
        descriptionEN: String,
        bulletsAR: [String],
        bulletsEN: [String],
        accentColor: Color
    ) -> some View {
        let bullets = lang.isArabic ? bulletsAR : bulletsEN

        return Button {
            // استدعاء إنشاء طلب باقة في Firebase
            createPaidOrder(for: planType)
        } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(lang.isArabic ? titleAR : titleEN)
                            .font(.headline)

                        Text(lang.isArabic ? subtitleAR : subtitleEN)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    Circle()
                        .fill(accentColor.opacity(0.15))
                        .frame(width: 40, height: 40)
                        .overlay(
                            Image(systemName: "star.fill")
                                .foregroundColor(accentColor)
                                .imageScale(.medium)
                        )
                }

                Text(lang.isArabic ? descriptionAR : descriptionEN)
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                VStack(alignment: .leading, spacing: 4) {
                    ForEach(bullets, id: \.self) { bullet in
                        HStack(alignment: .top, spacing: 6) {
                            Text("•")
                            Text(bullet)
                        }
                        .font(.footnote)
                        .foregroundColor(.secondary)
                    }
                }

                Text(lang.isArabic ? "اختيار هذه الباقة" : "Choose this plan")
                    .font(.subheadline.weight(.semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(accentColor)
                    )
                    .foregroundColor(.white)
                    .padding(.top, 4)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(Color(.systemBackground))
                    .shadow(color: Color.black.opacity(0.06),
                            radius: 6, x: 0, y: 3)
            )
        }
        .buttonStyle(.plain)
        .disabled(isSubmitting)
    }

    // MARK: - استدعاء الخدمة

    private func createPaidOrder(for plan: PaidAdPlanType) {
        guard !isSubmitting else { return }
        isSubmitting = true

        PaidAdsService.shared.createOrder(plan: plan) { result in
            DispatchQueue.main.async {
                isSubmitting = false
                switch result {
                case .success:
                    selectedPlanMessage =
                        lang.isArabic
                        ? "تم حفظ طلب هذه الباقة بنجاح. لاحقاً سيتم ربطه بالدفع عبر Apple Store وتعبئة تفاصيل الإعلان."
                        : "Your request for this plan has been saved. Later it will be linked to Apple Store payment and ad details."
                case .failure(let error):
                    selectedPlanMessage =
                        lang.isArabic
                        ? "حدث خطأ أثناء حفظ طلب الباقة: \(error.localizedDescription)"
                        : "Failed to save your plan request: \(error.localizedDescription)"
                }
                showAlert = true
            }
        }
    }

    // MARK: - باقي الأقسام كما هي عندك

    var comparisonSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(lang.isArabic ? "مقارنة سريعة بين الباقات" : "Quick comparison between plans")
                .font(.headline)

            VStack(spacing: 6) {
                comparisonRow(
                    label: lang.isArabic ? "مدة العرض" : "Duration",
                    daily: lang.isArabic ? "٢٤ ساعة" : "24 hours",
                    weekly: lang.isArabic ? "٧ أيام" : "7 days",
                    monthly: lang.isArabic ? "٣٠ يوم" : "30 days"
                )

                comparisonRow(
                    label: lang.isArabic ? "قوة الظهور" : "Visibility strength",
                    daily: "⭐",
                    weekly: "⭐⭐",
                    monthly: "⭐⭐⭐"
                )

                comparisonRow(
                    label: lang.isArabic ? "الأولوية" : "Priority",
                    daily: lang.isArabic ? "أساسية" : "Basic",
                    weekly: lang.isArabic ? "متوسطة" : "Medium",
                    monthly: lang.isArabic ? "عالية" : "High"
                )
            }
            .font(.footnote)
            .foregroundColor(.secondary)
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemGray6))
            )
        }
        .padding(.top, 8)
    }

    func comparisonRow(label: String, daily: String, weekly: String, monthly: String) -> some View {
        HStack {
            Text(label)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text(daily)
                .frame(maxWidth: .infinity, alignment: .center)
            Text(weekly)
                .frame(maxWidth: .infinity, alignment: .center)
            Text(monthly)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }

    var footerNote: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(lang.isArabic ? "ملاحظة مهمة" : "Important note")
                .font(.footnote.weight(.semibold))

            Text(
                lang.isArabic
                ? "حالياً يتم حفظ طلب الباقة داخل النظام كمرجع. في المرحلة القادمة سيتم ربط هذه الطلبات بالدفع من خلال Apple In-App Purchase وتفعيل الإعلانات تلقائياً."
                : "For now, your plan request is stored in the system as a reference. In the next phase these orders will be connected to Apple In-App Purchase and ads will auto-activate."
            )
            .font(.footnote)
            .foregroundColor(.secondary)
        }
        .padding(.top, 16)
    }
}

// MARK: - Preview

struct SelectAdPlanView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            SelectAdPlanView()
                .environmentObject(LanguageManager())
        }
    }
}
