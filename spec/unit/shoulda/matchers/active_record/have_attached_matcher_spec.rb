require 'unit_spec_helper'

describe Shoulda::Matchers::ActiveRecord::HaveAttachedMatcher, type: :model do
  if active_record_supports_active_storage?
    before do
      create_table :active_storage_blobs do |t|
        t.string :key, null: false
        t.string :filename, null: false
        t.string :content_type
        t.text :metadata
        t.bigint :byte_size, null: false
        t.string :checksum, null: false
        t.datetime :created_at, null: false

        t.index [:key], unique: true
      end

      create_table :active_storage_attachments do |t|
        t.string :name, null: false
        t.references :record, null: false, polymorphic: true, index: false
        t.references :blob, null: false

        t.datetime :created_at, null: false

        t.index [:record_type, :record_id, :name, :blob_id],
          name: 'index_active_storage_attachments_uniqueness', unique: true

        # The original rails migration has a foreign key.
        # Since this messes up the clearing of the database, it's removed here.
        # t.foreign_key :active_storage_blobs, column: :blob_id
      end
    end

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
  remove_eager_loading_scope: false
)
  model = define_model(model_name) do
    has_one_attached attached_name

    if remove_reader
      undef_method attached_name
    end

    if remove_writer
      undef_method "#{attached_name}="
    end

    if remove_attachments
      reflections.delete("#{attached_name}_attachment")
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
  remove_eager_loading_scope: false
)
  model = define_model(model_name) do
    has_many_attached attached_name

    if remove_reader
      undef_method attached_name
    end

    if remove_writer
      undef_method "#{attached_name}="
    end

    if remove_attachments
      reflections.delete("#{attached_name}_attachments")
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
