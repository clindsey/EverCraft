Model = require "models/base/Model"

module.exports = Model.extend "CharacterModel",
  {
    create: (options) ->
      characterModel = @_super()

      characterModel.name = options.name
      characterModel.alignment = options.alignment
      characterModel.armorClass = options.armorClass || @DEFAULT_OPTIONS.armorClass
      characterModel.hitPoints = options.hitPoints || @DEFAULT_OPTIONS.hitPoints
      characterModel.alive = true

      characterModel

    DEFAULT_OPTIONS:
      armorClass: 10
      hitPoints: 5
  }, {
    attack: (enemyCharacterModel, dieRoll) ->
      if dieRoll >= enemyCharacterModel.armorClass
        enemyCharacterModel.wasHit @_damageToDeal dieRoll

    wasHit: (damage) ->
      @hitPoints -= damage

      if @hitPoints <= 0
        @alive = false

    _damageToDeal: (dieRoll) ->
      damage = 1

      if dieRoll is 20
        damage *= 2

      damage
  }
