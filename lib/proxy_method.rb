module ProxyMethod
  module ClassMethods
    DEFAULT_PROXY_MESSAGE = 'Disabled by proxy_method'
    DEFAULT_PREFIX = 'unproxied_'

    def proxied_instance_methods
      @_proxied_instance_methods ||= {}
    end

    def proxied_class_methods
      @_proxied_class_methods ||= {}
    end

    def proxy_class_methods_enabled?
      return @_proxy_class_methods_enabled if defined?(@_proxy_class_methods_enabled)
      @_proxy_class_methods_enabled = true
    end

    def proxy_class_method(original_method_names, options = {})
      original_method_names = Array(original_method_names)

      error_message = options[:message] || DEFAULT_PROXY_MESSAGE
      prefix = options[:prefix] || DEFAULT_PREFIX

      original_method_names.each do |original_method_name|
        self.proxied_class_methods.merge!(original_method_name => prefix)
        new_method_name = :"#{prefix}#{original_method_name}"

        self.singleton_class.send(:alias_method, new_method_name, original_method_name)
        define_singleton_method(original_method_name) do |*args, &block|
          if proxy_class_methods_enabled?
            raise error_message
          else
            send(new_method_name, *args, &block)
          end
        end
      end
    end

    def proxy_instance_method(original_method_names, options = {})
      original_method_names = Array(original_method_names)

      error_message = options[:message] || DEFAULT_PROXY_MESSAGE
      prefix = options[:prefix] || DEFAULT_PREFIX

      original_method_names.each do |original_method_name|
        self.proxied_instance_methods.merge!(original_method_name => prefix)
        new_method_name = :"#{prefix}#{original_method_name}"

        alias_method new_method_name, original_method_name

        define_method(original_method_name) do |*args, &block|
          if proxy_instance_methods_enabled?
            raise error_message
          else
            send(new_method_name, *args, &block)
          end
        end
      end
    end

    alias_method :proxy_method, :proxy_instance_method

    def unproxied
      self.dup.unproxy!
    end

    def proxied
      self.dup.proxy!
    end

    def unproxy!
      @_proxy_class_methods_enabled = false
      self
    end

    def reproxy!
      @_proxy_class_methods_enabled = true
      self
    end
  end

  def self.included(base)
    base.extend ClassMethods
  end

  def proxy_instance_methods_enabled?
    return @_proxy_instance_methods_enabled if defined?(@_proxy_instance_methods_enabled)
    @_proxy_instance_methods_enabled = true
  end

  def unproxied
    self.dup.unproxy!
  end

  def proxied
    self.dup.proxy!
  end

  def unproxy!
    @_proxy_instance_methods_enabled = false
    self
  end

  def reproxy!
    @_proxy_instance_methods_enabled = true
    self
  end
end