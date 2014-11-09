require 'test_helper'

class ScheduleTest < ActiveSupport::TestCase

  test 'should accept a non-hash ticket price' do
    c = Schedule.new
    c.ticket_price = 150
    assert_equal(150, c.ticket_price.to_i)
  end

end
