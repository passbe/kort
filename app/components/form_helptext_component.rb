class FormHelptextComponent < ViewComponent::Base

  # If we have errors that match field - print errors
  # Otherwise if success = true print message
  # Otherwise print help text
  def initialize(errors: [], field: nil, error_heading: false, success: false, message: nil)
    @errors = errors
    @field = field
    @error_heading = error_heading
    @success = success
    @message = message
  end

  def render?
    error? or success? or helptext?
  end

  def error?
    !@errors.blank? and ((!@field.nil? and !@errors.where(@field).blank?) or @field.nil?)
  end

  def success?
    !error? and @success and !@message.nil?
  end

  def helptext?
    !error? and !success? and !@message.nil?
  end

  def message
    if error?
      (@field.nil? ?
        @errors :
        @errors.where(@field)
      ).map(&:full_message).join(", ")
    else
      @message
    end
  end

  def css
    [
      "pl-1 text-sm flex flex-col space-y-2",
      {
        "text-gray-400": helptext?,
        "text-green-300": success?,
        "text-red-300": error?
      }
    ]
  end

end
