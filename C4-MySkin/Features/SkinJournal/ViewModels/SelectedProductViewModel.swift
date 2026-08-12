//
//  SelectedProductViewModel.swift
//  C4-MySkin
//

import Observation
import Foundation

@MainActor
@Observable
final class SelectedProductViewModel {
    let product: SkincareProduct

    var keyIngredients: [String] = []
    var isLoading: Bool = false

    init(product: SkincareProduct) {
        self.product = product
    }

    /// Fetches the product dossier for real ingredient names.
    /// Falls back to the search highlights when no slug is available or the fetch fails.
    func loadDetails() async {
        guard let slug = product.slug, !slug.isEmpty else {
            keyIngredients = product.highlights
            return
        }

        isLoading = true
        do {
            let dossier = try await SkincareAPIClient().getProductDossier(slug: slug, enrich: false)
            let names = dossier.product.keyIngredients.map(\.name)
            keyIngredients = names.isEmpty ? dossier.product.highlights : names
        } catch {
            keyIngredients = product.highlights
        }
        isLoading = false
    }

    /// Fetches full validation result for product detail inspection.
    func fetchValidationResult() async -> ValidationResult {
        if let slug = product.slug, !slug.isEmpty {
            do {
                let client = SkincareAPIClient()
                let profile = AppDataService.shared.fetchOrCreateProfile()
                let concernIDs = Set(profile.selectedConcernIDs)
                let acnePoreTags: Set<String> = ["Komedo hitam", "Komedo putih", "Jerawat merah", "Jerawat bernanah", "Jerawat dalam"]
                let skinToneTags: Set<String> = ["Bekas jerawat gelap", "Kemerahan", "Flek", "Bercak coklat atau keabu-abuan"]
                let sunDamageTags: Set<String> = ["Flek karena matahari", "Warna tidak merata"]

                let concernAcnePore = concernIDs.intersection(acnePoreTags).isEmpty ? nil : "true"
                let concernSkinTone = concernIDs.intersection(skinToneTags).isEmpty ? nil : "true"
                let concernSunDamage = concernIDs.intersection(sunDamageTags).isEmpty ? nil : "true"

                let dossier = try await client.getProductDossier(
                    slug: slug,
                    enrich: true,
                    skinType: SkinType.apiValue(from: profile.skinTypeRaw),
                    skinSensitivity: SkinSensitivity.apiValue(from: profile.skinSensitivityRaw),
                    concernAcnePore: concernAcnePore,
                    concernSkinTone: concernSkinTone,
                    concernSunDamage: concernSunDamage
                )
                return ValidationResult(dossier: dossier)
            } catch {
                print("Failed to fetch dossier for slug \(slug): \(error)")
            }
        }
        return ValidationResult(product: product)
    }
}
