require 'test_helper'

class ScheduleTest < ActiveSupport::TestCase

  test 'old schedules scope' do
    sked = Schedule.old.first
    assert_equal('IMAX', sked.format)
  end

  test 'archiving old records' do
    count = Schedule.archive_old_records
    assert_equal(1, count)
  end

end
