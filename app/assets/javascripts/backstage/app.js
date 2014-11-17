Backstage = Ember.Application.create({
  Resolver: Ember.DefaultResolver.extend({
    // Pull templates from the backstage directory
    resolveTemplate: function(parsedName) {
      parsedName.fullNameWithoutType = 'backstage/' + parsedName.fullNameWithoutType;
      return this._super(parsedName);
    }
  }),
  LOG_TRANSITIONS: true,
  LOG_VIEW_LOOKUPS: true,
  
  // Builds a URL to Silver's JSON API.
  // Usage:
  // Backstage.api_url('movies', '1') -> /api/movies/1
  api_url: function() {
    return '/api/' + arguments.join('/')
  }
});

Quasar = {} || Quasar;