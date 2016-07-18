class Table {
  String[][] data;
  int rowCount;
  
  
  Table() {
    data = new String[10][10];
  }

  
  Table(String filename) {
    String[] rows = loadStrings(filename);
    data = new String[rows.length][];
    
    for (int i = 0; i < rows.length; i++) {
      if (trim(rows[i]).length() == 0) {
        continue; // skip empty rows
      }
      if (rows[i].startsWith("#")) {
        continue;  // skip comment lines
      }
      
      // split the row on the tabs
      String[] pieces = split(rows[i], TAB);
      // copy to the table array
      data[rowCount] = pieces;
      rowCount++;
      
      // this could be done in one fell swoop via:
      //data[rowCount++] = split(rows[i], TAB);
    }
    // resize the 'data' array as necessary
    data = (String[][]) subset(data, 0, rowCount);
  }


  int getRowCount() {
    return rowCount;
  }
  
  
  // find a row by its name, returns -1 if no row found
  int getRowIndex(String name) {
    for (int i = 0; i < rowCount; i++) {
      if (data[i][0].equals(name)) {
        return i;
      }
    }
    //println("No row named '" + name + "' was found");
    return -1;
  }
  
  
  String getRowName(int row) {
    return getString(row, 0);
  }


  String getString(int rowIndex, int column) {
    return data[rowIndex][column];
  }

  
  String getString(String rowName, int column) {
    return getString(getRowIndex(rowName), column);
  }

  
  int getInt(String rowName, int column) {
    return parseInt(getString(rowName, column));
  }

  
  int getInt(int rowIndex, int column) {
    return parseInt(getString(rowIndex, column));
  }

  
  float getFloat(String rowName, int column) {
    return parseFloat(getString(rowName, column));
  }

  
  float getFloat(int rowIndex, int column) {
    return parseFloat(getString(rowIndex, column));
  }
  
  
  void setRowName(int row, String what) {
    data[row][0] = what;
  }


  void setString(int rowIndex, int column, String what) {
    data[rowIndex][column] = what;
  }

  
  void setString(String rowName, int column, String what) {
    int rowIndex = getRowIndex(rowName);
    data[rowIndex][column] = what;
  }

  
  void setInt(int rowIndex, int column, int what) {
    data[rowIndex][column] = str(what);
  }

  
  void setInt(String rowName, int column, int what) {
    int rowIndex = getRowIndex(rowName);
    data[rowIndex][column] = str(what);
  }

  
  void setFloat(int rowIndex, int column, float what) {
    data[rowIndex][column] = str(what);
  }


  void setFloat(String rowName, int column, float what) {
    int rowIndex = getRowIndex(rowName);
    data[rowIndex][column] = str(what);
  }
  
  
  // Write this table as a TSV file
  void write(PrintWriter writer) {
    for (int i = 0; i < rowCount; i++) {
      for (int j = 0; j < data[i].length; j++) {
        if (j != 0) {
          writer.print(TAB);
        }
        if (data[i][j] != null) {
          writer.print(data[i][j]);
        }
      }
      writer.println();
    }
    writer.flush();
  }
}

Table data;
PFont font;
String counties[];
color backg;

void setup() {
  size(800,800);
  backg = color(255);
  background(backg);
  smooth();
  
  data = new Table("filingsdelta2.tsv");
  
  counties = new String[100];
  float numbers[] = new float[100];
  float numbersD[] = new float[100];
  float numbersS[] = new float[100];
  float numbersP[] = new float[100];
  
  
  
  for (int i = 1; i < 101; i++) {
    numbers[i-1] = data.getFloat("CVM delta", i);
    numbersD[i-1] = data.getFloat("CVD delta", i);
    numbersS[i-1] = data.getFloat("CVS delta", i);
    numbersP[i-1] = data.getFloat("2009 pop estimate", i);
      println("Made it!");
    counties[i-1] = data.getString("CTYNAME", i);
  };
  

  makeNormal(numbersP);
  
  barGraph(numbers, 250);
  barGraph(numbersD, 450);
  barGraph(numbersS, 600);
  barGraphKey(numbersP, 150);
  
  // Add labels
  font = loadFont("SansSerif-12.vlw");
  textFont(font, 12);
  fill(0,200);
  text("2009 population", 2, 48);
  text("delta CVM", 2, 248);
  text("delta CVD", 2, 415);
  text("delta CVS", 2, 565);
  
  // Add title
  textFont(font, 18);
  fill(0,200);
  text("Change in Civil Filings in NC Counties, 2000-2009", 2, 735);
  textFont(font, 11);
  text("Displayed in order of 2009 population; Figures represent filings per capita", 2, 750);

  // Save
  //save("image2.jpg");
  //print("Save complete.");

};
  
void barGraph(float[] nums, float y) {
  stroke(255);
  for (int i = 0; i < 100; i++) {
    fill(200, abs(nums[i]) * 225, 54);    
    rect(i*8, y, 8, -nums[i] * 100);  
  }
}

void barGraphKey(float[] nums, float y) {
  for (int i = 0; i < 100; i++) {
    fill(16,91,99);    
    rect(i*8, y, 8, -nums[i] * 100);
  }
}

void makeNormal(float[] nums) {
  
  // Note that this doesn't work if there are negative values
  // find max & min
  float min = nums[0];
  float max = nums[0];
  
  for(int i = 0; i < nums.length; i++) {
    if (nums[i] < min) { min = nums[i]; };
    if (nums[i] > max) { max = nums[i]; };
  };
  
  for(int i = 0; i < nums.length; i++) {
    nums[i] = norm(nums[i], min, max);
  };
};

void draw() {
};

void mouseMoved() {
  fill(255);
  rect(width-200, height-100, 200, 100);
  if(get(mouseX,mouseY) != backg){
    String label = counties[(int)mouseX/8];
    fill(0,200);
    textSize(10);
    textAlign(RIGHT);
    text(label, width-50, height-50);
  }
}
  
