shared_examples_for 'ignoring_interference_by_writer' do |common_config|
  valid_tests = [
    :accept_if_qualified_but_changing_value_does_not_interfere,
    :reject_if_qualified_but_changing_value_interferes
  ]
  tests = common_config.fetch(:tests)
  tests.assert_valid_keys(valid_tests)

  define_method(:common_config) { common_config }

  context 'when the writer method for the attribute changes incoming values' do
    context 'and the value change does not cause a test failure' do
      config_for_test = tests[:accept_if_qualified_but_changing_value_does_not_interfere]

      if config_for_test
        it 'accepts (and does not raise an error)' do
          args = build_args(config_for_test)
          scenario = build_scenario_for_validation_matcher(args)
          matcher = matcher_from(scenario)

          expect(scenario.record).to matcher
        end
      end
    end

    context 'and the value change causes a test failure' do
      config_for_test = tests[:reject_if_qualified_but_changing_value_interferes]

      if config_for_test
        it 'lists how the value got changed in the failure message' do
          args = build_args(config_for_test)
          scenario = build_scenario_for_validation_matcher(args)
          matcher = matcher_from(scenario)

          assertion = lambda do
            expect(scenario.record).to matcher
          end

          if config_for_test.key?(:expected_message_includes)
            message = config_for_test[:expected_message_includes]
            expect(&assertion).to fail_with_message_including(message)
          else
            message = config_for_test.fetch(:expected_message)
            expect(&assertion).to fail_with_message(message)
          end
        end
      end
    end
  end

  def build_args(config_for_test)
    args_from_common_config.merge(args_from_config_for_test(config_for_test))
  end

  def args_from_common_config
    common_config.slice(
      :column_type,
      :model_creator,
    )
  end

  def args_from_config_for_test(config)
    config.slice(
      :attribute_name,
      :attribute_overrides,
      :changing_values_with,
      :default_value,
      :model_name,
    )
  end

  def matcher_from(scenario)
    scenario.matcher.tap do |matcher|
      if respond_to?(:configure_validation_matcher)
        configure_validation_matcher(matcher)
      end
    end
  end
end
