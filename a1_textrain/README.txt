Christopher You
You00017@umn.edu

I have commented my code very specifically but I will state some of these things again here.
My letters are created through a class constructor (Line 50).
This constructor called "Letter" that has all of the features of the letter:
Position, color, speed falling down, speed going up.

I use several lists/arrays throughout.
I have a list of Letters that is used primarily to tell me how many letters on screen and allows for 
easy access of their position.
I have a list of strings that contain the characters from our phrase.
I also have an int list called "range" that is used in my pre-emptive algorithm (scroll down).

Basic Information:
I start by flipping the image.
This is done with simple swap algorithms and saving previous values in temp variables.

Spacebar:
Sets a toggle boolean as true or false.
Depending on the value, it will either make the image all black/white, or will set it back to normal.

Up Arrow:
Raises the overall threshold for pixels

Down Arrow:
Lowers the overall threshold for pixels

!!!!!!EXTRA BUTTONS!!!!!!
Left Arrow: 
Decreases the overall brightness of the displayed image.

Right Arrow: 
Increases the overall brightness of the displayed image.

Gray Scaling:
Each frame, I average out the colors of each pixel and set the color to their average.
This sets their brightness to gray scale.

Letter Generation:
Letters are generated every 600 frames.
We only spawn new letters if there are less than 4 on the screen.
Any time a letter is generated, we assign it a color and position.
Its y-position is generated at random somewhere off screen.
Its x-position is a fixed location.

Algorithms:
Pre-Emptive and Reflexive.

If we find something below the threshold in the next 10 pixels, we will decide that we need to move up
We do this by setting a boolean "shouldWeMoveUp" to true, telling us, we need to move up.
If it turns to false, meaning that we don't need to move it up, then it tells us that we are fine.

Reflexive:
If we are inside of a black pixel, then we know we have to move.  
We might not be able to detect a black pixel since it might come from the left or right side.
If  we find one, we will use a while loop to essentially shoots us back to the top.

This is shown in lines 260-283

Pre-Emptive:
If we're not directly in a black pixel, but one is coming, we can simply push our letter up a little bit
this will stop it from hitting a black pixel and give a small gap between the letter and black pixels.

Normal:
If we don't need to do either of these, we can just move our letter downward.
We can also delete letters that move off screen for clean up.

Velocity via Time rather than draw():
My deltaTime was always = 0 no matter what I did, so I gave up on this but here's the implementation of how it would be done.

I gave each Letter class a previousTime and currentTime.
I would measure the currentTime and subtract the previousTime (divided by 1000) to get the delta time.
Then once I did the calculation, I would update previousTime to be equal to currentTime.
class Letter {
	.
	.
	.
	previousTime = millis();
	currentTime = millis();
}

draw() {
	.
	.
	.
	letter.currentTime = millis();
	deltaTime = letter.currentTime - letter.previousTime;
	deltaTime /= 1000;
	letter.posy += (letter.speed * deltaTime);
	letter.previousTime = letter.currentTime;
	}



Here is how I get randomization, but still have chances to get a word:

I arbitrarily selected to spawn brand new letters every 500 frames,
but in order for them to spawn the following things happen:

First of all, a letter only spawns if there are less than 8 copies of that letter on the screen.
If my string is "Hello, my name is John", the "H" only appears if there are less than 8 H's.
Each letters is not considered to be unique so while there are 2 "l" letters,
so there can only be 4 of each "l" or some variation.


This is mostly used to diminish clutter and the likelihood of collecting sentences and phrases.

Next, we randomize the letter position. Letters are not all spawned at y = 0.  They are spawned at a random int such that it is between
(-700, 0).  By doing this, it gives off the appearance of randomized letter spawning, but in reality all letters are spawned at the same time.  
The only difference is that my letters progress through the out of bounds area, and eventually will reach the screen and appear as if they spawned at 
y = 0.

Also while this is part of a different instruction, by allowing for differing letter velocities, we are able to give off more randomness in letters,
thus I see that as a compliment to my progress.
