shared_examples_for 'a matcher' do
  subject { described_class }

  it { should have_instance_method(:description).with_arity(0) }
  it { should have_instance_method(:matches?).with_arity(1) }
  it { should have_instance_method(:failure_message).with_arity(0) }
  it { should have_instance_method(:failure_message).with_arity(0) }

  it do
    should alias_instance_method(:failure_message).
      to(:failure_message_for_should)
  end

  it do
    should alias_instance_method(:failure_message_when_negated).
      to(:failure_message_for_should_not)
  end
end
