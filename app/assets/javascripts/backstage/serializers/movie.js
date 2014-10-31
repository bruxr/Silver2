Backstage.MovieSerializer = DS.ActiveModelSerializer.extend(DS.EmbeddedRecordsMixin, {
  attrs: {
    sources: { embedded: 'always' },
    schedules: { embedded: 'always' }
  }
});