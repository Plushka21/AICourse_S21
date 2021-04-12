# Anton Buguev BS19-02
# a.buguev@innopolis.university

from PIL import Image, ImageDraw
import random
import tqdm
import numpy as np
import math

# Size of population and number of generations
population_size = 262144 # Assuming that original image is 512x512, population size is 512*512 for each pixel
num_generations = 100

# Open original image
original_image = Image.open("3.0input.png")

# Calculate fitness value for specific member of population
def calculate_fitness(member):
    # Get colour of pixel where that member is located
    converted_image = original_image.convert('RGB')
    R_or, G_or, B_or = converted_image.getpixel((member[1], member[2]))

    # Calculate fitness value using root mean square approximation
    fitness = np.sqrt(np.mean(np.square([R_or - member[3], G_or - member[4], B_or - member[5]])))

    # Set fitness value for that member
    member[0] = fitness
    return member

# Create initial population
def create_init_population():
    print("Creating initial population...\n")

    # Population contains members that consist of fitness value, X coordinate, Y coordinate, RGB colour
    population = []

    # For every pixel of image generate character with random colour
    for i in range(0, original_image.width, 1):
        for j in range(0, original_image.height, 1):
            R_ch = random.randint(1, 255)
            G_ch = random.randint(1, 255)
            B_ch = random.randint(1, 255)

            new_member = [-1, i - 1, j - 1, R_ch, G_ch, B_ch]
            # Calculate fitness value
            new_member = calculate_fitness(new_member)
            population.append(new_member)

    # Sort all mebers by fitness value
    population.sort(key = lambda x: x[0])

    print("Initial popualtion is created.\n")
    return population

# Mutation of meber
# Mutation randomly changes one of RGB chanels of member to new random value
def colour_mutation(member):
    # Randomly choose wich chanel will be changed
    choose_colour = random.randint(3, 5)
    # Generate new value
    new_chanel = random.randint(1, 255)
    # Set new value
    member[choose_colour] = new_chanel
    # Recalculate fitness value
    member = calculate_fitness(member)

    return member

# Generate population for cpecific number of generation and draw image
def draw_image(population):
    print("Start generation of image...\n")
    # Set counter to track execution
    counter = tqdm.tqdm(total = num_generations, desc = 'Generations', position = 0)

    for i in range(num_generations):
        # Let us keep the best half of population while other half will be changed
        bad_population = population[(population_size // 2) :]
        # Mutate each member of population that feat the least
        for i in range(len(bad_population)):
            mutated_member = colour_mutation(bad_population[i])
            bad_population[i] = mutated_member
        # Change the worst half of population by new members
        population[(population_size // 2) :] = bad_population

        # Sort population members by fitness value
        population.sort(key = lambda x: x[0])

        counter.update(1)

    print("Population is created. Drawing...\n")

    population.sort(key = lambda x: (x[1], x[2]))

    # Create new blank image
    new_image = Image.new(original_image.mode, original_image.size, (255,255,255))
    image_draw = ImageDraw.Draw(new_image)
    # Draw each member of population as '*' character
    for member in population:
        image_draw.text(
                        (member[1], member[2]), '*', (member[3], member[4], member[5])
                        )
    return new_image

# Main finction
if __name__ == "__main__":
    # Create initial population
    population = create_init_population()
    # Draw image
    new_image = draw_image(population)
    # Save result
    new_image.save("h.png")
