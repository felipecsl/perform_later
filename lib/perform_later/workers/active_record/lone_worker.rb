module PerformLater
  module Workers
    module ActiveRecord
      class LoneWorker < PerformLater::Workers::Base
        def self.perform(klass, id, method, *args)
          # Remove the loner flag from redis
          digest = PerformLater::PayloadHelper.get_digest(klass, method, args)
          Resque.redis.del(digest)

          args = PerformLater::ArgsParser.args_from_resque(args)
          runner_klass = klass.constantize
          
          record = nil

          # Try on slave first...
          record = runner_klass.where(id: id).first
          
          if record
            perform_job(record, method, args)
          else
            # If can't find on slave, go for master all the way
            Octopus.using(:master) do
              record = runner_klass.where(id: id).first
              
              # Can't find on master either...
              raise "Couldn't find #{klass} with ID = #{id}" unless record

              # perform job using master as well
              perform_job(record, method, args)
            end
          end
        end
      end
    end
  end
end