//
//  AsyncImageView.swift
//  AlarmPaw
//
//  Created by He Cho on 2024/1/20.
//

import SwiftUI





struct AsyncImageView: View {
    @State private var phase: AsyncImagePhase
    let urlRequest: URLRequest
    var session: URLSession = .imageSession
    
    init(url: URL, session: URLSession = .imageSession) {
        self.session = session
        self.urlRequest = URLRequest(url: url)
        
        if let data = session.configuration.urlCache?.cachedResponse(for: urlRequest)?.data,
           let uiImage = UIImage(data: data) {
            _phase = .init(wrappedValue: .success(.init(uiImage: uiImage)))
        } else {
            _phase = .init(wrappedValue: .empty)
        }
    }
    
    var body: some View {
        Group {
            switch phase {
                case .empty:
                    ProgressView().scaleEffect(2)
                        .task { await load() }
                case .success(let image):
                    image.resizable().scaledToFit()
                case .failure:
                    Text(NSLocalizedString("unknown"))
                @unknown default:
                    fatalError("This has not been implemented.")
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func load() async {
        do {
            let (data, response) = try await session.data(for: urlRequest)
            guard let response = response as? HTTPURLResponse,
                  200...299 ~= response.statusCode,
                  let uiImage = UIImage(data: data)
            else {
                throw URLError(.unknown)
            }
            
            phase = .success(.init(uiImage: uiImage))
        } catch {
            phase = .failure(error)
        }
    }
}

#Preview {
    AsyncImageView(url: URL(string: "https://day.app/assets/images/avatar.jpg")!)
    
}
