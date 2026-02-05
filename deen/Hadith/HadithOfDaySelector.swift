//
//  HadithOfDaySelector.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 1/30/26.
//
import Foundation

enum HadithOfDaySelector {

    static func pickTwo(
        for date: Date,
        from items: [HadithItem]
    ) -> (morning: HadithItem, evening: HadithItem)? {

        guard items.count >= 2 else { return nil }

        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        let morningIndex = (dayOfYear - 1) % items.count
        let eveningIndex = (morningIndex + 1) % items.count

        return (items[morningIndex], items[eveningIndex])
    }
}
