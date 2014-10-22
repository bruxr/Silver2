Backstage.MoviesRoute = Ember.Route.extend({
  model: function(params) {
  	return this.store.find('movie')
  }
});