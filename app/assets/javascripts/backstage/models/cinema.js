Backstage.Cinema = DS.Model.extend({
  name:       DS.attr('string'),
  slug:       DS.attr('string'),
  latitude:   DS.attr('number'),
  longitude:  DS.attr('number'),
  status:     DS.attr('string'),
  fetcher:    DS.attr('string'),
  createdAt:  DS.attr('date'),
  updatedAt:  DS.attr('date')
})