module ProxyMethod
  module ClassMethods
    DEFAULT_PROXY_MESSAGE = 'Disabled by proxy_method'
    DEFAULT_PREFIX = 'unproxied_'

    def proxy_class_method(*original_method_names, &proxy_block)
      options = if original_method_names.last.is_a?(Hash)
        original_method_names.pop
      else
        {}
      end

      original_method_names = Array(original_method_names).flatten

      error_message = options[:raise] || DEFAULT_PROXY_MESSAGE
      prefix = options[:prefix] || DEFAULT_PREFIX

      original_method_names.each do |original_method_name|
        proxied_class_methods.merge!(original_method_name => prefix)
        new_method_name = :"#{prefix}#{original_method_name}"

        self.singleton_class.send(:alias_method, new_method_name, original_method_name)
        define_singleton_method(original_method_name) do |*args, &block|
          if proxy_class_methods_enabled?
            if proxy_block
              proxy_block.call(self.unproxied, original_method_name, *args, &block)
            else
              raise error_message
            end
          else
            send(new_method_name, *args, &block)
          end
        end
      end
    end

    def proxy_instance_method(*original_method_names, &proxy_block)
      options = if original_method_names.last.is_a?(Hash)
        original_method_names.pop
      else
        {}
      end

      original_method_names = Array(original_method_names).flatten

      error_message = options[:raise] || DEFAULT_PROXY_MESSAGE
      prefix = options[:prefix] || DEFAULT_PREFIX

      original_method_names.each do |original_method_name|
        proxied_instance_methods.merge!(original_method_name => prefix)
        new_method_name = :"#{prefix}#{original_method_name}"

        alias_method new_method_name, original_method_name

        define_method(original_method_name) do |*args, &block|
          if proxy_instance_methods_enabled?
            if proxy_block
              proxy_block.call(self.unproxied, original_method_name, *args, &block)
            else
              raise error_message
            end
          else
            send(new_method_name, *args, &block)
          end
        end
      end
    end

    alias_method :proxy_method, :proxy_instance_method

    ##
    # Return an unproxied version of this class.
    #
    # This returns a copy of the class where all proxies are disabled. This is
    # sometimes necessary when a proxied method is being called by a different
    # method outside your control.

    def unproxied
      self.dup.send(:unproxy!)
    end

    ##
    # Return a proxied version of this class.
    #
    # If the class has previously been "unproxied", this returns a
    # copy where all proxies are re-enabled.

    def proxied
      self.dup.send(:reproxy!)
    end

    private

    def proxy_class_methods_enabled?
      return @_proxy_class_methods_enabled if defined?(@_proxy_class_methods_enabled)
      @_proxy_class_methods_enabled = true
    end

    def proxied_instance_methods
      @_proxied_instance_methods ||= {}
    end

    def proxied_class_methods
      @_proxied_class_methods ||= {}
    end

    def unproxy! # :nodoc:
      @_proxy_class_methods_enabled = false
      self
    end

    def reproxy! # :nodoc:
      @_proxy_class_methods_enabled = true
      self
    end
  end

  def self.included(base)
    base.extend ClassMethods
  end

  def unproxied
    self.dup.send(:unproxy!)
  end

  def proxied
    self.dup.send(:reproxy!)
  end

  private

  def proxy_instance_methods_enabled?
    return @_proxy_instance_methods_enabled if defined?(@_proxy_instance_methods_enabled)
    @_proxy_instance_methods_enabled = true
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