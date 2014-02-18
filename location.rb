
class Location
	@@class_total = 0
	def initialize(city, state, zipcode, temperature, weather)
		@city = city
		@state = state
		@zipcode = zipcode
		@temperature = temperature
		@weather = weather
	end

	#To string
	def to_s
		city + ", "+state+" "+zipcode+": Weather is "+weather+" and "+temperature+" degrees."
	end
	#Getters
	def city
		@city
	end
	def state
		@state
	end
	def zipcode
		@zipcode
	end
	def temperature
		@temperature
	end
	def weather
		@weather
	end

	#Setters
	def city=(city)
		@city = city
	end
	def state=(state)
		@state = state
	end
	def zipcode=(zipcode)
		@zipcode = zipcode
	end
	def temperature=(temperature)
		@temperature = temperature
	end
	def weather=(weather)
		@weather = weather
	end
end