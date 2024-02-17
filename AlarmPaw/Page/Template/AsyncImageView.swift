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
    var saveImageData:UIImage?
    @State var toastText:String = ""
    @State var isPressed:Bool = false
    @State var scale:Int = 1
    
    init(url: URL, session: URLSession = .imageSession) {
        self.session = session
        self.urlRequest = URLRequest(url: url)
        
        if let data = session.configuration.urlCache?.cachedResponse(for: urlRequest)?.data,
           let uiImage = UIImage(data: data) {
            _phase = .init(wrappedValue: .success(.init(uiImage: uiImage)))
            self.saveImageData = uiImage
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
                image
                    .resizable()
                    .scaledToFit()
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .scaleEffect(isPressed ? 1.2 : 1.0) // 控制缩放比例
                    .animation(.easeInOut(duration: 0.3), value: isPressed) // 应用动画
                    
                    .onTapGesture(count: 2) {
                        isPressed = true
                        Task{
                            if let image = saveImageData{
                                let imageSaver = ImageSaver()
                                imageSaver.requestAuthorizationAndSaveImage(image: image) { result in
                                    pawManager.shared.dispatch_sync_safely_main_queue {
                                        self.toastText = result.localized
                                        isPressed = false
                                    }
                                }
                            }
                        }
                        
                    }
                   
                    .overlay {
                        VStack{
                            Spacer()
                            HStack{
                                Spacer()
                                Text(NSLocalizedString("doubleClickSave",comment: "双击保存"))
                                    .foregroundStyle(Color.orange)
                                    .padding(.init(top: 0, leading: 0, bottom: 10, trailing: 10))
                                    
                            }
                        }
                    }
                    
                
            case .failure:
                Text(NSLocalizedString("unknown"))
            @unknown default:
                fatalError("This has not been implemented.")
            }
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
            .toast(info: $toastText)
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
