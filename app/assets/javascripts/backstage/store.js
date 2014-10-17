// Let Ember know that our REST API is at /api
Backstage.ApplicationAdapter = DS.RESTAdapter.extend({
	namespace: 'api'
});