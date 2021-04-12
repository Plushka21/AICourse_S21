It is better to run this Python code on Linux machine.

1) First, you need to install necessary libraries for Python (Pillow and tqdm), so run the following commands in terminal:
	$ python3 -m pip install --upgrade pip
	$ python3 -m pip install --upgrade Pillow
	$ python3 -m pip install --upgrade tqdm

2) Then you need to put some 512x512 image named 'input.png' in the same directory where Python code 'main.py' locates.

3) Using any IDE for Python run the code.

IMPORTANT! By default, number of generations is 500000, so it may take a lot of time to generate new image, approximately 2 hours. Therefore, if you do not to spend so much time, you can decrease number of generations, but therefore quality of output image will be less.

4) After execution result image will be saved in the same directory named 'output.png'
