FloatTable data;
float dataMin, dataMax;

float plotX1, plotY1;
float plotX2, plotY2;
float labelX, labelY;

int rowCount;
int columnCount;
int currentColumn = 0;

int yearMin, yearMax;
int[] years;

int yearInterval = 2;
int volumeInterval = 20;

PFont plotFont; 

float[] increases;
float circleThres1, circleThres2;

void setup() {
  size(920, 635);
  
  data = new FloatTable("fees.csv");
  rowCount = data.getRowCount();
  columnCount = data.getColumnCount();
  increases = new float[rowCount];
  
  years = int(data.getRowNames());
  yearMin = years[0];
  yearMax = years[years.length - 1];
  
  dataMin = -20;
  dataMax = 190;


  // Corners of the plotted time series
  plotX1 = 90; 
  plotX2 = width - 240;
  labelX = 50;
  plotY1 = 60;
  plotY2 = height - 100;
  labelY = height - 25;
  
  plotFont = createFont("SansSerif", 20);
  textFont(plotFont);
  
  circleThres1 = 40;
  circleThres2 = 100;

  smooth();
  noLoop();
}


void draw() {
  background(255);
  
  // Paint a negative area 
  float zeroY = map(0, dataMin, dataMax, plotY2, plotY1);
  fill(16,91,99,50);
  rectMode(CORNERS);
  noStroke();
  rect(plotX1, zeroY, plotX2, plotY2);

  drawTitle();
  drawAxisLabels();
  drawYearLabels();
  drawVolumeLabels();
  
  strokeWeight(2);
  noFill();
  drawRecursiveDelta(0,0);
  noStroke();
  drawRecursiveCircles(0,0);
  drawIncreases();
  drawLegend();
  
  save("image.jpg");
}


void drawTitle() {
  fill(0,200);
  textSize(20);
  textAlign(CENTER);
  String title = "Percentage Change in N.C. Small Claims Court Filing Fees as of 2010";
  text(title, width/2, height - 30);
}


void drawAxisLabels() {
  fill(0,200);
  textSize(13);
  textLeading(15);
}


void drawYearLabels() {
  fill(0,200);
  textSize(10);
  textAlign(CENTER);
    
  stroke(0,200);
  strokeWeight(1);
  
  for (int row = 0; row < rowCount; row++) {
    if (years[row] % yearInterval == 0) {
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      text(years[row], x, plotY2 + textAscent() + 10);
    }
  }
}

void drawVolumeLabels() {
  fill(0,200);
  textSize(10);
  textAlign(RIGHT);
  
  stroke(128);
  strokeWeight(1);

  for (float v = dataMin; v <= dataMax; v += volumeInterval) {
    float y = map(v, dataMin, dataMax, plotY2, plotY1);  
    if (v % volumeInterval == 0) {        
      float textOffset = textAscent()/2;  // Center vertical
      if (v == dataMin) {
        textOffset = 0;                   // Align by the bottom
      } else if (v == dataMax) {
        textOffset = textAscent();        // Align by the top
      }
      text(floor(v), plotX1 - 10, y + textOffset);
    } 
  }
}



void drawDataLine(int col) {  
  beginShape();
  for (int row = 0; row < rowCount; row++) {
    if (data.isValid(row, col)) {
      float value = data.getFloat(row, col);
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      float y = map(value, dataMin, dataMax, plotY2, plotY1);      
      vertex(x, y);
    }
  }
  endShape();
}

void drawRecursiveDelta(int startRow, int col) {
  if (startRow == rowCount-1) return;
  float baseValue = data.getFloat(startRow, col);
  
  if (startRow == 0) {
    stroke(16,91,99);
  } else stroke(189,50+startRow*7,50);
  beginShape();
  for (int row = startRow; row < rowCount; row++) {

    //compute the percent change between the startRow and row;
    if (data.isValid(row, col)) {    
      float value = data.getFloat(row, col);
      float delta = (value-baseValue)/baseValue*100;
      
      // extend the line there
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      float y = map(delta, dataMin, dataMax, plotY2, plotY1);      
      curveVertex(x, y);
      
      // Double the curve points for the start and stop 
      if ((row == startRow) || (row == rowCount-1)) {
        curveVertex(x,y);
      }
      
      if (row == rowCount-1) { // if we are at the last row
        increases[startRow] = delta;
      }
    }

  }
  endShape();
  drawRecursiveDelta(startRow+1, col);
}

void drawRecursiveCircles(int startRow, int col) {
  if (startRow == rowCount-1) return;
  float baseValue = data.getFloat(startRow, col);
  float baseValue2 = data.getFloat(startRow, col+1);
  
  for (int row = startRow; row < rowCount; row++) {

    //compute the percent change between the startRow and row;
    if (data.isValid(row, col)) {    
      float value = data.getFloat(row, col);
      float delta = (value-baseValue)/baseValue*100;
      
      // Compute difference between this delta and delta of other column
      float value2 = data.getFloat(row, col+1);
      float delta2 = (value2-baseValue2)/baseValue2*100;
      float deltaDelta = abs(delta-delta2);
      
      // put a circle there for deltaDelta, if sufficiently large
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      float y = map(delta, dataMin, dataMax, plotY2, plotY1);      
      
      if (deltaDelta > circleThres2) { 
        fill(16,91,99,60);
        ellipse(x,y,20,20);
      } else if (deltaDelta > circleThres1) { 
        fill(16,91,99,50);
        ellipse(x,y,10,10);
      }
    }

  }
  drawRecursiveCircles(startRow+1, col);
}

void drawIncreases() {
  fill(0,200);
  textSize(10);
  textAlign(LEFT);
  
  strokeWeight(1);

  for (int i = 0; i < increases.length; i++) {
    if (i == 0) {
      fill(16,91,99);
    } else fill(189,50+i*7,50);
    float y = map(i, 0, increases.length-1, plotY1, plotY2);  
    float textOffset = textAscent()/2;  // Center vertically
    if (1 == 0) {
      textOffset = 0;                   // Align by the bottom
    } 
    
    text(floor(increases[i]), plotX2 + 97, y + textOffset);
    if (i == 0) text("% since ");
    text(years[i], plotX2 + 150, y + textOffset);
    
    // Connection lines
    float y1 = map(increases[i], dataMin, dataMax, plotY2, plotY1);
    if (i == 0) {
      stroke(16,91,99);
    } else stroke(189,50+i*7,50);
    line(plotX2 + 15, y1, plotX2 + 90, y);

  } 
}

void drawLegend() {
  int legX = 70;
  int legY = 20;
  
  noStroke();
  fill(16,91,99,60);
  ellipse(plotX1+legX-20, plotY1+legY+35, 20, 20);
  fill(16,91,99,50);
  ellipse(plotX1+legX-20, plotY1+legY+57, 10, 10);
  
  fill(0,200);
  textSize(10);
  textAlign(LEFT);
  String legendTitle = "Difference between Small Claims\n and District Court Increases";
  text(legendTitle, plotX1+legX, plotY1+legY);
  
  text("> " + floor(circleThres2) + " pp", plotX1+legX, plotY1+legY+40);
  text("> " + floor(circleThres1) + " pp", plotX1+legX, plotY1+legY+62);
}

/*void mouseMoved() {
}*/
