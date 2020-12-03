//
//  File.swift
//  
//
//  Created by Tharak on 03/12/20.
//

import Foundation

public class LegendOfTheFiveRingsRollerModel: ObservableObject {

    @Published public var rolls: [Roll]
    
    public let roller = LegendOfTheFiveRingsRoller()
    
    private var coreDataService: CoreDataService
    private var coreDataStack: CoreDataStack

    public init(coreDataStack: CoreDataStack = CoreDataStack()) {
        self.coreDataStack = coreDataStack
        coreDataService = CoreDataService(managedObjectContext: coreDataStack.mainContext, coreDataStack: coreDataStack)
        rolls = coreDataService.getRolls() ?? []
    }
    
    public func roll(amount: Int, keep: Int, bonus: Int, keepHigh: Bool = true, explodesOn: Int? = 10, rerollOnOne: Bool = false) {
        let result = roller.rollDice(amount: amount, keep: keep, bonus: bonus, keepHigh: keepHigh, explodesOn: explodesOn, rerollOnOne: rerollOnOne)
        coreDataService.createRoll(result: result)
        rolls = coreDataService.getRolls() ?? []
    }

    public func delete(roll: Roll) {
        coreDataService.delete(roll)
        rolls = coreDataService.getRolls() ?? []
    }
    
    public func deleteAll() {
        coreDataService.deleteAll()
        rolls = coreDataService.getRolls() ?? []
    }

}
