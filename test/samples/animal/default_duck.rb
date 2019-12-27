class DefaultDuck < Animal
  include ProxyMethod

  proxy_class_method :create
  proxy_method :save
end
