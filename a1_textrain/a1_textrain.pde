/**
 CSci-4611 Assignment #1 Text Rain
 **/


import processing.video.*;
import java.util.*;

// Global variables for handling video data and the input selection screen
String[] cameras;
Capture cam;
Movie mov;
PImage inputImage;
boolean inputMethodSelected = false;

int previousTime;
int curTime;
//Our phrase
String phrase = "my life has been the poem I would have writ but I could not both live and utter it ";

//Size of phrase
int phraseLength = phrase.length();

//Number of frames that have happened while program runs
int frames;

//Our font
PFont myFont;

//Boolean to determine if we should toggle black and white mode.
boolean isToggled = false;

//threshold default set to 128
int threshold;

//An array to store the values for the current and next 10 pixels under our letter.
int[] range = new int[11];

//Our list of letters in our phrase
//This is phrase letters but each letter is its own string
List<String> phraseLetters = new ArrayList<String>();

//Our array of letters on the screen. I've made a class Letter
List<Letter> letters = new ArrayList<Letter>();

//boolean to tell us if we need to move up or not because we are about to hit a black pixel
boolean shouldWeMoveUp = false;

//Brightnesschange is an int to change our overall brightness.  This is an extra function I wrote that uses the left/right arrow keys
int brightnessChange = 0;

//Our class letter
//It describes each falling letter and all the characteristics of them.
class Letter {
  String letter;
  int posx;
  int posy;
  color dispColor;
  int speedUp;
  int speedDown;
  int previousTime;
  int currentTime;
  Letter(String character, int letterNum) {
    letter = character;
    posx = inputImage.width * (1 + letterNum)/phraseLength;
    posy = int(random(-700, 0));
    dispColor = color(int(random(0, 255)), int(random(0, 255)), int(random(0, 255)));
    //Differing Velocities such as in Bullet Point A
    speedDown = int(random(1,4));
    speedUp = -speedDown;
    previousTime = millis();
    currentTime = millis();
  }
}


void setup() {
  size(1280, 720);  
  inputImage = createImage(width, height, RGB);
  threshold = 128;
  frames = 0;
  myFont = createFont("Georgia", 22);
  textFont(myFont);
  for (int i = 0; i < phrase.length(); i++) {
    phraseLetters.add(phrase.charAt(i) + "");
  }

}


