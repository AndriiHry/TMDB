//
//  CoreDataController.swift
//  TMDB
//
//  Created by ANDRII HRYTSAI on 19.06.2023.
//

import Foundation
import CoreData

// MARK: - Core Data stack
class CoreDataController {
    
    static let shared = CoreDataController()
    private init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "CoreDB")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    func loadMoviesDB() async throws -> [MovieCoreDB] {
        var movies: [MovieCoreDB] = []
        let context = persistentContainer.viewContext
        context.performAndWait {
            let request = NSFetchRequest<MovieCoreDB>(entityName: MovieCoreDB.entity().name!)
//            request.sortDescriptors = [NSSortDescriptor()]
            let results = try? request.execute()
            movies = results.map {$0} ?? []
        }
        return movies
    }
    
    func saveMoviesDB(movies: Result) {
        persistentContainer.performBackgroundTask { context in
            let objectDB = MovieCoreDB(context: context)
            objectDB.id = Int64(movies.id)
            objectDB.title = movies.nameTitle
            objectDB.originalTitle = movies.origTitle
            objectDB.overview = movies.overview
            objectDB.voteAverage = movies.voteAverage
            objectDB.backdropPath = movies.backdropPath
            objectDB.reliseData = movies.airReleaseDate
//            Task.init {
//                do {
//                    let details: DetailsData? =
//                    try await NetworkController().loadDetailsFromId(id: Int(objectDB.id))
//                    objectDB.companiesDetail = details?.productionCompanies.map { $0.name }
//                    objectDB.genresDetail = details?.genres.map { $0.name }
//                    let videoData: [VideData] =
//                    try await NetworkController().loadVideoData(id: Int(objectDB.id))
//                    objectDB.youtubeKey = videoData.map{ $0.key }
//                    objectDB.youtubeType = videoData.map {$0.type }
//                    try? context.save()
//                } catch {
//                    print("Error saving context: \(error)")
//                }
//            }
            try? context.save()
        }
    }
    
    func deleteFromDB(movie: MovieCoreDB) {
        let context = persistentContainer.viewContext
        context.delete(movie as NSManagedObject)
        try? context.save()
    }
    
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {

                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
