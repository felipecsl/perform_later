module PerformLater
  module Workers
    module Objects
      class Worker < PerformLater::Workers::Base
        def self.perform(klass_name, method, *args)
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
