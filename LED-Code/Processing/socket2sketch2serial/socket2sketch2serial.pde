/*  OctoWS2811 movie2serial.pde - Transmit video data to 1 or more
 Teensy 3.0 boards running OctoWS2811 VideoDisplay.ino
 http://www.pjrc.com/teensy/td_libs_OctoWS2811.html
 Copyright (c) 2013 Paul Stoffregen, PJRC.COM, LLC
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 */

// To configure this program, edit the following sections:
//
//  1: change myMovie to open a video file of your choice    ;-)
//
//  2: edit the serialConfigure() lines in setup() for your
//     serial device names (Mac, Linux) or COM ports (Windows)
//
//  3: if your LED strips have unusual color configuration,
//     edit colorWiring().  Nearly all strips have GRB wiring,
//     so normally you can leave this as-is.
//
//  4: if playing 50 or 60 Hz progressive video (or faster),
//     edit framerate in movieEvent().

import processing.video.*;
import processing.serial.*;
import java.awt.Rectangle;
import processing.net.*;

Client myClient;
String dataIn = " ";

//Movie myMovie;

float gamma = 1.7;

int numPorts=0;  // the number of serial ports in use
int maxPorts=24; // maximum number of serial ports

int xpos = 0;

PImage img;
PFont retro;

//Serial[] ledSerial = new Serial[maxPorts];     // each port's actual Serial port
Serial myPort;
String portName = "/dev/cu.usbmodem3973051";

Rectangle[] ledArea = new Rectangle[maxPorts]; // the area of the movie each port gets, in % (0-100)
boolean[] ledLayout = new boolean[maxPorts];   // layout of rows, true = even is left->right
PImage[] ledImage = new PImage[maxPorts];      // image sent to each port
int[] gammatable = new int[256];
int errorCount=0;
float framerate=0;
PImage cvImg = createImage(304, 32, RGB);

void setup() {
  //String[] list = Serial.list();
  //println("Serial Ports List:");
  //println(list);
  for (int i=0; i < 256; i++) {
    gammatable[i] = (int)(pow((float)i / 255.0, gamma) * 255.0 + 0.5);
  }
  size(304, 32);  // create the window
  //img = loadImage("rainbow.png");
  //myMovie = new Movie(this, "kaleido.mp4");
  //println("Movie added");
  //myMovie.loop();  // start the movie :-)
  //println("Movie should be playing");
  //serialConfigure("/dev/cu.usbmodem3973051");  // change these to your port names
  //serialConfigure("/dev/tty.usbmodem3973051");
  //myPort = new Serial(this, portName);

  myClient = new Client(this, "127.0.0.1", 50008);

  desperation();
  if (errorCount > 0) exit();
  retro = createFont("5x90.ttf", 10);
}

/*
// movieEvent runs for each new frame of movie data
 */void movieEvent(Movie m) {
  // read the movie's next frame
  m.read();/*
 
   //if (framerate == 0) framerate = m.getSourceFrameRate();
   framerate = 30.0; // TODO, how to read the frame rate???
   
   for (int i=0; i < numPorts; i++) {    
   // copy a portion of the movie's image to the LED image
   int xoffset = percentage(m.width, ledArea[i].x);
   int yoffset = percentage(m.height, ledArea[i].y);
   int xwidth =  percentage(m.width, ledArea[i].width);
   int yheight = percentage(m.height, ledArea[i].height);
   ledImage[i].copy(m, xoffset, yoffset, xwidth, yheight, 
   0, 0, ledImage[i].width, ledImage[i].height);
   // convert the LED image to raw data
   byte[] ledData =  new byte[(ledImage[i].width * ledImage[i].height * 3) + 3];
   image2data(ledImage[i], ledData, ledLayout[i]);
   if (i == 0) {
   ledData[0] = '*';  // first Teensy is the frame sync master
   int usec = (int)((1000000.0 / framerate) * 0.75);
   ledData[1] = (byte)(usec);   // request the frame sync pulse
   ledData[2] = (byte)(usec >> 8); // at 75% of the frame time
   } else {
   ledData[0] = '%';  // others sync to the master board
   ledData[1] = 0;
   ledData[2] = 0;
   }
   // send the raw data to the LEDs  :-)
   //ledSerial[i].write(ledData);
   myPort.write(ledData);
   }*/
}

void canvasevent(PImage m) {
  for (int i=0; i < numPorts; i++) {    
    // copy a portion of the movie's image to the LED image
    int xoffset = percentage(m.width, ledArea[i].x);
    int yoffset = percentage(m.height, ledArea[i].y);
    int xwidth =  percentage(m.width, ledArea[i].width);
    int yheight = percentage(m.height, ledArea[i].height);
    ledImage[i].copy(m, xoffset, yoffset, xwidth, yheight, 
      0, 0, ledImage[i].width, ledImage[i].height);
    // convert the LED image to raw data
    byte[] ledData =  new byte[(ledImage[i].width * ledImage[i].height * 3) + 3];
    image2data(ledImage[i], ledData, ledLayout[i]);
    if (i == 0) {
      ledData[0] = '*';  // first Teensy is the frame sync master
      int usec = (int)((1000000.0 / framerate) * 0.75);
      ledData[1] = (byte)(usec);   // request the frame sync pulse
      ledData[2] = (byte)(usec >> 8); // at 75% of the frame time
    } else {
      ledData[0] = '%';  // others sync to the master board
      ledData[1] = 0;
      ledData[2] = 0;
    }
    // send the raw data to the LEDs  :-)
    //ledSerial[i].write(ledData);
    //myPort.write(ledData);
  }
}

