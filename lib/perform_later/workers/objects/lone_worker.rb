module PerformLater
  module Workers
    module Objects
      class LoneWorker < PerformLater::Workers::Base
        def self.perform(klass_name, method, *args)
          digest = PerformLater::PayloadHelper.get_digest(klass_name, method, args)
          PerformLater.config.redis.del(digest)

          arguments = PerformLater::ArgsParser.args_from_resque(args)
          klass = klass_name.constantize

          Octopus.using(:master) do
            perform_job klass, method, arguments
          end
        end
      end
    end
  end
end
