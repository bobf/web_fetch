# frozen_string_literal: true

describe WebFetch::Validatable do
  class ConcernedInvalid
    include ::WebFetch::Validatable
    def validate
      error(:bad_json)
      error(:missing_url)
      error(:requests_empty, 'Hello there')
    end
  end

  class ConcernedValid
    include ::WebFetch::Validatable
    def validate; end
  end

  class ConcernedNotOverridden
    include ::WebFetch::Validatable
  end

  describe '#valid?' do
    context 'invalid' do
      subject { ConcernedInvalid.new }

      it 'runs validations and provides errors including supplementary text' do
        expect(subject.valid?).to be false
        expect(subject.errors).to include I18n.t(:bad_json)
        expect(subject.errors).to include I18n.t(:missing_url)
        expect(subject.errors.last).to include 'Hello there'
      end
    end

    context 'valid' do
      subject { ConcernedValid.new }

      it 'runs validations and provides (empty) errors' do
        expect(subject.valid?).to be true
        expect(subject.errors).to be_empty
      end
    end

    context '#validate not overridden' do
      subject { ConcernedNotOverridden.new }

      it 'raises NotImplementedError when #valid? called' do
        expect do
          subject.valid?
        end.to raise_error(NotImplementedError)
      end
    end
  end
end
