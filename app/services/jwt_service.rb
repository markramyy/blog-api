class JwtService
  HMAC_SECRET = ENV['JWT_SECRET'] || Rails.application.credentials.secret_key_base || 'fallback_secret_for_development'
  ALGORITHM = 'HS256'.freeze

  def self.encode(payload)
    JWT.encode(payload, HMAC_SECRET, ALGORITHM)
  end

  def self.decode(token)
    result = JWT.decode(token, HMAC_SECRET, true, { algorithm: ALGORITHM })[0]
    result
  rescue JWT::DecodeError, JWT::ExpiredSignature => e
    Rails.logger.error "JWT decode error: #{e.message}"
    nil
  rescue StandardError => e
    Rails.logger.error "Unexpected JWT error: #{e.message}"
    nil
  end
end