void draw() {
  // When the program first starts, draw a menu of different options for which camera to use for input
  // The input method is selected by pressing a key 0-9 on the keyboard
  curTime = millis();

  if (!inputMethodSelected) {
    cameras = Capture.list();
    int y=40;
    text("O: Offline mode, test with TextRainInput.mov movie file instead of live camera feed.", 20, y);
    y += 40; 
    for (int i = 0; i < min(9, cameras.length); i++) {
      text(i+1 + ": " + cameras[i], 20, y);
      y += 40;
    }
    return;
  }


  // This part of the draw loop gets called after the input selection screen, during normal execution of the program.


  // STEP 1.  Load an image, either from a movie file or from a live camera feed. Store the result in the inputImage variable

  if ((cam != null) && (cam.available())) {
    cam.read();
    inputImage.copy(cam, 0, 0, cam.width, cam.height, 0, 0, inputImage.width, inputImage.height);
  } else if ((mov != null) && (mov.available())) {
    mov.read();
    inputImage.copy(mov, 0, 0, mov.width, mov.height, 0, 0, inputImage.width, inputImage.height);
  }


  // Fill in your code to implement the rest of TextRain here..

  // Tip: This code draws the current input image to the screen

  //Load the inputImage
  set(0, 0, inputImage);
  loadPixels();
  //Flips image so that we are looking in the same direction in the mirror.
  //Simply double for loop that flips, nothing fancy.
  for (int i = 0; i < pixelHeight; i++) {
    for (int j = 0; j < pixelWidth/2; j++) {
      int curIndex = (i * pixelWidth) + j;
      int switchIndex =((i+1) * pixelWidth) - 1 - j;
      color temp = pixels[curIndex];
      pixels[curIndex] = pixels[switchIndex];
      pixels[switchIndex] = temp;
    }
  }
  updatePixels();

  //Check to see if the user has activated the toggle or not.
  //If he has, then we will find all the pixels on the screen,
  //We will loop through them, and set them to either black or white.
  int totalPixels = pixelWidth * pixelHeight;
  if (isToggled) {
    for (int i = 0; i < totalPixels; i++) {
      if (green(pixels[i]) <= threshold) {
        pixels[i] = color(0);
      } else {
        pixels[i] = color(255);
      }
    }
  }  


  //I've included an increase brightness function that is controlled by the left and right arrow keys
  //Doesn't provide anything other than simply aesthetic.
  //Looks at each pixel
  //Increases the brightness of the pixel by brightnessChange 
  //brightnessChange is an int that increases by 1 everytime the up key is pressed
  //And it decreases by 1 everytime the down key is pressed
  //If it tries to go over 255 or below 0, I will set it to 255 or 0 respectively.
  for (int i = 0; i < totalPixels; i++) {
    float r, g, b = 0;
    if (red(pixels[i]) + brightnessChange > 255) {
      r = 255;
    } else if (red(pixels[i]) + brightnessChange < 0) {
      r = 0;
    } else {
      r = red(pixels[i]) + brightnessChange;
    }

    if (green(pixels[i]) + brightnessChange > 255) {
      g = 255;
    } else if (green(pixels[i]) + brightnessChange < 0) {
      g = 0;
    } else {
      g = green(pixels[i]) + brightnessChange;
    }

    if (blue(pixels[i]) + brightnessChange > 255) {
      b = 255;
    } else if (blue(pixels[i]) + brightnessChange < 0) {
      b = 0;
    } else {
      b = green(pixels[i]) + brightnessChange;
    }
    pixels[i] = color(r, g, b);
  }


  //This greyscales the image.
  //Finds the average of the pixel colors
  //Then sets the color of the pixels to the average
  for (int i = 0; i < totalPixels; i++) {
    float r = red(pixels[i]);
    float g = green(pixels[i]);
    float b = blue(pixels[i]);
    float average = (r+g+b)/3;
    pixels[i] = color(average, average, average);
  }
  updatePixels();




  //Determines when to generate new letters
  //Currently we are generating letters every 500 frames.
  if (frames % 500 == 0) {
    for (int i = 0; i < phraseLength; i++) {
      int numberOfLetters = 0;      
      for (int j = 0; j < letters.size(); j++) {
        if ((letters.get(j)).letter == phraseLetters.get(i)) {
          numberOfLetters ++;
        }
      }
      //We only have 8 of a letter on screen at a time.
      if (numberOfLetters < 8) {
        Letter newLetter = new Letter(phraseLetters.get(i), i);
        letters.add(newLetter);
        fill(newLetter.dispColor);
        text(newLetter.letter, newLetter.posx, newLetter.posy);
      }
    }
  }

  //This long for loop boils down to basically two things.
  //A reflexive algorithm
  //A preemptive algorithm
  //A Normal action
  //We check the numberOfLettersOnScreen 
  //And for each letter on the screen we will decide whether want to do the following:
  // Move it up because its caught in something
  // Move it up because it might hit something (pre-emptive)
  // Move it down as normal
  int numberOfLettersOnScreen = letters.size();
  for (int i = 0; i < numberOfLettersOnScreen; i++) {
    //Calculate the current position of the pixel we are at.
    int pixelLocY = (letters.get(i)).posy;
    int pixelLocX = (letters.get(i)).posx;
    //This for loop checks the next 10 pixels below a letter image.
    //If we find something below the threshold in the next 10 pixels, we will decide that we need to move up
    //We do this by setting a boolean "shouldWeMoveUp" to true, telling us, we need to move up.
    //If it turns to false, meaning that we don't need to move it up, then it tells us that we are fine.
    for (int j = 0; j < 10; j++) {
      range[j] = ((pixelLocY + j) * inputImage.width) + pixelLocX;
      if (range[j] > 0 && range[j] < totalPixels && int(green(pixels[range[j]])) <= threshold) {
        shouldWeMoveUp = true;
      } else {
        shouldWeMoveUp = false;
      }
    }

    //So if it turns out we need to move up then we make one immediate check.
    if (shouldWeMoveUp) {
      //This check tells us if our letter is currently inside a black pixel.
      //This can happen if an object moves left to right rather than down to up.  
      //I deemed that the best way to handle this scenario is with a while loop.
      if (range[0] > 0 && range[0] < totalPixels && int(green(pixels[range[0]])) <= threshold) {
        boolean moveUp = true;
        int moveUpToPixel;
        int sub = 1;
        while (moveUp) {
          //The while loop checks the pixel directly above where we are. 
          //If its a white pixel, we can move to it.
          //If it isn't then we need to move our letter even further up.
          //We only exit out of the loop when we find a safe place to move our pixel.
          //This is the reflexive part of the algorithm.
          moveUpToPixel = (((letters.get(i)).posy - sub) * inputImage.width) + (letters.get(i)).posx;
          if (moveUpToPixel > 0 && moveUpToPixel < totalPixels && int(green(pixels[moveUpToPixel])) > threshold) {
            int yPixel = (moveUpToPixel - (letters.get(i)).posx)/inputImage.width;
            (letters.get(i)).posy = yPixel;
            fill((letters.get(i)).dispColor);
            text((letters.get(i)).letter, (letters.get(i)).posx, (letters.get(i)).posy);
            moveUp = false;
          } else {
            sub++;
            moveUpToPixel = (((letters.get(i)).posy - sub) * inputImage.width) + (letters.get(i)).posx;
          }
        }
      } else {
        //If we aren't directly on a black pixel, but we see one is coming our way
        //We will have our letter move up a bit.
        //This is our pre-emptive algorithm.
        //deltaTime is used to cause pixels to move per second rather than frame
        (letters.get(i)).posy += (letters.get(i)).speedUp;
        fill((letters.get(i)).dispColor);
        text((letters.get(i)).letter, (letters.get(i)).posx, (letters.get(i)).posy);
      }
    }
    //If there's no black coming our way, then we are safe to simply move down.
    else {
      //If we end up moving the letter off screen, we'll delete it and this will also help with keeping track of how many letters on screen.
      if ((letters.get(i)).posy - 5 > inputImage.height) {
        letters.remove(i);
      } else {
        //If we aren't going off screen, then we can move the letter down as normal.
        //Increase the y position and move on.
        //Ensure that it has the proper colors too.
        //  (letters.get(i)).currentTime = millis();
        // int deltaTime = (letters.get(i)).currentTime - (letters.get(i)).previousTime;
        //deltaTime /= 1000;
        //print("Delta Time : " + deltaTime + "\n");
        //(letters.get(i)).previousTime = (letters.get(i)).currentTime;
        (letters.get(i)).posy += (letters.get(i)).speedDown;
        fill((letters.get(i)).dispColor);
        text((letters.get(i)).letter, (letters.get(i)).posx, (letters.get(i)).posy);
      }
    }
    //We need to change numberOfLettersOnScreen every time because we might remove letters, so this
    //Needs to be a constantly changing value.
    numberOfLettersOnScreen = letters.size();
  }
  //Keeping track of frames so we know how often to spawn letters.
  frames++;
}



