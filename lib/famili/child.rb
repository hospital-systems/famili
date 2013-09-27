module Famili
  class Child < BasicObject
    def initialize(mother, attributes)
      @mother = mother
      @attributes = attributes
      @unresolved_attribute_names = attributes.keys.dup
      @cached_attributes = {}
    end

    def [](name)
      resolve_attribute(name)
    end

    def resolve_attributes(instance = nil, &block)
      bind(instance, &block) if instance
      resolve_attribute(unresolved_attribute_names.first) until unresolved_attribute_names.empty?
      unbind if instance
      instance
    end

    def bind(instance, &block)
      @instance = instance
      @resolve_callback = block
      @instance.instance_variable_set(:@__famili_child__, self)
      define_method_stub(:method_missing) do |name, *args|
        mother = @__famili_child__.__send__(:mother)
        if mother.respond_to?(name)
          mother.send(name, *args)
        elsif (value = @__famili_child__.__send__(:cached_attributes)[name])
          value
        else
          send(@__famili_child__.__send__(:munge, :method_missing), name, *args)
        end
      end
      @attributes.each { |attr_name, _| define_property_stub(attr_name) }
    end

    def unbind
      @resolve_callback = nil
      @attributes.each { |attr_name, _| undefine_property_stub(attr_name) }
      undefine_method_stub(:method_missing)
      @instance.send(:remove_instance_variable, :@__famili_child__)
    end

    private

    attr_reader :mother, :unresolved_attribute_names, :cached_attributes

    def meta_class
      @instance.singleton_class
    end

    def munge(property_name)
      "__famili_child_proxied_#{property_name}"
    end

    def define_property_stub(property_name)
      define_method_stub property_name do
        @__famili_child__[property_name]
      end if @instance.respond_to?(property_name)
    end

    def undefine_property_stub(property_name)
      undefine_method_stub(property_name) if meta_class.send(:method_defined?, munge(property_name))
    end

    def define_method_stub(method_name, &block)
      meta_class.send(:alias_method, munge(method_name), method_name)
      meta_class.send(:define_method, method_name, &block)
    end

    def undefine_method_stub(method_name)
      munged_name = munge(method_name)
      if meta_class.send(:method_defined?, munged_name)
        meta_class.send(:alias_method, method_name, munged_name)
        meta_class.send(:remove_method, munged_name)
      else
        meta_class.send(:remove_method, method_name)
      end
    end

    def resolve_attribute(name)
      @cached_attributes[name] ||=
        if unresolved_attribute_names.delete(name)
          attribute_value = @attributes[name]
          if attribute_value.is_a?(::Proc)
            attribute_value = @instance.instance_exec(&attribute_value)
          elsif attribute_value.respond_to?(:call)
            attribute_value = attribute_value.call
          end
          attribute_value = attribute_value.build if attribute_value.is_a?(::Famili::Father)
          undefine_property_stub(name)
          @resolve_callback.call(@instance, name, attribute_value) if @resolve_callback
          attribute_value
        end
    end
  end
end