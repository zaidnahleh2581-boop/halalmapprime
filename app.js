// ===== Settings =====
const WHATSAPP_NUMBER = "6319475782"; // <-- حط رقم الواتساب هون (بدون +)

// ===== i18n content =====
const I18N = {
  en: {
    tagline: "Global Halal Infrastructure",
    email: "Email",
    kicker: "Built in New York • Designed for the World",
    heroTitleA: "Not just an app.",
    heroTitleB: "An ecosystem.",
    heroLead:
      "Halal Map Prime is the trust layer on top of the city — halal food, masjids, schools, services, community ads, and ethical visibility — all in one premium experience.",
    ctaPrimary: "Get Listed / Add Your Location",
    ctaSecondary: "See the Vision",
    proof1: "Launch city",
    proof2: "Paid visibility",
    proof3: "Verified halal layer",
    chipA: "Halal • Verified • Premium",
    chipB: "Community • Jobs • Events",
    panelTitle: "The Halal Trust Layer",
    panelLine1: "• Show halal places instantly.",
    panelLine2: "• Verify food sellers via proof (invoice/photo).",
    panelLine3: "• Promote businesses with Prime ads.",
    panelLine4: "• One map. One community. One standard.",
    scroll: "Scroll",
    featuresTitle: "What makes it powerful",
    featuresLead: "Luxury experience + community utility + halal verification where it matters.",
    f1Title: "Halal map that feels premium",
    f1Body: "Fast discovery of masjids, schools, services and halal places around you.",
    f2Title: "Verification where it matters",
    f2Body: "Only food/meat sellers require verification. Masjids, schools & services appear directly.",
    f3Title: "Prime Ads & paid visibility",
    f3Body: "Paid banners and boosted listings for halal businesses that want real growth.",
    f4Title: "Community hub",
    f4Body: "Jobs, hiring, events, notices — a clean system that supports the Muslim community.",
    f5Title: "Built for scale",
    f5Body: "New York first, then NJ, then global cities with the same halal trust standard.",
    f6Title: "Islamic identity, modern execution",
    f6Body: "A world-class product that reflects who we are — strong, clean, and future-ready.",
    visionTitle: "Global vision",
    visionLead: "A halal infrastructure layer across the world’s biggest cities.",
    v1Title: "New York City",
    v1Body: "The strongest launch: diverse, fast, and the world is watching.",
    v2Title: "New Jersey",
    v2Body: "Expand coverage, strengthen trust, and lock in the ecosystem.",
    v3Title: "London • Toronto • Dubai • Istanbul",
    v3Body: "Scale to global hubs with the same premium standard and verification model.",
    quote: "Google shows places. Halal Map Prime shows TRUST.",
    quoteBy: "— Halal Map Prime",
    contactTitle: "Get listed / Contact",
    contactLead: "Business? Masjid? School? Service? Want Prime Ads? Contact us now.",
    contactEmailTitle: "Email",
    contactEmailHint: "Best for detailed requests & documents.",
    contactWaTitle: "WhatsApp",
    contactWaHint: "Fast for verification (invoice/photo) & quick support.",
    contactSocialTitle: "Social",
    contactSocialHint: "Follow us & share the movement.",
    footerSub: "Not just an app. An ecosystem.",
    footerBuilt: "Built in New York",
  },

  ar: {
    tagline: "البنية التحتية العالمية للحلال",
    email: "إيميل",
    kicker: "صُنع في نيويورك • مُصمم للعالم",
    heroTitleA: "مش مجرد تطبيق.",
    heroTitleB: "هذا نظام عالمي.",
    heroLead:
      "Halal Map Prime هو طبقة الثقة فوق المدينة: أماكن حلال، مساجد، مدارس، خدمات، إعلانات مجتمع، وظهور تجاري أخلاقي — بتجربة فخمة واحدة.",
    ctaPrimary: "سجّل مكانك / أضف موقعك",
    ctaSecondary: "شوف الرؤية",
    proof1: "مدينة الإطلاق",
    proof2: "ظهور مدفوع",
    proof3: "طبقة توثيق",
    chipA: "حلال • موثوق • فخم",
    chipB: "مجتمع • وظائف • فعاليات",
    panelTitle: "طبقة الثقة الحلال",
    panelLine1: "• عرض الأماكن مباشرة.",
    panelLine2: "• توثيق بائعي الطعام عبر إثبات (فاتورة/صورة).",
    panelLine3: "• ترويج تجاري عبر Prime Ads.",
    panelLine4: "• خريطة واحدة. مجتمع واحد. معيار واحد.",
    scroll: "انزل",
    featuresTitle: "ليش هذا قوي؟",
    featuresLead: "فخامة + خدمة مجتمع + توثيق فقط حيث يلزم.",
    f1Title: "خريطة حلال بتجربة فخمة",
    f1Body: "اكتشف المساجد والمدارس والخدمات والأماكن الحلال حولك بسرعة.",
    f2Title: "توثيق ذكي حسب النوع",
    f2Body: "فقط الطعام/اللحوم يحتاج توثيق. المساجد والمدارس والخدمات تظهر مباشرة.",
    f3Title: "Prime Ads وظهور مدفوع",
    f3Body: "بنرات مدفوعة ورفع ظهور للنشاطات الحلال اللي بدها نمو فعلي.",
    f4Title: "مركز مجتمع قوي",
    f4Body: "وظائف، توظيف، فعاليات، تنبيهات — بنظام نظيف يخدم المجتمع.",
    f5Title: "مبني للتوسع",
    f5Body: "نيويورك أولاً، ثم نيوجيرسي، ثم مدن العالم بنفس معيار الثقة.",
    f6Title: "هوية إسلامية بتنفيذ عصري",
    f6Body: "منتج عالمي يعكس قوتنا: نظيف، فخم، وجاهز للمستقبل.",
    visionTitle: "الرؤية العالمية",
    visionLead: "طبقة حلال عالمية فوق أكبر مدن العالم.",
    v1Title: "نيويورك",
    v1Body: "أفضل بداية: تنوع، سرعة، والعالم يراقب.",
    v2Title: "نيوجيرسي",
    v2Body: "توسعة تغطية وتعزيز الثقة وتثبيت النظام.",
    v3Title: "لندن • تورونتو • دبي • إسطنبول",
    v3Body: "توسع لمدن عالمية بنفس الجودة ونفس نموذج التوثيق.",
    quote: "Google يعرض المكان… Halal Map Prime يعرض الثقة.",
    quoteBy: "— Halal Map Prime",
    contactTitle: "سجّل مكانك / تواصل",
    contactLead: "مطعم؟ مسجد؟ مدرسة؟ خدمة؟ بدك Prime Ads؟ تواصل الآن.",
    contactEmailTitle: "الإيميل",
    contactEmailHint: "أفضل للتفاصيل والوثائق.",
    contactWaTitle: "واتساب",
    contactWaHint: "أسرع للتوثيق (فاتورة/صورة) والدعم السريع.",
    contactSocialTitle: "السوشال",
    contactSocialHint: "تابعنا وشارك الحركة.",
    footerSub: "مش مجرد تطبيق. هذا نظام عالمي.",
    footerBuilt: "صُنع في نيويورك",
  },

  fa: {
    tagline: "زیرساخت جهانی حلال",
    email: "ایمیل",
    kicker: "ساخته‌شده در نیویورک • برای جهان",
    heroTitleA: "فقط یک اپ نیست.",
    heroTitleB: "یک اکوسیستم است.",
    heroLead:
      "Halal Map Prime لایهٔ اعتماد حلال روی شهر است: غذای حلال، مسجد، مدرسه، خدمات، آگهی‌های جامعه و دیده‌شدن اخلاقی — همه در یک تجربهٔ لوکس.",
    ctaPrimary: "ثبت مکان / افزودن لوکیشن",
    ctaSecondary: "دیدن چشم‌انداز",
    proof1: "شهر آغاز",
    proof2: "دیده‌شدن پولی",
    proof3: "لایهٔ تأیید",
    chipA: "حلال • تأیید • لوکس",
    chipB: "جامعه • کار • رویداد",
    panelTitle: "لایهٔ اعتماد حلال",
    panelLine1: "• نمایش فوری مکان‌ها.",
    panelLine2: "• تأیید فروشندگان غذا با مدرک (فاکتور/عکس).",
    panelLine3: "• تبلیغات Prime برای رشد واقعی.",
    panelLine4: "• یک نقشه. یک جامعه. یک استاندارد.",
    scroll: "اسکرول",
    featuresTitle: "چه چیزی آن را قدرتمند می‌کند",
    featuresLead: "تجربهٔ لوکس + کاربرد اجتماعی + تأیید فقط جایی که لازم است.",
    f1Title: "نقشهٔ حلالِ لوکس",
    f1Body: "مسجد، مدرسه، خدمات و مکان‌های حلال اطراف را سریع پیدا کن.",
    f2Title: "تأیید فقط برای غذا/گوشت",
    f2Body: "مسجدها، مدارس و خدمات مستقیم نمایش داده می‌شوند.",
    f3Title: "Prime Ads و دیده‌شدن پولی",
    f3Body: "بنرهای پولی و لیست‌های تقویت‌شده برای کسب‌وکارهای حلال.",
    f4Title: "مرکز جامعه",
    f4Body: "کار، استخدام، رویدادها و اعلان‌ها با سیستم تمیز.",
    f5Title: "ساخته‌شده برای رشد",
    f5Body: "اول نیویورک، بعد نیوجرسی و سپس شهرهای جهانی.",
    f6Title: "هویت اسلامی، اجرای مدرن",
    f6Body: "محصولی در سطح جهانی: تمیز، قدرتمند، آینده‌محور.",
    visionTitle: "چشم‌انداز جهانی",
    visionLead: "لایهٔ حلال در بزرگ‌ترین شهرهای جهان.",
    v1Title: "نیویورک",
    v1Body: "بهترین شروع: سریع، متنوع و جهانی.",
    v2Title: "نیوجرسی",
    v2Body: "گسترش پوشش و تقویت اعتماد.",
    v3Title: "لندن • تورنتو • دبی • استانبول",
    v3Body: "گسترش به مراکز جهانی با همان استاندارد.",
    quote: "Google مکان را نشان می‌دهد. Halal Map Prime اعتماد را نشان می‌دهد.",
    quoteBy: "— Halal Map Prime",
    contactTitle: "ثبت / تماس",
    contactLead: "کسب‌وکار؟ مسجد؟ مدرسه؟ خدمات؟ Prime Ads؟ همین حالا تماس بگیر.",
    contactEmailTitle: "ایمیل",
    contactEmailHint: "برای درخواست‌های کامل و مدارک.",
    contactWaTitle: "واتساپ",
    contactWaHint: "برای تأیید (فاکتور/عکس) و پشتیبانی سریع.",
    contactSocialTitle: "شبکه‌های اجتماعی",
    contactSocialHint: "دنبال کنید و به اشتراک بگذارید.",
    footerSub: "فقط یک اپ نیست. یک اکوسیستم است.",
    footerBuilt: "ساخته‌شده در نیویورک",
  },

  tr: {
    tagline: "Küresel Helal Altyapısı",
    email: "E-posta",
    kicker: "New York’ta üretildi • Dünya için tasarlandı",
    heroTitleA: "Sadece bir uygulama değil.",
    heroTitleB: "Bir ekosistem.",
    heroLead:
      "Halal Map Prime şehrin üstünde bir güven katmanı: helal yemek, camiler, okullar, hizmetler, topluluk ilanları ve etik görünürlük — hepsi premium bir deneyimde.",
    ctaPrimary: "Listele / Konum Ekle",
    ctaSecondary: "Vizyonu Gör",
    proof1: "Başlangıç şehri",
    proof2: "Ücretli görünürlük",
    proof3: "Doğrulama katmanı",
    chipA: "Helal • Doğrulanmış • Premium",
    chipB: "Topluluk • İş • Etkinlik",
    panelTitle: "Helal Güven Katmanı",
    panelLine1: "• Mekanları anında göster.",
    panelLine2: "• Yemek satıcılarını kanıtla doğrula (fatura/foto).",
    panelLine3: "• Prime Ads ile büyüme.",
    panelLine4: "• Tek harita. Tek topluluk. Tek standart.",
    scroll: "Kaydır",
    featuresTitle: "Neden güçlü?",
    featuresLead: "Premium deneyim + topluluk faydası + gerekli yerde doğrulama.",
    f1Title: "Premium helal harita",
    f1Body: "Yakındaki cami, okul, hizmet ve helal mekanları hızlıca bul.",
    f2Title: "Doğrulama sadece yemek/et için",
    f2Body: "Cami, okul ve hizmetler direkt görünür.",
    f3Title: "Prime Ads & ücretli görünürlük",
    f3Body: "Helal işletmeler için banner ve güçlendirilmiş listeleme.",
    f4Title: "Topluluk merkezi",
    f4Body: "İş ilanları, etkinlikler, duyurular — temiz bir sistem.",
    f5Title: "Ölçeklenebilir",
    f5Body: "Önce NYC, sonra NJ, sonra global şehirler.",
    f6Title: "İslami kimlik, modern uygulama",
    f6Body: "Dünya standartlarında ürün: temiz, güçlü, geleceğe hazır.",
    visionTitle: "Küresel vizyon",
    visionLead: "Dünyanın en büyük şehirlerinde helal güven katmanı.",
    v1Title: "New York City",
    v1Body: "En güçlü başlangıç: hızlı ve global.",
    v2Title: "New Jersey",
    v2Body: "Kapsamı büyüt, güveni güçlendir.",
    v3Title: "Londra • Toronto • Dubai • İstanbul",
    v3Body: "Aynı standartla dünya merkezlerine yayıl.",
    quote: "Google mekanları gösterir. Halal Map Prime GÜVENİ gösterir.",
    quoteBy: "— Halal Map Prime",
    contactTitle: "Listele / İletişim",
    contactLead: "İşletme? Cami? Okul? Hizmet? Prime Ads? Hemen iletişim.",
    contactEmailTitle: "E-posta",
    contactEmailHint: "Detaylı talepler ve belgeler için.",
    contactWaTitle: "WhatsApp",
    contactWaHint: "Doğrulama (fatura/foto) ve hızlı destek.",
    contactSocialTitle: "Sosyal",
    contactSocialHint: "Takip edin ve paylaşın.",
    footerSub: "Sadece bir uygulama değil. Bir ekosistem.",
    footerBuilt: "New York’ta üretildi",
  },

  ur: {
    tagline: "عالمی حلال انفراسٹرکچر",
    email: "ای میل",
    kicker: "نیویارک میں بنا • دنیا کے لیے",
    heroTitleA: "یہ صرف ایپ نہیں۔",
    heroTitleB: "یہ ایک ایکوسسٹم ہے۔",
    heroLead:
      "Halal Map Prime شہر کے اوپر حلال اعتماد کی تہہ ہے: حلال کھانا، مساجد، اسکولز، سروسز، کمیونٹی اشتہارات اور اخلاقی نظر آنا — سب ایک پریمیم تجربے میں۔",
    ctaPrimary: "اپنا مقام شامل کریں",
    ctaSecondary: "ویژن دیکھیں",
    proof1: "لانچ سٹی",
    proof2: "Paid visibility",
    proof3: "Verification layer",
    chipA: "حلال • تصدیق • پریمیم",
    chipB: "کمیونٹی • نوکریاں • ایونٹس",
    panelTitle: "حلال ٹرسٹ لیئر",
    panelLine1: "• جگہیں فوراً دکھائیں۔",
    panelLine2: "• فوڈ سیلرز کی تصدیق (بل/فوٹو) سے۔",
    panelLine3: "• Prime Ads سے بزنس گروتھ۔",
    panelLine4: "• ایک نقشہ۔ ایک کمیونٹی۔ ایک معیار۔",
    scroll: "نیچے",
    featuresTitle: "یہ پاورفل کیوں ہے",
    featuresLead: "پریمیم تجربہ + کمیونٹی فائدہ + جہاں ضروری ہو تصدیق۔",
    f1Title: "پریمیم حلال میپ",
    f1Body: "قریب کی مساجد، اسکولز، سروسز اور حلال مقامات تیزی سے تلاش کریں۔",
    f2Title: "تصدیق صرف کھانے/گوشت والوں کیلئے",
    f2Body: "مساجد، اسکولز اور سروسز فوراً دکھتے ہیں۔",
    f3Title: "Prime Ads اور Paid visibility",
    f3Body: "بینرز اور بوسٹڈ لسٹنگز حلال بزنس کیلئے۔",
    f4Title: "کمیونٹی ہب",
    f4Body: "نوکریاں، ہائرنگ، ایونٹس، نوٹس — صاف سسٹم۔",
    f5Title: "اسکیل کیلئے تیار",
    f5Body: "پہلے NYC، پھر NJ، پھر عالمی شہر۔",
    f6Title: "اسلامی شناخت، جدید ایگزیکیوشن",
    f6Body: "ورلڈ کلاس پراڈکٹ: صاف، مضبوط، مستقبل کیلئے تیار۔",
    visionTitle: "عالمی ویژن",
    visionLead: "دنیا کے بڑے شہروں پر حلال اعتماد کی تہہ۔",
    v1Title: "New York City",
    v1Body: "سب سے مضبوط آغاز: تیز اور گلوبل۔",
    v2Title: "New Jersey",
    v2Body: "کوریج بڑھے، اعتماد مضبوط ہو۔",
    v3Title: "London • Toronto • Dubai • Istanbul",
    v3Body: "اسی معیار کے ساتھ عالمی ہبز میں توسیع۔",
    quote: "Google جگہ دکھاتا ہے۔ Halal Map Prime اعتماد دکھاتا ہے۔",
    quoteBy: "— Halal Map Prime",
    contactTitle: "شامل کریں / رابطہ",
    contactLead: "بزنس؟ مسجد؟ اسکول؟ سروس؟ Prime Ads؟ ابھی رابطہ کریں۔",
    contactEmailTitle: "ای میل",
    contactEmailHint: "تفصیل اور ڈاکیومنٹس کیلئے۔",
    contactWaTitle: "WhatsApp",
    contactWaHint: "تصدیق (بل/فوٹو) اور فوری سپورٹ کیلئے۔",
    contactSocialTitle: "سوشل",
    contactSocialHint: "فالو کریں اور شیئر کریں۔",
    footerSub: "یہ صرف ایپ نہیں۔ یہ ایک ایکوسسٹم ہے۔",
    footerBuilt: "نیویارک میں بنا",
  },
};

