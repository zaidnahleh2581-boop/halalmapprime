//
//  QuranFavoritesViewModel.swift
//  HalalMapPrime
//
//  Created by zaid nahleh on 1/27/26.
//
import Foundation
import Combine

final class QuranFavoritesViewModel: ObservableObject {

    @Published var favorites: [QuranFavorite] = []

    init() {
        favorites = FavoritesStore.shared.load()
    }

    func reload() {
        favorites = FavoritesStore.shared.load()
    }

    func remove(_ fav: QuranFavorite) {
        FavoritesStore.shared.remove(fav)
        reload()
    }
}
