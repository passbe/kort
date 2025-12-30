module StoreCasting
  extend ActiveSupport::Concern

  class_methods do

    # Cast integers
    def store_accessor_integer(store, field)
      store_accessor store, field
      define_method(field) do
        super().to_i
      end
      define_method("#{field}=") do |value|
        super(value.to_i)
      end
    end

    # Cast 1/0 as boolean only (checkboxes)
    def store_accessor_boolean(store, field)
      store_accessor store, field
      define_method(field) do
        value = super()
        return true if value == "1"
        return false if value == "0"
        value
      end
      define_method("#{field}=") do |value|
        cast = value
        cast = true if value == "1"
        cast = false if value == "0"
        super(cast)
      end
    end

    # Cast key = value string to hash
    def store_accessor_hash(store, field)
      store_accessor store, field
      define_method(field) do
        value = super()
        return store_accessor_cast_hash(value) if value.is_a?(String)
        value
      end
      define_method("#{field}=") do |value|
        cast = value
        cast = store_accessor_cast_hash(value) if value.is_a?(String)
        super(cast)
      end
      define_method("store_accessor_cast_hash") do |value|
        Hash[value.split("\n").map { |pair| pair.split(/(?<!\\)=/, 2).map { |x|
          x.delete("\\").strip
        }}]
      end
    end

  end
end
