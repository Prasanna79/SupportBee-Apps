module SupportBeeApp
	class Base
		class << self
			attr_accessor :env
			attr_reader :title
			attr_reader :stub

			%w(development test production staging).each do |m|
      	define_method "#{m}?" do
        	env == m
      	end
    	end

    	def apps
				@apps ||= []
			end

			def schema
				@schema ||= []
			end

			def add_to_schema(type, attrs)
      	attrs.each do |attr|
        	schema << [type, attr.to_sym]
      	end
    	end

    	def string(*attrs)
      	add_to_schema :string, attrs
    	end

    	def password(*attrs)
      	add_to_schema :password, attrs
    	end

    	def boolean(*attrs)
      	add_to_schema :boolean, attrs
    	end

    	def set_title(app_title)
    		@title = app_title
    	end

    	def set_stub(app_stub)
    		@stub = app_stub
    	end

    	def receive(event, data, payload = nil)
    		app = new(event,data,payload)
    		methods = ["receive_#{event}","receive_event"]
    		if event_method = methods.detect {|method| app.respond_to?(method)}
    			app.send(event_method)
    			app
    		end
    	end

    	def inherited(app)
      	SupportBeeApp::Base.apps << app 
      	super
    	end

    	def setup_for(sinatra_app)
    		sinatra_app.setup(self)
    	end
		end

		attr_reader :data
		attr_reader :payload
		attr_reader :event

		self.env ||= ENV['RACK_ENV']

		def initialize(event = :'ticket.created', data = {}, payload = nil)
    	@event = event.to_sym
    	@data = data || {}
    	@payload = payload || {}
  	end
	end
end