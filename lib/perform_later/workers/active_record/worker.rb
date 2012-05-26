module PerformLater
  module Workers
    module ActiveRecord
      class Worker < PerformLater::Workers::Base
        def self.perform(klass, id, method, *args)
          args = PerformLater::ArgsParser.args_from_resque(args)
          runner_klass = klass.constantize
          
          record = nil
          Octopus.using(:master) do
            record = runner_klass.where(id: id).first
            raise "Couldn't find UserCheckin with ID=#{id}" unless record
          end
          
          perform_job(record, method, args)
        end
      end
    end
  end
end