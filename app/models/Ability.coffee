Model = require "models/base/Model"

module.exports = Model.extend "AbilityModel",
    create: (value) ->
      abilityModel = @_super()

      abilityModel.value = value || @DEFAULT_VALUE

      abilityModel

    DEFAULT_VALUE: 10
  ,
    modifier: ->
      Math.floor (@value - 10) / 2
