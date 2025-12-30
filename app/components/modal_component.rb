class ModalComponent < ViewComponent::Base

  renders_one :actions

  def initialize(title:, description:)
    @title = title
    @description = description
  end

end
