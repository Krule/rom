require 'addressable/uri'

module ROM
  # Abstract repository class
  #
  # @api public
  class Repository
    # Return connection object
    #
    # @return [Object] type varies depending on the repository
    #
    # @api public
    attr_reader :connection

    # @api private
    def self.inherited(klass)
      Repository.registered.unshift(klass)
    end

    # @api private
    def self.registered
      @__registered__ ||= []
    end

    # Setup a repository instance with the given connection URI
    #
    # @example
    #
    #   Repository = Class.new(ROM::Repository) do
    #     def self.schemes
    #       [:foo]
    #     end
    #   end
    #
    #   repository = Repository.setup(:foo, 'mysql://localhost/test')
    #
    #   repository.uri.scheme # => 'mysql'
    #   repository.uri.host # => 'localhost'
    #   repository.uri.path # => '/test'
    #
    # @param [Symbol,Repository] repository_or_scheme
    # @param [String] uri_string
    # @param [Hash] options
    #
    # @return [Repository]
    #
    # @api public
    def self.setup(repository_or_scheme, *args)
      case repository_or_scheme
      when String
        fail ArgumentError, <<-STRING.gsub(/^ {10}/, '')
          URIs without an explicit scheme are not supported anymore.
          See https://github.com/rom-rb/rom/blob/master/CHANGELOG.md
        STRING
      when Symbol
        class_from_symbol(repository_or_scheme).new(*args)
      else
        args.empty? ? repository_or_scheme : fail(
          ArgumentError,
          "Can't accept uri or options to repository when passing an instance"
        )
      end
    end

    # @api private
    def self.class_from_symbol(sym)
      self[sym] || fail(
        ArgumentError, "#{sym.inspect} scheme is not supported"
      )
    end

    # Return repository class for the given scheme
    #
    # @see Repository.register
    #
    # @return [Class] repository class
    #
    # @api public
    def self.[](type)
      registered.detect do |repository|
        repository.schemes.include?(type.to_sym)
      end
    end

    # @api public
    def use_logger(*)
      # noop
    end

    # @api public
    def logger
      # noop
    end

    # Hook called in constructor so that specialized repositorys can implement
    # setting up their connections without the need to override constructor
    #
    # @api private
    def setup
      # noop
    end

    # Extension hook for adding repository-specific behavior to a relation class
    #
    # @param [Class] klass Relation class generated by ROM
    #
    # @return [Class] extended relation class
    #
    # @api public
    def extend_relation_class(klass)
      klass
    end

    # Extension hook for adding repository-specific behavior to a relation instance
    #
    # @param [Relation] relation
    #
    # @return [Relation] extended relation instance
    #
    # @api public
    def extend_relation_instance(relation)
      relation
    end

    # Builds a command
    #
    # @param [Symbol] name of the command
    # @param [Relation] relation used by the command
    # @param [CommandDSL::Definition] command definition object
    #
    # @return [Object] created command instance
    #
    # @api public
    def command(name, relation, definition)
      type = definition.type || name

      klass =
        case type
        when :create then command_namespace.const_get(:Create)
        when :update then command_namespace.const_get(:Update)
        when :delete then command_namespace.const_get(:Delete)
        else
          raise ArgumentError, "#{type.inspect} is not a supported command type"
        end

      klass.new(relation, definition.to_h)
    end

    # Schema inference hook
    #
    # Every repository that supports schema inference should implement this method
    #
    # @return [Array] array with datasets and their names
    #
    # @api private
    def schema
      []
    end

    # Disconnect is optional and it's a no-op by default
    #
    # @api public
    def disconnect
      # noop
    end

    # Return namespace with repository-specific command classes
    #
    # @return [Module]
    #
    # @api private
    def command_namespace
      self.class.const_get(:Commands)
    end
  end
end
