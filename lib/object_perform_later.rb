module ObjectPerformLater
  def perform_later(queue, method, *args)
    return perform_now(method, args) unless PerformLater.config.enabled?

    worker = PerformLater::Workers::Objects::Worker
    perform_later_enqueue(worker, queue, method, args)
  end

  def perform_later!(queue, method, *args)
    return perform_now(method, args) unless PerformLater.config.enabled?

    return "EXISTS!" if loner_exists(method, args)

    worker = PerformLater::Workers::Objects::LoneWorker
    perform_later_enqueue(worker, queue, method, args)
  end

  private 
    def loner_exists(method, *args)
      digest = PerformLater::PayloadHelper.get_digest(self.name, method, args)

      return true unless Resque.redis.get(digest).blank?
      Resque.redis.set(digest, 'EXISTS')
      Resque.redis.expire(digest, 86400) # expires in one day
      return false
    end

    def perform_later_enqueue(worker, queue, method, args)
      args = PerformLater::ArgsParser.args_to_resque(args)
      args.size == 1 ? Resque::Job.create(queue, worker, self.name, method, args.first) : Resque::Job.create(queue, worker, self.name, method, *args)
    end

    def perform_now(method, args)
      args.size == 1 ? send(method, args.first) : send(method, *args)
    end
end

Object.send(:include, ObjectPerformLater)