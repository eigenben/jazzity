module KeyContext
  def self.included(klass)
    klass.class_eval do
      attr_accessor :key

      def in_key_of(name)
        self.key = name.is_a?(Key) ? name : Key[name]
        self
      end
      alias_method :in, :in_key_of

      def without_key
        self.key = nil
        self
      end
    end
  end
end
