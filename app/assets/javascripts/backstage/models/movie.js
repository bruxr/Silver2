Backstage.Movie = DS.Model.extend({
  title: 					 DS.attr('string'),
  slug: 					 DS.attr('string'),
	overview: 			 DS.attr('string'),
	runtime: 				 DS.attr('number'),
	aggregateScore:  DS.attr('number'),
	trailer: 				 DS.attr('string'),
	mtrcbRating: 	   DS.attr('string'),
	createdAt:  		 DS.attr('date'),
	updatedAt:  		 DS.attr('date')
});