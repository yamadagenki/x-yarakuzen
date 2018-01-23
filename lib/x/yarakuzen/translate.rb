require 'net/http'
require 'openssl'
require 'json'
require 'time'

module X
  module Yarakuzen
    class Translate
      LANGUAGES = %w[
        ar de en es fr hi id it ja
        ko mn ms my nl pt ru sv th tl vi zh zh_Hant
      ].freeze
      TIERS = %w[standard business pro].freeze
      API_URL = 'https://app.yarakuzen.com/api'.freeze

      # rubocop:disable Metrics/CyclomaticComplexity
      def initialize(options = {})
        super()
        @api_pub_key     = ENV['YARAKUZEN_PUB_KEY']
        @api_secret_key  = ENV['YARAKUZEN_SECRET_KEY']
        @origin_lang = options['origin_lang'] || 'ja'
        @target_lang = options['target_lang'] || 'en'
        @tier = options['tier'] || 'standard'
        raise "Please check origin lang option(#{@origin_lang})." unless LANGUAGES.include?(@origin_lang)
        raise "Please check target lang option(#{@origin_lang})." unless LANGUAGES.include?(@target_lang)
        raise "Please check tier option(#{@tier})." unless TIERS.include?(@tier)
      end
      # rubocop:enable Metrics/CyclomaticComplexity

      def translate(text)
        puts text
      end

      private

      def get_timestamp
        current = Time.now
        "#{current.to_i}#{current.usec}"
      end

      def get_signature(timestamp)
        OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha1'), timestamp + @api_secret, @api_secret)
      end

      def post_with_sign(text)
        uri = URI.parse(API_URL)
        nonce = get_timestamp
        signature = get_signature(nonce)

        body = {
          publicKey: @api_pub_key,
          timestamp: nonce,
          signature: signature,
          lcSrc: @origin_lang,
          lcTgt: @target_lang,
          tier: @tier,
          texts: [
            {
              customData: nonce,
              text: text
            }
          ]
        }
        begin
          req = Net::HTTP::Post.new(uri, headers)
          req.body = body.to_json

          https = initialize_https(uri)
          https.start do |w|
            response = w.request(req)
            case response
            when Net::HTTPSuccess
              json = JSON.parse(response.body)
              return json
            else
              raise ConnectionFailedException, "Failed to connect to #{@name}: " + response.value
            end
          end
        rescue StandardError
          raise
        end
      end
    end
  end
end
