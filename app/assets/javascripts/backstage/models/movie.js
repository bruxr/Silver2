Backstage.Movie = DS.Model.extend({
  schedules:       DS.hasMany('schedule', {async: true}),
  sources:         DS.hasMany('source'),
  title: 					 DS.attr('string'),
  slug: 					 DS.attr('string'),
	overview: 			 DS.attr('string'),
	runtime: 				 DS.attr('number'),
	aggregateScore:  DS.attr('number'),
	trailer: 				 DS.attr('string'),
	mtrcbRating: 	   DS.attr('string'),
  posterUrl:       DS.attr('string'),
  backdropUrl:     DS.attr('string'),
  tagline:         DS.attr('string'),
  website:         DS.attr('string'),
  releaseDate:     DS.attr('date'),
  genres:          DS.attr(),
  cast:            DS.attr(),
	createdAt:  		 DS.attr('date'),
	updatedAt:  		 DS.attr('date'),
  partial:         DS.attr('boolean'),
  
  updateScores: function() {
    
    var url = '/api/movies/%d/update_scores'.replace('%d', this.get('id')),
        self = this;
    
    $.post(url, function(resp) {
      if (resp.status == 'ok') {
        setTimeout(self.reload, 5000); // reload model after 5 secs.
      }
    }, 'json');
    
  }
});