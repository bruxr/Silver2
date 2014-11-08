Backstage.CinemaRoute = Ember.Route.extend({
  
  model: function(params) {
  	return this.store.find('cinema', params.id);
  },
  
  afterModel: function(cinema, transition) {
    cinema.reload();
  },
  
  actions: {
    
    // Invoked when the slidein modal is closed
    // e.g. clicking the curtains
    close: function() {
      this.get('controller').set('isEditing', false);
      this.transitionTo('cinemas');
    }
    
  }
});