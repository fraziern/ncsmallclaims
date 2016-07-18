FloatTable data;
PFont font;

void setup() {
  size(800,800);
  background(255);
  smooth();
  
  data = new FloatTable("countyDeltas.csv");
  float numbers[] = new float[100];
  float numbersD[] = new float[100];
  float numbersS[] = new float[100];
  float numbersP[] = new float[100];

  
  for (int i = 0; i < 100; i++) {
    numbers[i] = data.getFloat(i, 2);
    numbersD[i] = data.getFloat(i,1);
    numbersS[i] = data.getFloat(i,3);
    numbersP[i] = data.getFloat(i,0);
  };
  
  print(data.getFloat(0,0) + " " + data.getFloat(0,1) + " " + data.getFloat(0,2) + " " + data.getFloat(0,3));
  makeNormal(numbersP);
  
  barGraph(numbers, 250);
  barGraph(numbersD, 450);
  barGraph(numbersS, 600);
  barGraphKey(numbersP, 150);
  
  // Add labels
  font = loadFont("SansSerif-12.vlw");
  textFont(font, 12);
  fill(0,200);
  text("2009 median income", 2, 48);
  text("delta CVM", 2, 248);
  text("delta CVD", 2, 405);
  text("delta CVS", 2, 565);
  
  // Add title
  textFont(font, 18);
  fill(0,200);
  text("Change in Civil Filings in NC Counties, 2000-2009", 2, 735);
  textFont(font, 11);
  text("Displayed in order of 2009 median income; Figures represent filings per capita", 2, 750);

  // Save
  //save("image3.jpg");

};
  
void barGraph(float[] nums, float y) {
  stroke(255);
  for (int i = 0; i < 100; i++) {
    fill(200, abs(nums[i]) * 225, 54);    
    rect(i*8, y, 8, -nums[i] * 100);
  };
};

void barGraphKey(float[] nums, float y) {
  for (int i = 0; i < 100; i++) {
    fill(16,91,99);    
    rect(i*8, y, 8, -nums[i] * 100);
  };
};

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

  
