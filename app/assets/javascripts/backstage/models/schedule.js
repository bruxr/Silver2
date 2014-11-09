Backstage.Schedule = DS.Model.extend({
  cinema:         DS.belongsTo('cinema', {async: true}),
  movie:          DS.belongsTo('movie', {async: true}),
  screeningTime:  DS.attr('date'),
  format:         DS.attr('string'),
  ticketUrl:      DS.attr('string'),
  ticketPrice:    DS.attr('number'),
  room:           DS.attr('string')
});