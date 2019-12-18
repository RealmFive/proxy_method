require 'minitest/autorun'
require 'proxy_method'

class Animal
  def self.create
    'created'
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

class DefaultCow < Animal
  include ProxyMethod

  proxy_method :save
end

class MultiMonkey < Animal
  include ProxyMethod

  proxy_method [:save, :update]
end

class ProxyMethodTest < MiniTest::Test
  def test_does_not_allow_original_class_method_name_to_be_called
    exception = assert_raises StandardError do
      Turtle.create
    end

    assert_equal "Don't Create directly, use Interactor!", exception.message
  end

  def test_allows_proxied_class_method_name_to_be_called
    assert 'created', Turtle.unproxied_create
  end

  def test_does_not_confuse_proxied_class_method_with_instance_method
    assert_raises NoMethodError do
      Turtle.save
    end

    assert_raises NoMethodError do
      Turtle.unproxied_save
    end
  end

  def test_does_not_allow_original_instance_method_name_to_be_called
    exception = assert_raises StandardError do
      Turtle.new.save
    end

    assert_equal "Don't Save directly, use Interactor!", exception.message
  end

  def test_allows_proxied_instance_method_name_to_be_called
    assert 'saved', Turtle.new.unproxied_save
  end

  def test_aliases_proxy_method_to_proxy_instance_method
    exception = assert_raises StandardError do
      Turtle.new.update
    end

    assert_equal "Don't Update directly, use Interactor!", exception.message
  end

  def test_does_not_confuse_proxied_instance_method_with_class_method
    assert_raises NoMethodError do
      Turtle.new.create
    end

    assert_raises NoMethodError do
      Turtle.new.unproxied_create
    end
  end

  def test_provides_default_error_message
    exception = assert_raises StandardError do
      DefaultCow.new.save
    end

    assert_equal "Disabled by proxy_method", exception.message
  end

  def test_allow_for_multiple_methods
    exception = assert_raises StandardError do
      MultiMonkey.new.save
    end

    assert_equal "Disabled by proxy_method", exception.message

    exception = assert_raises StandardError do
      MultiMonkey.new.update
    end

    assert_equal "Disabled by proxy_method", exception.message
  end
end