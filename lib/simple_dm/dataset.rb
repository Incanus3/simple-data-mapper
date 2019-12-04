require_relative './query'

module SimpleDM
  class Dataset
    def initialize(data_provider, group_name, mapper:, **query_options)
      @data_provider = data_provider
      @group_name    = group_name
      @mapper        = mapper
      @query         = Query.new(**query_options)
    end

    def to_a
      data_provider.fetch(group_name, query).map(&mapper)
    end

    private

    attr_reader :data_provider, :group_name, :mapper, :query
  end
end
