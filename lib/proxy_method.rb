module ProxyMethod
  module ClassMethods
    DEFAULT_PROXY_MESSAGE = 'Disabled by proxy_method'
    DEFAULT_PREFIX = 'unproxied_'

    def proxied_instance_methods
      @_proxied_instance_methods ||= {}
    end

    def proxy_class_method(original_method_names, options = {})
      error_message = options[:message] || DEFAULT_PROXY_MESSAGE
      prefix = options[:prefix] || DEFAULT_PREFIX

      Array(original_method_names).each do |original_method_name|
        self.singleton_class.send(:alias_method, :"#{prefix}#{original_method_name}", original_method_name)
        define_singleton_method(original_method_name){ |*args, &block| raise error_message }
      end
    end

    def proxy_instance_method(original_method_names, options = {})
      original_method_names = Array(original_method_names)


      error_message = options[:message] || DEFAULT_PROXY_MESSAGE
      prefix = options[:prefix] || DEFAULT_PREFIX

      original_method_names.each do |original_method_name|
        self.proxied_instance_methods.merge!(original_method_name => prefix)

        alias_method :"#{prefix}#{original_method_name}", original_method_name
        define_method(original_method_name){ |*args, &block| raise error_message }
      end
    end

    alias_method :proxy_method, :proxy_instance_method
  end

  def self.included(base)
    base.extend ClassMethods
  end

  def unproxied
    self.class.proxied_instance_methods.each do |original_method_name, prefix|
      define_singleton_method(original_method_name){ |*args, &block| send(:"#{prefix}#{original_method_name}", *args, &block) }
    end

    self
  end
end