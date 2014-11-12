Backstage.SchedulesRoute = Ember.Route.extend({
  
  queryParams: {
    page: { refreshModel: true },
    date: { refreshModel: true },
    cinema: { refreshModel: true },
    movie: { refreshModel: true }
  },
  
  movies: null,
  cinemas: null,
  
  model: function(params) {
  	return this.store.find('schedule', params);
  },
  
  afterModel: function() {
    var self = this;
    
    if (self.get('movies') !== null) {
      return true // skip if we already cached the movies
    }
    
    return new Promise(function(resolve, reject) {
      $.when(
        $.getJSON('/api/movies?type=list', function(resp) {
          var movies = resp.movies
          movies.unshift({id: -1, title: 'Movie'})
          self.set('movies', movies);
        }),
        $.getJSON('/api/cinemas?type=list', function(resp) {
          var cinemas = resp.cinemas
          cinemas.unshift({id: -1, name: 'Cinema'})
          self.set('cinemas', cinemas);
        })
      ).then(resolve);
    });
  },
  
  setupController: function(controller, model) {
    controller.set('movies', this.get('movies'));
    controller.set('cinemas', this.get('cinemas'));
    this._super(controller, model);
  }
  
});