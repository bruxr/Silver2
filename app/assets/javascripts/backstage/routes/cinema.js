Backstage.CinemaRoute = Ember.Route.extend({
  
  model: function(params) {
  	return this.store.find('cinema', params.id);
  },
  
  // Load each of our cinema's upcoming movie.
  // TODO: merge schedules & movies to store?
  afterModel: function(cinema, transition) {
    return $.getJSON('/api/cinemas/'+ cinema.id +'/schedules', function(resp) {
      skeds = []
      $.each(resp.schedules, function(i, v) {
        v.screeningTime = Date.parse(v);
        skeds.push(v)
      });
      cinema.set('movies', skeds);
    });
  },
  
  actions: {
    
    // Invoked when the slidein modal is closed
    // e.g. clicking the curtains
    close: function() {
      if (this.get('controller').get('isEditing') === true) {
        return;
      }
      else {
        this.transitionTo('movies');
      }
    }
    
  }
});