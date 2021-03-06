module Smile
  module Common
    BASE = 'http://api.smugmug.com/hack/json/1.2.0/'
    BASE_SECURE = 'https://api.smugmug.com/hack/json/1.2.0/'
    UPLOAD = "http://upload.smugmug.com/"

    VERSION = '1.2.0'

    def session
      @session ||= Session.instance
    end

    # This will be included in every request once you have logged in
    def default_params
      @params ||= { :api_key => session.api_key }
      @params.merge!( :session_id => session.id ) if( session.id )
      @params = Smile::ParamConverter.clean_hash_keys( @params )
    end

    # This is the base work that will need to be done on ALL
    # web calls.  Given a set of web options and other params
    # call the web service and convert it to json
    def web_method_call( web_options, options = {} )
			base_web_method_call( web_options, options, BASE )
    end

    # This is the base work that will need to be done on ALL
    # web calls.  Given a set of web options and other params
    # call the web service and convert it to json
    def secure_web_method_call( web_options, options = {} )
			base_web_method_call( web_options, options, BASE_SECURE )
    end

		# Call either the secure or the base web url
		def base_web_method_call( web_options, options ={}, url )
      options     = Smile::ParamConverter.clean_hash_keys( options )
      web_options = Smile::ParamConverter.clean_hash_keys( web_options )

      params = default_params.merge( web_options )
      params.merge!( options ) if( options )

      logger.info( params.inspect )

      json = RestClient.post( url, params ).body
      upper_hash_to_lower_hash( Smile::Json.parse( json ) )
		end

    # This converts a hash that has mixed case
    # into all lower case
    def upper_hash_to_lower_hash( upper )
			case upper
			when Hash
        upper.inject({}) do |lower,array|
					key, value = array
          lower[key.downcase] = upper_hash_to_lower_hash( value )
					lower
        end
      else
        upper
      end
    end

    def logger
      session.logger
    end

    def logger_on?
      session.logger_on?
    end
  end
end
