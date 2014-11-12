Backstage.MovieView = Ember.View.extend({
  name: 'movie',
  templateName: 'movie',
  
  // Slide in the modal & fade in the curtains
  // when our view is in the DOM.
  animateIn: function(done) {
    this.$('.movie.paper').velocity({
      properties: { right: 0 },
      options: {
        duration: 300,
        easing: 'easeOutQuint'
      }
    });
    this.$('.curtains').css('display', 'block')
                       .velocity({
                         properties: { opacity: 1 },
                         options: {
                           duration: 150,
                           easing: 'easeIn',
                           complete: done
                         }
                       });
  },
  
  animateOut: function(done) {
    this.$('.movie.paper').velocity('reverse');
    this.$('.curtains').velocity('reverse', { complete: done });
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