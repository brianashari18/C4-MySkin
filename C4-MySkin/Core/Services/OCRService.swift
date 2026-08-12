//
//  OCRService.swift
//  C4-MySkin
//
//  Created by Brian Anashari on 10/08/26.
//

import UIKit
@preconcurrency import Vision

/// Service for extracting text from product label photos using Apple's native Vision framework.
struct OCRService {

    /// Performs fast, accurate text recognition on a UIImage using VNRecognizeTextRequest.
    /// Returns joined recognized text string, or nil if no text is detected.
    static func extractText(from image: UIImage) async -> String? {
        guard let cgImage = image.cgImage else { return nil }

        return await withCheckedContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                guard error == nil, let observations = request.results as? [VNRecognizedTextObservation] else {
                    continuation.resume(returning: nil)
                    return
                }

                let recognizedStrings = observations.compactMap { observation in
                    observation.topCandidates(1).first?.string
                }

                let fullText = recognizedStrings.joined(separator: " ").trimmingCharacters(in: .whitespacesAndNewlines)
                continuation.resume(returning: fullText.isEmpty ? nil : fullText)
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true
            request.recognitionLanguages = ["en-US", "id-ID"]

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(returning: nil)
            }
        }
    }
}
