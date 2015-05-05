int blockSize = 14;
int viewSizeInBlocks = 10;
int viewScale = 2;

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
				rect(x * viewScale + left * viewScale, y * viewScale + top * viewScale, viewScale, viewScale);
			}
		}
	}

	public void drawAtBlock (int x, int y) {
		drawAtPoint(x * blockSize, y * blockSize);
	}
}

class PushPushGame {
	public char[][] map = new char[viewSizeInBlocks][viewSizeInBlocks];
	private static final String stageDirectory = "stage/";
	public String name;
	public String path;
	public boolean needsViewUpdate = true;

	final String pathForStage (String name) {
		return stageDirectory + name + ".stage";
	}

	public PushPushGame (String name) {
		this.name = name;
		this.path = pathForStage(name);
		this.parse();
	}

	private void parse() {
		String[] content = loadStrings(this.path);
		for(int index = 0; index < content.length; index++){
			String line = content[index];
			int lineLength = line.length();
			for(int position = 0; position < lineLength; position++){
				this.map[index][position] = line.charAt(position);
			}
		}
	}

	public void drawAtBlock(int x, int y) {
		for(int top = 0; top < viewSizeInBlocks; top++){
			for(int left = 0; left < viewSizeInBlocks; left++){
				char itemIdAtPoint = this.map[top][left];
				if(itemIdAtPoint == '+'){
					continue;
				}
				if(itemIdAtPoint == '#'){
					brickMap.drawAtBlock(x + left, y + top);
					continue;
				}
				if(itemIdAtPoint == '^'){
					houseMap.drawAtBlock(x + left, y + top);
					continue;
				}
				if(itemIdAtPoint == '0'){
					crystalMap.drawAtBlock(x + left, y + top);
					continue;
				}
				if(itemIdAtPoint == '*'){
					characterMap.drawAtBlock(x + left, y + top);
					continue;
				}
			}
		}
		this.needsViewUpdate = false;
	}
}

HCPixmap characterMap, backgroundMap, brickMap, crystalMap, houseMap, redhouseMap;
PushPushGame currentGame;

void setup () {
	size(blockSize * viewSizeInBlocks * viewScale, blockSize * viewSizeInBlocks * viewScale);
	currentGame = new PushPushGame("1");
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

void drawBackground(){
	for(int top = 0; top < viewSizeInBlocks; top++){
		for(int left = 0; left < viewSizeInBlocks; left++){
			backgroundMap.drawAtBlock(left, top);
		}
	}
}

void drawBasedOnStateMap(){
	if(currentGame.needsViewUpdate){
		clear();
		drawBackground();
		currentGame.drawAtBlock(0,0);
	}
}

void draw(){
	drawBasedOnStateMap();
}