import random
from PIL import Image, ImageChops, ImageDraw, ImageStat

# Open image that we want to redraw
original_image = Image.open("input.png")

# Size of population and number of generations
population_size = 10
num_generations = 200000

# Function to find firness for current image
# The less number, the better image fits
# Taken from https://www.programcreek.com/python/?code=victordomingos%2Foptimize-images%2Foptimize-images-master%2Foptimize_images%2Fimg_dynamic_quality.py
def calculate_fitness(image):
    # Find difference of images
    diff_img = ImageChops.difference(image, original_image)
    # Calculate difference as a ratio, i.e. fitness value
    stat = ImageStat.Stat(diff_img)
    fitness = sum(stat.mean) / (len(stat.mean) * 255)
    fitness *= 100

    return fitness

# Function to create initial population
def create_init_population():
    # Initialize empty list that will contain pairs (fitness, image)
    population = []

    # Since intially all images are blank, fitness values for all of them is the same:
    fitness = calculate_fitness(Image.new(original_image.mode, original_image.size, (0,0,0)))

    # Fill list with calculated fitness value and blank images
    for i in range(population_size):
        new_image = Image.new(original_image.mode, original_image.size, (0,0,0))
        population.append((fitness, new_image))
        
    # Return initial population
    return population

# Function for mutation
# Mutation is placing '*' character in random place and with random colour
def mutation(image):
    image_copy = image.copy()
    draw_image = ImageDraw.Draw(image_copy)

    draw_image.text(
                # Generate random coordinates
                (random.randint(-5, image.width + 5), random.randint(-5, image.height + 5)),
    		    '*',
                # Generate random colours
    		    (random.randint(1, 255), random.randint(1, 255), random.randint(1, 255))
            )
    
    # Return resulting image
    return image_copy

# Function to create population, i.e. increase number of members on image
def create_population(population):
    # Create empty list for new population
    new_population = []
    
    # Since items in population list are sorted by fitness value, 
    # we keep only first half of images that are the best comparing to original image
    for i in range(len(population)//2):
        # So we copy old members
        new_population.append(population[i])

        # And perform mutation on this image, i.e. add more '*' characters
        new_image = mutation(population[i][1])
        # Calculate fitness for this new image
        new_fitness = calculate_fitness(new_image)
        # And add it into the list with new population
        new_population.append((new_fitness, new_image))
    
    # After all steps, sort images by fitness value, so the best will be on first places
    new_population.sort(key = lambda x: x[0])
    return new_population

# Function to draw image
def draw_image(population):

    # For certain amount of times we generate population, 
    # by removing inappropriate images, i.e. with high fitness value
    # and by generating new images with more '*' signs
    for i in range(num_generations):
        population = create_population(population)

    # Since the best image will be on the first place, we just return it
    return population[0][1]

if __name__ == "__main__":
    # Generate initial population
    population = create_init_population()
    # Draw image
    new_image = draw_image(population)
    # Save result
    new_image.save("output.png")