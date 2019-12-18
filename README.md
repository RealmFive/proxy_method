# ProxyMethod

Prevent running an inherited method directly.

The purpose of this gem is to prevent directly running the inherited
methods you choose to block, and instead raise a custom Error message.
The original method can still be called under a different name.

This was created to help enforce the use of interactors over directly
calling ActiveRecord methods like create, save, and update. One downside
of interactors is that they require top-of-mind awareness in order to use
them, and by default new/forgetful/overworked developers will create
ActiveRecord instances all willy nilly until society crumbles.

While this was created for ActiveRecord models specifically, it works
with *any* inherited methods. The method being proxied has to already
exist, or it can't be overridden.

## Usage

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
    
      proxy_class_method :create, "Don't create here, use an Interactor!"
      proxy_instance_method :save, "Don't save here, use an Interactor!"
      
      # for instance methods, you can also just call "proxy_method"
      proxy_method :update, "Don't update here, use an Interactor!"
    end
    
    Turtle.create
    # => RuntimeError: Don't create here, use an Interactor!
    
    Turtle.new.save
    # => RuntimeError: Don't save here, use an Interactor!
    
    Turtle.proxied_create
    # => 'created'
    
    Turtle.new.save
    # => 'saved'


## Installation
Add this line to your application's Gemfile:

```ruby
gem 'proxy_method'
```

And then execute:
```bash
$ bundle
```

Or install it yourself as:
```bash
$ gem install proxy_method
```

## Contributing
Feel free to fork and create a pull request. 

## License
The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
