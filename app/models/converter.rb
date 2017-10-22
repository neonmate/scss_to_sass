require 'open3'

class Converter < ActiveType::Object
  attribute :source, :text
  attribute :from_syntax, :string
  attribute :output, :text

  validates :source, presence: true
  validates :from_syntax, presence: true

  after_validation :perform_conversion

  assignable_values_for :from_syntax, default: 'scss' do
    ['scss', 'sass']
  end

  def perform_conversion
    stdout_str, _error_str, status = Open3.capture3(
        'sass-convert',
        '--from',
        from_syntax,
        '--to',
        to_syntax,
        '--stdin',
        '--no-cache',
        stdin_data: source
    )

    if status.success?
      self.output = stdout_str
    else
      errors.add(:source, "Syntax error: No valid #{from_syntax.upcase} syntax.")
    end
  end

  def new_record?
    # We don't want simple_form to think this is a updatable resource
    false
  end

  private

  def to_syntax
    if from_syntax == 'scss'
      'sass'
    elsif from_syntax == 'sass'
      'scss'
    else
      raise(InvalidArgument, <<-ERROR.squish)
        Expected #{from_syntax} to be either 'sass' or 'scss', but it wasn't.
      ERROR
    end
  end
end
