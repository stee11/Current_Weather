require './location'
require 'open-uri'

class Driver
	def initialize()
		@url = "http://www.weather.com/weather/today/" #Url/xxxxx is what we will ping
		@date = "" #Last day of use
		@clock = "" #Last time of use
		@places = [] #All of the location. Zipcodes found in the zipcodes.txt file
		@place_numbers = 0 #Used for adding location to array
		begin #Get last time of use from the file.
			file = File.open("date.txt", "r")
			@date = file.gets
			@clock = file.gets
			@date.strip!
			@clock.strip!
		rescue Exception => e #Set to default date
			puts "WARNING: Was not able to determine last time the application has been used."
			@date = "00/00/0000"
			@clock = "00:00"
		end
	end
	def go
		puts "Welcome to Steven Kolln's Weather Program!!!\n"
		puts "Would you like to update your weather data? The last time it was updated was: "+date+" at "+clock+"."
		puts "Not updating will only allow you to use individual queries on individual places."
		puts "Type Yes to update or No to not have United States biggest cities data:"
		STDOUT.flush #Flush any characters left in stream
		answer = gets.chomp().downcase
		if (answer.chr == 'y') #Will scrape weather.com for data on cities with > 100,000 population
			puts "\nUpdating data..."
			updateData
			groupQuery

		else #Only allows for individual zip code queries
			puts "\nWill not update data.\n"
			run = true
			while (run)
				puts "Please enter the zipcode of the weather you would like to see:"
				STDOUT.flush
				answer = gets.chomp()
				singleQuery(answer.to_s)
				puts "\nWould you like to search again? Yes or no?"
				STDOUT.flush
				answer = gets.chomp().downcase
				if (answer.chr != 'y')
					run = false
					puts "Bye Bye!"
				end
			end
		end
	end

	def singleQuery(zip)
		begin
			source = open(@url+zip.to_s).read #Open URL and get HTML
			place = source[/[a-zA-Z]*\S\s[A-Z]{2}\s\S[0-9]{5}\S\sWeather/] #Regex for town
			temperature = source[/<span itemprop="temperature-fahrenheit">\d*<\/span>/] #Regex for temp
			conditions = source[/<div class="wx-phrase ">[A-Z][a-zA-Zs\s]*<\/div>/] #Regex for conditions
			town = place[0,place.index(',')]
			state = place[place.index(',')+2,2]
			zip = place[place.index(',')+6,5]
			temp = temperature[temperature.index(">")+1, 2]
			if temp[1] == '<'
				temp = '0'+temp[0]
			end
			descrip = conditions[conditions.index(">")+1, (conditions.index("</") - conditions.index(">"))-1]
			loc = Location.new(town, state, zip, temp, descrip) #Make new location object
			puts loc #Print the object
		rescue Exception => e
			puts "The zipcode given was not found or entered incorectly."
		end
	end
	def groupQuery()
		continue = true
		return_array = [] # Array with our data we will return
		while continue
			puts"\nOptions:\n1: Find areas given a temperature\n2: Find coldest areas\n3: Find warmest areas\n4: Enter a zipcode for data.\n5: Vew all cities"
			STDOUT.flush
			answer = gets.chomp()
			case answer.chr #Switch case for user entry
			when "1"
				puts "Please enter the temperature you would like to see:"
				STDOUT.flush
				begin
					tem = gets.chomp().to_i
					count = 0
					for i in 0...@places.length #Does our array contain the temp entered by our user
						if @places[i].temperature.to_i == tem.to_i
							return_array[count] = @places[i]
							count+=1
							if count == 5 #Max of 5
								break
							end
						end
					end
					if count == 0 #If there we not matches
						puts "Could not find an area with you temperature. Here are close results:"
						@places.sort! {|a,b| a.temperature.to_i <=> b.temperature.to_i}
						if tem.to_i < @places[0].temperature.to_i #Pick the coldest ones if the user entered the colest temp
							puts @places[0], @places[1], @places[2]
						else
							for i in 0...@places.length
								if i == 0
								else
									if @places[i].temperature.to_i > tem.to_i #Find the middle, upper, and lower temps
										puts @places[i-1], @places[i], @places[i+1]
										break
									elsif i == @places.length-2 #Pick the highest temperatures if high temp entered
										puts @places[@places.length-1], @places[(@places.length)-2], @places[(@places.length)-3]
										break
									end
								end
							end
						end
					else #If there were matches print them
						for i in 0...return_array.length
							puts return_array[i]
						end
					end
				end
			when "2" #Sort by colest to warmest
				@places.sort! {|a,b| a.temperature <=> b.temperature}
				for i in 0...5
					puts @places[i]
				end
			when "3" #Sort by warmest to coldest
				@places.sort! {|a,b| b.temperature <=> a.temperature}
				for i in 0...5
					puts @places[i]
				end
			when "4" #Call singlequery
				puts "Please enter the zipcode of the weather you would like to see:"
				STDOUT.flush
				answer = gets.chomp()
				singleQuery(answer.to_s)
			when "5" #Print all
				for i in 0...@places.length
					puts @places[i]
				end
			else
				puts "Invalid number entered. You entered: "+answer
			end
			puts "\nWould you like to search again? Yes or no?"
			STDOUT.flush
			answer = gets.chomp().downcase
			if (answer.chr != 'y')
				continue = false
				puts "Bye Bye!"
			end
		end
	end
	def updateData
		file = File.open("zipcodes.txt", "r")
		while(line = file.gets) #While our file has more zipcodes
			begin
				line.strip!
				source = open(@url+line).read
				place = source[/[a-zA-Z]*\S\s[A-Z]{2}\s\S[0-9]{5}\S\sWeather/] #Regex for town, temp, and conditions
				temperature = source[/<span itemprop="temperature-fahrenheit">\d*<\/span>/]
				conditions = source[/<div class="wx-phrase ">[A-Z][a-zA-Zs\s]*<\/div>/]
				town = place[0,place.index(',')]
				state = place[place.index(',')+2,2]
				zip = place[place.index(',')+6,5]
				temp = temperature[temperature.index(">")+1, 2]
				if temp[1] == '<'
					temp = '0'+temp[0]
				end
				descrip = conditions[conditions.index(">")+1, (conditions.index("</") - conditions.index(">"))-1]
				loc = Location.new(town, state, zip, temp, descrip)
				@places[@place_numbers] = loc
				@place_numbers +=1
				print ((@place_numbers.to_f / 249)*100).to_s[0,4] + "%\r" #Print percentage done
			rescue Exception => e
				puts e.backtrace
			end
		end
		writeTime #Write the time of last update
		file.close
	end


	def writeTime
		timer = Time.new #Timer obj
		@date = timer.month.to_s + "/" + timer.day.to_s + "/" + timer.year.to_s
		hour = timer.hour
		minutes = timer.min
		if hour > 12 #Convert to 12 hour time
			hour -= 12
			@clock = hour.to_s + ":"+minutes.to_s+" PM"
		else
			@clock ="0" + hour.to_s + ":"+minutes.to_s+" AM"
		end
		begin
			file = File.open("date.txt", "w")
			file.write(@date+"\n")
			file.write(@clock)
		rescue IOError => e
			puts "WARNING: Was not able to update timer."
		end
	end

	#Getters
	def url
		@url
	end
	def clock
		@clock
	end
	def date
		@date
	end
	def places
		@places
	end
	def place_numbers
		@place_numbers
	end

	#Setters
	def url=(url)
		@url = url
	end
	def clock=(clock)
		@clock = clock
	end
	def date=(date)
		@date = date
	end
	def place_numbers=(place_numbers)
		@place_numbers = place_numbers
	end
end
