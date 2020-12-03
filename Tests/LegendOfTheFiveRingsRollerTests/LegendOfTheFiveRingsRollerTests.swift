import XCTest
@testable import LegendOfTheFiveRingsRoller

final class LegendOfTheFiveRingsRollerTests: XCTestCase {
    // MARK: - Properties
    // swiftlint:disable implicitly_unwrapped_optional
    var coreDataService: CoreDataService!
    var coreDataStack: CoreDataStack!
    // swiftlint:enable implicitly_unwrapped_optional
    var die: LegendOfTheFiveRingsRoller!
    
    override func setUp() {
        super.setUp()
        die = LegendOfTheFiveRingsRoller()
        coreDataStack = TestCoreDataStack()
        coreDataService = CoreDataService(managedObjectContext: coreDataStack.mainContext, coreDataStack: coreDataStack)
    }

    override func tearDown() {
        super.tearDown()
        coreDataService = nil
        coreDataStack = nil
        die = nil
    }

    func testCreateRoll() {
        let roll = coreDataService.createRoll(result: RollResult(original: (amount: 1, keep: 1, bonus: 1), bonus: 1, rolls: [1], total: 1))
        XCTAssertNotNil(roll)
        XCTAssertNotNil(roll.id)
        XCTAssertNotNil(roll.value == 1)
        XCTAssertTrue(roll.order == 1)
        XCTAssertTrue(roll.rolls == "1")
        XCTAssertTrue(roll.text == "1k1+2", roll.text)
        
        let second = coreDataService.createRoll(result: RollResult(original: (amount: 32, keep: 11, bonus: 0), bonus: 3, rolls: [1, 2, 3], total: 1))
        XCTAssertTrue(roll.order == 1)
        XCTAssertTrue(second.order == 2)
        XCTAssertTrue(second.rolls == "1 2 3")
        XCTAssertTrue(second.text == "32k11+3", roll.text)

        for i in 1..<die.maximumDice {
            let result = RollResult(original: (amount: 0, keep: 0, bonus: 0), bonus: 0, rolls: [], total: i)
            XCTAssertTrue(coreDataService.createRoll(result: result).value == i)
        }
    }

    func testRootContextIsSavedAfterAddingRoll() {
        let derivedContext = coreDataStack.newDerivedContext()
        coreDataService = CoreDataService(managedObjectContext: derivedContext, coreDataStack: coreDataStack)

        expectation(
            forNotification: .NSManagedObjectContextDidSave,
            object: coreDataStack.mainContext) { _ in
              return true
        }

        derivedContext.perform {
            let result = RollResult(original: (amount: 0, keep: 0, bonus: 0), bonus: 0, rolls: [], total: 0)
            let roll = self.coreDataService.createRoll(result: result)
            XCTAssertNotNil(roll)
        }

        waitForExpectations(timeout: 2.0) { error in
            XCTAssertNil(error, "Save did not occur")
        }
    }

    func testGetRolls() {
        let result = RollResult(original: (amount: 0, keep: 0, bonus: 0), bonus: 0, rolls: [], total: 0)
        coreDataService.createRoll(result: result)
        coreDataService.createRoll(result: result)
        let rolls = coreDataService.getRolls()
        XCTAssertTrue(rolls?.count == 2)
        XCTAssertTrue(rolls?[1].order == 1)
        XCTAssertTrue(rolls?[0].order == 2)
    }

    func testDeleteRolls() {
        let result = RollResult(original: (amount: 0, keep: 0, bonus: 0), bonus: 0, rolls: [], total: 0)
        let roll = coreDataService.createRoll(result: result)
        for _ in 0..<1000 {
            coreDataService.createRoll(result: result)
        }
        coreDataService.delete(roll)
        XCTAssertTrue(coreDataService.getRolls()?.count == 1000)
        coreDataService.deleteAll()
        XCTAssertTrue(coreDataService.getRolls()?.count == 0)
    }

