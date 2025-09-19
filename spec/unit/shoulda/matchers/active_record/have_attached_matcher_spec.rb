require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveRecord::HaveAttachedMatcher, type: :model do
  describe 'have_one_attached' do
    describe '#description' do
      it 'returns the message with the name of the association' do
        matcher = have_one_attached(:avatar)
        expect(matcher.description).
          to eq('have a has_one_attached called avatar')
      end
    end

    context 'when the attached exists on the model' do
      it 'matches' do
        record = record_having_one_attached(:avatar)
        expect { have_one_attached(:avatar) }.
          to match_against(record).
          or_fail_with(<<-MESSAGE)
Did not expect User to have a has_one_attached called avatar, but it does.
        MESSAGE
      end

      context 'and the reader attribute does not exist' do
        it 'matches' do
          record = record_having_one_attached(:avatar, remove_reader: true)
          expect { have_one_attached(:avatar) }.
            not_to match_against(record).
            and_fail_with(<<-MESSAGE)
Expected User to have a has_one_attached called avatar, but this could not be proved.
  User does not have a :avatar method.
          MESSAGE
        end
      end

      context 'and the writer attribute does not exist' do
        it 'matches' do
          record = record_having_one_attached(:avatar, remove_writer: true)
          expect { have_one_attached(:avatar) }.
            not_to match_against(record).
            and_fail_with(<<-MESSAGE)
Expected User to have a has_one_attached called avatar, but this could not be proved.
  User does not have a :avatar= method.
          MESSAGE
        end
      end

      context 'and the attachments association does not exist' do
        it 'matches' do
          record = record_having_one_attached(:avatar, remove_attachments: true)
          expect { have_one_attached(:avatar) }.
            not_to match_against(record).
            and_fail_with(<<-MESSAGE)
Expected User to have a has_one_attached called avatar, but this could not be proved.
  Expected User to have a has_one association called avatar_attachment (no association called avatar_attachment)
          MESSAGE
        end
      end

      context 'and the blobs association is invalid' do
        it 'matches' do
          record = record_having_one_attached(:avatar, invalidate_blobs: true)
          expect { have_one_attached(:avatar) }.
            not_to match_against(record).
            and_fail_with(<<-MESSAGE)
Expected User to have a has_one_attached called avatar, but this could not be proved.
  Expected User to have a has_one association called avatar_blob through avatar_attachment (avatar_blob should resolve to ActiveStorage::Blob for class_name)
          MESSAGE
        end
      end

      context 'and the eager loading scope does not exist' do
        it 'matches' do
          record = record_having_one_attached(:avatar, remove_eager_loading_scope: true)
          expect { have_one_attached(:avatar) }.
            not_to match_against(record).
            and_fail_with <<-MESSAGE
Expected User to have a has_one_attached called avatar, but this could not be proved.
  User does not have a :with_attached_avatar scope.
          MESSAGE
        end
      end
    end

    context 'when specifying a service' do
      it 'matches when the service is correct' do
        record = record_having_one_attached(:avatar, options: { service: :local })
        expect { have_one_attached(:avatar).service(:local) }.
          to match_against(record).
          or_fail_with(<<-MESSAGE)
Did not expect User to have a has_one_attached called avatar with service :local, but it does.
          MESSAGE
      end

      it 'does not match when the service is incorrect' do
        record = record_having_one_attached(:avatar, options: { service: :local })
        expect { have_one_attached(:avatar).service(:foo) }.
          not_to match_against(record).
          and_fail_with(<<-MESSAGE)
Expected User to have a has_one_attached called avatar with service :foo, but this could not be proved.
  The service for the association called avatar_attachment is incorrect (expected: :foo, actual: :local)
          MESSAGE
      end

      it 'matches when no service is specified' do
        record = record_having_one_attached(:avatar, options: { service: :local })
        expect { have_one_attached(:avatar) }.
          to match_against(record).
          or_fail_with(<<-MESSAGE)
Did not expect User to have a has_one_attached called avatar, but it does.
          MESSAGE
      end
    end

    context 'when specifying strict loading option' do
      it 'matches when the strict loading option is correct' do
        record = record_having_one_attached(:avatar, options: { strict_loading: true })
        expect { have_one_attached(:avatar).strict_loading }.
          to match_against(record).
          or_fail_with(<<-MESSAGE)
Did not expect User to have a has_one_attached called avatar with strict_loading option set to true, but it does.
          MESSAGE
      end

      it 'does not match when the strict loading option is incorrect' do
        record = record_having_one_attached(:avatar, options: { strict_loading: true })
        expect { have_one_attached(:avatar).strict_loading(false) }.
          not_to match_against(record).
          and_fail_with(<<-MESSAGE)
Expected User to have a has_one_attached called avatar with strict_loading option set to false, but this could not be proved.
  Expected User to have a has_one association called avatar_blob through avatar_attachment (avatar_blob should have strict_loading set to false)
          MESSAGE
      end

      it 'matches when no strict loading option is specified' do
        record = record_having_one_attached(:avatar, options: { strict_loading: true })
        expect { have_one_attached(:avatar) }.
          to match_against(record).
          or_fail_with(<<-MESSAGE)
