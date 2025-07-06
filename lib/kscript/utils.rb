# frozen_string_literal: true

module Kscript
  class Utils
    def [](key)
      ENV["KSCRIPT_#{key.to_s.upcase}"]
    end

    def log_level
      self['log_level']
    end
  end
end
