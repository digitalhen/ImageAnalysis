require 'chunky_png'

class ChunkyPNG::Image
  def neighbors(x,y)
    [[x, y-1], [x+1, y], [x, y+1], [x-1, y]].select do |xy|
      include_xy?(*xy)
    end
  end
end

def label_recursively(image, areas, label, x, y)
  image[x,y] = label
  (areas[label] ||= []) << [x,y]

  image.neighbors(x,y).each do |xy|
    if image[*xy] == -1
      areas[label] << xy
      label_recursively(image, areas, label, *xy)
    end
  end
end

# which file should we read?
file = "port"

# read the image, and duplicate in memory
image = ChunkyPNG::Image.from_file(file + '.png')
working_image = image.dup

# TODO: create an array, with rgb lower as the first three, and rgb upper as the second three

fires = Hash.new
fires["orange"] = [ 210, 50, 0, 250, 90, 30 ]
fires["horange"] = [ 200, 50, 30, 230, 90, 70 ]
fires["hdarkred"] = [ 125, 30, 20, 179, 60, 60 ]
fires["worange"] = [ 230, 130, 50, 250, 150, 75 ]
fires["sdarkorange"] = [ 230, 70, 15, 250, 90, 35 ]
fires["slightorange"] = [ 240, 130, 45, 255, 160, 110 ]
fires["spink"] = [ 240, 150, 125, 255, 170, 145 ]
fires["sdarkpink"] = [ 240, 220, 105, 255, 240, 125 ]
fires["smelon"] = [ 240, 157, 105, 255, 177, 125 ]
fires["syellow"] = [ 240, 202, 74, 255, 222, 94 ]
fires["sorange"] = [ 240, 157, 89, 255, 177, 109 ]
fires["slightorange"] = [ 240, 202, 130, 255, 222, 150 ]
fires["cyellow"] = [ 245, 240, 70, 255, 255, 110 ]
fires["cyellow2"] = [ 245, 240, 135, 255, 255, 155 ]
fires["torange"] = [ 199, 87, 36, 219, 107, 56 ]
fires["tedge"] = [ 190, 83, 40, 210, 103, 60 ]
fires["trust"] = [ 202, 108, 55, 222, 128, 75 ]

# set bounds
#smokeupperbound = 75
#smokelowerbound = 60

# set fire bounds
#fireupperred = 255
#firelowerred = 220
#fireuppergreen = 180
#firelowergreen = 60
#fireupperblue = 40
#firelowerblue = 20

working_image.pixels.map! do |pixel|
  redness = ChunkyPNG::Color.r(pixel)
  greenness = ChunkyPNG::Color.g(pixel)
  blueness = ChunkyPNG::Color.b(pixel)
  
  pixelvalue = 0
  
  # TODO: loop through bounding array and check if the pixel matches any
  
  fires.each do | name,data |
  	if redness >= data[0] && redness <= data[3] && greenness >= data[1] && greenness <= data[4] && blueness >= data[2] && blueness <= data[5]
  		pixelvalue = -1
  		#puts "Fire detected!"
  	end
  end  
  
  pixelvalue
end

areas, label = {}, 0

working_image.height.times do |y|
  working_image.row(y).each_with_index do |pixel, x|
    label_recursively(working_image, areas, label += 1, x, y) if pixel == -1
  end
end

# TODO: count number of areas, and total percentage of image
#puts "Found " + areas.count.to_s + " matching areas!"
#puts (image.width * image.height).to_s + " pixels in the image"

totalarea = 0

areas.each do |result, area| 
	x, y = area.map{ |xy| xy[0] }, area.map{ |xy| xy[1] }
	if ((y.max-y.min)*(x.max-x.min)) > 1
		image.rect(x.min, y.min, x.max, y.max, ChunkyPNG::Color.rgb(0,255,0))
	end
	
	totalarea = totalarea + ((y.max-y.min)*(x.max-x.min))
end

#area = areas.values.max { |result, area| result.length <=> area.length }
#x, y = area.map{ |xy| xy[0] }, area.map{ |xy| xy[1] }

# need to decide here if it's an important size
#image.rect(x.min, y.min, x.max, y.max, ChunkyPNG::Color.rgb(0,255,0))

#puts (y.max - y.min) * (x.max - x.min)

# print total area
puts totalarea.to_s + " pixels total area detected"

# save the images
working_image.save(file + '_detected.png')
image.save(file + '_bounded.png')