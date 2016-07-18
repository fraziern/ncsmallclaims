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

void setup() {
  size(920, 435);
  
  data = new FloatTable("fees.csv");
  rowCount = data.getRowCount();
  columnCount = data.getColumnCount();
  increases = new float[rowCount];
  
  years = int(data.getRowNames());
  yearMin = years[0];
  yearMax = years[years.length - 1];
  
  //dataMin =-20;
  //dataMax = ceil(data.getTableMax() / volumeInterval) * volumeInterval;
  dataMin = -20;
  dataMax = 190;


  // Corners of the plotted time series
  plotX1 = 90; 
  plotX2 = width - 220;
  labelX = 50;
  plotY1 = 60;
  plotY2 = height - 100;
  labelY = height - 25;
  
  plotFont = createFont("SansSerif", 20);
  textFont(plotFont);

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
  //drawLineLabels();

  
  strokeWeight(2);
  noFill();
  //drawDataLine(0);  
  drawRecursiveDelta(0,0);
  drawIncreases();
  //for(int i=0; i < increases.length; i++) {
  //  print(increases[i] + " ");
  //}
  save("image.jpg");
}


void drawTitle() {
  fill(0,200);
  textSize(20);
  textAlign(CENTER);
  String title = "Percentage Change in N.C. Small Claims Court Filing Fees 1984-2010";
  text(title, width/2, height - 30);
}


void drawAxisLabels() {
  fill(0,200);
  textSize(13);
  textLeading(15);
  
  //textAlign(CENTER, CENTER);
  //text("Real Dollars (July 2010 CPI)", labelX, (plotY1+plotY2)/2);
  //textAlign(CENTER);
  //text("Year", (plotX1+plotX2)/2, labelY);
}


void drawYearLabels() {
  fill(0,200);
  textSize(10);
  textAlign(CENTER);
  
  // Use thin, gray lines to draw the grid
  
  stroke(0,200);
  strokeWeight(1);
  
  for (int row = 0; row < rowCount; row++) {
    if (years[row] % yearInterval == 0) {
      float x = map(years[row], yearMin, yearMax, plotX1, plotX2);
      text(years[row], x, plotY2 + textAscent() + 10);
      //line(x, plotY1, x, plotY2);
    }
  }
}


int volumeIntervalMinor = 5;   // Add this above setup()

void drawVolumeLabels() {
  fill(0,200);
  textSize(10);
  textAlign(RIGHT);
  
  stroke(128);
  strokeWeight(1);

  for (float v = dataMin; v <= dataMax; v += volumeIntervalMinor) {
    if (v % volumeIntervalMinor == 0) {     // If a tick mark
      float y = map(v, dataMin, dataMax, plotY2, plotY1);  
      if (v % volumeInterval == 0) {        // If a major tick mark
        float textOffset = textAscent()/2;  // Center vertically
        if (v == dataMin) {
          textOffset = 0;                   // Align by the bottom
        } else if (v == dataMax) {
          textOffset = textAscent();        // Align by the top
        }
        text(floor(v), plotX1 - 10, y + textOffset);
        //line(plotX1 - 4, y, plotX1, y);     // Draw major tick
      } else {
        //line(plotX1 - 2, y, plotX1, y);     // Draw minor tick
      }
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
      vertex(x, y);
      if (row == rowCount-1) { // if we are at the last row
        increases[startRow] = delta;
      }
    }

  }
  endShape();
  drawRecursiveDelta(startRow+1, col);
}

void drawLineLabels() {
  String[] lineName = {"Magistrates", "District", "Superior"};
  
  // Get y offsets for the first point in each line
  float[] stops = new float[3];
  for(int i = 0; i < stops.length; i++) {
    stops[i] = data.getFloat(rowCount-1,i);
    stops[i] = map(stops[i], dataMin, dataMax, plotY2, plotY1);
  }
  
  fill(0,200);
  textSize(10);
  textAlign(LEFT);
  for(int j = 0; j < lineName.length; j++){
    text(lineName[j], plotX2 + 10, stops[j]);
  }

}

void drawIncreases() {
  fill(0,200);
  textSize(10);
  textAlign(LEFT);
  
  stroke(128);
  strokeWeight(1);

  for (int i = 0; i < increases.length; i++) {
    float y = map(i, 0, increases.length-1, plotY1, plotY2);  
    float textOffset = textAscent()/2;  // Center vertically
    if (1 == 0) {
      textOffset = 0;                   // Align by the bottom
    } 
    //else if (i == increases.length-1) {
    //  textOffset = textAscent();        // Align by the top
    //}
    text(floor(increases[i]), plotX2 + 110, y + textOffset);
    text(years[i], plotX2 + 140, y + textOffset);
    
    // Connection lines
    float y1 = map(increases[i], dataMin, dataMax, plotY2, plotY1);
    if (i == 0) {
      stroke(16,91,99);
    } else stroke(189,50+i*7,50);
    line(plotX2 + 10, y1, plotX2 + 100, y);

  } 
}
 
