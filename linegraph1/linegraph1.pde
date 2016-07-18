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
int volumeInterval = 10;

PFont plotFont; 


void setup() {
  size(720, 435);
  
  data = new FloatTable("fees.tsv");
  rowCount = data.getRowCount();
  columnCount = data.getColumnCount();
  // Testing
  
  years = int(data.getRowNames());
  yearMin = years[0];
  yearMax = years[years.length - 1];
  print(years.length);
  
  dataMin = 0;
  dataMax = ceil(data.getTableMax() / volumeInterval) * volumeInterval;

  // Corners of the plotted time series
  plotX1 = 120; 
  plotX2 = width - 80;
  labelX = 50;
  plotY1 = 60;
  plotY2 = height - 100;
  labelY = height - 25;
  
  plotFont = createFont("SansSerif", 20);
  textFont(plotFont);

  smooth();
}


void draw() {
  background(255);
  
  // Show the plot area as a white box  
  //fill(255);
  //rectMode(CORNERS);
  //noStroke();
  //rect(plotX1, plotY1, plotX2, plotY2);

  drawTitle();
  drawAxisLabels();
  drawYearLabels();
  drawVolumeLabels();
  drawLineLabels();

  stroke(189,73,50);
  strokeWeight(5);
  noFill();
  drawDataLine(0);  
  
  stroke(219,158,54);
  drawDataLine(1);
  
  stroke(255,211,78);
  drawDataLine(2);
  
  save("image.jpg");
}


void drawTitle() {
  fill(0,200);
  textSize(20);
  textAlign(LEFT);
  String title = "N.C. Filing Fees in 2010 Dollars";
  text(title, 2, height - 10);
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


/*
void keyPressed() {
  if (key == '[') {
    currentColumn--;
    if (currentColumn < 0) {
      currentColumn = columnCount - 1;
    }
  } else if (key == ']') {
    currentColumn++;
    if (currentColumn == columnCount) {
      currentColumn = 0;
    }
  }
} */
