# frozen_string_literal: true

describe WebFetch::Storage::Redis do
  before(:all) do
    class MockRedisClient
      def initialize(*_args)
        @state = {}
      end

      def set(key, value, _options = {})
        @state[key] = value
      end

      def get(key)
        @state[key]
      end

      def del(key)
        @state.delete(key)
      end
    end
  end

  subject { described_class.new(MockRedisClient) }

  it_behaves_like 'a storage adapter'
end
