module Error
  class AuthorizerError < StandardError
    def initialize(message='An error occurrred')
      super
    end
  end

  class DecodeError < AuthorizerError; end

  class NoSuchOrg < AuthorizerError; end
end
