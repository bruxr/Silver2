Backstage.MovieController = Ember.ObjectController.extend({
  isEditing: false,
  mtrcbRatings: ['G', 'PG', 'R-13', 'R-16', 'R-18'],
  trailerUrl: function() {
    return 'http://www.youtube.com/watch?v='+ this.get('trailer');
  }.property('trailer'),
  
  actions: {
    edit: function() {
      this.set('isEditing', true);
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