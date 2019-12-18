require 'minitest/autorun'
require 'proxy_method'

class Animal
  def self.create
    'created'
  end

  def save
    'saved'
  end
end

class Turtle < Animal
  include ProxyMethod

  proxy_class_method :create, "Don't Create directly, use Interactor!"
  proxy_method :save, "Don't Save directly, use Interactor!"
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

  def test_does_not_confuse_proxied_instance_method_with_class_method
    assert_raises NoMethodError do
      Turtle.new.create
    end

    assert_raises NoMethodError do
      Turtle.new.unproxied_create
    end
  end
end