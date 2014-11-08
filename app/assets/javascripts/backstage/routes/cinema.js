Backstage.CinemaRoute = Ember.Route.extend({
  
  model: function(params) {
  	return this.store.find('cinema', params.id);
  },
  
  // Load each of our cinema's upcoming movie.
  afterModel: function(cinema, transition) {
    var store = this.store;
    return $.getJSON('/api/cinemas/'+ cinema.id +'/schedules', function(resp) {
      $.each(resp, function() {
        var i = Backstage.Utils.unserialize(this);
        store.push('schedule', i);
      });
    });
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