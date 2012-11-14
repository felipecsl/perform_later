module PerformLater
  class Config
    def self.loner_prefix=(prefix)
      @prefix = prefix
    end
    def self.loner_prefix
      @prefix || "loner"
    end
    def self.enabled=(value)
      @enabled = value
    end

    def self.enabled?
      !!@enabled
    end
  end
end