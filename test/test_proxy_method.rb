require 'minitest/autorun'
require 'proxy_method'

class Animal
  def self.create
    'created'
  end

  def self.destroy_all
    'destroyed'
  end

  def save
    'saved'
  end

  def update
    'updated'
  end
end

class Turtle < Animal
  include ProxyMethod

  proxy_class_method :create, message: "Don't Create directly, use Interactor!"
  proxy_instance_method :update, message: "Don't Update directly, use Interactor!"
  proxy_method :save, message: "Don't Save directly, use Interactor!"
end

class DefaultDuck < Animal
  include ProxyMethod

  proxy_class_method :create
  proxy_method :save
end

class MultiMonkey < Animal
  include ProxyMethod

  proxy_class_method [:create, :destroy_all]
  proxy_method [:save, :update]
end

class PrefixPelican < Animal
  include ProxyMethod

  proxy_class_method :create, prefix: 'pelican_'
  proxy_method :save, prefix: 'pelican_'
end

class ProxyMethodTest < MiniTest::Test
  describe "proxying class methods" do
    it "does not allow original method name to be called" do
      exception = assert_raises StandardError do
        Turtle.create
      end

      assert_equal "Don't Create directly, use Interactor!", exception.message
    end

    it "allows proxied method name to be called" do
      assert 'created', Turtle.unproxied_create
    end

    it "does not confuse proxied class method with instance method" do
      assert_raises NoMethodError do
        Turtle.save
      end

      assert_raises NoMethodError do
        Turtle.unproxied_save
      end
    end

    it "provides default error message" do
      exception = assert_raises StandardError do
        DefaultDuck.create
      end

      assert_equal "Disabled by proxy_method", exception.message
    end

    it "allows for multiple methods to be proxied in one call" do
      exception = assert_raises StandardError do
        MultiMonkey.create
      end

      assert_equal "Disabled by proxy_method", exception.message

      exception = assert_raises StandardError do
        MultiMonkey.destroy_all
      end

      assert_equal "Disabled by proxy_method", exception.message
    end

    it "allows for a custom prefix" do
      exception = assert_raises StandardError do
        PrefixPelican.create
      end

      assert_equal "Disabled by proxy_method", exception.message

      assert 'created', PrefixPelican.pelican_create
    end
  end

  describe "proxying instance methods" do
    it "does not allow original method name to be called" do
      exception = assert_raises StandardError do
        Turtle.new.save
      end

      assert_equal "Don't Save directly, use Interactor!", exception.message
    end

    it "allows proxied method name to be called" do
      assert 'saved', Turtle.new.unproxied_save
    end

    it "does not confuse proxied class method with instance method" do
      assert_raises NoMethodError do
        Turtle.new.create
      end

      assert_raises NoMethodError do
        Turtle.new.unproxied_create
      end
    end

    it "aliases proxy_method to proxy_instance_method" do
      exception = assert_raises StandardError do
        Turtle.new.update
      end

      assert_equal "Don't Update directly, use Interactor!", exception.message
    end

    it "provides default error message" do
      exception = assert_raises StandardError do
        DefaultDuck.new.save
      end

      assert_equal "Disabled by proxy_method", exception.message
    end

    it "allows for multiple methods to be proxied in one call" do
      exception = assert_raises StandardError do
        MultiMonkey.new.save
      end

      assert_equal "Disabled by proxy_method", exception.message

      exception = assert_raises StandardError do
        MultiMonkey.new.update
      end

      assert_equal "Disabled by proxy_method", exception.message
    end

    it "allows for a custom prefix" do
      exception = assert_raises StandardError do
        PrefixPelican.new.save
      end

      assert_equal "Disabled by proxy_method", exception.message

      assert 'saved', PrefixPelican.new.pelican_save
    end
  end
end