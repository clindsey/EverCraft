AbilityModel = require "models/Ability"

describe "Model Ability", ->
  afterEach ->
    @abilityModel.dispose()

    expect(AbilityModel.getUsedLength()).to.equal 0

  context "when created", ->
    context "with extra options", ->
      extraAbilityOptions =
        value: 12

      beforeEach ->
        @abilityModel = AbilityModel.create extraAbilityOptions.value

      it "has a value", ->
        expect(@abilityModel.value).to.equal extraAbilityOptions.value

    context "with minimum options", ->
      beforeEach ->
        @abilityModel = AbilityModel.create()

      it "has a default value", ->
        expect(@abilityModel.value).to.equal AbilityModel.DEFAULT_VALUE
  
  context "has a modifier table", ->
    extraAbilityOptions =
      low_value: 1
      low_value_answer: -5
      high_value: 20
      high_value_answer: 5
      medium_value: 10
      medium_value_answer: 0

    context "with a low score", ->
      beforeEach ->
        @abilityModel = AbilityModel.create extraAbilityOptions.low_value

      it "is negative", ->
        expect(@abilityModel.modifier()).to.equal extraAbilityOptions.low_value_answer

    context "with a high score", ->
      beforeEach ->
        @abilityModel = AbilityModel.create extraAbilityOptions.high_value

      it "is positive", ->
        expect(@abilityModel.modifier()).to.equal extraAbilityOptions.high_value_answer

    context "with a medium score", ->
      beforeEach ->
        @abilityModel = AbilityModel.create extraAbilityOptions.medium_value

      it "is positive", ->
        expect(@abilityModel.modifier()).to.equal extraAbilityOptions.medium_value_answer
