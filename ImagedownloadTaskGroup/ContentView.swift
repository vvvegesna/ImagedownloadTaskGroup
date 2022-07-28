//
//  ContentView.swift
//  ImagedownloadTaskGroup
//
//  Created by Vegesna, Vijay Varma on 7/23/22.
//

import SwiftUI

class ImageDownloadManager {
    
    struct Constants {
        static let url1 = URL(string: "https://picsum.photos/300")!
        static let url2 = URL(string: "https://picsum.photos/300")!
        static let url3 = URL(string: "https://picsum.photos/300")!
        static let url4 = URL(string: "https://picsum.photos/300")!
        static let url5 = URL(string: "https://picsum.photos/300")!
    }
    
    func fetchImage(from url: URL) async throws -> UIImage {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let uiImage = UIImage(data: data) {
                return uiImage
            } else {
                throw URLError(.badURL)
            }
        } catch {
            throw error
        }
    }
    
}

class ImageDownloadViewModel: ObservableObject {
    @Published var images: [UIImage] = []
    let imageDownloadManager = ImageDownloadManager()
    
    typealias URLs = ImageDownloadManager.Constants
    
    func downloadImagesSynchronously() async {
        let urlArray = [URLs.url1, URLs.url2, URLs.url3, URLs.url4, URLs.url5]
        
        for url in urlArray {
            if let syncedImage = try? await imageDownloadManager.fetchImage(from: url) {
                images.append(syncedImage)
            }
        }
    }
    
    func downloadImagesConcurrently() async {
        
        //        async let fetchImage1 = imageDownloadManager.fetchImage(from: URLs.url1)
        //        async let fetchImage2 = imageDownloadManager.fetchImage(from: URLs.url2)
        //        async let fetchImage3 = imageDownloadManager.fetchImage(from: URLs.url3)
        //        async let fetchImage4 = imageDownloadManager.fetchImage(from: URLs.url4)
        //        async let fetchImage5 = imageDownloadManager.fetchImage(from: URLs.url5)
        //
        //        let (image1, image2, image3, image4, image5) = await (try? fetchImage1, try? fetchImage2, try? fetchImage3, try? fetchImage4, try? fetchImage5)
        
        await withTaskGroup(of: UIImage.self) { group in
            
            group.addTask {
                try! await self.imageDownloadManager.fetchImage(from: URLs.url1)
            }
            group.addTask {
                try! await self.imageDownloadManager.fetchImage(from: URLs.url2)
            }
            group.addTask {
                try! await self.imageDownloadManager.fetchImage(from: URLs.url3)
            }
            group.addTask {
                try! await self.imageDownloadManager.fetchImage(from: URLs.url4)
            }
            group.addTask {
                try! await self.imageDownloadManager.fetchImage(from: URLs.url5)
            }
            
            for await newImage in group {
                images.append(newImage)
            }
        }
    }
    
    func downloadConcurretnlyWithError() async throws {
        let ids = [URLs.url1, URLs.url2, URLs.url3, URL(string: "https://picum.photos/600")!, URLs.url5]
        
        // Following API can return partial results
        
        try await withThrowingTaskGroup(of: UIImage?.self, body: { group in
            
            for id in ids {
                group.addTask {
                    try? await self.imageDownloadManager.fetchImage(from: id)
                }
            }
            
            for try await newImage in group {
                if let image = newImage {
                    await MainActor.run(body: {
                        images.append(image)
                    })
                }
            }
        })
    }
    
}

struct ContentView: View {
    @StateObject var viewModel = ImageDownloadViewModel()
    let coulmns = [GridItem(.flexible()), GridItem(.flexible())]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: coulmns) {
                    ForEach(viewModel.images, id: \.self) { image in
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 150)
                    }
                }
            }
            .navigationTitle("Load my Images!")
            .task {
                //await viewModel.downloadImagesSynchronously()
                //await viewModel.downloadImagesConcurrently()
                try? await viewModel.downloadConcurretnlyWithError()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
