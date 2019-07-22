# frozen_string_literal: true

module RuboCop
  module Cop
    module Style
      # This cop checks for multiple positional arguments on public methods.
      # More than one positional argument on a public method requires too much
      # knowledge about the method for consumers to safely or realistically consume.
      # It does not care about private or protected methods.
      #
      # @example EnforcedStyle:
      #   # bad
      #   def bad_method(positional_argument, another_positional_argument); end
      #
      #   # good
      #   def good_method(named_argument:, another_named_argument:); end
      #   
      #   # good
      #   def good_method(positional_argument, named_argument:); end
      #   
      #   # good
      #   def good_method(positional_argument); end
      #
      #   # good
      #   def setter=(value); end
      #
      class KeywordArguments < Cop
        MSG = 'Prefer only one positional argument per public method.'.freeze

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
