//
//  Library.swift
//  AppleMusic-EduProject
//
//  Created by Виктор on 18.03.2021.
//

import SwiftUI
import URLImage

struct Library: View {
    
    @State var tracks = UserDefaults.standard.savedTracks()
    @State private var showingAlert = false
    @State private var track: SearchViewModel.Cell!
    
    weak var tabBarDelegate: MainTabBarControllerDelegate?
    var body: some View {
        NavigationView {
            VStack {
                GeometryReader { geometry in
                    HStack(spacing: 20 ){
                        Button(action: {
                            self.track = self.tracks[0]
                            self.tabBarDelegate?.maximizedTrackDetailController(viewModel: self.track)
                        }
                               , label: {
                                Image(systemName: "play.fill")
                                    .frame(width: geometry.size.width / 2 - 10, height: 50)
                                    .accentColor(Color.init(#colorLiteral(red: 0.9098039216, green: 0.2705882353, blue: 0.3529411765, alpha: 1)))
                                    .background(Color.init(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                                    .cornerRadius(10)
                               })
                        Button(action: {
                            self.tracks = UserDefaults.standard.savedTracks()
                        }
                               , label: {
                                Image(systemName: "arrow.2.circlepath")
                                    .frame(width: geometry.size.width / 2 - 10, height: 50)
                                    .accentColor(Color.init(#colorLiteral(red: 0.9098039216, green: 0.2705882353, blue: 0.3529411765, alpha: 1)))
                                    .background(Color.init(#colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)))
                                    .cornerRadius(10)
                               })
                    }
                }.padding().frame(height: 50)
                Divider().padding(.leading).padding(.trailing).padding(.top)
                List {
                    ForEach(tracks) { track in
                        LibraryCell(cell: track).gesture(LongPressGesture().onEnded({ _tracks in
                            self.track = track
                            self.showingAlert = true
                        })).simultaneousGesture(TapGesture().onEnded({ _ in
                            let keyWindow = UIApplication.shared.connectedScenes
                            .filter({$0.activationState == .foregroundActive})
                            .map({$0 as? UIWindowScene})
                            .compactMap({$0})
                            .first?.windows
                            .filter({$0.isKeyWindow}).first
                            let tabBarVC = keyWindow?.rootViewController as? MainTabBarController
                            tabBarVC?.trackDetailView.delegate = self
                            self.track = track
                            self.tabBarDelegate?.maximizedTrackDetailController(viewModel: self.track)
                        }))
                    }.onDelete(perform: delete)
                }.listStyle(PlainListStyle())
            }
            .actionSheet(isPresented: $showingAlert, content: {
                ActionSheet(title: Text("Are you sure you want to delete this track?"), buttons: [.destructive(Text("Delete"), action: {
                    self.delete(track: self.track)
                }), .cancel()
                ])
            })
            .navigationTitle("Library")
        }
    }
    
    func delete(offsets: IndexSet) {
        tracks.remove(atOffsets: offsets)
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: tracks, requiringSecureCoding: false){
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: UserDefaults.favouriteTrackKey)
        }
    }
    
    func delete(track: SearchViewModel.Cell ) {
        let index = tracks.firstIndex(of: track)
        guard let myIndex = index else { return }
        tracks.remove(at: myIndex)
        if let savedData = try? NSKeyedArchiver.archivedData(withRootObject: tracks, requiringSecureCoding: false){
            let defaults = UserDefaults.standard
            defaults.set(savedData, forKey: UserDefaults.favouriteTrackKey)
        }
    }
}

struct LibraryCell: View {
    
    var cell: SearchViewModel.Cell
    
    var body: some View {
        HStack {
            URLImage(url: URL(string: cell.iconUrlString ?? "")!, content: { image in
                image
                    .resizable()
                    .frame(width: 60, height: 60)
                    .cornerRadius(2)
            })
            VStack(alignment: .leading) {
                Text("\(cell.trackName)")
                Text("\(cell.artistName)")
            }
        }
    }
}

struct Library_Preview: PreviewProvider {
    static var previews: some View {
        Library()
    }
}
extension Library: TrackMovingDelegate {
    func moveBackforPreviousTrack() -> SearchViewModel.Cell? {
        let index = tracks.firstIndex(of: track)
        guard let myIndex = index else { return nil }
        var nextTrack: SearchViewModel.Cell
        if myIndex - 1 == -1 {
            nextTrack = tracks[tracks.count - 1]
        } else {
            nextTrack = tracks[myIndex - 1]
        }
        self.track = nextTrack
        return nextTrack
    }
    
    func moveForwardForPreviousTrack() -> SearchViewModel.Cell? {
        let index = tracks.firstIndex(of: track)
        guard let myIndex = index else { return nil }
        var nextTrack: SearchViewModel.Cell
        if myIndex + 1 == tracks.count {
            nextTrack = tracks[0]
        } else {
            nextTrack = tracks[myIndex + 1]
        }
        self.track = nextTrack
        return nextTrack
    }
    
    
}
