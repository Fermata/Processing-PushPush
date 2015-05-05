int blockSize = 14;
int viewSizeInBlocks = 10;

class HCColor {
	public int red;
	public int green;
	public int blue;

	public HCColor (int red, int green, int blue) {
		this.red = red;
		this.green = green;
		this.blue = blue;
	}

	public HCColor (String colorList) {
		String[] colors = split(colorList, ",");
		this.red = Integer.parseInt(colors[0]);
		this.green = Integer.parseInt(colors[1]);
		this.blue = Integer.parseInt(colors[2]);
	}
}

class HCPixmap {
	private static final String pixmapDirectory = "pixmap/";
	public String name;
	public String path;
	public int canvasWidth;
	public int canvasHeight;
	private char[][] canvas;
	private HCColor[] colors = new HCColor[10];
	private int colorCount = 0;

	final String pathForPixmap (String name) {
		return pixmapDirectory + name + ".pixmap";
	}

	HCPixmap (String name) {
		this.name = name;
		this.path = pathForPixmap(name);
		this.parse();
	}

	private void parse () {
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

			if(line.equals("COLORMAP")){
				index++;
				line = content[index];
				int colorIndex = 0;
				while(!line.equals("")){
					String colorList = split(line, ":")[1];
					this.colors[colorIndex] = new HCColor(colorList);
					colorIndex++;
					index++;
					line = content[index];
				}
				this.colorCount = colorIndex;
				continue;
			} 

			if(line.equals("GRID")){
				index++;
				line = content[index];
				int top = 0;
				int left = 0;
				while(!line.equals("")){
					for(left = 0; left < this.canvasWidth; left++){
						this.canvas[top][left] = line.charAt(left);
					}
					top++;
					index++;
					line = content[index];
				}
				continue;
			}

			if(line.equals("END")){
				break;
			}
		}
	}

	public void drawAtPoint(int x, int y) {
		for(int top = 0; top < this.canvasHeight; top++){
			for(int left = 0; left < this.canvasWidth; left++){
				char colorIdAtPoint = this.canvas[top][left];
				if(colorIdAtPoint == '0'){
					continue;
				}
				colorIdAtPoint -= 65;
				HCColor colorAtPoint = this.colors[colorIdAtPoint];
				fill(colorAtPoint.red, colorAtPoint.green, colorAtPoint.blue);
				noStroke();
				rect(x+left, y+top, 1, 1);
				println("Draw point " + (x+top) + "," + (y+left) + " color : " + colorAtPoint.red + colorAtPoint.green + colorAtPoint.blue);
			}
		}
	}

	public void drawAtBlock (int x, int y) {
		drawAtPoint(x * blockSize, y * blockSize);
	}
}


HCPixmap characterMap, backgroundMap, brickMap, crystalMap, houseMap, redhouseMap;

void setup () {
	size(blockSize * viewSizeInBlocks, blockSize * viewSizeInBlocks);
	loadPixmaps();
}

void loadPixmaps () {
	characterMap = new HCPixmap("character");
	backgroundMap = new HCPixmap("background");
	brickMap = new HCPixmap("brick");
	crystalMap = new HCPixmap("crystal");
	houseMap = new HCPixmap("house");
	redhouseMap = new HCPixmap("redhouse");
}

void draw(){
	brickMap.drawAtBlock(0,0);
	brickMap.drawAtBlock(1,0);
	brickMap.drawAtBlock(2,0);
	characterMap.drawAtBlock(3,0);
}
