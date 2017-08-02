//put a whatsapp chat archive (in a chat tap chat as email, and use the file attached to the email) 
//with the given file name (rename it) in the sketch folder for it to be read
//press s-key to save the frame to a file
//the cirle around one message is the next message after the selected message

//--import libraries--
//import java date formatter
import java.text.*;

//import java date
import java.util.*;

//--definition of variables--
//data (input and storage)
String[] fileData; //String data from the chat archive
Message[] chatData = {}; //all messages as induvidual message objects
IntDict nameColorsDict; //index to the color to the names are stored in this referenced by string(author)
color[] nameColors = {}; //stroes the colors for the names, indexes are looked up in nameColorsDict by name
PFont colorLegendFont; //the font used as the color legend text font
int[] colorParam = {0, 255, 100, 255, 100, 230}; //parameters for color randomisation in HSB (lowH, highH, lowS, highS, lowB, highB)
Date timeNow = new Date(); //the date and time now
String[] additLabels = {"\n10 sec.", "\n1 min., 40 sec.", "\n16min., 40sec.", "\nca. 2h, 46min.", "\nca. 1d, 3h", "\nca. 11d, 12h", ""}; //additional labels for the time labels
String[] beginLabels = {"0 sec.\nTime taken as response >", "0 sec.\nTime until response ^    "}; //labels in the first place of the two axes
//variables (changing)
SimpleDateFormat dateFormat; //object for using the date format 
String messageLine = ""; //the whole line of one message (used because some messages are multiple lines long)
int colorIndexCounter = 0; //what index new colors are added to in the nameColors array
int selectedMessage = -1; //what message is currently selected
//constants(/settings)
String dataFileName = "input.txt"; //the file name for path of the chat file (must be in the whatsapp-on-iphone-chat-sent-by-email format)
String lineStartPattern = "\\d\\d.\\d\\d.\\d\\d \\d\\d:\\d\\d:\\d\\d: "; //the regex for matching dates
String dateFormatString = "dd.MM.yy HH:mm:ss"; //the format of the date used
color backgroundColor = color(255); //color of the background
int sidePadding = 350; //padding between the graph and the window on the left side
int verticalPadding = 70; ///padding between the graph and the window on the bottom
int fillAlpha = 40; //alpha value of the fill color
int strokeThickness = 3; //thickness of the lines arount the circles
float strokeDarkness = 0.5; //how much more opague the stroke is
float selectedDarkness = 4; //how much more opague the whole message gets when selected (hovered over)
float lengthFactor = 4; //how big the drawn circles area is compared to the message length
float axisScaling = 65; //scaling of both axes (after log) (65 for class chat)
int axisThickness = 3; //thickness of the axis
int hintLineThickness = 2; //thickness of the hint lines
color axisColor = color(100); //color used for axis lines, label hints and labels, and arrows
int colorLegendTextSize = 20; //size of the text used to display the color of the authors
int colorLegendTextPadding = 10; //padding around the color legend text
String colorLegendFontName = "Arial-Black"; //name of the font used as the font of the color legend text (a thicker font so colors can be seen better)
int randomColorSeed = 495378532; //seed for the randomizer for random colors
int colorLegendAlpha = 100; //alpha value of the color legend text
boolean showLastName = false; //true will also show the last name with the first name
int arrowSize = 10; //how big the arraw is on the end of both axes
int axisPadding = 10; //space between the window and the tip of the arrow(/axis)
int axisLabelTextSize = 15; //text size of the labels on the axes
int hintLineLength = 10; //length of the hint lines
float labelIntervall = 2.4; //intervall factor for the amount of labels
int minBoundingBox = 5; //minimum size of boudging box for message selection
int selectedConnLineThickness = 2; //thickness of the lines showing the previous and response messages
int selectedConnAlpha = 150; //alpha of the connection shown to and from a message whn selected
int defaultConnAlpha = 5; //alpha value of all connections shown by default (set to 0 to hide connections being shown by default)
color selectedConnColor = color(50); //color of the connection to an from a message when it is selected
float connCircleSizeFactor = 1.7; //factor of the size of the cirle draw around the next message to the size of the message circle itself

