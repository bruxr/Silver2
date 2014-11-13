Backstage.MovieView = Ember.View.extend({
  name: 'movie',
  templateName: 'movie',
  uploadersReady: false,
  isEditing: Ember.computed.alias('controller.isEditing'),
  
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
  
  willEdit: function() {
    if (this.get('isEditing')) {
      
      if (this.get('uploadersReady') === true) return;
      
      $('.movie-media-replace').each(function() {
        var el = $(this),
            type = el.data('media-type');
        el.mirror({
          mirrorTo: el.data('mirror-to'),
          url: Backstage.api_url('movies', this.get('controller.id'), 'upload_'+ type)
        });
      });
      this.set('uploadersReady', true);
      
    }
  }.observes('isEditing'),
  
  // Clicking the curtains will close
  // the modal & go back to the movies route.
  click: function(event) {
    var t = $(event.target);
    if (t.hasClass('curtains')) {
      this.controller.send('close');
    }
  }
  
});