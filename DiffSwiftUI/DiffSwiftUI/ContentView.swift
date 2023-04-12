//
//  ContentView.swift
//  DiffSwiftUI
//
//  Created by mac on 21/03/2023.
//

import SwiftUI

extension Asset: Equatable {
    static func == (lhs: Asset, rhs: Asset) -> Bool {
        lhs.id == rhs.id // <-- here, whatever is appropriate for you
    }
}

struct AssetsResponse: Codable {
    let data: [Asset]
}

struct Asset: Codable, Identifiable {
    let id: String
    let rank: String
    let symbol: String
    let name: String
    let supply: String
    let maxSupply: String?
    let marketCapUsd: String
    let volumeUsd24Hr: String
    let priceUsd: String
    let changePercent24Hr: String
}


struct ContentView: View {
    @State private var assets = [Asset]()
    @State private var isLoadingMore = false
    @State private var isRefreshing = false
    @State private var currentPage = 1
    
    var body: some View {
        NavigationView {
            List(assets, id: \.id) { asset in
                VStack(alignment: .leading) {
                    Text("\(asset.rank). \(asset.name)")
                        .font(.headline)
                    Text("$\(asset.priceUsd)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                .onAppear {
                    if self.assets.last == asset {
                        self.fetchMoreAssets()
                    }
                }
            }
            .navigationBarTitle("Assets")
            .refreshable(action: {
                self.currentPage = 1
                self.fetchAssets()
                self.isRefreshing = false
            })
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                self.fetchAssets()
            }
            .onAppear {
                UITableView.appearance().tableFooterView = UIView()
            }
            .overlay(
                Group {
                    if isLoadingMore {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle())
                    } else {
                        EmptyView()
                    }
                }
                    .frame(height: isLoadingMore ? 40 : 0)
                    .animation(.easeInOut)
                    .onAppear {
                        self.fetchMoreAssets()
                    }
                , alignment: .bottom
            )
        }
    }
    
    func fetchAssets() {
        let limit = currentPage * 15
        guard let url = URL(string: "https://api.coincap.io/v2/assets?limit=\(limit)") else { return }
        
        isRefreshing = true
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let data = data, error == nil else {
                print("Error fetching asset data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let assetsResponse = try decoder.decode(AssetsResponse.self, from: data)
                DispatchQueue.main.async {
                    self.assets = assetsResponse.data
                    self.isLoadingMore = false
                    self.isRefreshing = false
                    self.currentPage += 1
                }
            } catch {
                print("Error decoding asset data: \(error.localizedDescription)")
            }
        }.resume()
    }
    
    func fetchMoreAssets() {
        if !isLoadingMore {
            isLoadingMore = true
            fetchAssets()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
