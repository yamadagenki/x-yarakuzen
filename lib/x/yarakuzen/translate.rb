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
      API_URL = 'https://app.yarakuzen.com/api/texts'.freeze

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

      def exec(text)
        text = 'こんにちは'
        puts post_with_sign(text)
      end

      private

      def initialize_https(uri)
        https = Net::HTTP.new(uri.host, uri.port)
        https.use_ssl = true
        https.open_timeout = 5
        https.read_timeout = 15
        https.verify_mode = OpenSSL::SSL::VERIFY_PEER
        https.verify_depth = 5
        https
      end

      def get_timestamp
        Time.now.to_i
      end

      def get_signature(timestamp)
        OpenSSL::HMAC.hexdigest(OpenSSL::Digest::SHA1.new, @api_secret_key, "#{timestamp}#{@api_pub_key}")
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
          "texts[0][customData]": nonce,
          "texts[0][text]": text
        }

        begin
          req = Net::HTTP::Post.new(uri)
          req.form_data = body

          https = initialize_https(uri)
          https.start do |w|
            response = w.request(req)
            case response
            when Net::HTTPSuccess
              json = JSON.parse(response.body)
              return json
            else
              raise 'Failed to connect to Yarakuzen: ' + response.body
            end
          end
        rescue StandardError
          raise
        end
      end
    end
  end
end
