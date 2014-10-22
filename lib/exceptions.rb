module Exceptions
  
  # Raised whenever a deprecated method is invoked
  class DeprecatedMethod < StandardError
  end
  
  # Raised when we reach a web service's quota.
  class QuotaReached < StandardError
    
    def initialize(service)
      @service = service
    end
    
    def message
      "Reached quota for #{@service}."
    end
    
  end
  
end