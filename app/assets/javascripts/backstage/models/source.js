Backstage.Source = DS.Model.extend({
  movie:        DS.belongsTo('movie'),
  name:         DS.attr('string'),
  external_id:  DS.attr('string'),
  url:          DS.attr('string'),
  score:        DS.attr('number')
})