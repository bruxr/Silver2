Backstage = Ember.Application.create({
  Resolver: Ember.DefaultResolver.extend({
    // Pull templates from the backstage directory
    resolveTemplate: function(parsedName) {
      parsedName.fullNameWithoutType = 'backstage/' + parsedName.fullNameWithoutType;
      return this._super(parsedName);
    }
  })
});