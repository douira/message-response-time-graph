//define a message class for creating message objects for every message
class Message {
  String origLine; //the original line passed (from fileData)
  String timeString; //the time as a parsed string
  int time; //when the message was sent in seconds (unix time)
  String author; //who wrote this message
  int contentLength = 0; //length of this message (in chars)
  String content; //content of this message
  PVector position = new PVector(0, 0); //the postion of this message on the graph (will be calculated after all messages have been created)
  float ellipseSize; //size of the circle drawn on the graph (diameter)
  boolean isSelected = false; //if true this message is selected and will display itself darker
  int ID; //index of this message in the chatData array
  
  //constructor that sets everything up
  Message(String chatLine) {
    //copy the given line to origLine
    origLine = chatLine;
    
    //split the given string into the message fields
    timeString = chatLine.substring(0, 17); //date (17 is uniform date length)
    author = split(chatLine.substring(19, chatLine.length()), ": ")[0]; //author (19 is uniform date length + 2)
    
    //parse the content if the length of the whole string is longer than the author and the date stamp
    if (timeString.length() + author.length() < chatLine.length() - 2) {
      //parse content (19 is end of author + 2)
      content = chatLine.substring(21 + author.length(), chatLine.length());
    }
    
    //shorten the author if showLastName is disables (= false)
    if (! showLastName) {
      //split at space and take first piece
      author = split(author, " ")[0];
    }
    
    //calculate the time (and try/catch a parse exception, because it is a "special" kind of exception)
    try {
      //get and convert the time and make an int
      time = (int)dateFormat.parse(timeString).getTime() / 1000;
    } //catch the exception
    catch (ParseException e) {
      //print the stack trace if an exception occurs
      e.printStackTrace();
    }
    
    //calculate the content length if there is content, stays 0 otherwise
    if (content != null) { 
      //get the length
      contentLength = content.length();
    }
    
    //if there is content and the author not is present in nameColors add it and assign a radnom color to it (through indexing)
    if ((! nameColorsDict.hasKey(author)) && contentLength > 0) {
      //calculate a color from a random number
      color authorColor = color(random(colorParam[0], colorParam[1]), random(colorParam[2], colorParam[3]), random(colorParam[4], colorParam[5]));
      
      //add a (calculated) color to the color array
      nameColors = append(nameColors, authorColor);
      
      //add this author and give it a index in the color array
      nameColorsDict.set(author, colorIndexCounter);
      
      //increment the colorIndexCounter
      colorIndexCounter ++;
    }
    
    //calculate the size of the circle to be drawn on the graph
    ellipseSize = sqrt(contentLength) * lengthFactor;
  }
  
  //method for calculating the position of this message (passed the index of its position in the chatData array)
  void calcPosition(int id) {
    //save the given id to the own id
    ID = id;
    
    //set the postion if not first and not last message because there wouldn't be two neighbours
    if (0 < ID && ID < chatData.length - 1) {
      //set the position
      position.set(scaleValue(float(abs(time - chatData[ID - 1].time))), - scaleValue(float(chatData[ID + 1].time - time)));
    }
  }
  
  //method for drawing itself
  void draw() {
    if (contentLength > 0) {
      render();
    }
  }
  void render() {
    //set the fill (with alpha) to gotten value and darken if is selected
    color col = getNameColor(author);
    fill(col, fillAlpha * (selectedMessage == ID ? selectedDarkness : 1));
    
    //set the stroke like the fill just with another alpha(less transparent) and darken if is selected
    stroke(col, fillAlpha * strokeDarkness * (selectedMessage == ID ? selectedDarkness : 1));
    
    //draw an ellipse at its position
    ellipse(position.x, position.y, ellipseSize, ellipseSize);
    
    //draw connection to next and previous messages if selected and messages before and after present
    if (1 < ID && ID < chatData.length - 2 && selectedMessage == ID) {
      //set the stroke to the color of connections
      stroke(selectedConnColor, selectedConnAlpha);
      
      //set the stroke thickness for connecing lines
      strokeWeight(selectedConnLineThickness);
      
      //draw a connection to the previous message
      line(position.x, position.y, chatData[ID - 1].position.x, chatData[ID - 1].position.y);
      
      //draw a connection to the next message
      line(position.x, position.y, chatData[ID + 1].position.x, chatData[ID + 1].position.y);
      
      //remove fill
      noFill();
      
      //draw a circle at the next message
      ellipse(chatData[ID + 1].position.x, chatData[ID + 1].position.y, chatData[ID + 1].ellipseSize * connCircleSizeFactor, chatData[ID + 1].ellipseSize * connCircleSizeFactor);
    }
  }
  
  //method for returning the distance to the mouse
  float distToMouse() {
    return position.dist(new PVector(mouseX - sidePadding, mouseY - (height - verticalPadding)));
  }
}