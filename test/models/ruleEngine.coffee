RuleEngineModel = require "models/RuleEngine"
CharacterModel = require "models/Character"

minimumCharacterOptions =
  name: "Marceline"
  alignment: "Evil"

describe "Model RuleEngine", ->
  beforeEach ->
    @ruleEngineModel = RuleEngineModel.create()

  afterEach ->
    @ruleEngineModel.dispose()

    expect(RuleEngineModel.getUsedLength()).to.equal 0
    expect(CharacterModel.getUsedLength()).to.equal 0

  context "for core rules", ->
    context "with strength modifier", ->
      extraCharacterOptions = _.extend (_.extend {}, minimumCharacterOptions),
        abilities:
          strength: 20

      afterEach ->
        @characterModel.dispose()

      context "determines value", ->
        beforeEach ->
          @characterModel = CharacterModel.create extraCharacterOptions, @ruleEngineModel

        it "is normal for regular roll", ->
          dieRoll = 10

          strengthModifier = @ruleEngineModel.determineStrengthModifier @characterModel, dieRoll

          expect(strengthModifier).to.equal @characterModel.abilities.strength.modifier()

        it "is double for critical", ->
          dieRoll = 20

          strengthModifier = @ruleEngineModel.determineStrengthModifier @characterModel, dieRoll

          expect(strengthModifier).to.equal @characterModel.abilities.strength.modifier() * 2

      context "determines attack roll", ->
        beforeEach ->
          @characterModel = CharacterModel.create extraCharacterOptions, @ruleEngineModel
          @enemyModel = CharacterModel.create minimumCharacterOptions

        afterEach ->
          @enemyModel.dispose()

        it "for a low level", ->
          dieRoll = 10

          attackRoll = @ruleEngineModel.determineAttackRoll @characterModel, dieRoll

          expect(attackRoll).to.equal @characterModel.abilities.strength.modifier() + dieRoll

        it "for a higher level", ->
          dieRoll = 10

          @characterModel.experiencePoints = 8990
          @characterModel.attack @enemyModel, 20
          expect(@characterModel.level).to.equal 10

          levelBonus = Math.floor @characterModel.level / 2

          attackRoll = @ruleEngineModel.determineAttackRoll @characterModel, dieRoll

          expect(attackRoll).to.equal @characterModel.abilities.strength.modifier() + dieRoll + levelBonus

    context "calculates damage to deal", ->
      afterEach ->
        @characterModel.dispose()

      context "for a moderate level", ->
        extraCharacterOptions = _.extend (_.extend {}, minimumCharacterOptions),
          abilities:
            strength: 10

        beforeEach ->
          @characterModel = CharacterModel.create extraCharacterOptions, @ruleEngineModel

        it "is valid with normal roll", ->
          dieRoll = 10

          damageToDeal = @ruleEngineModel.damageToDeal @characterModel, dieRoll

          expect(damageToDeal).to.equal 1

        it "is valid with a critical roll", ->
          dieRoll = 20

          damageToDeal = @ruleEngineModel.damageToDeal @characterModel, dieRoll

          expect(damageToDeal).to.equal 2

      context "for a high level", ->
        extraCharacterOptions = _.extend (_.extend {}, minimumCharacterOptions),
          abilities:
            strength: 20

        beforeEach ->
          @characterModel = CharacterModel.create extraCharacterOptions, @ruleEngineModel

        it "is valid with normal roll", ->
          dieRoll = 10

          damageToDeal = @ruleEngineModel.damageToDeal @characterModel, dieRoll

          expect(damageToDeal).to.equal 6

      context "for a low level", ->
        extraCharacterOptions = _.extend (_.extend {}, minimumCharacterOptions),
          abilities:
            strength: 1

        beforeEach ->
          @characterModel = CharacterModel.create extraCharacterOptions, @ruleEngineModel

        it "has a minimum value of 1", ->
          dieRoll = 10

          damageToDeal = @ruleEngineModel.damageToDeal @characterModel, dieRoll

          expect(damageToDeal).to.equal 1

    context "with dexterity modifier", ->
      beforeEach ->
        @characterModel = CharacterModel.create minimumCharacterOptions

      afterEach ->
        @characterModel.dispose()

      context "of moderate value", ->
        extraEnemyOptions = _.extend (_.extend {}, minimumCharacterOptions),
          abilities:
            dexterity: 10

        beforeEach ->
          @enemyModel = CharacterModel.create extraEnemyOptions

        afterEach ->
          @enemyModel.dispose()

        context "determines hit success", ->
          it "misses", ->
            dieRoll = 10
            hitSuccess = @ruleEngineModel.determineHitSuccess @characterModel, @enemyModel, dieRoll
            expect(hitSuccess).to.equal true

          it "hits", ->
            dieRoll = 20
            hitSuccess = @ruleEngineModel.determineHitSuccess @characterModel, @enemyModel, dieRoll
            expect(hitSuccess).to.equal true

      context "of high value", ->
        extraEnemyOptions = _.extend (_.extend {}, minimumCharacterOptions),
          abilities:
            dexterity: 20

        beforeEach ->
          @enemyModel = CharacterModel.create extraEnemyOptions

        afterEach ->
          @enemyModel.dispose()

        it "considers dexterity modifier", ->
          dieRoll = 10
          hitSuccess = @ruleEngineModel.determineHitSuccess @characterModel, @enemyModel, dieRoll
          expect(hitSuccess).to.equal false

    context "with the leveling system", ->
      beforeEach ->
        @characterModel = CharacterModel.create minimumCharacterOptions

      afterEach ->
        @characterModel.dispose()

      it "adds experience points to a character", ->
        @ruleEngineModel.addExperiencePoints @characterModel, 10

        expect(@characterModel.experiencePoints).to.equal 10

      it "causes them to level up at certain thresholds", ->
        @ruleEngineModel.addExperiencePoints @characterModel, 9000

        expect(@characterModel.level).to.equal 10