// image2data converts an image to OctoWS2811's raw data format.
// The number of vertical pixels in the image must be a multiple
// of 8.  The data array must be the proper size for the image.
void image2data(PImage image, byte[] data, boolean layout) {
  int offset = 3;
  int x, y, xbegin, xend, xinc, mask;
  int linesPerPin = image.height / 8;
  int pixel[] = new int[8];

  for (y = 0; y < linesPerPin; y++) {
    if ((y & 1) == (layout ? 0 : 1)) {
      // even numbered rows are left to right
      xbegin = 0;
      xend = image.width;
      xinc = 1;
    } else {
      // odd numbered rows are right to left
      xbegin = image.width - 1;
      xend = -1;
      xinc = -1;
    }
    for (x = xbegin; x != xend; x += xinc) {
      for (int i=0; i < 8; i++) {
        // fetch 8 pixels from the image, 1 for each pin
        pixel[i] = image.pixels[x + (y + linesPerPin * i) * image.width];
        pixel[i] = colorWiring(pixel[i]);
      }
      // convert 8 pixels to 24 bytes
      for (mask = 0x800000; mask != 0; mask >>= 1) {
        byte b = 0;
        for (int i=0; i < 8; i++) {
          if ((pixel[i] & mask) != 0) b |= (1 << i);
        }
        data[offset++] = b;
      }
    }
  }
}



// translate the 24 bit color from RGB to the actual
// order used by the LED wiring.  GRB is the most common.
int colorWiring(int c) {
  int red = (c & 0xFF0000) >> 16;
  int green = (c & 0x00FF00) >> 8;
  int blue = (c & 0x0000FF);
  red = gammatable[red];
  green = gammatable[green];
  blue = gammatable[blue];
  return (green << 16) | (red << 8) | (blue); // GRB - most common wiring
}

void desperation() {
  ledImage[numPorts] = new PImage(152, 16, RGB);
  ledArea[numPorts] = new Rectangle(0, 0, 
    100, 100);
  ledLayout[numPorts] = false;
  numPorts++;
}

// draw runs every time the screen is redrawn - show the movie...
void draw() {
  background(0);


  if (myClient.available() > 0) { 
    wordX = 320;
    dataIn = myClient.readString(); 
    println(dataIn);
  } 

  //datalines();
  //noise();
  writeSomething(dataIn);
  noStroke(); 

  loadPixels();

  for (int i = 0; i < pixels.length; i++) {
    cvImg.pixels[i] = pixels[i];
  }

  cvImg.updatePixels();

  //image(img, 0, 0);
  canvasevent(cvImg);
  // then try to show what was most recently sent to the LEDs
  // by displaying all the images for each port.
  for (int i=0; i < numPorts; i++) {
    // compute the intended size of the entire LED array
    int xsize = percentageInverse(ledImage[i].width, ledArea[i].width);
    int ysize = percentageInverse(ledImage[i].height, ledArea[i].height);
    // computer this image's position within it
    int xloc =  percentage(xsize, ledArea[i].x);
    int yloc =  percentage(ysize, ledArea[i].y);
    // show what should appear on the LEDs
    stroke(255, 0, 0);
    rect(152 - xsize / 2 + xloc - 1, 10 + yloc - 1, xsize + 2, ysize + 2);
    image(ledImage[i], 152 - xsize / 2 + xloc, 10 + yloc);
    noStroke();
  }
}

//void clientEvent(Client someClient) {
  //print("Server Says:  ");
  //dataIn = myClient.readString();
  //background(dataIn);
//}

// respond to mouse clicks as pause/play
void datalines() {
  for (int i = 0; i < width; i+=30) {
    fill(0, 50, 100);
    rect(i+xpos, 0, 15, height/4);
    fill(150, 0, 0);
    rect(i+xpos + 15, height/4, 15, height/4);
  }
  xpos-=1;
  if (xpos < -320) {
    xpos = 320;
  }
}

void noise() {
  for (int i = 0; i < 20; i++) {
    fill(random(60));
    ellipse(random(320), random(32), random(10), random(10));
  }
  for (int i = 0; i < 40; i++) {
    fill(random(50), random(50), random(50));
    ellipse(random(320), random(32), random(10), random(10));
  }
}

int wordX = 320;

void writeSomething(String words) {
  fill(100);
  textFont(retro);
  textSize(10);
  text(words, wordX, 10);
  wordX--;
  //if (wordX < -300) {
  //  wordX=320;
  //}
}

// scale a number by a percentage, from 0 to 100
int percentage(int num, int percent) {
  double mult = percentageFloat(percent);
  double output = num * mult;
  return (int)output;
}

// scale a number by the inverse of a percentage, from 0 to 100
int percentageInverse(int num, int percent) {
  double div = percentageFloat(percent);
  double output = num / div;
  return (int)output;
}

// convert an integer from 0 to 100 to a float percentage
// from 0.0 to 1.0.  Special cases for 1/3, 1/6, 1/7, etc
// are handled automatically to fix integer rounding.
double percentageFloat(int percent) {
  if (percent == 33) return 1.0 / 3.0;
  if (percent == 17) return 1.0 / 6.0;
  if (percent == 14) return 1.0 / 7.0;
  if (percent == 13) return 1.0 / 8.0;
  if (percent == 11) return 1.0 / 9.0;
  if (percent ==  9) return 1.0 / 11.0;
  if (percent ==  8) return 1.0 / 12.0;
  return (double)percent / 100.0;
}
