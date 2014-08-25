module Sluggable
  extend ActiveSupport::Concern

  included do
    before_create :create_slug
    class_attribute :slug_for
  end

  # Prevent outsiders from setting a slug.
  def slug=(value)
    raise "Custom slugs are not allowed."
  end

  protected

    # Creates
    def create_slug

      source_str = read_attribute(self.slug_for)
      slug = self.class.to_slug(source_str)
      write_attribute(:slug, slug)

    end

  module ClassMethods

    # Slugify "macro" which automatically
    # creates slugs for a field before saving.
    #
    # To use, put this inside your models:
    # slugify :title
    # to automatically create slugs for title to the slug field
    def slugify(field)

      self.slug_for = field

    end

    # Creates human & URL friendly strings
    # e.g. hello-i-am-a-slug
    # Thank you klochner!
    # http://stackoverflow.com/questions/1302022/best-way-to-generate-slugs-human-readable-ids-in-rails
    def to_slug(str)

      #strip and downcase the string
      ret = str.strip.downcase

      #blow away apostrophes
      ret.gsub! /['`]/,""

      # @ --> at, and & --> and
      ret.gsub! /\s*@\s*/, " at "
      ret.gsub! /\s*&\s*/, " and "

      #replace all non alphanumeric, underscore or periods with underscore
      ret.gsub! /\s*[^A-Za-z0-9\.\-]\s*/, '-'  

      #convert double underscores to single
      ret.gsub! /\-+/,"-"

      #strip off leading/trailing underscore
      ret.gsub! /\A[-\.]+|[-\.]+\z/,""

      ret

    end

  end

end