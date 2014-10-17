// Let Ember know that our REST API is at /api
Backstage.ApplicationAdapter = DS.ActiveModelAdapter.extend({
	namespace: 'api'
});