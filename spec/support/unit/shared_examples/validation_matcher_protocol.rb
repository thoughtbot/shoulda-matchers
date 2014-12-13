shared_examples_for 'a validation matcher' do
  subject { described_class }

  it { should have_instance_method(:initialize).with_arity(1) }
  it { should have_instance_method(:with_message).with_arity(1) }
  # it { should have_instance_method(:on).with_arity(1) }
  # it { should have_instance_method(:strict).with_arity(0) }
end
