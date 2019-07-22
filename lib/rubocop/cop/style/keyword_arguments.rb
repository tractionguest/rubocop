# frozen_string_literal: true

require 'byebug'
require 'ap'

# TODO: when finished, run `rake generate_cops_documentation` to update the docs
module RuboCop
  module Cop
    module Style
      # TODO: Write cop description and example of bad / good code. For every
      # `SupportedStyle` and unique configuration, there needs to be examples.
      # Examples must have valid Ruby syntax. Do not use upticks.
      #
      # @example EnforcedStyle: bar (default)
      #   # Description of the `bar` style.
      #
      #   # bad
      #   bad_bar_method
      #
      #   # bad
      #   bad_bar_method(args)
      #
      #   # good
      #   good_bar_method
      #
      #   # good
      #   good_bar_method(args)
      #
      # @example EnforcedStyle: foo
      #   # Description of the `foo` style.
      #
      #   # bad
      #   bad_foo_method
      #
      #   # bad
      #   bad_foo_method(args)
      #
      #   # good
      #   good_foo_method
      #
      #   # good
      #   good_foo_method(args)
      #
      class KeywordArguments < Cop
        MSG = 'Prefer only one positional argument per public method'.freeze

        def on_class(node)
          check_node(node)
        end

        def on_module(node)
          check_node(node)
        end

        private

        def check_node(node)
            find_suspect_methods(node).each do |_k, candidate_method|
              pos_args = positional_arguments(candidate_method.arguments)
              next if pos_args.count < 2 # One positional argument is fine

              pos_args.each { |positional_arg|
                add_offense(candidate_method)              
              }
          end
        end

        def positional_arguments(arguments)
          arg_positions = []

          arguments.each_with_index do |argument, index|
            arg_positions << index if argument.arg_type?
          end

          arg_positions
        end

        def find_suspect_methods(node, modifier = :public)
          suspect_methods = {}
          private_modified_methods = []

          node.each_child_node do |child|
            case child.type
            when :send
              private_modified_methods.append(modified_private_methods(child)) if child.non_bare_access_modifier?
              modifier = child.method_name if access_modifier?(child)
            when :def
              suspect_methods[child.method_name] = child if modifier != :private 
            when :defs
              suspect_methods[child.method_name] = child if modifier != :private 
            when :kwbegin
              suspect_methods.merge(find_suspect_methods(child, modifier))
            end
          end
          private_modified_methods.flatten.each { |modified_method|
            suspect_methods.delete(modified_method)
          }
          suspect_methods
        end

        def modified_private_methods(node)
          return [] unless node.method_name == :private

          node.arguments.map do |argument|
            argument.value
          end
        end

        def private_modifier?(node)
          node.access_modifier?
        end

        def access_modifier?(node)
          node.bare_access_modifier? && !node.method?(:module_function)
        end
      end
    end
  end
end
