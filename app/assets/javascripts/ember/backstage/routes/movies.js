Silver.MoviesRoute = Ember.Route.extend({
  model: function() {
    this.store.find('movie');
  }
});