# frozen_string_literal: true

describe WebFetch::Storage::Memcached do
  before(:all) do
    class MockDalliClient
      def initialize(*_args)
        @state = {}
      end

      def set(key, value)
        @state[key] = value
      end

      def get(key)
        @state[key]
      end

      def delete(key)
        @state.delete(key)
      end
    end
  end

  subject { described_class.new(MockDalliClient) }

  it_behaves_like 'a storage adapter'
end
