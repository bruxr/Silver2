Backstage.Schedule = DS.Model.extend({
  cinema:         DS.belongsTo('cinema'),
  movie:          DS.belongsTo('movie'),
  screening_time: DS.attr('date'),
  format:         DS.attr('string'),
  ticket_url:     DS.attr('string'),
  ticket_price:   DS.attr('number'),
  room:           DS.attr('room')
});