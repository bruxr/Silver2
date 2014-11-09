Backstage.Cinema = DS.Model.extend({
  schedules:    DS.hasMany('schedule', {async: true}),
  name:         DS.attr('string'),
  slug:         DS.attr('string'),
  latitude:     DS.attr('number'),
  longitude:    DS.attr('number'),
  status:       DS.attr('string'),
  fetcher:      DS.attr('string'),
  phoneNumber:  DS.attr('string'),
  website:      DS.attr('string'),
  address:      DS.attr('string'),
  createdAt:    DS.attr('date'),
  updatedAt:    DS.attr('date')
})