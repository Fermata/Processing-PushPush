int blockSize = 14;
int viewSizeInBlocks = 10;

class HCColor {
  int red;
  int green;
  int blue;
  HCColor (int red, int green, int blue) {
    this.red = red;
    this.green = green;
    this.blue = blue;
  }
  HCColor (String colorList) {
    String[] colors = split(colorList, ",");
    this.red = Integer.parseInt(colors[0]);
    this.green = Integer.parseInt(colors[1]);
    this.blue = Integer.parseInt(colors[2]);
  }
}

class HCPixmap {
  static final pixmapDirectory = "pixmap/";
  String name;
  String path;
  int canvasWidth;
  int canvasHeight;
  char[][] canvas;
  HCColor[] colors = new HCColor[10];
  static final String pathForPixmap (String fileName) {
    return pixmapDirectory + fileName;
  }
  HCPixmap (String name) {
    this.name = name;
    this.path = pathForPixmap(name);
    this.parse();
  }
  void parse () {
    String[] content = loadStrings(this.path);
    for(int index = 0; index < content.length; index++){
      String line = content[index];
      if(line.equals("CANVAS")){
        index++;
        line = content[index];
        String[] sizeString = split(line, "x");
        this.canvasWidth = Integer.parseInt(sizeString[0]);
        this.canvasHeight = Integer.parseInt(sizeString[1]);
        this.canvas = new char[canvasWidth][canvasHeight];
        continue;
      }
      if(line.equals("COLORS")){
        index++;
        line = content[index];
        int colorIndex = 0;
        while(!line.equals("")){
          String.colorMap
          this.colors[]
          colorIndex++;
          index++;
          line = content[index];
        }
        continue;
      } 
      if(line.equals("END"){
        break;
      }
    }
  }
  
}
    

void setup(){
  size(blockSize * viewSizeInBlocks, blockSize * viewSizeInBlocks);
}
