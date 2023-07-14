module MonopayRuby
  module Services
    class BaseService
      def self.call(*args)
        new(*args).call
      end
    end
  end
end