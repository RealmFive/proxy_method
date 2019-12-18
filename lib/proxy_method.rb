module ProxyMethod
  module ClassMethods
    DEFAULT_PROXY_MESSAGE = 'Disabled by proxy_method'
    DEFAULT_PREFIX = 'unproxied_'

    def proxy_class_method(original_method_names, options = {})
      error_message = options[:message] || DEFAULT_PROXY_MESSAGE
      prefix = options[:prefix] || DEFAULT_PREFIX

      Array(original_method_names).each do |original_method_name|
        self.singleton_class.send(:alias_method, :"#{prefix}#{original_method_name}", original_method_name)
        define_singleton_method(original_method_name){ raise error_message }
      end
    end

    def proxy_instance_method(original_method_names, options = {})
      error_message = options[:message] || DEFAULT_PROXY_MESSAGE
      prefix = options[:prefix] || DEFAULT_PREFIX

      Array(original_method_names).each do |original_method_name|
        alias_method :"#{prefix}#{original_method_name}", original_method_name
        define_method(original_method_name){ raise error_message }
      end
    end

    alias_method :proxy_method, :proxy_instance_method
  end

  def self.included(base)
    base.extend ClassMethods
  end
end