class MethodicalMeerkat < Animal
  include ProxyMethod

  proxy_class_method(:create) do |klass, method_name, *args, &block|
    'indirectly ' + klass.send(method_name, *args, &block) + '!'
  end

  proxy_method(:save) do |object, method_name, *args, &block|
    'indirectly ' + object.send(method_name, *args, &block) + '!'
  end
end
