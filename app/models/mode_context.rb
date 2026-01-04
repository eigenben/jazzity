module ModeContext
  def self.included(klass)
    klass.class_eval do
      attr_accessor :mode
    
      def in_mode(value)
        if value.is_a?(String)
          mode_object = self.respond_to?(:modes) ? self.modes.find_by(name: value) : Mode.find_by(name: value)
          self.mode = mode_object.mode unless mode_object.nil?
        else
          self.mode = value
        end
        self
      end
    
      def without_mode
        self.mode = nil
        self
      end
    end
  end
end
