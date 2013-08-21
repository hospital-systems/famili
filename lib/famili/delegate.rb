class Module
  def delegate(*method_names)
    opts = method_names.pop
    declarations = ''
    to = opts[:to]
    method_names.each do |name|
      declarations << <<-RUBY
        def #{name}(*args, &block)
          #{to}.#{name}(*args, &block)
        end
      RUBY
    end
    module_eval declarations
  end
end