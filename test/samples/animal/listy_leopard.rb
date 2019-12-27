class ListyLeopard < Animal
  include ProxyMethod

  proxy_class_method :create, :destroy_all
  proxy_method :save, :update
end