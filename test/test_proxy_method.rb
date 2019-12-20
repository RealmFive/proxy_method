require 'minitest/autorun'
require 'proxy_method'

class Animal
  def self.create target=nil
    ['created', target].compact.join(' ')
  end

  def self.destroy_all
    'destroyed'
  end

  def self.blocky(first, second)
    yield(first, second)
  end

  def save
    'saved'
  end

  def update target=nil
    ['updated', target].compact.join(' ')
  end

  def blocky(first, second)
    yield(first, second)
  end
end

class Turtle < Animal
  include ProxyMethod

  proxy_class_method :create, raise: "Don't Create directly, use Interactor!"
  proxy_instance_method :update, raise: "Don't Update directly, use Interactor!"
  proxy_method :save, raise: "Don't Save directly, use Interactor!"
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

class ArgumentativeAardvark < Animal
  include ProxyMethod

  proxy_method :blocky
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

    describe "unproxied class" do
      it "allows methods to be called directly" do
        assert_equal 'created feathers', MultiMonkey.unproxied.create('feathers')

        # ensure that it doesn't affect any other classes
        exception = assert_raises StandardError do
          DefaultDuck.create('feathers')
        end

        assert_equal "Disabled by proxy_method", exception.message
      end

      it "handles arguments and blocks" do
        assert_equal 13, ArgumentativeAardvark.unproxied.blocky(6, 7){ |a, b| a + b }
      end

      it "handles custom prefixes" do
        assert_equal 'created', PrefixPelican.unproxied.create
      end
    end

    it "leaves the original proxied" do
      duck_unproxied = DefaultDuck.unproxied
      duck_proxied = DefaultDuck

      assert_equal 'created', duck_unproxied.create

      assert_raises StandardError do
        duck_proxied.create
      end
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

  describe "unproxied instance" do
    it "allows methods to be called directly" do
      assert_equal 'updated feathers', MultiMonkey.new.unproxied.update('feathers')

      # ensure that it doesn't affect any other instances
      exception = assert_raises StandardError do
        MultiMonkey.new.update('feathers')
      end

      assert_equal "Disabled by proxy_method", exception.message
    end

    it "handles arguments and blocks" do
      assert_equal 13, ArgumentativeAardvark.new.unproxied.blocky(6, 7){ |a, b| a + b }
    end

    it "handles custom prefixes" do
      assert_equal 'saved', PrefixPelican.new.unproxied.save
    end

    it "leaves the original proxied" do
      duck_proxied = DefaultDuck.new
      duck_unproxied = duck_proxied.unproxied

      assert_equal 'saved', duck_unproxied.save

      assert_raises StandardError do
        duck_proxied.save
      end
    end
  end
end