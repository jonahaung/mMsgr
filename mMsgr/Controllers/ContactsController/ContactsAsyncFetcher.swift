//
//  ContactsAsyncFetcher.swift
//  mMsgr
//
//  Created by Aung Ko Min on 18/1/18.
//  Copyright © 2018 Aung Ko Min. All rights reserved.
//

import Foundation

/// - Tag: AsyncFetcher
class ContactsAsyncFetcher {
    // MARK: Types
    /// An `NSCache` used to store fetched objects.
    var contactCache = NSCache<NSString, ContactsDisplayData>()

    /// A serial `OperationQueue` to lock access to the `fetchQueue` and `completionHandlers` properties.
    private let serialAccessQueue = OperationQueue()

    /// An `OperationQueue` that contains `AsyncFetcherOperation`s for requested data.
    private let fetchQueue = OperationQueue()

    /// A dictionary of arrays of closures to call when an object has been fetched for an id.
    private var completionHandlers = [String: [(ContactsDisplayData?) -> Void]]()



    // MARK: Initialization

    init() {
        serialAccessQueue.maxConcurrentOperationCount = 1
    }

    // MARK: Object fetching

    /**
     Asynchronously fetches data for a specified `UUID`.

     - Parameters:
     - identifier: The `UUID` to fetch data for.
     - completion: An optional called when the data has been fetched.
     */
    func fetchAsync(_ friend: Friend, completion: ((ContactsDisplayData?) -> Void)? = nil) {
        // Use the serial queue while we access the fetch queue and completion handlers.
        serialAccessQueue.addOperation {
            // If a completion block has been provided, store it.
            if let completion = completion {
                let handlers = self.completionHandlers[friend.uid, default: []]
                self.completionHandlers[friend.uid] = handlers + [completion]
            }
            self.fetchData(for: friend)
        }
    }

    /**
     Returns the previously fetched data for a specified `UUID`.

     - Parameter identifier: The `UUID` of the object to return.
     - Returns: The 'DisplayData' that has previously been fetched or nil.
     */
    func fetchedData(for identifier: String) -> ContactsDisplayData? {
        return contactCache.object(forKey: identifier as NSString)
    }

    /**
     Cancels any enqueued asychronous fetches for a specified `UUID`. Completion
     handlers are not called if a fetch is canceled.

     - Parameter identifier: The `UUID` to cancel fetches for.
     */
    func cancelFetch(_ identifier: String) {
        serialAccessQueue.addOperation {
            self.fetchQueue.isSuspended = true
            defer {
                self.fetchQueue.isSuspended = false
            }

            self.operation(for: identifier)?.cancel()
            self.completionHandlers[identifier] = nil
        }
    }

    // MARK: Convenience

    /**
     Begins fetching data for the provided `identifier` invoking the associated
     completion handler when complete.

     - Parameter identifier: The `UUID` to fetch data for.
     */
    private func fetchData(for friend: Friend) {
        // If a request has already been made for the object, do nothing more.
        guard operation(for: friend.uid) == nil else { return }

        if let data = fetchedData(for: friend.uid) {
            // The object has already been cached; call the completion handler with that object.
            invokeCompletionHandlers(for: friend.uid, with: data)
        } else {
            // Enqueue a request for the object.
            let operation = ContactsAsyncFetcherOperation(friend: friend)

            // Set the operation's completion block to cache the fetched object and call the associated completion blocks.
            operation.completionBlock = { [weak operation] in
                guard let fetchedData = operation?.fetchedData else { return }
                self.contactCache.setObject(fetchedData, forKey: friend.uid as NSString)

                self.serialAccessQueue.addOperation {
                    self.invokeCompletionHandlers(for: friend.uid, with: fetchedData)
                }
            }

            fetchQueue.addOperation(operation)
        }
    }

    /**
     Returns any enqueued `ObjectFetcherOperation` for a specified `UUID`.

     - Parameter identifier: The `UUID` of the operation to return.
     - Returns: The enqueued `ObjectFetcherOperation` or nil.
     */
    private func operation(for identifier: String) -> ContactsAsyncFetcherOperation? {
        for case let fetchOperation as ContactsAsyncFetcherOperation in fetchQueue.operations
            where !fetchOperation.isCancelled && fetchOperation.identifier == identifier {
                return fetchOperation
        }

        return nil
    }

    /**
     Invokes any completion handlers for a specified `UUID`. Once called,
     the stored array of completion handlers for the `UUID` is cleared.

     - Parameters:
     - identifier: The `UUID` of the completion handlers to call.
     - object: The fetched object to pass when calling a completion handler.
     */
    private func invokeCompletionHandlers(for identifier: String, with fetchedData: ContactsDisplayData) {
        let completionHandlers = self.completionHandlers[identifier, default: []]
        self.completionHandlers[identifier] = nil

        for completionHandler in completionHandlers {
            completionHandler(fetchedData)
        }
    }
}

class ContactsAsyncFetcherOperation: Operation {
    // MARK: Properties

    /// The `UUID` that the operation is fetching data for.
    let identifier: String
    let friend: Friend

    /// The `DisplayData` that has been fetched by this operation.
    private(set) var fetchedData: ContactsDisplayData?

    // MARK: Initialization

    init(friend: Friend) {
        self.identifier = friend.uid
        self.friend = friend
    }

    // MARK: Operation overrides
    override func main() {
        // Wait for a second to mimic a slow operation.
        Thread.sleep(until: Date().addingTimeInterval(1))
        guard !isCancelled else { return }

        fetchedData = ContactsDisplayData(friend: friend)
    }
}

