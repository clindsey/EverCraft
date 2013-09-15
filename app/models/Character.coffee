Model = require "models/base/Model"
AbilityModel = require "models/Ability"

module.exports = Model.extend "CharacterModel",
    create: (options) ->
      characterModel = @_super()

      characterModel.name = options.name
      characterModel.alignment = options.alignment
      characterModel.armorClass = options.armorClass || @DEFAULT_OPTIONS.armorClass
      characterModel.baseHitPoints = options.hitPoints || @DEFAULT_OPTIONS.hitPoints
      characterModel.alive = true
      characterModel.abilities = @_buildAbilities options.abilities || {}
      characterModel.experiencePoints = 0
      characterModel.level = 1

      characterModel

    DEFAULT_OPTIONS:
      armorClass: 10
      hitPoints: 5

    _buildAbilities: (abilityOptions) ->
      abilities =
        strength: AbilityModel.create abilityOptions.strength
        dexterity: AbilityModel.create abilityOptions.dexterity
        constitution: AbilityModel.create abilityOptions.constitution
        wisdom: AbilityModel.create abilityOptions.wisdom
        intelligence: AbilityModel.create abilityOptions.intelligence
        charisma: AbilityModel.create abilityOptions.charisma
  ,
    hitPoints: ->
      hitPointModifier = Math.max @abilities.constitution.modifier(), 1
      @baseHitPoints + hitPointModifier

    attack: (enemyCharacterModel, dieRoll) ->
      strengthModifier = @_determineStrengthModifier dieRoll
      attackRoll = @_determineAttackRoll dieRoll, strengthModifier
      damageToDeal = @_damageToDeal dieRoll, strengthModifier
      if @_determineHitSuccess enemyCharacterModel, attackRoll
        enemyCharacterModel.wasHit damageToDeal, attackRoll
        @_addExperiencePoints 10

    wasHit: (damage, attackRoll) ->
      @baseHitPoints -= damage

      if @baseHitPoints <= 0
        @alive = false

    _addExperiencePoints: (amount) ->
      @experiencePoints += amount

      newLevel = Math.floor(@experiencePoints / 1000) + 1

      if newLevel isnt @level
        _.each [@level..newLevel - 1], (i) =>
          @baseHitPoints += 5 + @abilities.constitution.modifier()

        @level = newLevel

    _determineStrengthModifier: (dieRoll) ->
      strengthModifier = @abilities.strength.modifier()

      if dieRoll is 20
        strengthModifier *= 2

      strengthModifier

    _damageToDeal: (dieRoll, strengthModifier) ->
      damage = 1

      damage += strengthModifier

      if dieRoll is 20
        damage += 1

      damage = Math.max damage, 1

      damage

    _determineAttackRoll: (dieRoll, strengthModifier) ->
      levelModifier = Math.floor @level / 2
      dieRoll + strengthModifier + levelModifier

    _determineHitSuccess: (enemyCharacterModel, attackRoll) ->
      enemyArmorClass = enemyCharacterModel.armorClass + enemyCharacterModel.abilities.dexterity.modifier()
      attackRoll >= enemyArmorClass

    dispose: ->
      _.invoke @abilities, "dispose"

      @_super()
