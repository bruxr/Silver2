Backstage.MovieView = Ember.View.extend({
  name: 'movie',
  templateName: 'movie',
  
  // Slide in the modal & fade in the curtains
  // when our view is in the DOM.
  didInsertElement: function() {
    this.$('.movie-popover').addClass('shown');
    this.$('.curtains').addClass('shown');
  },
  
  willDestroyElement: function() {
    this.$('.movie-popover').removeClass('shown');
    this.$('.curtains').removeClass('shown');
  },
  
  // Clicking the curtains will close
  // the modal & go back to the movies route.
  click: function(event) {
    var t = $(event.target)
    if (t.hasClass('curtains')) {
      this.controller.send('close');
    }
  }
  
});