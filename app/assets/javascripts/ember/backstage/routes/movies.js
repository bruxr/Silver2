Silver.MoviesRoute = Ember.Route.extend({
  model: function() {
    return this.store.findAll('movie');
  }
});