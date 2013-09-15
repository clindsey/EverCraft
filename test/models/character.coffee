CharacterModel = require "models/Character"
AbilityModel = require "models/Ability"

attackExperiencePoints = 10

describe "Model Character", ->
  minimumCharacterOptions =
    name: "Jake"
    alignment: "Neutral"

  afterEach ->
    @characterModel.dispose()

    expect(CharacterModel.getUsedLength()).to.equal 0
    expect(AbilityModel.getUsedLength()).to.equal 0

  context "when created", ->
    context "with minimum options", ->
      beforeEach ->
        @characterModel = CharacterModel.create minimumCharacterOptions

      it "has a name", ->
        expect(@characterModel.name).to.equal minimumCharacterOptions.name

      it "has an alignment", ->
        expect(@characterModel.alignment).to.equal minimumCharacterOptions.alignment

      it "has default armor class", ->
        expect(@characterModel.armorClass).to.equal CharacterModel.DEFAULT_OPTIONS.armorClass

      it "has default hit points", ->
        expect(@characterModel.hitPoints()).to.equal CharacterModel.DEFAULT_OPTIONS.hitPoints + 1

      it "is alive", ->
        expect(@characterModel.alive).to.equal true

      it "has all 6 abilities", ->
        expect(@characterModel.abilities.strength).to.not.equal undefined
        expect(@characterModel.abilities.dexterity).to.not.equal undefined
        expect(@characterModel.abilities.constitution).to.not.equal undefined
        expect(@characterModel.abilities.wisdom).to.not.equal undefined
        expect(@characterModel.abilities.intelligence).to.not.equal undefined
        expect(@characterModel.abilities.charisma).to.not.equal undefined

      it "has 0 experience points", ->
        expect(@characterModel.experiencePoints).to.equal 0

      it "begins as level 1", ->
        expect(@characterModel.level).to.equal 1

    context "with extra options", ->
      extraCharacterOptions =
        armorClass: 11
        hitPoints: 6
        abilities:
          strength: 11
          dexterity: 9
          constitution: 11
          wisdom: 9
          intelligence: 11
          charisma: 9

      characterModelOptions = _.extend (_.extend {}, minimumCharacterOptions), extraCharacterOptions

      beforeEach ->
        @characterModel = CharacterModel.create characterModelOptions

      it "has different armor class", ->
        expect(@characterModel.armorClass).to.equal characterModelOptions.armorClass

      it "has different hit points", ->
        expect(@characterModel.hitPoints()).to.equal characterModelOptions.hitPoints + 1

      it "has different ability points", ->
        expect(@characterModel.abilities.strength.value).to.equal characterModelOptions.abilities.strength
        expect(@characterModel.abilities.dexterity.value).to.equal characterModelOptions.abilities.dexterity
        expect(@characterModel.abilities.constitution.value).to.equal characterModelOptions.abilities.constitution
        expect(@characterModel.abilities.wisdom.value).to.equal characterModelOptions.abilities.wisdom
        expect(@characterModel.abilities.intelligence.value).to.equal characterModelOptions.abilities.intelligence
        expect(@characterModel.abilities.charisma.value).to.equal characterModelOptions.abilities.charisma

  context "during a battle", ->
    afterEach ->
      @enemyModel.dispose()

    minimumEnemyOptions =
      name: "Finn"
      alignment: "Good"

    context "when attacking", ->
      beforeEach ->
        @characterModel = CharacterModel.create minimumCharacterOptions

      context "with a high roll", ->
        enemyModelOptions = _.extend (_.extend {}, minimumEnemyOptions),
          armorClass: 1

        beforeEach ->
          @enemyModel = CharacterModel.create enemyModelOptions

        it "hits", ->
          sinon.stub @enemyModel, "wasHit"

          @characterModel.attack @enemyModel, 10

          sinon.assert.calledOnce @enemyModel.wasHit

          @enemyModel.wasHit.restore()

        it "gains experience", ->
          newExperiencePoints = @characterModel.experiencePoints + attackExperiencePoints

          @characterModel.attack @enemyModel, 10

          expect(@characterModel.experiencePoints).to.equal newExperiencePoints

      context "with a low roll", ->
        enemyModelOptions = _.extend (_.extend {}, minimumEnemyOptions),
          armorClass: 20

        beforeEach ->
          @enemyModel = CharacterModel.create enemyModelOptions

        it "misses", ->
          sinon.stub @enemyModel, "wasHit"

          @characterModel.attack @enemyModel, 10

          sinon.assert.notCalled @enemyModel.wasHit

          @enemyModel.wasHit.restore()

        it "gains no experience", ->
          newExperiencePoints = @characterModel.experiencePoints

          @characterModel.attack @enemyModel, 10

          expect(@characterModel.experiencePoints).to.equal newExperiencePoints

    context "when blocking", ->
      characterModelOptions = _.extend (_.extend {}, minimumCharacterOptions),
        armorClass: 1
        hitPoints: 7

      beforeEach ->
        @characterModel = CharacterModel.create characterModelOptions
        @enemyModel = CharacterModel.create minimumEnemyOptions

      context "a successful attack", ->
        it "gets hit", ->
          sinon.stub @characterModel, "wasHit"

          @enemyModel.attack @characterModel, 15

          sinon.assert.calledWith @characterModel.wasHit, 1, 15

          @characterModel.wasHit.restore()

        it "takes damage", ->
          @enemyModel.attack @characterModel, 15

          expect(@characterModel.hitPoints()).to.equal characterModelOptions.hitPoints - 1 + 1 # constitution adds +1 hp

      context "a critical attack", ->
        it "gets hit for double", ->
          sinon.stub @characterModel, "wasHit"

          @enemyModel.attack @characterModel, 20

          sinon.assert.calledWith @characterModel.wasHit, 2, 20

          @characterModel.wasHit.restore()

        it "takes double damage", ->
          @enemyModel.attack @characterModel, 20

          expect(@characterModel.hitPoints()).to.equal characterModelOptions.hitPoints - 2 + 1 # constitution adds +1 hp

    context "and near death", ->
      characterModelOptions = _.extend (_.extend {}, minimumCharacterOptions),
        armorClass: 1
        hitPoints: 1

      beforeEach ->
        @characterModel = CharacterModel.create characterModelOptions
        @enemyModel = CharacterModel.create minimumEnemyOptions

      context "when blocking", ->
        it "dies", ->
          @enemyModel.attack @characterModel, 10

          expect(@characterModel.alive).to.equal false

    context "using modifiers", ->
      context "on the enemy", ->
        beforeEach ->
          @characterModel = CharacterModel.create minimumCharacterOptions

        context "using high strength", ->
          enemyModelOptions = _.extend (_.extend {}, minimumEnemyOptions),
            abilities:
              strength: 20

          beforeEach ->
            @enemyModel = CharacterModel.create enemyModelOptions

          it "applies to attack roll and damage dealt", ->
            sinon.stub @characterModel, "wasHit"

            @enemyModel.attack @characterModel, 12

            sinon.assert.calledWith @characterModel.wasHit, 6, 17

            @characterModel.wasHit.restore()

          it "doubles strength modifier on critical hit", ->
            sinon.stub @characterModel, "wasHit"

            @enemyModel.attack @characterModel, 20

            sinon.assert.calledWith @characterModel.wasHit, 12, 30

            @characterModel.wasHit.restore()

        context "using low strength", ->
          enemyModelOptions = _.extend (_.extend {}, minimumEnemyOptions),
            abilities:
              strength: 1

          beforeEach ->
            @enemyModel = CharacterModel.create enemyModelOptions

          it "minimum damage is at least 1", ->
            sinon.stub @characterModel, "wasHit"

            @enemyModel.attack @characterModel, 18

            sinon.assert.calledWith @characterModel.wasHit, 1, 13

            @characterModel.wasHit.restore()

          it "applies to attack roll and damage dealt", ->
            sinon.stub @characterModel, "wasHit"

            @enemyModel.attack @characterModel, 18

            sinon.assert.calledWith @characterModel.wasHit, 1, 13

            @characterModel.wasHit.restore()

          it "doubles strength modifier on critical hit", ->
            sinon.stub @characterModel, "wasHit"

            @enemyModel.attack @characterModel, 20

            sinon.assert.calledWith @characterModel.wasHit, 1, 10

            @characterModel.wasHit.restore()

      context "on the main character", ->
        context "using high dexterity", ->
          extraCharacterOptions = _.extend (_.extend {}, minimumCharacterOptions),
            armorClass: 10
            abilities:
              dexterity: 20

          beforeEach ->
            @characterModel = CharacterModel.create extraCharacterOptions
            @enemyModel = CharacterModel.create minimumEnemyOptions

          it "applies to armor class", ->
            sinon.stub @characterModel, "wasHit"

            @enemyModel.attack @characterModel, 14

            sinon.assert.notCalled @characterModel.wasHit

            @characterModel.wasHit.restore()

        context "using low dexterity", ->
          extraCharacterOptions = _.extend (_.extend {}, minimumCharacterOptions),
            armorClass: 10
            abilities:
              dexterity: 1

          beforeEach ->
            @characterModel = CharacterModel.create extraCharacterOptions
            @enemyModel = CharacterModel.create minimumEnemyOptions

          it "applies to armor class", ->
            sinon.stub @characterModel, "wasHit"

            @enemyModel.attack @characterModel, 14

            sinon.assert.calledWith @characterModel.wasHit, 1, 14

            @characterModel.wasHit.restore()

    context "leveling up", ->
      beforeEach ->
        @characterModel = CharacterModel.create minimumCharacterOptions
        @enemyModel = CharacterModel.create minimumEnemyOptions

      it "happens every one thousand experience points", ->
        @characterModel.experiencePoints = 990
        @characterModel.attack @enemyModel, 20
        expect(@characterModel.level).to.equal 2

        @characterModel.experiencePoints = 1990
        @characterModel.attack @enemyModel, 20
        expect(@characterModel.level).to.equal 3

        @characterModel.experiencePoints = 8990
        @characterModel.attack @enemyModel, 20
        expect(@characterModel.level).to.equal 10

      it "increases hit points", ->
        @characterModel.experiencePoints = 1990
        @characterModel.attack @enemyModel, 20

        expect(@characterModel.hitPoints()).to.equal 16 # dont forget about constitution adding that +1

      it "increases attack rolls", ->
        @characterModel.experiencePoints = 17990 # level 19
        @characterModel.attack @enemyModel, 10

        sinon.stub @enemyModel, "wasHit"
        @characterModel.attack @enemyModel, 10
        sinon.assert.calledWith @enemyModel.wasHit, 1, 19
        @enemyModel.wasHit.restore()

  context "in general", ->
    context "using modifiers", ->
      context "with high constitution", ->
        extraCharacterOptions = _.extend (_.extend {}, minimumCharacterOptions),
          hitPoints: 10
          abilities:
            constitution: 20

        beforeEach ->
          @characterModel = CharacterModel.create extraCharacterOptions

        it "gives a bonus to hitpoints", ->
          expect(@characterModel.hitPoints()).to.equal 15

      context "with low constitution", ->
        extraCharacterOptions = _.extend (_.extend {}, minimumCharacterOptions),
          hitPoints: 10
          abilities:
            constitution: 1

        beforeEach ->
          @characterModel = CharacterModel.create extraCharacterOptions

        it "gives a bonus to hitpoints", ->
          expect(@characterModel.hitPoints()).to.equal 11
