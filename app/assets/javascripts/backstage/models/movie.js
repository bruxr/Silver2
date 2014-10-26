Backstage.Movie = DS.Model.extend({
  title: 					 DS.attr('string'),
  slug: 					 DS.attr('string'),
	overview: 			 DS.attr('string'),
	runtime: 				 DS.attr('number'),
	aggregateScore:  DS.attr('number'),
	trailer: 				 DS.attr('string'),
	mtrcbRating: 	   DS.attr('string'),
  posterUrl:       DS.attr('string'),
  backdropUrl:     DS.attr('string'),
  scheduleCount:   DS.attr('number'),
  cinemaCount:     DS.attr('number'),
	createdAt:  		 DS.attr('date'),
	updatedAt:  		 DS.attr('date')
});