class PrefixPelican < Animal
  include ProxyMethod

  proxy_class_method :create, prefix: 'pelican_'
  proxy_method :save, prefix: 'pelican_'
end