//--define utility functions--
//message function for printing status messages
void msg(int level, String s) {
  //add time
  s = "["+ hour() + ":" + minute() + ":" + second() + "-" + millis() + "ms]" + s; 
  
  //apply level indicator
  switch (level) {
  case 0: //info-level message
  default:
    //add "INFO"
    s = "INFO" + s;
  break;
  case 1: //warning-level message
    //add "WARNING"
    s = "WARNING" + s;
  break;
  case 2: //error-level message
    //add "ERROR"
    s = "ERROR" + s;
  break;
  case 3: //de-bug message
    //add "DEBUG"
    s = "DEBUG" + s;
  break;
  }
  
  //print it
  println(s);
}

//--define specific functions--
//define getNameColor function for getting the color of a name from the dict and the nameColors array
color getNameColor(String name) {
  //return the color from the nameColors array with the index gotten from the dict
  return nameColors[nameColorsDict.get(name)];
}

//define scaleValue function for calculating the
float scaleValue(float value) {
  //return the position value on screen after log and scaling
  return axisScaling * log(value);
}

//--start setup--
void setup() {
  //set the size
  fullScreen();
  
  //msg
  msg(0, "reading chat text file.");
  
  //load String data from given file name
  fileData = loadStrings(dataFileName);
  
  //msg
  msg(0, "initializing date formater.");
  
  //init the dateFormat used
  dateFormat = new SimpleDateFormat(dateFormatString);
  
  //msg
  msg(0, "parsing " + fileData.length + " lines of chat messages.");
  
  //init the int dict
  nameColorsDict = new IntDict();
  
  //set the random seed to the given seed
  randomSeed(randomColorSeed);
  
  //set the color mode to hsb to have better controll over random colors
  colorMode(HSB);
  
  //for each line in the chat file
  for (int line = 0; line < fileData.length; line ++) {
    //add the current line to the messageLine
    messageLine += fileData[line];
    
    //repeat while the current line doesn't start with a date until we find a date
    while (match(fileData[constrain(line + 1, 0, fileData.length - 1)], lineStartPattern) == null && line + 1 != fileData.length) {
      //increment the line index
      line ++;
      
      //add current line to the messageLine
      messageLine += fileData[line];
    }
    
    //append a new message object to the array and cast into the right datatype
    chatData = (Message[])append(chatData, new Message(messageLine));
    
    //reset messageLine
    messageLine = "";
  }
  
  //set the colorMode back to normal (RGB)
  colorMode(RGB);
  
  //go through all messages again to make them calculate their position
  for (int i = 0; i < chatData.length; i ++) {
    //call the calcPosition method of this message
    chatData[i].calcPosition(i);
  }
  
  //msg
  msg(0, "rendering " + (chatData.length - 2) + " messages from " + nameColors.length + " different authors.");
}

