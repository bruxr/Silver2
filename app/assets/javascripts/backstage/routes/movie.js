Backstage.MovieRoute = Ember.Route.extend({
  model: function(params) {
  	return this.store.find('movie', params.id);
  },
  actions: {
    didTransition: function() {
      $('.movie-popover').addClass('shown');
      $('.curtains').addClass('shown');
    }
  }
});