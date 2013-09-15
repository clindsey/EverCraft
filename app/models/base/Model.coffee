# The base model which all other models should probably extend.

# Used because for memory leak deletection.
module.exports = gamecore.DualPooled.extend "Model",
    # Returns the number of objects of this type that currently exist in this object pool.
    getUsedLength: ->
      @getPool().getUsedList().count
  ,
    dispose: ->
      @release()
