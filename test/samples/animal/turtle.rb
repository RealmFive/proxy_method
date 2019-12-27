class Turtle < Animal
  include ProxyMethod

  proxy_class_method :create, raise: "Don't Create directly, use Interactor!"
  proxy_instance_method :update, raise: "Don't Update directly, use Interactor!"
  proxy_method :save, raise: "Don't Save directly, use Interactor!"
end
