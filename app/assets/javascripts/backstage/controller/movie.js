Backstage.MovieController = Ember.ObjectController.extend({
  isEditing: false,
  mtrcbRatings: ['G', 'PG', 'R-13', 'R-16', 'R-18'],
  trailerUrl: function() {
    return 'http://www.youtube.com/watch?v='+ this.get('trailer');
  }.property('trailer'),
  
  isoReleaseDate: function() {
    return moment(this.get('releaseDate')).toISOString().substring(0, 10);
  }.property('releaseDate'),
  
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
    }
  }
  
});