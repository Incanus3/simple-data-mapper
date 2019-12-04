module SimpleDM
  class Query
    attr_reader :filters, :limit

    def initialize(filters: {}, limit: nil)
      @filters = filters
      @limit   = limit
    end
  end
end
