Backstage.MovieSerializer = DS.RESTSerializer.extend(DS.EmbeddedRecordsMixin, {
  attrs: {
    sources: { embedded: 'always' },
    schedules: { embedded: 'always' }
  }
});