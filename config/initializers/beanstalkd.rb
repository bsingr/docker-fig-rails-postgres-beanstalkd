def docker_beanstalkd_ports
  ports = []
  queue_no = 1
  while port = ENV["QUEUE_#{queue_no}_PORT"]
    ports << port.gsub('tcp', 'beanstalk')
    queue_no += 1
  end
  ports
end

# beanstalkd_view
ENV['BEANSTALK_URL'] = docker_beanstalkd_ports.join(' ')

# backburner
Backburner.configure do |config|
  config.beanstalk_url    = docker_beanstalkd_ports
  config.tube_namespace   = "some.app.production"
  config.on_error         = lambda { |e| puts e }
  config.max_job_retries  = 3 # default 0 retries
  config.retry_delay      = 2 # default 5 seconds
  config.default_priority = 65536
  config.respond_timeout  = 120
  config.default_worker   = Backburner::Workers::Simple
  config.logger           = Logger.new(STDOUT)
  config.primary_queue    = "backburner-jobs"
  config.priority_labels  = { :custom => 50, :useless => 1000 }
end if defined? Backburner
