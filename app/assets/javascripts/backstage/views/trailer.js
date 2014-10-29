Backstage.TrailerView = Ember.View.extend({
  name: 'trailer',
  templateName: 'trailer',
  
  didInsertElement: function() {
    this._super();
    var playBtn = this.$('.play-btn');
    this.$('.fadein').on('load', function() {
      $(this).velocity({
        properties: { opacity: 1 },
        options: {
          easing: 'easeInOutElastic',
          duration: 300,
          complete: function() {
            playBtn.addClass('ready');
          }
        }
      });
    });
  },
  
  playTrailer: function() {
    var trailer = this.get('controller').get('trailer');
    var iframe = '<iframe src="https://www.youtube.com/embed/%s?autoplay=1&controls=0&iv_load_policy=3&modestbranding=1&rel=0&showinfo=0" width="640" height="350" frameborder="0"></iframe>'.replace('%s', trailer);
    this.$('img,.play-btn').hide();
    this.$('.movie-trailer').append(iframe);
  },
  
  click: function(event) {
    event.preventDefault();
    var el = $(event.target);
    if (el.hasClass('fa-play')) {
      this.playTrailer();
    }
  },
});