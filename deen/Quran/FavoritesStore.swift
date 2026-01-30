//
//  FavoritesStore.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 1/27/26.
//

import Foundation

final class FavoritesStore {

    static let shared = FavoritesStore()
    private init() {}

    private let key = "quran_favorites"

    func load() -> [QuranFavorite] {
        guard
            let data = UserDefaults.standard.data(forKey: key),
            let decoded = try? JSONDecoder().decode([QuranFavorite].self, from: data)
        else {
            return []
        }
        return decoded
    }

    func save(_ favorites: [QuranFavorite]) {
        let data = try? JSONEncoder().encode(favorites)
        UserDefaults.standard.set(data, forKey: key)
    }

    func add(_ fav: QuranFavorite) {
        var all = load()
        guard !all.contains(fav) else { return }
        all.append(fav)
        save(all)
    }

    func remove(_ fav: QuranFavorite) {
        var all = load()
        all.removeAll { $0 == fav }
        save(all)
    }

    func isFavorite(_ fav: QuranFavorite) -> Bool {
        load().contains(fav)
    }
}