//--draw loop--
void draw() {
  //--draw the background--
  background(backgroundColor);
  
  //--draw name color legend--
  //set the textAlign to bottom, left
  textAlign(BOTTOM, LEFT);
  
  //create the specified font
  colorLegendFont = createFont(colorLegendFontName, colorLegendTextSize);
  
  //apply the created font
  textFont(colorLegendFont);
  
  //set the text size to specified
  textSize(colorLegendTextSize);
  
  //iterate through every stored color
  for (int i = 0; i < nameColors.length; i ++) {
    //set the fill to the current color with alpha to get similar colors and darker if message with this author is selected
    fill(nameColors[i], colorLegendAlpha * (selectedMessage >= 0 && chatData[abs(selectedMessage)].author.equals(nameColorsDict.keyArray()[i]) ? selectedDarkness : 1));
    
    //draw a text with the current author
    text(nameColorsDict.keyArray()[i], colorLegendTextPadding, textAscent() * (i + 1));
  }
  
  //--draw circles(message data)--
  //set the stroke weight for circlesto specified
  strokeWeight(strokeThickness);
  
  //translate to graph origin
  translate(sidePadding, height - verticalPadding);
  
  //iterate through every message (omit first and last message, because they dont't have two adjacent messages)
  for (int i = 1; i < chatData.length - 1; i ++) {
    //call the draw function of this message to draw it
    chatData[i].draw();
  }
  
  //--draw axes things--
  //set stroke and fill to specified axisColor
  stroke(axisColor);
  fill(axisColor);
  
  //--draw axes
  //set stroke weight to specified
  strokeWeight(axisThickness);
  
  //draw the x axis
  line(0, 0, width - sidePadding - axisPadding, 0);
  
  //draw the y axis
  line(0, 0, 0, - height + axisPadding + verticalPadding);
  
  //--draw arrows--
  //draw the arrow head on the x axis
  triangle(width - sidePadding - axisPadding - arrowSize, - arrowSize, width - sidePadding - axisPadding - arrowSize, arrowSize, width - sidePadding - axisPadding, 0);
  
  //draw the arrow head on the y axis
  triangle(- arrowSize, - height + axisPadding + verticalPadding + arrowSize, arrowSize, - height + axisPadding + verticalPadding + arrowSize, 0, - height + axisPadding + verticalPadding);
  
  //--draw axes label hint lines and labels--
  //set the strokeWeight to the specified thickness
  strokeWeight(hintLineThickness);
  
  //set the textSize to specified
  textSize(axisLabelTextSize);
  
  //draw hint lines and labels on the x axis
  //set the text alignment to center and top
  textAlign(CENTER, TOP);
  
  //iterate through labels
  for (int x = 0; x < width - sidePadding - axisPadding - arrowSize; x += axisScaling * labelIntervall) {
    //draw line
    line(x, 0, x, hintLineLength);
    
    //draw text if after first
    if (x > 0) {
      //draw text with additional label
      text("10^" + ceil(x / (axisScaling * labelIntervall)) + " sec." + additLabels[constrain(ceil(x / (axisScaling * labelIntervall)) - 1, 0, additLabels.length - 1)], x, hintLineLength);
    } //first label
    else {
      //draw text with "0 sec."
      text(beginLabels[0], x, hintLineLength);
    }
  }
  
  //draw hint lines and labels on the y axis
  //set the text alignment to right and center
  textAlign(RIGHT, CENTER);
  
  //iterate through labels
  for (int y = 0; y > - height + axisPadding + verticalPadding; y -= axisScaling * labelIntervall) {
    //draw line
    line(- hintLineLength, y, 0, y);
    
    //draw text if after first
    if (y < 0) {
      //draw text with additional label
      text("10^" + ceil(abs(y) / (axisScaling * labelIntervall)) + " sec." + additLabels[constrain(abs(ceil(y / (axisScaling * labelIntervall)) + 1), 0, additLabels.length - 1)], - hintLineLength, y);
    } //first label
    else {
      //draw text with "0 sec."
      text(beginLabels[1], - hintLineLength, y);
    }
  }
  
  //msg done if frist frame
  if (frameCount == 1) {
    //done msg
    msg(0, "done rendering.");
    
    //stop loop
    noLoop();
  }
}

//--define callback functions--
//define mouseClicked for selection at mouseclick
void mouseClicked() {
  //init variables for detecting closest message to cursor
  int closestID = -1; //the index of the message closest to the cursor
  float closestDist = -1; //the closest distance of a message (the message with closestID) to the cursor
  float currentDist; //current distance to the cursor from the current message
  
  //for every message in chatData
  for (int i = 0; i < chatData.length; i ++) {
    //calculate the distance from the cursor to the message
    currentDist = chatData[i].distToMouse();
    
    //if closer than closest message yet
    if ((currentDist < closestDist || closestDist == -1) && currentDist <= chatData[i].ellipseSize / 2) {
      //set closestDist to the new closest distance
      closestDist = currentDist;
      
      //set the closestID to the new closest messages ID (= index)
      closestID = i;
    }
  }
  
  //if any closest message found
  if (closestID > -1) {
    //make the detected closest message selected
    selectedMessage = closestID;
    
    //msg
    msg(0, "selected message Nr. " + closestID + ", by " + chatData[closestID].author + ", is " + chatData[closestID].contentLength + " chars long, content is: " + chatData[closestID].content);
  } //make no message selected
  else {
    //no message selected, set to -1
    selectedMessage = -1;
  }
  
  //redraw canvas
  redraw();
}
//define keyTyped for catching key presses
void keyTyped() {
  //save the frame if S was pressed
  if (key == 's') {
    //save the frame
    save(timeNow.getTime() + ".png");
    
    //msg
    msg(0, "saved the current frame to \"" + timeNow.getTime() + ".png\".");
  }
}
