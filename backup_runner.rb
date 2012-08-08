class BackupRunner
  
  def try_running_backup(job, &block)
    @proxy = ProxyDSL[block]
    run_backup(job)
    @proxy.respond_with(:success)
    rescue => e
      @proxy.respond_with(:failure, e.message)
  end
  
  def run_backup(job)
    @proxy.respond_with(:waiting)
    sleep 1
    raise "Unable to run '#{job}' job" if rand < 0.5
    job
  end
  
  class ProxyDSL
        
    def self.[](block)
      new.tap { |proxy| block.call(proxy) }
    end

    def respond_with(callback, *args)
      callbacks[callback].call(*args)
    end

    def method_missing(m, *args, &block)
      block ? callbacks[m] = block : super
      self      
    end

    private

    def callbacks
      @callbacks ||= {}
    end
  end
end
if __FILE__ == $0
  backup = BackupRunner.new

  backup.try_running_backup('Jobber') do |progress|
    progress.waiting do
      puts "Trying ..."
    end
    progress.success do
      puts "Success!"
    end
    progress.failure do |message|
      puts "Failed: #{message}"
    end
  end
end
