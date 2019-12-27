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

Dir[File.dirname(__FILE__) + '/animal/**/*.rb'].each do |file|
  require file
end