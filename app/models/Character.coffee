Model = require "models/base/Model"
AbilityModel = require "models/Ability"

module.exports = Model.extend "CharacterModel",
    create: (options, ruleEngineModel) ->
      characterModel = @_super()

      characterModel.name = options.name
      characterModel.alignment = options.alignment
      characterModel.armorClass = options.armorClass || @DEFAULT_OPTIONS.armorClass
      characterModel.baseHitPoints = options.hitPoints || @DEFAULT_OPTIONS.hitPoints
      characterModel.alive = true
      characterModel.abilities = @_buildAbilities options.abilities || {}
      characterModel.experiencePoints = 0
      characterModel.level = 1
      characterModel.ruleEngineModel = ruleEngineModel

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
      attackRoll = @ruleEngineModel.determineAttackRoll @, dieRoll
      damageToDeal = @ruleEngineModel.damageToDeal @, dieRoll
      if @ruleEngineModel.determineHitSuccess @, enemyCharacterModel, dieRoll
        enemyCharacterModel.wasHit damageToDeal, attackRoll
        @ruleEngineModel.addExperiencePoints @, 10

    wasHit: (damage, attackRoll) ->
      @baseHitPoints -= damage

      if @baseHitPoints <= 0
        @alive = false

    dispose: ->
      _.invoke @abilities, "dispose"

      @_super()
