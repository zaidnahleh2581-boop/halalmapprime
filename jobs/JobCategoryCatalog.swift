//
//  JobCategoryCatalog.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 2/5/26.
//

import Foundation

enum JobCategoryCatalog {

    // ✅ قائمة كبيرة كبداية (بتقدر تزيدها لاحقًا أو تنقلها لـ JSON)
    static func all(isArabic: Bool) -> [String] {

        if isArabic {
            return [
                // Food & Hospitality
                "مطعم - شيف", "مطعم - مساعد شيف", "مطعم - نادل", "مطعم - كاشير", "مطعم - غسيل صحون",
                "مخبز - خباز", "مخبز - مساعد خباز", "قهوة - باريستا", "قهوة - مساعد",
                "فود ترك - طباخ", "فود ترك - كاشير",
                "ملحمة - جزار", "ملحمة - مساعد جزار",
                "سوبرماركت - كاشير", "سوبرماركت - ترتيب رفوف", "مخزن - مستودع",

                // Education
                "مدرس - عربي", "مدرس - إنجليزي", "مدرس - رياضيات", "مدرس - علوم", "مدرس - تاريخ",
                "مساعد معلم", "مشرف مدرسة", "إدارة مدرسة",

                // Medical
                "عيادة - طبيب", "عيادة - ممرض/ممرضة", "عيادة - استقبال", "عيادة - مساعد طبيب",
                "صيدلية - صيدلي", "صيدلية - مساعد صيدلي",

                // Trades
                "نجار", "حداد", "كهربائي", "سباك", "دهان", "جبس", "بلاط", "مقاول",
                "HVAC - فني تبريد وتكييف", "فني صيانة عامة",

                // Office & Services
                "محامي", "مساعد محامي", "مكتب عقارات", "سمسار", "محاسب", "سكرتير/سكرتيرة",
                "خدمة عملاء", "مركز اتصالات",
                "مترجم", "مصمم جرافيك", "مصور",

                // Beauty
                "صالون - حلاق", "صالون - كوافيرة", "صالون - أظافر", "صالون - استقبال",

                // Driving & Delivery
                "سائق توصيل", "سائق شاحنة", "سائق تاكسي", "مندوب توصيل طعام",

                // Security & Cleaning
                "حارس أمن", "تنظيف منازل", "تنظيف مكاتب", "تنظيف مطاعم",

                // Retail
                "محل ملابس - بائع", "محل مجوهرات - بائع", "محل هواتف - بائع", "محل إلكترونيات - بائع",

                // Construction helper roles
                "عامل بناء", "عامل تحميل وتنزيل", "عامل يومي",

                // Other
                "أخرى (حدد بنفسك)"
            ]
        } else {
            return [
                // Food & Hospitality
                "Restaurant - Chef", "Restaurant - Assistant Chef", "Restaurant - Waiter", "Restaurant - Cashier", "Restaurant - Dishwasher",
                "Bakery - Baker", "Bakery - Assistant Baker", "Coffee - Barista", "Coffee - Assistant",
                "Food Truck - Cook", "Food Truck - Cashier",
                "Butcher - Butcher", "Butcher - Assistant",
                "Supermarket - Cashier", "Supermarket - Stocking", "Warehouse",

                // Education
                "Teacher - Arabic", "Teacher - English", "Teacher - Math", "Teacher - Science", "Teacher - History",
                "Teacher Assistant", "School Supervisor", "School Administration",

                // Medical
                "Clinic - Doctor", "Clinic - Nurse", "Clinic - Receptionist", "Clinic - Assistant",
                "Pharmacy - Pharmacist", "Pharmacy - Assistant",

                // Trades
                "Carpenter", "Welder", "Electrician", "Plumber", "Painter", "Drywall", "Tile Installer", "Contractor",
                "HVAC Technician", "General Maintenance",

                // Office & Services
                "Lawyer", "Legal Assistant", "Real Estate Office", "Agent", "Accountant", "Secretary",
                "Customer Service", "Call Center",
                "Translator", "Graphic Designer", "Photographer",

                // Beauty
                "Barber", "Hair Stylist", "Nails", "Salon Receptionist",

                // Driving & Delivery
                "Delivery Driver", "Truck Driver", "Taxi Driver", "Food Delivery",

                // Security & Cleaning
                "Security Guard", "House Cleaning", "Office Cleaning", "Restaurant Cleaning",

                // Retail
                "Clothing Store - Sales", "Jewelry Store - Sales", "Phone Shop - Sales", "Electronics - Sales",

                // Construction helper roles
                "Construction Worker", "Loader/Unloader", "Day Labor",

                // Other
                "Other (type it)"
            ]
        }
    }
}
