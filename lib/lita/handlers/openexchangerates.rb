module Lita
  module Handlers
    class Openexchangerates < Handler
      config :app_id, type: String, required: true

      route(/^currencies$/, :list_currencies, help: {
        "currencies" => "Show valid currencies",
      })

      route(/^(?:convert|exchange)\s+(.*)$/, :exchange, help: {
        "exchange FROM TO" => "Show exchange rate FROM for TO",
      })

      def list_currencies(response)
        response.reply "See: https://docs.openexchangerates.org/docs/supported-currencies"
      end

      def exchange(response)
        tokens = response.match_data[1].split.map { |t| t.upcase }
        value, currencies = tokens.partition { |t| /[\d\.]+/.match?(t) }

        from, to = currencies
        value = value.any? ? value[0].to_f : 1.0

        exchange_rate = convert(from, to)

        response.reply "#{from} \u279e #{to}: #{sprintf("%0.2f", value * exchange_rate)}"
      end

      private

      def currencies
        currencies_api_url = "https://openexchangerates.org/api/currencies.json"
        req = http.get(currencies_api_url, app_id: config.app_id)
        currencies = MultiJson.load(req.body)
        currencies
      end

      def convert(from, to)
        valid_currencies = currencies.collect {|currency, comment| currency}

        [from, to].each do |currency_code|
          unless valid_currencies.include?(currency_code)
            return "Invalid currency code, please use 'currencies' for a valid list!"
          end
        end

        latest_exchange_rate_api_url = "https://openexchangerates.org/api/latest.json"
        req = http.get(latest_exchange_rate_api_url, app_id: config.app_id)
        exchange_rates = MultiJson.load(req.body)

        exchange_rates['rates'][from] / exchange_rates['rates'][to]
      end

      Lita.register_handler(self)
    end
  end
end
