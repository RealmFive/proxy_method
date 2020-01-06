module ProxyMethod
  module ClassMethods
    DEFAULT_PROXY_MESSAGE = 'Disabled by proxy_method'
    DEFAULT_PREFIX = 'unproxied_'

    ##
    # Proxy one or more inherited class methods, so that they are not used
    # directly. Given this base class:
    #
    #     class Animal
    #       def self.create
    #         'created'
    #       end
    #
    #       def destroy
    #         'destroyed'
    #       end
    #     end
    #
    # The simplest implementation is to pass just a single method name:
    #
    #     class Dog < Animal
    #       proxy_class_method :create
    #     end
    #
    #     Dog.create
    #     # => RuntimeError: Disabled by proxy_method
    #
    #     Dog.destroy
    #     # 'destroyed'
    #
    # Or multiple method names:
    #
    #     class Dog < Animal
    #       proxy_class_method :create, :destroy
    #     end
    #
    #     Dog.create
    #     # => RuntimeError: Disabled by proxy_method
    #
    #     Dog.destroy
    #     # => RuntimeError: Disabled by proxy_method
    #
    # With a custom error message:
    #
    #     class Dog < Animal
    #       proxy_class_method :create, raise: 'Disabled!'
    #     end
    #
    #     Dog.create
    #     # => RuntimeError: Disabled!
    #
    # You can still access the unproxied version by prefixing 'unproxied'
    # to the method name:
    #
    #     Dog.unproxied_create
    #     # => 'created'
    #
    # And you can change the prefix for unproxied versions:
    #
    #     class Dog < Animal
    #       proxy_class_method :create, prefix: 'original_'
    #     end
    #
    #     Dog.original_create
    #     # => 'created'
    #
    # Finally, you can actually *proxy* the method, by providing an
    # alternative block of code to run:
    #
    #     class Dog < Animal
    #       proxy_class_method(:create) do |object, method_name, *args, &block|
    #         "indirectly #{object.send(method_name)}"
    #       end
    #     end
    #
    #     Dog.original_create
    #     # => 'indirectly created'


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

  ##
  # Return an unproxied version of this instance.
  #
  # This returns a copy of the instance where all proxies are disabled. This is
  # sometimes necessary when a proxied method is being called by a different
  # method outside your control.

  def unproxied
    self.dup.send(:unproxy!)
  end

  ##
  # Return a proxied version of this instance.
  #
  # If the instance has previously been "unproxied", this returns a
  # copy where all proxies are re-enabled.

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