//
//  CoreDataController.swift
//  TMDB
//
//  Created by ANDRII HRYTSAI on 19.06.2023.
//

import Foundation
import CoreData

//MARK: - Protocol delegat
protocol CoreDataControllerDelegate: AnyObject {
    func favoriteMoviesUpdated()
}


// MARK: - Core Data stack
class CoreDataController {
    
    static let shared = CoreDataController()
    private init() {}
    
    weak var delegate: CoreDataControllerDelegate?
    
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
            let results = try? request.execute()
            movies = results.map {$0} ?? []
        }
        return movies
    }
    
    func saveMoviesDB(movies: Result) {
        persistentContainer.performBackgroundTask { context in
            let fetchRequest: NSFetchRequest<MovieCoreDB> = MovieCoreDB.fetchRequest()
            fetchRequest.predicate = NSPredicate(format: "id == %ld", movies.id)
            Task.init {
                do {
                    let existingMovies = try context.fetch(fetchRequest)
                    
                    if existingMovies.isEmpty {
                        let objectDB = MovieCoreDB(context: context)
                        objectDB.id = Int64(movies.id)
                        objectDB.title = movies.nameTitle
                        objectDB.originalTitle = movies.origTitle
                        objectDB.overview = movies.overview
                        objectDB.voteAverage = movies.voteAverage
                        objectDB.backdropPath = movies.backdropPath
                        objectDB.reliseData = movies.airReleaseDate
                        objectDB.mediaType = movies.mediaType?.rawValue
                        try? context.save()
                        self.delegate?.favoriteMoviesUpdated()
                    } else {
                        print("\(movies.id) already exists in the database")
                    }
                }
            }
        }
        
    }
    
    func deleteFromDB(movie: MovieCoreDB) {
        let context = persistentContainer.viewContext
        context.delete(movie as NSManagedObject)
        try? context.save()
        self.delegate?.favoriteMoviesUpdated()
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
