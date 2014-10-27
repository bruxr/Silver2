Backstage.MovieRoute = Ember.Route.extend({
  model: function(params) {
  	return this.store.find('movie', params.id);
  },
  actions: {
    
    // Invoked when the slidein modal is closed
    // e.g. clicking the curtains
    close: function() {
      this.transitionTo('movies');
    }
    
  }
});