Did not expect User to have a has_one_attached called avatar, but it does.
          MESSAGE
      end
    end

    context 'when specifying a dependent option' do
      it 'matches when the dependent option is correct' do
        record = record_having_one_attached(:avatar, options: { dependent: :destroy })
        expect { have_one_attached(:avatar).dependent(:destroy) }.
          to match_against(record).
          or_fail_with(<<-MESSAGE)
Did not expect User to have a has_one_attached called avatar with dependent option set to :destroy, but it does.
          MESSAGE
      end

      it 'does not match when the dependent option is incorrect' do
        record = record_having_one_attached(:avatar, options: { dependent: :destroy })
        expect { have_one_attached(:avatar).dependent(:nullify) }.
          not_to match_against(record).
          and_fail_with(<<-MESSAGE)
Expected User to have a has_one_attached called avatar with dependent option set to :nullify, but this could not be proved.
  The dependent option for the association called avatar_attachment is incorrect (expected: :nullify, actual: :destroy)
          MESSAGE
      end

      it 'matches when no dependent option is specified' do
        record = record_having_one_attached(:avatar, options: { dependent: :destroy })
        expect { have_one_attached(:avatar) }.
          to match_against(record).
          or_fail_with(<<-MESSAGE)
Did not expect User to have a has_one_attached called avatar, but it does.
          MESSAGE
      end
    end
  end

  describe 'have_many_attached' do
    describe '#description' do
      it 'returns the message with the name of the association' do
        matcher = have_many_attached(:avatars)
        expect(matcher.description).
          to eq('have a has_many_attached called avatars')
      end
    end

    context 'when the attached exists on the model' do
      it 'matches' do
        record = record_having_many_attached(:avatars)
        expect { have_many_attached(:avatars) }.
          to match_against(record).
          or_fail_with(<<-MESSAGE)
Did not expect User to have a has_many_attached called avatars, but it does.
        MESSAGE
      end

      context 'and the reader attribute does not exist' do
        it 'matches' do
          record = record_having_many_attached(:avatars, remove_reader: true)
          expect { have_many_attached(:avatars) }.
            not_to match_against(record).
            and_fail_with(<<-MESSAGE)
Expected User to have a has_many_attached called avatars, but this could not be proved.
  User does not have a :avatars method.
          MESSAGE
        end
      end

      context 'and the writer attribute does not exist' do
        it 'matches' do
          record = record_having_many_attached(:avatars, remove_writer: true)
          expect { have_many_attached(:avatars) }.
            not_to match_against(record).
            and_fail_with(<<-MESSAGE)
Expected User to have a has_many_attached called avatars, but this could not be proved.
  User does not have a :avatars= method.
          MESSAGE
        end
      end

      context 'and the attachments association does not exist' do
        it 'matches' do
          record = record_having_many_attached(:avatars, remove_attachments: true)
          expect { have_many_attached(:avatars) }.
            not_to match_against(record).
            and_fail_with(<<-MESSAGE)
Expected User to have a has_many_attached called avatars, but this could not be proved.
  Expected User to have a has_many association called avatars_attachments (no association called avatars_attachments)
          MESSAGE
        end
      end

      context 'and the blobs association is invalid' do
        it 'matches' do
          record = record_having_many_attached(:avatars, invalidate_blobs: true)
          expect { have_many_attached(:avatars) }.
            not_to match_against(record).
            and_fail_with(<<-MESSAGE)
Expected User to have a has_many_attached called avatars, but this could not be proved.
  Expected User to have a has_many association called avatars_blobs through avatars_attachments (avatars_blobs should resolve to ActiveStorage::Blob for class_name)
          MESSAGE
        end
      end

      context 'and the eager loading scope does not exist' do
        it 'matches' do
          record = record_having_many_attached(:avatars, remove_eager_loading_scope: true)
          expect { have_many_attached(:avatars) }.
            not_to match_against(record).
            and_fail_with(<<-MESSAGE)
Expected User to have a has_many_attached called avatars, but this could not be proved.
  User does not have a :with_attached_avatars scope.
          MESSAGE
        end
      end
    end

    context 'when specifying a service' do
      it 'matches when the service is correct' do
        record = record_having_many_attached(:avatars, options: { service: :local })
        expect { have_many_attached(:avatars).service(:local) }.
          to match_against(record).
          or_fail_with(<<-MESSAGE)
Did not expect User to have a has_many_attached called avatars with service :local, but it does.
          MESSAGE
      end

      it 'does not match when the service is incorrect' do
        record = record_having_many_attached(:avatars, options: { service: :local })
        expect { have_many_attached(:avatars).service(:foo) }.
          not_to match_against(record).
          and_fail_with(<<-MESSAGE)
