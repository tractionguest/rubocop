# frozen_string_literal: true

RSpec.describe RuboCop::Cop::Style::KeywordArguments do
  subject(:cop) { described_class.new(config) }

  let(:config) { RuboCop::Config.new }

  it 'registers an offense when using more than one positional argument' do
    expect_offense(<<~RUBY)
      class C
        def candidate_method(bacon, cheese)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer only one positional argument per public method
        end
      end
    RUBY
  end

 
  it 'registers an offense when using more than one positional argument in a module' do
    expect_offense(<<~RUBY)
      module C
        def candidate_method(bacon, cheese)
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Prefer only one positional argument per public method
        end
      end
    RUBY
  end

  it 'does not register an offense when using keyword arguments after a public declaration' do
    expect_no_offenses(<<~RUBY)
      class C
        private

        def non_candidate_method(bacon)
        end

        public 
        def candidate_method(bacon:)
        end
      end
    RUBY
  end

  it 'does not register an offense when using keyword arguments' do
    expect_no_offenses(<<~RUBY)
      class C
        def candidate_method(bacon:)
        end
      end
    RUBY
  end

  it 'does not register an offense when using keyword arguments and one positional' do
    expect_no_offenses(<<~RUBY)
      class C
        def candidate_method(bacon, cheese:)
        end
      end
    RUBY
  end

  it 'does not register an offense when using positional arguments in a private method' do
    expect_no_offenses(<<~RUBY)
      class C
        def candidate_method(bacon:)
        end
        
        def non_candidate_method(bacon)
        end

        private :non_candidate_method
      end
    RUBY
  end

  it 'does not register an offense when using positional arguments in a private method' do
    expect_no_offenses(<<~RUBY)
      class C
        def candidate_method(bacon:)
        end
        
        private

        def non_candidate_method(bacon)
        end
      end
    RUBY
  end
end