    func testDiceRolls() {
        for i in 1...die.maximumDice {
            XCTAssertTrue(die.rollDie(testValue: i, explodesOn: nil) == i)
        }

        for i in 1...die.maximumDice {
            if i == 10 {
                XCTAssertTrue(die.rollDie(testValue: i, explodesOn: 10) > 10)
                XCTAssertTrue(die.rollDie(testValue: i) > 10)
                continue
            }
            XCTAssertTrue(die.rollDie(testValue: i, explodesOn: nil) == i)
        }

        for i in 1...die.maximumDice {
            if [9, 10].contains(i) {
                XCTAssertTrue(die.rollDie(testValue: i, explodesOn: 9) > 9)
                continue
            }
            XCTAssertTrue(die.rollDie(testValue: i, explodesOn: 9) == i)
        }

        for i in 1...die.maximumDice {
            if [10].contains(i) {
                XCTAssertTrue(die.rollDie(testValue: i, explodesOn: 8) > 10)
                continue
            }
            if [9, 10].contains(i) {
                XCTAssertTrue(die.rollDie(testValue: i, explodesOn: 8) > 9)
                continue
            }
            if [8, 9, 10].contains(i) {
                XCTAssertTrue(die.rollDie(testValue: i, explodesOn: 8) > i)
                continue
            }
            XCTAssertTrue(die.rollDie(testValue: i, explodesOn: 8) == i)
        }
    }

    func testRandomDiceRolls() {
        var numbers = Set<Int>()
        for _ in 0...100 {
            numbers.insert(die.rollDie(explodesOn: nil))
        }
        XCTAssertTrue(numbers == [1,2,3,4,5,6,7,8,9,10])
        numbers = Set<Int>()
        for _ in 0...100 {
            numbers.insert(die.rollDie(explodesOn: nil, rerollOnOne: true))
        }
        XCTAssertTrue(numbers == [2,3,4,5,6,7,8,9,10])
        numbers = Set<Int>()
        for _ in 0...100 {
            numbers.insert(die.rollDie(rerollOnOne: true))
        }
        XCTAssertTrue(numbers.count > 10)
    }

    func testTheTenDiceRule() {
        for i in 0...10 {
            XCTAssertTrue(die.applyTheTenDiceRule(amount: i, keep: i) == (amount: i, keep: i, bonus: 0))
        }
        var roll = die.applyTheTenDiceRule(amount: 11, keep: 4)
        XCTAssertTrue(roll.amount == 10)
        XCTAssertTrue(roll.keep == 4)
        XCTAssertTrue(roll.bonus == 2)

        roll = die.applyTheTenDiceRule(amount: 13, keep: 4)
        XCTAssertTrue(roll.amount == 10)
        XCTAssertTrue(roll.keep == 5)
        XCTAssertTrue(roll.bonus == 2)

        roll = die.applyTheTenDiceRule(amount: 12, keep: 4)
        XCTAssertTrue(roll.amount == 10)
        XCTAssertTrue(roll.keep == 5)
        XCTAssertTrue(roll.bonus == 0)

        roll = die.applyTheTenDiceRule(amount: 13, keep: 9)
        XCTAssertTrue(roll.amount == 10)
        XCTAssertTrue(roll.keep == 10)
        XCTAssertTrue(roll.bonus == 2)

        roll = die.applyTheTenDiceRule(amount: 10, keep: 12)
        XCTAssertTrue(roll.amount == 10)
        XCTAssertTrue(roll.keep == 10)
        XCTAssertTrue(roll.bonus == 4)

        roll = die.applyTheTenDiceRule(amount: 14, keep: 12)
        XCTAssertTrue(roll.amount == 10)
        XCTAssertTrue(roll.keep == 10)
        XCTAssertTrue(roll.bonus == 12)
    }

    func testCalculateTotal() {
        let rolls = [1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]
        for i in 0...rolls.count {
            XCTAssertTrue(die.calculateTotal(
                            rolls: rolls, keep: i, bonus: 0) == i)
        }
    }
    
    func testRollDiceBonus() {
        for i in 1...10 {
            XCTAssertTrue(die.rollDice(amount: 0, keep: 0, bonus: i).total == i)
        }
    }
}