Expected User to have a has_many_attached called avatars with service :foo, but this could not be proved.
  The service for the association called avatars_attachments is incorrect (expected: :foo, actual: :local)
          MESSAGE
      end

      it 'matches when no service is specified' do
        record = record_having_many_attached(:avatars, options: { service: :local })
        expect { have_many_attached(:avatars) }.
          to match_against(record).
          or_fail_with(<<-MESSAGE)
Did not expect User to have a has_many_attached called avatars, but it does.
          MESSAGE
      end
    end

    context 'when specifying strict loading option' do
      it 'matches when the strict loading option is correct' do
        record = record_having_many_attached(:avatars, options: { strict_loading: true })
        expect { have_many_attached(:avatars).strict_loading }.
          to match_against(record).
          or_fail_with(<<-MESSAGE)
Did not expect User to have a has_many_attached called avatars with strict_loading option set to true, but it does.
          MESSAGE
      end

      it 'does not match when the strict loading option is incorrect' do
        record = record_having_many_attached(:avatars, options: { strict_loading: true })
        expect { have_many_attached(:avatars).strict_loading(false) }.
          not_to match_against(record).
          and_fail_with(<<-MESSAGE)
Expected User to have a has_many_attached called avatars with strict_loading option set to false, but this could not be proved.
  Expected User to have a has_many association called avatars_blobs through avatars_attachments (avatars_blobs should have strict_loading set to false)
          MESSAGE
      end

      it 'matches when no strict loading option is specified' do
        record = record_having_many_attached(:avatars, options: { strict_loading: true })
        expect { have_many_attached(:avatars) }.
          to match_against(record).
          or_fail_with(<<-MESSAGE)
Did not expect User to have a has_many_attached called avatars, but it does.
          MESSAGE
      end
    end

    context 'when specifying a dependent option' do
      it 'matches when the dependent option is correct' do
        record = record_having_many_attached(:avatars, options: { dependent: :destroy })
        expect { have_many_attached(:avatars).dependent(:destroy) }.
          to match_against(record).
          or_fail_with(<<-MESSAGE)
Did not expect User to have a has_many_attached called avatars with dependent option set to :destroy, but it does.
          MESSAGE
      end

      it 'does not match when the dependent option is incorrect' do
        record = record_having_many_attached(:avatars, options: { dependent: :destroy })
        expect { have_many_attached(:avatars).dependent(:nullify) }.
          not_to match_against(record).
          and_fail_with(<<-MESSAGE)
Expected User to have a has_many_attached called avatars with dependent option set to :nullify, but this could not be proved.
  The dependent option for the association called avatars_attachments is incorrect (expected: :nullify, actual: :destroy)
          MESSAGE
      end

      it 'matches when no dependent option is specified' do
        record = record_having_many_attached(:avatars, options: { dependent: :destroy })
        expect { have_many_attached(:avatars) }.
          to match_against(record).
          or_fail_with(<<-MESSAGE)
Did not expect User to have a has_many_attached called avatars, but it does.
          MESSAGE
      end
    end
  end
end

def record_having_one_attached(
  attached_name,
  model_name: 'User',
  remove_reader: false,
  remove_writer: false,
  remove_attachments: false,
  invalidate_blobs: false,
  remove_eager_loading_scope: false,
  options: {}
)
  model = define_model(model_name) do
    has_one_attached attached_name, **options

    if remove_reader
      undef_method attached_name
    end

    if remove_writer
      undef_method "#{attached_name}="
    end

    if remove_attachments
      if respond_to?(:normalized_reflections)
        clear_reflections_cache
        _reflections.delete("#{attached_name}_attachment".to_sym)
        normalized_reflections
      else
        reflections.delete("#{attached_name}_attachment")
      end
    end

    if invalidate_blobs
      reflections["#{attached_name}_blob"].options[:class_name] = 'User'
    end

    if remove_eager_loading_scope
      instance_eval <<-CODE, __FILE__, __LINE__ + 1
undef with_attached_#{attached_name}
      CODE
    end
  end

  model.new
end

def record_having_many_attached(
  attached_name,
  model_name: 'User',
  remove_reader: false,
  remove_writer: false,
  remove_attachments: false,
  invalidate_blobs: false,
  remove_eager_loading_scope: false,
  options: {}
)
  model = define_model(model_name) do
    has_many_attached attached_name, **options

    if remove_reader
      undef_method attached_name
    end

    if remove_writer
      undef_method "#{attached_name}="
    end

    if remove_attachments
      if respond_to?(:normalized_reflections)
        clear_reflections_cache
        _reflections.delete("#{attached_name}_attachments".to_sym)
        normalized_reflections
      else
        reflections.delete("#{attached_name}_attachments")
      end
    end

    if invalidate_blobs
      reflections["#{attached_name}_blobs"].options[:class_name] = 'User'
    end

    if remove_eager_loading_scope
      instance_eval <<-CODE, __FILE__, __LINE__ + 1
undef with_attached_#{attached_name}
      CODE
    end
  end

  model.new
end
