Silver = Ember.Application.create({
  Resolver: Ember.DefaultResolver.extend({
    // Pull templates from the backstage directory
    resolveTemplate: function(parsedName) {
      parsedName.fullNameWithoutType = 'ember/backstage/' + parsedName.fullNameWithoutType;
      return this._super(parsedName);
    }
  })
});