import SwiftUI
import Foundation

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Text("Hello, world!")
            Button(/*@START_MENU_TOKEN@*/"Button"/*@END_MENU_TOKEN@*/) {
                // Usage
                let accessToken = "your_access_token"
                let collectionID = "your_collection_id"
                
                Task {
                    do {
                        let photos = try await fetchPhotos(accessToken: accessToken, collectionID: collectionID)
                        for photo in photos {
                            print("Photo ID:", photo.id)
                            print("Photo URL:", photo.url)
                            print("GPS Latitude:", photo.gpsLatitude ?? "N/A")
                            print("GPS Longitude:", photo.gpsLongitude ?? "N/A")
                            print()
                        }
                    } catch {
                        print("Error fetching photos:", error)
                    }
                }
            }
        }
    }
}

struct Photo: Codable {
    let id: String
    let url: URL
    let gpsLatitude: String?
    let gpsLongitude: String?
}

func fetchPhotos(accessToken: String, collectionID: String) async throws -> [Photo] {
    let apiBaseURL = "https://image.adobe.io"
    let url = URL(string: "\(apiBaseURL)/v2/catalogs/1/collections/\(collectionID)/assets")!
    
    var request = URLRequest(url: url)
    request.addValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
    
    let (data, _) = try await URLSession.shared.data(for: request)
    
    let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
    guard let assets = (jsonObject as? [String: Any])?["assets"] as? [[String: Any]] else {
        throw NSError(domain: "com.example.app", code: 1, userInfo: [NSLocalizedDescriptionKey: "Error parsing assets"])
    }
    
    var photos: [Photo] = []
    
    for asset in assets {
        if let id = asset["id"] as? String,
           let urlString = asset["url"] as? String,
           let url = URL(string: urlString),
           let metadata = asset["metadata"] as? [String: Any] {
            
            let gpsLatitude = metadata["GPSLatitude"] as? String
            let gpsLongitude = metadata["GPSLongitude"] as? String
            
            if gpsLatitude != nil && gpsLongitude != nil {
                let photo = Photo(id: id, url: url, gpsLatitude: gpsLatitude, gpsLongitude: gpsLongitude)
                photos.append(photo)
            }
        }
    }
    
    return photos
}


