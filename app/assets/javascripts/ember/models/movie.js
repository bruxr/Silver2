Silver.Movie = DS.Model.extend({
  title: DS.attr('string'),
  slug: DS.attr('string'),
  poster: DS.attr('string'),
  poster_url: DS.attr('string'),
  schedules_count: DS.attr('number', {default_value: 0}),
  schedules_cinema_count: DS.attr('number', {default_value: 0}),
  type: DS.attr('string')
})