require 'rom/relation'

RSpec.describe ROM::Relation, '#to_ast' do
  let(:user_relation) do
    Class.new(ROM::Relation[:memory]) do
      schema(:users) do
        attribute :id, ROM::Types::Int
        attribute :name, ROM::Types::String
      end

      def self.name
        'Users'
      end
    end
  end

  let(:task_relation) do
    Class.new(ROM::Relation[:memory]) do
      schema(:tasks) do
        attribute :id, ROM::Types::Int
        attribute :user_id, ROM::Types::Int.meta(foreign_key: true, target: :users)
        attribute :title, ROM::Types::String
      end

      def self.name
        'Tasks'
      end
    end
  end

  let(:users) do
    user_relation.new([], name: ROM::Relation::Name[:users])
  end

  let(:tasks) do
    task_relation.new([], name: ROM::Relation::Name[:tasks])
  end

  it 'returns valid ast for a plain relation' do
    expect(users.to_ast).to eql(
      [:relation, [
        :users,
        [
          users.schema[:id].to_read_ast,
          users.schema[:name].to_read_ast
        ],
        { dataset: :users, alias: nil, model: false }
      ]]
    )
  end

  it 'returns valid ast for a combined relation' do
    relation = users.graph(tasks)

    expect(relation.to_ast).to eql(
      [:relation, [
        :users,
        [
          users.schema[:id].to_read_ast,
          users.schema[:name].to_read_ast,
          [:relation, [
            :tasks,
            [
                tasks.schema[:id].to_read_ast,
                tasks.schema[:user_id].to_read_ast,
                tasks.schema[:title].to_read_ast
            ],
            { dataset: :tasks, alias: nil, model: false }
          ]]
        ],
        { dataset: :users, alias: nil, model: false }
      ]]
    )
  end

  it 'returns valid ast for a wrapped relation' do
    # FIXME: seems like `wrap` is not nonsistent with `graph`
    relation = tasks.send(:wrap_class).new(tasks, [users])

    tasks_schema = tasks.schema
    users_schema = users.schema

    expect(relation.to_ast).to eql(
      [:relation, [
        :tasks,
        [
          tasks_schema[:id].to_read_ast,
          tasks_schema[:user_id].to_read_ast,
          tasks_schema[:title].to_read_ast,
          [:relation, [
            :users,
            [
                users_schema[:id].to_read_ast,
                users_schema[:name].to_read_ast,
            ],
            { dataset: :users, alias: nil, model: false }
          ]]
        ],
        { dataset: :tasks, alias: nil, model: false }
      ]]
    )
  end
end
