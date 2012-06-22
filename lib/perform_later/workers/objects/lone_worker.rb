module PerformLater
  module Workers
    module Objects
      class LoneWorker < PerformLater::Workers::Base
        def self.perform(klass_name, method, *args)
          digest = PerformLater::PayloadHelper.get_digest(klass_name, method, args)
          Resque.redis.del(digest)

          arguments = PerformLater::ArgsParser.args_from_resque(args)          
          klass = klass_name.constantize

          begin
            slave_status = ::ActiveRecord::Base.connection.select_one("show slave status")

            if slave_status['Seconds_Behind_Master'] > 0
              Octopus.using(:master) do
                perform_job klass, method, arguments
              end
            else
              perform_job klass, method, arguments
            end
          rescue
            perform_job klass, method, arguments
          end
        end
      end
    end
  end
end
