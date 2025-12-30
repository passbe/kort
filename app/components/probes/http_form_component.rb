class Probes::HttpFormComponent < ViewComponent::Base

  include FormHelper

  def initialize(probe:)
    @probe = probe
  end

  def method_options
    HTTP::Request::METHODS.map { _1.to_s.upcase }
  end

  def hash_to_str(h)
    return "" if h.nil?
    lines = []
    h.each do |key, value|
      value.gsub!(/=/, "\\\\\\\=") unless value.nil?
      lines << "#{key.gsub(/=/, "\\\\\\\=")} = #{value}"
    end
    lines.join("\n")
  end

end
