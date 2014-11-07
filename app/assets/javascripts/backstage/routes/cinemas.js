Backstage.CinemasRoute = Ember.Route.extend({
  model: function(params) {
  	return this.store.find('cinema');
  }
});