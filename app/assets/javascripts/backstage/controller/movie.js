Backstage.MovieController = Ember.ObjectController.extend({
  isEditing: false,
  
  mtrcbRatings: ['None', 'G', 'PG', 'R-13', 'R-16', 'R-18'],
  sourceTypes: ['metacritic', 'omdb', 'rt', 'tmdb'],
  
  isoReleaseDate: function(k, v) {
    if (arguments.length > 1) {
      this.set('model.releaseDate', new Date(v));
    }
    return this.get('model.releaseDate').toISOString().substring(0, 10);
  }.property('model.releaseDate'),
  
  name: function() {
    console.log(arguments);
    return this.get('model.title')
  }.property('model.title'),
  
  actions: {
    
    edit: function() {
      this.set('isEditing', true);
      $('.movie-popover').animate({scrollTop: 0}, 'fast');
    },
    
    doneEditing: function() {
      this.get('model').save().then(function() {
        this.set('isEditing', false);
      });
    },
    
    cancelEditing: function() {
      this.set('isEditing', false);
    },
    
    removeSource: function(source) {
      movie = this.get('model');
      movie.get('sources').removeObject(source);
      movie.save();
      source.deleteRecord();
      source.save();
    },
    
  }
  
});