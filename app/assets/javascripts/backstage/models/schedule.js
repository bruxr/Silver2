Backstage.Schedule = DS.Model.extend({
  cinema:         DS.belongsTo('cinema'),
  movie:          DS.belongsTo('movie'),
  screeningTime:  DS.attr('date'),
  format:         DS.attr('string'),
  ticketUrl:      DS.attr('string'),
  ticketPrice:    DS.attr('number'),
  room:           DS.attr('string')
});