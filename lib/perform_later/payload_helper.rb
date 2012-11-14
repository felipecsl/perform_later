module PerformLater
  class PayloadHelper
    def self.get_digest(klass, method, *args)
      args = args.flatten
      payload = {:class => klass, :method => method.to_s, :args => args}.to_s

      digest = []

      digest << PerformLater.config.loner_prefix
      digest << Digest::MD5.hexdigest("#{payload}")

      digest.join(":")
    end
  end
end