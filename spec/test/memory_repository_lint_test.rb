require 'rom/memory'
require 'rom/adapter/lint/test'

require 'minitest/autorun'

class MemoryRepositoryLintTest < Minitest::Test
  include ROM::Adapter::Lint::TestRepository

  def repository_instance
    ROM::Memory::Repository.new
  end
end

class MemoryAdapterDatasetLintTest < Minitest::Test
  include ROM::Adapter::Lint::TestEnumerableDataset

  def setup
    @data  = [{ name: 'Jane', age: 24 }, { name: 'Joe', age: 25 }]
    @dataset = ROM::Memory::Dataset.new(@data)
  end
end