void keyPressed() {

  if (!inputMethodSelected) {
    // If we haven't yet selected the input method, then check for 0 to 9 keypresses to select from the input menu
    if ((key >= '0') && (key <= '9')) { 
      int input = key - '0';
      if (input == 0) {
        println("Offline mode selected.");
        mov = new Movie(this, "TextRainInput2.mov");
        mov.loop();
        inputMethodSelected = true;
      } else if ((input >= 1) && (input <= 9)) {
        println("Camera " + input + " selected.");           
        // The camera can be initialized directly using an element from the array returned by list():
        cam = new Capture(this, cameras[input-1]);
        cam.start();
        inputMethodSelected = true;
      }
    }
    return;
  }


  // This part of the keyPressed routine gets called after the input selection screen during normal execution of the program
  // Fill in your code to handle keypresses here..


  if (key == CODED) {

    //Increasing/Decreasing Threshold
    if (keyCode == UP) {
      threshold++;
    } else if (keyCode == DOWN) {
      threshold--;
    }

    //Increasing/Decreasing overall brightness (I made this function for no reason)
    else if (keyCode == LEFT) {
      brightnessChange--;
    } else if (keyCode == RIGHT) {
      brightnessChange++;
    }
  }

  //If the space key is pressed, the global boolean "isToggled" is changed.
  //"isToggled" is true causes the black and white filter to be toggled.
  //"isToggled" is false causes no filter to be toggled.
  //Determines if toggle is on for black and white.
  else if (key == ' ') {
    if (isToggled) {
      isToggled = false;
    } else {
      isToggled = true;
    }
  }
}
