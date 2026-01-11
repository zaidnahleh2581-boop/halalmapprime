//
//  RamadanImsakiyahDay.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 1/10/26.
//

import Foundation

struct RamadanImsakiyahDay: Identifiable, Equatable {
    let id: String

    let hijriDateAr: String
    let hijriDateEn: String
    let gregorianDate: String

    let imsak: String
    let fajr: String
    let maghrib: String
}
