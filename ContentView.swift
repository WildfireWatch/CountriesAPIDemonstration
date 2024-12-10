//
//  ContentView.swift
//  StarWarsGraphQLAPIDemonstration
//
//  Created by Christopher Wright on 12/9/24.
//

import SwiftUI
import Apollo
import StarWarsAPI

class FilmsViewModel: ObservableObject {
    @Published var films: [StarWarsAPI.Query.Data.AllFilms.Film?] = []

    private let apollo = ApolloClient(url: URL(string: "https://swapi-graphql.netlify.app/.netlify/functions/index")!)

    func fetchFilms() {
        apollo.fetch(query: StarWarsAPI.Query()) { [weak self] result in
            switch result {
            case .success(let graphQLResult):
                DispatchQueue.main.async {
                    self?.films = graphQLResult.data?.allFilms?.films ?? []
                }
            case .failure(let error):
                print("Error fetching films: \(error)")
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = FilmsViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.films, id: \.?.title) { film in
                if let film = film {
                    FilmRow(film: film)
                }
            }
            .navigationTitle("Star Wars Films")
            .onAppear {
                viewModel.fetchFilms()
            }
        }
    }
}

struct FilmRow: View {
    let film: StarWarsAPI.Query.Data.AllFilms.Film

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(film.title ?? "Unknown Title")
                .font(.headline)

            if let director = film.director {
                Text("Director: \(director)")
                    .font(.subheadline)
            }

            if let releaseDate = film.releaseDate {
                Text("Released: \(releaseDate)")
                    .font(.subheadline)
            }

            if let species = film.speciesConnection?.species {
                DisclosureGroup("Species") {
                    ForEach(species, id: \.?.name) { specie in
                        if let specie = specie {
                            VStack(alignment: .leading) {
                                Text(specie.name ?? "Unknown Species")
                                    .font(.subheadline)
                                if let classification = specie.classification {
                                    Text("Classification: \(classification)")
                                        .font(.caption)
                                }
                                if let homeworld = specie.homeworld?.name {
                                    Text("Homeworld: \(homeworld)")
                                        .font(.caption)
                                }
                            }
                            .padding(.leading)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

#Preview {
    ContentView()
}
