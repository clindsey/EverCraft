CharacterModel = require "models/Character"

describe "Model Character", ->
  minimumCharacterOptions =
    name: "Jake"
    alignment: "Neutral"

  afterEach ->
    @characterModel.dispose()

    expect(CharacterModel.getUsedLength()).to.equal 0

  context "when created", ->
    context "with minimum options", ->
      beforeEach ->
        @characterModel = CharacterModel.create minimumCharacterOptions

      it "has a name", ->
        expect(@characterModel.name).to.equal minimumCharacterOptions.name

      it "has an alignment", ->
        expect(@characterModel.alignment).to.equal minimumCharacterOptions.alignment

      it "has an armor class", ->
        expect(@characterModel.armorClass).to.equal CharacterModel.DEFAULT_OPTIONS.armorClass

      it "has hit points", ->
        expect(@characterModel.hitPoints).to.equal CharacterModel.DEFAULT_OPTIONS.hitPoints

      it "is alive", ->
        expect(@characterModel.alive).to.equal true

    context "with extra options", ->
      extraCharacterOptions =
        armorClass: 11
        hitPoints: 6

      characterModelOptions = _.extend (_.extend {}, minimumCharacterOptions), extraCharacterOptions

      beforeEach ->
        @characterModel = CharacterModel.create characterModelOptions

      it "has an armor class", ->
        expect(@characterModel.armorClass).to.equal characterModelOptions.armorClass

      it "has hit points", ->
        expect(@characterModel.hitPoints).to.equal characterModelOptions.hitPoints

  context "during a battle", ->
    afterEach ->
      @enemyModel.dispose()

    minimumEnemyOptions =
      name: "Finn"
      alignment: "Good"

    context "when attacking", ->
      beforeEach ->
        @characterModel = CharacterModel.create minimumCharacterOptions

      context "a weaker enemy", ->
        enemyModelOptions = _.extend (_.extend {}, minimumEnemyOptions),
          armorClass: 1

        beforeEach ->
          @enemyModel = CharacterModel.create enemyModelOptions

        it "hits", ->
          sinon.stub @enemyModel, "wasHit"

          @characterModel.attack @enemyModel, 10

          sinon.assert.calledOnce @enemyModel.wasHit

          @enemyModel.wasHit.restore()

      context "a stronger enemy", ->
        enemyModelOptions = _.extend (_.extend {}, minimumEnemyOptions),
          armorClass: 20

        beforeEach ->
          @enemyModel = CharacterModel.create enemyModelOptions

        it "misses", ->
          sinon.stub @enemyModel, "wasHit"

          @characterModel.attack @enemyModel, 10

          sinon.assert.notCalled @enemyModel.wasHit

          @enemyModel.wasHit.restore()

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

          sinon.assert.calledWith @characterModel.wasHit, 1

          @characterModel.wasHit.restore()

        it "takes damage", ->
          @enemyModel.attack @characterModel, 15

          expect(@characterModel.hitPoints).to.equal characterModelOptions.hitPoints - 1

      context "a critical attack", ->
        it "gets hit", ->
          sinon.stub @characterModel, "wasHit"

          @enemyModel.attack @characterModel, 20

          sinon.assert.calledWith @characterModel.wasHit, 2

          @characterModel.wasHit.restore()

        it "takes damage", ->
          @enemyModel.attack @characterModel, 20

          expect(@characterModel.hitPoints).to.equal characterModelOptions.hitPoints - 2

    context "with 1 hit point", ->
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
