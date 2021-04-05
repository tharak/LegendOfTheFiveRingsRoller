//
//  File.swift
//  
//
//  Created by Tharak on 03/12/20.
//
import GameplayKit

public struct LegendOfTheFiveRingsRoller {

    public init() {}

    public static let dieSides = 10
    let maximumDice = 10
    let bonusForMoreThanMaximumDice = 2

    public func rollDice(amount: Int, keep: Int,
                         bonus: Int, keepHigh: Bool = true,
                         explodesOn: Int? = LegendOfTheFiveRingsRoller.dieSides,
                         rerollOnOne: Bool = false) -> RollResult {
        let tenDiceRuled = applyTheTenDiceRule(amount: amount, keep: keep)
        var rolls: [Int] = []
        for _ in 0..<tenDiceRuled.amount {
            rolls.append(rollDie(explodesOn: explodesOn, rerollOnOne: rerollOnOne))
        }
        keepHigh ? rolls.sort(by: >) : rolls.sort(by: <)
        let total = calculateTotal(rolls: rolls,
                                   keep: tenDiceRuled.keep,
                                   bonus: tenDiceRuled.bonus + bonus)
        return RollResult(original: (amount: amount, keep: keep, bonus: 0), bonus: bonus, rolls: rolls, total: total)
    }

    func calculateTotal(rolls: [Int], keep: Int, bonus: Int) -> Int {
        return rolls[0..<keep].reduce(0, +) + bonus
    }
    
    func applyTheTenDiceRule(amount: Int, keep: Int) -> (amount: Int, keep: Int, bonus: Int) {
        let realAmount = min(amount, maximumDice)
        let extraAmount = amount <= maximumDice ? 0 : (amount - maximumDice)
        let keepFromExtraRoll = Int(extraAmount / 2)
        var bonusFromExtraRoll: Int = (extraAmount % 2) * bonusForMoreThanMaximumDice

        let bonusFromExtraKeep: Int
        var realKeep = keep
        if realKeep > maximumDice {
            bonusFromExtraRoll = extraAmount * bonusForMoreThanMaximumDice
            bonusFromExtraKeep = (realKeep - maximumDice) * bonusForMoreThanMaximumDice
            realKeep = maximumDice
        } else if realKeep + keepFromExtraRoll > maximumDice {
            realKeep = maximumDice
            bonusFromExtraKeep = (realKeep + keepFromExtraRoll - maximumDice) * bonusForMoreThanMaximumDice
        } else {
            realKeep = realKeep + keepFromExtraRoll
            bonusFromExtraKeep = 0
        }
        return (realAmount, realKeep, bonusFromExtraRoll + bonusFromExtraKeep)
    }

    public func rollDie(testValue: Int? = nil,
                    explodesOn: Int? = LegendOfTheFiveRingsRoller.dieSides,
                    rerollOnOne: Bool = false) -> Int {
        let value = testValue ?? random(rerollOnOne: rerollOnOne)
        if let explodesOn = explodesOn, value >= explodesOn {
            return value + rollDie(explodesOn: explodesOn, rerollOnOne: false)
        }
        return value
    }

    func random(rerollOnOne: Bool = false) -> Int {
        let minimumValue = rerollOnOne ? 2 : 1
        return GKRandomDistribution(lowestValue: minimumValue, highestValue: 10).nextInt()
    }
}