// ===== Language switch =====
function setLang(lang){
  const dict = I18N[lang] || I18N.en;

  // Set direction
  const rtl = (lang === "ar" || lang === "fa" || lang === "ur");
  document.documentElement.lang = lang;
  document.documentElement.dir = rtl ? "rtl" : "ltr";
  document.body.setAttribute("dir", rtl ? "rtl" : "ltr");

  // Update texts
  document.querySelectorAll("[data-i18n]").forEach(el=>{
    const key = el.getAttribute("data-i18n");
    if (dict[key]) el.textContent = dict[key];
  });

  // Active button
  document.querySelectorAll(".lang-btn").forEach(b=>{
    b.classList.toggle("is-active", b.dataset.lang === lang);
  });

  // Save
  localStorage.setItem("hmp_lang", lang);
}

document.querySelectorAll(".lang-btn").forEach(btn=>{
  btn.addEventListener("click", ()=> setLang(btn.dataset.lang));
});

// WhatsApp Button
const waBtn = document.getElementById("waBtn");
if (waBtn) {
  waBtn.addEventListener("click", ()=>{
    const msg =
      "Hi Halal Map Prime, I want to add my location / request Prime Ads / verification. " +
      "Name: ____  City: ____  Category: ____";
    const encoded = encodeURIComponent(msg);
    const url = `https://wa.me/${WHATSAPP_NUMBER}?text=${encoded}`;
    window.open(url, "_blank");
  });
}

// Footer year
document.getElementById("year").textContent = new Date().getFullYear();

// Init
const saved = localStorage.getItem("hmp_lang") || "en";
setLang(saved);
