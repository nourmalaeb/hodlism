/*  OctoWS2811 VideoDisplay.ino - Video on LEDs, from a PC, Mac, Raspberry Pi
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

  Update: The movie2serial program which transmit data has moved to "extras"
  https://github.com/PaulStoffregen/OctoWS2811/tree/master/extras

  Required Connections
  --------------------
    pin 2:  LED Strip #1    OctoWS2811 drives 8 LED Strips.
    pin 14: LED strip #2    All 8 are the same length.
    pin 7:  LED strip #3
    pin 8:  LED strip #4    A 100 to 220 ohm resistor should used
    pin 6:  LED strip #5    between each Teensy pin and the
    pin 20: LED strip #6    wire to the LED strip, to minimize
    pin 21: LED strip #7    high frequency ringining & noise.
    pin 5:  LED strip #8
    pin 15 & 16 - Connect together, but do not use
    pin 4:  Do not use
    pin 3:  Do not use as PWM.  Normal use is ok.
    pin 12: Frame Sync

    When using more than 1 Teensy to display a video image, connect
    the Frame Sync signal between every board.  All boards will
    synchronize their WS2811 update using this signal.

    Beware of image distortion from long LED strip lengths.  During
    the WS2811 update, the LEDs update in sequence, not all at the
    same instant!  The first pixel updates after 30 microseconds,
    the second pixel after 60 us, and so on.  A strip of 120 LEDs
    updates in 3.6 ms, which is 10.8% of a 30 Hz video frame time.
    Doubling the strip length to 240 LEDs increases the lag to 21.6%
    of a video frame.  For best results, use shorter length strips.
    Multiple boards linked by the frame sync signal provides superior
    video timing accuracy.

    A Multi-TT USB hub should be used if 2 or more Teensy boards
    are connected.  The Multi-TT feature allows proper USB bandwidth
    allocation.  Single-TT hubs, or direct connection to multiple
    ports on the same motherboard, may give poor performance.
*/

#include <OctoWS2811.h>

// The actual arrangement of the LEDs connected to this Teensy 3.0 board.
// LED_HEIGHT *must* be a multiple of 8.  When 16, 24, 32 are used, each
// strip spans 2, 3, 4 rows.  LED_LAYOUT indicates the direction the strips
// are arranged.  If 0, each strip begins on the left for its first row,
// then goes right to left for its second row, then left to right,
// zig-zagging for each successive row.
#define LED_WIDTH      76   // number of LEDs horizontally
#define LED_HEIGHT     16   // number of LEDs vertically (must be multiple of 8)
#define LED_LAYOUT     0    // 0 = even rows left->right, 1 = even rows right->left

// The portion of the video image to show on this set of LEDs.  All 4 numbers
// are percentages, from 0 to 100.  For a large LED installation with many
// Teensy 3.0 boards driving groups of LEDs, these parameters allow you to
// program each Teensy to tell the video application which portion of the
// video it displays.  By reading these numbers, the video application can
// automatically configure itself, regardless of which serial port COM number
// or device names are assigned to each Teensy 3.0 by your operating system.
#define VIDEO_XOFFSET  0
#define VIDEO_YOFFSET  0       // display entire image
#define VIDEO_WIDTH    100
#define VIDEO_HEIGHT   100

//#define VIDEO_XOFFSET  0
//#define VIDEO_YOFFSET  0     // display upper half
//#define VIDEO_WIDTH    100
//#define VIDEO_HEIGHT   50

//#define VIDEO_XOFFSET  0
//#define VIDEO_YOFFSET  50    // display lower half
//#define VIDEO_WIDTH    100
//#define VIDEO_HEIGHT   50


const int ledsPerStrip = LED_WIDTH * LED_HEIGHT / 8;

DMAMEM int displayMemory[ledsPerStrip * 6];
int drawingMemory[ledsPerStrip * 6];
elapsedMicros elapsedUsecSinceLastFrameSync = 0;

const int config = WS2811_GRB | WS2811_800kHz; // color config is on the PC side

OctoWS2811 leds(ledsPerStrip, displayMemory, drawingMemory, config);

void setup() {
  pinMode(12, INPUT_PULLUP); // Frame Sync
  Serial.setTimeout(50);
  leds.begin();
  leds.show();
}

void loop() {
  //
  // wait for a Start-Of-Message character:
  //
  //   '*' = Frame of image data, with frame sync pulse to be sent
  //         a specified number of microseconds after reception of
  //         the first byte (typically at 75% of the frame time, to
  //         allow other boards to fully receive their data).
  //         Normally '*' is used when the sender controls the pace
  //         of playback by transmitting each frame as it should
  //         appear.
  //
  //   '$' = Frame of image data, with frame sync pulse to be sent
  //         a specified number of microseconds after the previous
  //         frame sync.  Normally this is used when the sender
  //         transmits each frame as quickly as possible, and we
  //         control the pacing of video playback by updating the
  //         LEDs based on time elapsed from the previous frame.
  //
  //   '%' = Frame of image data, to be displayed with a frame sync
  //         pulse is received from another board.  In a multi-board
  //         system, the sender would normally transmit one '*' or '$'
  //         message and '%' messages to all other boards, so every
  //         Teensy 3.0 updates at the exact same moment.
  //
  //   '@' = Reset the elapsed time, used for '$' messages.  This
  //         should be sent before the first '$' message, so many
  //         frames are not played quickly if time as elapsed since
  //         startup or prior video playing.
  //
  //   '?' = Query LED and Video parameters.  Teensy 3.0 responds
  //         with a comma delimited list of information.
  //
  char startChar = Serial.read();

  if (startChar == '?') {
    pinMode(13, OUTPUT);
    digitalWrite(13, HIGH);
    delay(100);
    digitalWrite(13, LOW);
    delay(100);
  }
}

