require './driver'


def main
	driver = Driver.new()
	driver.go()
end


if __FILE__ == $0 #If this was the file called  from the command line
	main()
end