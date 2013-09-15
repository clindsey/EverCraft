(function() {
  var initializeModule, r;

  if (window.require == null) {
    initializeModule = function(module) {
      try {
        module.state = 'initializing';
        module.initializer(r, module);
        return module.state = 'initialized';
      } catch (error) {
        throw new r.ModuleInitializerException(module.name, error);
      }
    };
    r = window.require = function(moduleName) {
      var module;
      module = r.cache[moduleName];
      if (module != null) {
        if (module.state === 'initializing') {
          throw new r.ModuleInitializerException(module.name, "Circular reference");
        } else if (module.state === 'registered') {
          initializeModule(module);
        }
        return module.exports;
      } else {
        throw new r.MissingModuleException(moduleName);
      }
    };
    r.cache = {};
    r.register = function(moduleName, initializer) {
      return r.cache[moduleName] = {
        name: moduleName,
        initializer: initializer,
        state: 'registered',
        exports: null
      };
    };
    r.MissingModuleException = (function() {

      function MissingModuleException(moduleName) {
        this.moduleName = moduleName;
        this.message = "Cannot find module '" + this.moduleName + "'";
        if (typeof console !== "undefined" && console !== null) {
          console.error(this.message);
        }
      }

      return MissingModuleException;

    })();
    r.MissingModuleException.prototype = new Error();
    r.MissingModuleException.prototype.constructor = r.MissingModuleException;
    r.ModuleInitializerException = (function() {

      function ModuleInitializerException(moduleName, innerException) {
        this.moduleName = moduleName;
        this.innerException = innerException;
        this.message = ("Error initializing module '" + this.moduleName + "': ") + this.innerException;
        if (typeof console !== "undefined" && console !== null) {
          console.error(this.message);
        }
      }

      return ModuleInitializerException;

    })();
    r.ModuleInitializerException.prototype = new Error();
    r.ModuleInitializerException.prototype.constructor = r.ModuleInitializerException;
  }

}).call(this);