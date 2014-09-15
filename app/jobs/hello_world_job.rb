class HelloWorldJob
  def self.perform(message)
    puts "Hello world! From #{message}."
  end
end
