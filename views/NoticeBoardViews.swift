import SwiftUI
import FirebaseFirestore
import Combine

// MARK: - موديل إعلان لوحة المجتمع

struct NoticeAd: Identifiable {
    let id: String
    let title: String
    let body: String
    let city: String
    let contactPhone: String
    let createdAt: Date?

    init?(from doc: DocumentSnapshot) {
        let data = doc.data() ?? [:]

        guard let title = data["title"] as? String else {
            return nil
        }

        self.id = doc.documentID
        self.title = title
        self.body = data["body"] as? String ?? ""
        self.city = data["city"] as? String ?? ""
        self.contactPhone = data["contactPhone"] as? String ?? ""

        if let ts = data["createdAt"] as? Timestamp {
            self.createdAt = ts.dateValue()
        } else {
            self.createdAt = nil
        }
    }
}

// MARK: - ViewModel لوحة المجتمع (Firebase + فلترة ٧ أيام)

final class NoticeBoardViewModel: ObservableObject {

    @Published var notices: [NoticeAd] = []

    private let db = Firestore.firestore()
    private var listener: ListenerRegistration?

    init() {
        DispatchQueue.main.async {
            self.startListening()
        }
    }

    deinit {
        listener?.remove()
    }

    private func startListening() {
        listener = db.collection("noticeBoard")
            .order(by: "createdAt", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }

                if let error = error {
                    print("Error listening for noticeBoard: \(error.localizedDescription)")
                    return
                }

                guard let docs = snapshot?.documents else {
                    DispatchQueue.main.async {
                        self.notices = []
                    }
                    return
                }

                let now = Date()
                let maxAge: TimeInterval = 7 * 24 * 60 * 60

                let items = docs
                    .compactMap { NoticeAd(from: $0) }
                    .filter { ad in
                        guard let created = ad.createdAt else { return true }
                        return now.timeIntervalSince(created) <= maxAge
                    }

                DispatchQueue.main.async {
                    self.notices = items
                }
            }
    }

    func addNotice(title: String, body: String, city: String, phone: String) {
        let data: [String: Any] = [
            "title": title,
            "body": body,
            "city": city,
            "contactPhone": phone,
            "createdAt": FieldValue.serverTimestamp()
        ]
        db.collection("noticeBoard").addDocument(data: data)
    }
}

// MARK: - شاشة إضافة إعلان جديد

struct NoticeComposerView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    @State private var title: String = ""
    @State private var bodyText: String = ""
    @State private var city: String = ""
    @State private var phone: String = ""

    @State private var isSubmitting: Bool = false
    @State private var errorMessage: String?

    private let db = Firestore.firestore()

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    private var isValid: Bool {
        !title.trimmingCharacters(in: .whitespaces).isEmpty &&
        !bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        NavigationStack {
            Form {
                Section(header: Text(L("عنوان الإعلان", "Notice title"))) {
                    TextField(
                        L("مثال: إعلان مفقودات في المسجد", "Example: Lost & found in masjid"),
                        text: $title
                    )
                }

                Section(header: Text(L("نص الإعلان", "Notice text"))) {
                    ZStack(alignment: .topLeading) {
                        TextEditor(text: $bodyText)
                            .frame(minHeight: 120)

                        if bodyText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                            Text(L("اكتب تفاصيل الإعلان هنا…", "Write your notice details here…"))
                                .foregroundColor(.secondary)
                                .padding(.top, 8)
                                .padding(.horizontal, 4)
                                .allowsHitTesting(false)
                        }
                    }
                }

                Section(header: Text(L("المدينة / المنطقة (اختياري)", "City / Area (optional)"))) {
                    TextField(
                        L("مثال: باترسون، نيوجيرسي", "e.g. Paterson, NJ"),
                        text: $city
                    )

                    TextField(
                        L("رقم هاتف للتواصل (اختياري)", "Phone for contact (optional)"),
                        text: $phone
                    )
                    .keyboardType(.phonePad)
                }

                Section {
                    Button {
                        submit()
                    } label: {
                        HStack {
                            if isSubmitting { ProgressView() }
                            Text(L("نشر الإعلان على لوحة المجتمع", "Publish notice"))
                                .frame(maxWidth: .infinity)
                        }
                    }
                    .disabled(!isValid || isSubmitting)
                }

                if let errorMessage {
                    Section {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .font(.footnote)
                    }
                }
            }
            .navigationTitle(L("إعلان لوحة المجتمع", "Community notice"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .imageScale(.medium)
                    }
                }
            }
        }
    }

    private func submit() {
        guard isValid else { return }

        isSubmitting = true
        errorMessage = nil

        let data: [String: Any] = [
            "title": title.trimmingCharacters(in: .whitespaces),
            "body": bodyText.trimmingCharacters(in: .whitespacesAndNewlines),
            "city": city.trimmingCharacters(in: .whitespaces),
            "contactPhone": phone.trimmingCharacters(in: .whitespaces),
            "createdAt": FieldValue.serverTimestamp()
        ]

        db.collection("noticeBoard").addDocument(data: data) { error in
            DispatchQueue.main.async {
                self.isSubmitting = false
                if let error = error {
                    self.errorMessage = error.localizedDescription
                } else {
                    self.dismiss()
                }
            }
        }
    }
}

// MARK: - شاشة لوحة المجتمع

struct NoticeBoardView: View {

    @EnvironmentObject var lang: LanguageManager
    @Environment(\.dismiss) private var dismiss

    @StateObject private var viewModel = NoticeBoardViewModel()

    private func L(_ ar: String, _ en: String) -> String {
        lang.isArabic ? ar : en
    }

    private var dateFormatter: DateFormatter {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .short
        return df
    }

    var body: some View {
        NavigationStack {
            List {
                if viewModel.notices.isEmpty {
                    Text(L("لا توجد إعلانات حالياً.", "No notices yet."))
                        .foregroundColor(.secondary)
                        .padding(.vertical, 8)
                } else {
                    ForEach(viewModel.notices) { ad in
                        VStack(alignment: .leading, spacing: 6) {
                            Text(ad.title)
                                .font(.headline)

                            if !ad.body.isEmpty {
                                Text(ad.body)
                                    .font(.subheadline)
                                    .fixedSize(horizontal: false, vertical: true)
                            }

                            HStack {
                                if !ad.city.isEmpty {
                                    Label(ad.city, systemImage: "mappin.and.ellipse")
                                }
                                Spacer()
                                if let created = ad.createdAt {
                                    Text(dateFormatter.string(from: created))
                                }
                            }
                            .font(.footnote)
                            .foregroundColor(.secondary)

                            if !ad.contactPhone.isEmpty {
                                HStack(spacing: 6) {
                                    Image(systemName: "phone.fill")
                                    Text(ad.contactPhone)
                                }
                                .font(.footnote)
                            }
                        }
                        .padding(.vertical, 4)
                    }
                }
            }
            .navigationTitle(L("لوحة المجتمع", "Community notice board"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .imageScale(.medium)
                    }
                }
            }
        }
    }
}
