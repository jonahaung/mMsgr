//
//  CoreDataStack.swift
//  Ambar
//
//  Copyright © 2016 Radiant Tap
//  MIT License · http://choosealicense.com/licenses/mit/
//

import Foundation
import CoreData

public final class CoreDataStack {
    
    public typealias Callback = () -> Void
    public private(set) var isReady: Bool = false
    public private(set) var dataModel: NSManagedObjectModel!
    public private(set) var storeURL: URL?
   
    public private(set) var isUsingSeparatePersistentStoreCoordinators: Bool

    public init(storeType: String = NSSQLiteStoreType, withDataModelNamed dataModel: String? = nil, storeURL: URL? = nil, usingSeparatePSCs: Bool = true, callback: @escaping Callback = {}) {
       
        self.isUsingSeparatePersistentStoreCoordinators = usingSeparatePSCs

        setup(withDataModelNamed: dataModel, storeURL: storeURL, callback: callback)
    }

    public private(set) var mainCoordinator: NSPersistentStoreCoordinator!
    public private(set) var writerCoordinator: NSPersistentStoreCoordinator!
    public private(set) var mainContext: NSManagedObjectContext!
  
    public lazy var viewContext: NSManagedObjectContext = {
        $0.parent = mainContext
        $0.undoManager = nil
        $0.shouldDeleteInaccessibleFaults = true
        $0.mergePolicy = NSMergeByPropertyStoreTrumpMergePolicy
        return $0
    }(NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType))
    
    public var isMainContextReadOnly: Bool = false {
        didSet {
            if !isReady { return }
            if isMainContextReadOnly == oldValue { return }
            mainContext.mergePolicy = (isMainContextReadOnly) ? NSRollbackMergePolicy : NSMergeByPropertyStoreTrumpMergePolicy
        }
    }

    public var shouldMergeIncomingSavedObjects: Bool = false

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    private var callback: Callback?
    private var setupFlags: SetupFlags = .none
}

private struct SetupFlags: OptionSet {
    public let rawValue: Int
    public init(rawValue:Int) {
        self.rawValue = rawValue
    }

    static let none = SetupFlags(rawValue: 0)
    static let base = SetupFlags(rawValue: 1)
    static let mainPSC = SetupFlags(rawValue: 2)
    static let writePSC = SetupFlags(rawValue: 4)
    static let mainMOC = SetupFlags(rawValue: 8)

    static let done : SetupFlags = [.base, .mainPSC, .writePSC, .mainMOC]
}


public extension CoreDataStack {
    

    func importerContext() -> NSManagedObjectContext {
        let x = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        x.persistentStoreCoordinator = writerCoordinator
        x.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return x
    }

    
    func temporaryContext() -> NSManagedObjectContext {
        let x = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        x.persistentStoreCoordinator = mainCoordinator
        x.mergePolicy = NSRollbackMergePolicy
        return x
    }

    func editorContext() -> NSManagedObjectContext {
        if isMainContextReadOnly {
            let log = String(format: "E | %@:%@/%@ Can't create editorContext when isMainContextReadOnly=true.\nHint: you can set it temporary to false, make the changes, save them using save(callback:) and revert to true inside the callback block.",
                             String(describing: self), #file, #line)
            fatalError(log)
        }

        let x = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        x.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        x.parent = viewContext
        x.undoManager = nil
        x.shouldDeleteInaccessibleFaults = true
        x.propagatesDeletesAtEndOfEvent = true
        return x
    }
}


//MARK:- Setup
private extension CoreDataStack {
    
