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

          begin
            # Try on slave first...
            record = runner_klass.where(id: id).first
            raise "Couldn't find #{klass} with ID = #{id}" unless record

            perform_job(record, method, args)
            
          rescue ActiveRecord::RecordNotFound => e
            # If can't find on slave, go for master all the way
            Octopus.using(:master) do
              record = runner_klass.where(id: id).first
              raise "Couldn't find #{klass} with ID = #{id}" unless record

              perform_job(record, method, args)
            end
          end
        end
      end
    end
  end
end