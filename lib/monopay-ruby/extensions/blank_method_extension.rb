module MonopayRuby
  module Extensions
    module BlankMethodExtension
      refine Object do
        BLANK_RE = /\A[[:space:]]*\z/

        # Check if the object is blank
        #
        # @return [Boolean] true if the object is blank, false otherwise
        def blank?
          nil? || respond_to?(:empty?) && empty? || (self.is_a?(String) && BLANK_RE.match?(self))
        end

        # Check if the object is present
        #
        # @return [Boolean] true if the object is present, false otherwise
        def present?
          !blank?
        end
      end
    end
  end
end
