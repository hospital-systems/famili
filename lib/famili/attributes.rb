module Famili
  class Attributes
    attr :unresolved_names

    def initialize(attributes)
      @attributes = attributes
      @unresolved_names = attributes.keys
    end

    def resolve(model, name)
      if unresolved_names.delete(name)
        attribute_value = @attributes[name]
        if attribute_value.is_a?(::Proc)
          attribute_value = model.instance_exec(&attribute_value)
        elsif attribute_value.respond_to?(:call)
          attribute_value = attribute_value.call
        end
        attribute_value = attribute_value.build if attribute_value.is_a?(::Famili::Father)
        attribute_value
      end
    end
  end
end