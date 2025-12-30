module PrimaryUUID
  extend ActiveSupport::Concern

  included do
    before_create :assign_primary_key
  end

  private

  def assign_primary_key
    self.id = SecureRandom.uuid if self.id.blank?
  end
end
