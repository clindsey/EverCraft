Model = require "models/base/Model"

module.exports = Model.extend "RuleEngineModel",
    create: ->
      ruleEngineModel = @_super()

      ruleEngineModel
  ,
    determineStrengthModifier: (characterModel, dieRoll) ->
      strengthModifier = characterModel.abilities.strength.modifier()

      if dieRoll is 20
        strengthModifier *= 2

      strengthModifier

    determineAttackRoll: (characterModel, dieRoll) ->
      strengthModifier = @determineStrengthModifier characterModel, dieRoll
      levelBonus = Math.floor characterModel.level / 2
      dieRoll + strengthModifier + levelBonus

    damageToDeal: (characterModel, dieRoll) ->
      damage = 1

      strengthModifier = @determineStrengthModifier characterModel, dieRoll
      damage += strengthModifier

      if dieRoll is 20
        damage += 1

      damage = Math.max damage, 1

      damage

    determineHitSuccess: (attackerModel, defenderModel, dieRoll) ->
      attackRoll = @determineAttackRoll attackerModel, dieRoll
      enemyArmorClass = defenderModel.armorClass + defenderModel.abilities.dexterity.modifier()
      attackRoll >= enemyArmorClass

    addExperiencePoints: (characterModel, amount) ->
      characterModel.experiencePoints += amount
      level = characterModel.level

      newLevel = Math.floor(characterModel.experiencePoints / 1000) + 1

      if newLevel isnt level
        _.each [level..newLevel - 1], =>
          characterModel.baseHitPoints += 5 + characterModel.abilities.constitution.modifier()

        characterModel.level = newLevel

    dispose: ->
      @_super()
