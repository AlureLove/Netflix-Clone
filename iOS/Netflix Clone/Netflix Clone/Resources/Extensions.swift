//
//  Extensions.swift
//  Netflix Clone
//
//  Created by Jethro Liu on 2025/11/18.
//

import Foundation
import UIKit

extension String {
    func capitalizeFirstLetter() -> String {
        return self.prefix(1).uppercased() + self.lowercased().dropFirst()
    }
}

extension UIImageView {
    func loadTestImage() {
        guard let url = URL(string: "https://picsum.photos/200") else { return }
        Task {
            if let (data, _) = try? await URLSession.shared.data(from: url),
               let image = UIImage(data: data) {
                self.image = image
            }
        }
    }
}
