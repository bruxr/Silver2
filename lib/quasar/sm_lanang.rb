# A Quasar Fetcher for SM City Davao Cinemas
# Instantiate and invoke get_schedules() to 
# return an array of screening times.
# 
# Take note that SM only publishes screening times
# after the current date & time. Be sure to 
# fetch them before the start of each day!
class Quasar::SmLanang < Quasar::SmFetcher

  def initialize
    @branch_code = 'SMLA'
    @schedules = []
  end

end