    static var defaultStoreFolderURL: URL {
        let searchPathOption: FileManager.SearchPathDirectory = .applicationSupportDirectory
        guard let url = FileManager.default.urls(for: searchPathOption, in: .userDomainMask).first else {
            let log = String(format: "E | %@:%@/%@ Could not fetch Application Support directory",
                             String(describing: self), #file, #line)
            fatalError(log)
        }
        return url
    }
    private static var cleanAppName: String {
        guard let appName = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as? String else {
            let log = String(format: "E | %@:%@/%@ Unable to fetch CFBundleName from main bundle",
                             String(describing: self), #file, #line)
            fatalError(log)
        }
        return appName.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
    }

    static var defaultStoreFileName: String {
        return "\(cleanAppName ).sqlite"
    }

    static var defaultStoreURL: URL {
        return defaultStoreFolderURL.appendingPathComponent(defaultStoreFileName)
    }

    func setupDone(flags: SetupFlags) {
        setupFlags.insert(flags)

        if setupFlags != .done { return }

        isReady = true
        if let callback = callback {
            callback()
            self.callback = nil
        }
    }

    func setup(withDataModelNamed dataModelName: String? = nil, storeURL: URL? = nil, callback: @escaping Callback = {}) {
        
        self.callback = callback

        let url: URL
        if let storeURL = storeURL {
            CoreDataStack.verify(storeURL: storeURL)
            url = storeURL
        } else {
            url = CoreDataStack.defaultStoreURL
            CoreDataStack.verify(storeURL: url)
        }
        self.storeURL = url

        let mom = managedObjectModel(named: dataModelName)
        self.dataModel = mom

        setupPersistentStoreCoordinators(using: mom)

        setupNotifications()

        setupDone(flags: .base)
    }

    func setupPersistentStoreCoordinators(using mom: NSManagedObjectModel) {
        self.mainCoordinator = {
            let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
            connectStores(toCoordinator: psc, andExecute: { [unowned self] in
                DispatchQueue.main.async { [unowned self] in
                    self.setupMainContext()
                }
                self.setupDone(flags: .mainPSC)
            })
            return psc
        }()

        if isUsingSeparatePersistentStoreCoordinators {
            self.writerCoordinator = {
                let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
                connectStores(toCoordinator: psc) { [unowned self] in
                    self.setupDone(flags: .writePSC)
                }
                return psc
            }()

        } else {
            self.writerCoordinator = self.mainCoordinator
            self.setupDone(flags: .writePSC)
        }

    }

  
    func connectStores(toCoordinator psc: NSPersistentStoreCoordinator, andExecute postConnect: (()-> Void)? = nil) {
        psc.addPersistentStore(with: storeDescription, completionHandler: { [unowned self] (sd, error) in
            if let error = error {
                let log = String(format: "E | %@:%@/%@ Error adding persistent stores to coordinator %@:\n%@",
                                 String(describing: self), #file, #line, String(describing: psc), error.localizedDescription)
                fatalError(log)
            }
            if let postConnect = postConnect {
                postConnect()
            }
        })
    }

    func setupMainContext() {
        mainContext = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        mainContext.persistentStoreCoordinator = mainCoordinator
        mainContext.mergePolicy = (isMainContextReadOnly) ? NSRollbackMergePolicy : NSMergeByPropertyStoreTrumpMergePolicy
//        mainContext.undoManager = nil
//        mainContext.shouldDeleteInaccessibleFaults = true
//        mainContext.propagatesDeletesAtEndOfEvent = true
        setupDone(flags: .mainMOC)
    }

    var storeDescription: NSPersistentStoreDescription {
        guard let storeURL = storeURL else { fatalError("E | StoreURL missing. It's required when using SQLiteStoreType.")}
        let sd = NSPersistentStoreDescription(url: storeURL)
        //    use options that allow automatic model migrations
        sd.setOption(true as NSObject?, forKey: NSMigratePersistentStoresAutomaticallyOption)
        sd.shouldInferMappingModelAutomatically = true
        return sd
    }


    static func verify(storeURL url: URL) {
        let directoryURL = url.deletingLastPathComponent()

        var isFolder: ObjCBool = true
        let isExists = FileManager.default.fileExists(atPath: directoryURL.path, isDirectory: &isFolder)
        if isExists && isFolder.boolValue {
            return
        }

        do {
            try FileManager.default.createDirectory(at: directoryURL, withIntermediateDirectories: true, attributes: nil)
        } catch let error {
            let log = String(format: "E | %@:%@/%@ Error verifying (creating) full URL path %@:\n%@",
                             String(describing: self), #file, #line, directoryURL.path, error.localizedDescription)
            fatalError(log)
        }
    }

    
    func managedObjectModel(named name: String? = nil) -> NSManagedObjectModel {
        if name == nil {
            guard let mom = NSManagedObjectModel.mergedModel(from: nil) else {
                let log = String(format: "E | %@:%@/%@ Unable to create ManagedObjectModel by merging all models in the main bundle",
                                 String(describing: self), #file, #line)
                fatalError(log)
            }
            return mom
        }

        guard
            let url = Bundle.main.url(forResource: name, withExtension: "momd"),
            let mom = NSManagedObjectModel(contentsOf: url)
            else {
                let log = String(format: "E | %@:%@/%@ Unable to create ManagedObjectModel using name %@",
                                 String(describing: self), #file, #line, name!)
                fatalError(log)
        }

        return mom
    }

}



//    MARK: Migration

public extension CoreDataStack {
    convenience init(withDataModelNamed dataModel: String? = nil, migratingFrom oldStoreURL: URL? = nil, to storeURL: URL, usingSeparatePSCs: Bool = true,  callback: @escaping Callback = {}) {
        let fm = FileManager.default

        //    what's the old URL?
        let oldURL: URL = oldStoreURL ?? CoreDataStack.defaultStoreURL

        //    is there a core data store file at the old url?
        let shouldMigrate = fm.fileExists(atPath: oldURL.path)

        //    if nothing to migrate, then just start with new URL
        if !shouldMigrate {
            self.init(withDataModelNamed: dataModel, storeURL: storeURL, usingSeparatePSCs: usingSeparatePSCs, callback: callback)
            return
        }

        //    is there a file at new URL?
        //    (maybe migration was already done and deleting old file failed originally)
        if fm.fileExists(atPath: storeURL.path) {
            //    init with new URL
            self.init(withDataModelNamed: dataModel, storeURL: storeURL, usingSeparatePSCs: usingSeparatePSCs, callback: callback)

            //    attempt to delete old file again
            deleteDocumentAtUrl(url: oldURL)
            return
        }


        //    ok, we need to migrate.

        //    so first make a dummy instance
        self.init()
        self.isUsingSeparatePersistentStoreCoordinators = usingSeparatePSCs

        //    new storeURL must be full file URL, not directory URL
        CoreDataStack.verify(storeURL: storeURL)

        //    build Model
        let mom = managedObjectModel(named: dataModel)
        self.dataModel = mom

        //    setup temporary migration PSC
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        //    connect old store
        self.storeURL = oldURL
        connectStores(toCoordinator: psc)

        //    ok, now migrate to new location
        var storeOptions = [AnyHashable : Any]()
        storeOptions[NSMigratePersistentStoresAutomaticallyOption] = true
        storeOptions[NSInferMappingModelAutomaticallyOption] = true

        if let store = psc.persistentStore(for: oldURL) {
            do {
                try psc.migratePersistentStore(store, to: storeURL, options: storeOptions, withType: NSSQLiteStoreType)

                //    successful migration, so update the value of store URL
                self.storeURL = storeURL
                self.callback = callback

                //    setup persistent store coordinators
                setupPersistentStoreCoordinators(using: mom)

                //    setup DidSaveNotification handling
                setupNotifications()

                //    report back
                setupDone(flags: .base)

                deleteDocumentAtUrl(url: oldURL)

            } catch let error {
                let log = String(format: "E | %@:%@/%@ Failed to migrate old store to new URL: %@,\n%@",
                                 String(describing: self), #file, #line, storeURL.path, error as NSError)
                fatalError(log)
            }
        } else {
            let log = String(format: "E | %@:%@/%@ Failed to migrate due to missing old store",
                             String(describing: self), #file, #line)
            fatalError(log)
        }
    }

    private func deleteDocumentAtUrl(url: URL){
        let fileCoordinator = NSFileCoordinator(filePresenter: nil)
        fileCoordinator.coordinate(writingItemAt: url, options: .forDeleting, error: nil, byAccessor: {
            (urlForModifying) -> Void in
            do {
                try FileManager.default.removeItem(at: urlForModifying)
            }  catch {
               Log(error)
           }
        })
    }
}


private extension CoreDataStack {


    func setupNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(CoreDataStack.handle(notification:)), name: .NSManagedObjectContextDidSave, object: nil)
    }

    @objc func handle(notification: Notification) {
        if !shouldMergeIncomingSavedObjects { return }

        
        guard let savedContext = notification.object as? NSManagedObjectContext else { return }

        if savedContext === mainContext { return }

        if let parentContext = savedContext.parent {
            if parentContext === mainContext { return }
        }

        if let coordinator = savedContext.persistentStoreCoordinator {
            if coordinator !== mainCoordinator && coordinator !== writerCoordinator { return }
        }

        mainContext.perform({ [unowned self] in
            self.mainContext.mergeChanges(fromContextDidSave: notification)
            print(notification)
        })
    }
}
