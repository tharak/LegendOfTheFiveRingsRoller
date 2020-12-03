/// Copyright (c) 2020 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// This project and source code may use libraries or frameworks that are
/// released under various Open-Source licenses. Use of those libraries and
/// frameworks are governed by their own individual licenses.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import Foundation
import CoreData

public final class CoreDataService {
    // MARK: - Properties
    let managedObjectContext: NSManagedObjectContext
    let coreDataStack: CoreDataStack

    // MARK: - Initializers
    public init(managedObjectContext: NSManagedObjectContext, coreDataStack: CoreDataStack) {
        self.managedObjectContext = managedObjectContext
        self.coreDataStack = coreDataStack
    }
}

// MARK: - Public
extension CoreDataService {

    @discardableResult
    public func createRoll(result: RollResult) -> Roll {
        let item = Roll(context: managedObjectContext)
        item.id = UUID()
        item.rolls = result.rolls.map({"\($0)"}).joined(separator: " ")
        item.text = "\(result.original.amount)k\(result.original.keep)+\(result.original.bonus + result.bonus)"
        item.value = Int16(result.total)
        item.order = Int16(getRolls()?.count ?? 0)
        coreDataStack.saveContext(managedObjectContext)
        return item
    }

    public func delete(_ item: Roll) {
        managedObjectContext.delete(item)
        coreDataStack.saveContext(managedObjectContext)
    }

    public func getRolls() -> [Roll]? {
        let fetchRequest: NSFetchRequest<Roll> = Roll.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "order", ascending: false)]
        do {
            let results = try managedObjectContext.fetch(fetchRequest)
            return results
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
        return nil
    }

    public func delete(roll: Roll) {
        managedObjectContext.delete(roll)
        coreDataStack.saveContext(managedObjectContext)
    }

    public func deleteAll() {
        let rolls = getRolls() ?? []
        for roll in rolls {
            managedObjectContext.delete(roll)
        }
        coreDataStack.saveContext(managedObjectContext)
    }
}
