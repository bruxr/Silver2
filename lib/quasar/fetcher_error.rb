# Generic Fetcher class error
class Quasar::FetcherError < StandardError

  attr_reader :message

  def initialize(message)
    @message = message
  end

  def to_s
    @message
  end

end