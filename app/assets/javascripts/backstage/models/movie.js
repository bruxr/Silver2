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
  tagline:         DS.attr('string'),
  website:         DS.attr('string'),
  releaseDate:     DS.attr('date'),
  genres:          DS.attr(),
  cast:            DS.attr(),
	createdAt:  		 DS.attr('date'),
	updatedAt:  		 DS.attr('date')
});