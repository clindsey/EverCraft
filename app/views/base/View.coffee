# All other views should probably extend this.

# Useful for detecting memory leaks
module.exports = gamecore.DualPooled.extend "View",
    # Returns the number of objects of this type that currently exist in this object pool.
    getUsedLength: ->
      @getPool().getUsedList().count
  ,
    dispose: ->
      @release()
