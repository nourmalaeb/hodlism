import processing.serial.*;

Serial myPort;  // Create object from Serial class
String val;     // Data received from the serial port


void setup() 
{
  size(200, 200); //make our canvas 200 x 200 pixels big
  String portName = "/dev/cu.usbmodem3973051"; //change the 0 to a 1 or 2 etc. to match your port
  myPort = new Serial(this, portName);
}

void draw() {
  if (mousePressed == true) 
  {                           //if we clicked in the window
    myPort.write('1');         //send a 1
    println("1");
  } else 
  {                           //otherwise
    myPort.write('0');          //send a 0
  }

  if ( myPort.available() > 0) 
  {  // If data is available,
    val = myPort.readStringUntil('\n');         // read it and store it in val
  } 
  println(val); //print it out in the console
}
