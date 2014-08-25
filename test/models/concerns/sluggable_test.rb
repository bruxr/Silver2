require 'test_helper'

class SluggableConcernTest < ActiveSupport::TestCase
  
  test 'should not be able to set custom slugs' do
    model = Movie.new
    assert_raises(RuntimeError) do
      model.slug = 'custom-slug'
    end
  end

  test 'should automatically set a slug' do
    model = Movie.new
    model.title = 'Chronicles: Brux & %#%^(Friends @ Party'
    model.save
    assert_equal('chronicles-brux-and-friends-at-party', model.slug)
  end

end
