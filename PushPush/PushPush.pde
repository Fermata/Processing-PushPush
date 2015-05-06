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

	public void drawAtPoint (int x, int y) {
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
	private static final String recordDirectory = "records/";
	public String name;
	public String path;
	public String recordPath;
	public int characterX;
	public int characterY;
	public int moveCount = 0;
	public int bestMoves = 0;
	public int numberOfHouse = 0;
	public int numberOfFinishedHouse = 0;
	public boolean isNewBest = false;
	public boolean displayFinished = false;
	public boolean needsViewUpdate = true;

	final String pathForStage (String name) {
		return stageDirectory + name + ".stage";
	}

	final String pathForRecord (String name) {
		return recordDirectory + name + ".record";
	}


	public PushPushGame (String name) {
		this.name = name;
		this.path = pathForStage(name);
		this.recordPath = pathForRecord(name);
		this.parse();
	}

	private void parse () {
		String[] content = loadStrings(this.path);
		for(int index = 0; index < content.length; index++){
			String line = content[index];
			int lineLength = line.length();
			for(int position = 0; position < lineLength; position++){
				this.map[index][position] = line.charAt(position);
			}
		}
		this.findCharacter();
		this.fetchHouseCount();
		this.loadBest();
	}

	public void loadBest () {
		String best = loadStrings(this.recordPath)[0];
		this.bestMoves = Integer.parseInt(best);
		println(best);
	}

	public String bestScore () {
		if(this.bestMoves == 0){
			return "NONE";
		}else{
			return "" + this.bestMoves;
		}
	}

	public void fetchHouseCount () {
		for(int top = 0; top < viewSizeInBlocks; top++){
			for(int left = 0; left < viewSizeInBlocks; left++){
				char itemIdAtPoint = this.map[top][left];
				if(itemIdAtPoint == '^'){
					this.numberOfHouse++;
				}
			}
		}
	}

	public void findCharacter () {
		for(int top = 0; top < viewSizeInBlocks; top++){
			for(int left = 0; left < viewSizeInBlocks; left++){
				char itemIdAtPoint = this.map[top][left];
				if(itemIdAtPoint == '*'){
					this.characterX = left;
					this.characterY = top;
					return;
				}
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
				if(itemIdAtPoint == '$'){
					houseMap.drawAtBlock(x + left, y + top);
					characterMap.drawAtBlock(x + left, y + top);
					continue;
				}
				if(itemIdAtPoint == '@'){
					redhouseMap.drawAtBlock(x + left, y + top);
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

	public char itemIdAtPoint (int x, int y) {
		return this.map[y][x];
	}

	public boolean isItemMovableAtPoint (int x, int y) {
		char itemIdAtPoint = this.itemIdAtPoint(x, y);
		return (itemIdAtPoint == '0');
	}

	public boolean isCharacterMovableToDirection (int direction) {
		if(direction == UP){
			if(this.characterY == 0) return false;
			char itemId = this.itemIdAtPoint(this.characterX, this.characterY - 1);
			if(itemId == '+' || itemId == '^') return true;
		}
		if(direction == DOWN){
			if(this.characterY == viewSizeInBlocks) return false;
			char itemId = this.itemIdAtPoint(this.characterX, this.characterY + 1);
			if(itemId == '+' || itemId == '^') return true;
		}
		if(direction == LEFT){
			if(this.characterX == 0) return false;
			char itemId = this.itemIdAtPoint(this.characterX - 1, this.characterY);
			if(itemId == '+' || itemId == '^') return true;
		}
		if(direction == RIGHT){
			if(this.characterX == viewSizeInBlocks) return false;
			char itemId = this.itemIdAtPoint(this.characterX + 1, this.characterY);
			if(itemId == '+' || itemId == '^') return true;
		}
		return false;
	}

	public boolean isCrystalOnDirection (int direction) {
		if(direction == UP){
			if(this.characterY == 0) return false;
			char itemId = this.itemIdAtPoint(this.characterX, this.characterY - 1);
			if(itemId == '0' || itemId == '@') return true;
		}
		if(direction == DOWN){
			if(this.characterY == viewSizeInBlocks) return false;
			char itemId = this.itemIdAtPoint(this.characterX, this.characterY + 1);
			if(itemId == '0' || itemId == '@') return true;
		}
		if(direction == LEFT){
			if(this.characterX == 0) return false;
			char itemId = this.itemIdAtPoint(this.characterX - 1, this.characterY);
			if(itemId == '0' || itemId == '@') return true;
		}
		if(direction == RIGHT){
			if(this.characterX == viewSizeInBlocks) return false;
			char itemId = this.itemIdAtPoint(this.characterX + 1, this.characterY);
			if(itemId == '0' || itemId == '@') return true;
		}
		return false;
	}

	public boolean isCrystalOnPointMovableToDirection (int x, int y, int direction) {
		if(direction == UP){
			if(y == 0) return false;
			if(this.itemIdAtPoint(x, y - 1) == '+') return true;
		}
		if(direction == DOWN){
			if(y == viewSizeInBlocks) return false;
			if(this.itemIdAtPoint(x, y + 1) == '+') return true;
		}
		if(direction == LEFT){
			if(x == 0) return false;
			if(this.itemIdAtPoint(x - 1, y) == '+') return true;
		}
		if(direction == RIGHT){
			if(x == viewSizeInBlocks) return false;
			if(this.itemIdAtPoint(x + 1, y) == '+') return true;
		}
		return false;
	}

	public boolean isCrystalOnPointHasHouseOnDirection (int x, int y, int direction) {
		if(direction == UP){
			if(y == 0) return false;
			if(this.itemIdAtPoint(x, y - 1) == '^') return true;
		}
		if(direction == DOWN){
			if(y == viewSizeInBlocks) return false;
			if(this.itemIdAtPoint(x, y + 1) == '^') return true;
		}
		if(direction == LEFT){
			if(x == 0) return false;
			if(this.itemIdAtPoint(x - 1, y) == '^') return true;
		}
		if(direction == RIGHT){
			if(x == viewSizeInBlocks) return false;
			if(this.itemIdAtPoint(x + 1, y) == '^') return true;
		}
		return false;
	}

	public void finishHouse () {
		this.numberOfFinishedHouse++;
		if(this.numberOfHouse == this.numberOfFinishedHouse){
			this.stageCleared();
		}
	}

	public void increaseMove () {
		this.moveCount++;
	}

	public void stageCleared () {
		if(this.moveCount + 1 < this.bestMoves){
			this.bestMoves = this.moveCount + 1;
			this.isNewBest = true;
			this.saveBest();
		}
		displayFinished = true;
	}

	public void saveBest () {
		String[] score = new String[1];
		score[0] = "" + this.bestMoves;
		saveStrings(this.recordPath, score);
	}

	public void moveCharacher (int input) {
		if(this.isCrystalOnDirection(input)){
			if(input == UP){
				if(this.isCrystalOnPointHasHouseOnDirection(this.characterX, this.characterY - 1, UP)){
					this.map[this.characterY - 2][this.characterX] = '@';
					this.finishHouse();
				}else if(this.isCrystalOnPointMovableToDirection(this.characterX, this.characterY - 1, UP)){
					this.map[this.characterY - 2][this.characterX] = '0';
				}else{
					return;
				}
				this.map[this.characterY - 1][this.characterX] = '*';
				if(this.map[this.characterY][this.characterX] == '$'){
					this.map[this.characterY][this.characterX] = '^';
				}else{
					this.map[this.characterY][this.characterX] = '+';
				}
				this.characterY -= 1;
			}
			if(input == DOWN){
				if(this.isCrystalOnPointHasHouseOnDirection(this.characterX, this.characterY + 1, DOWN)){
					this.map[this.characterY + 2][this.characterX] = '@';
					this.finishHouse();
				}else if(this.isCrystalOnPointMovableToDirection(this.characterX, this.characterY + 1, DOWN)){
					this.map[this.characterY + 2][this.characterX] = '0';
				}else{
					return;
				}
				this.map[this.characterY + 1][this.characterX] = '*';
				if(this.map[this.characterY][this.characterX] == '$'){
					this.map[this.characterY][this.characterX] = '^';
				}else{
					this.map[this.characterY][this.characterX] = '+';
				}
				this.characterY += 1;
			}
			if(input == LEFT){
				if(this.isCrystalOnPointHasHouseOnDirection(this.characterX - 1, this.characterY, LEFT)){
					this.map[this.characterY][this.characterX - 2] = '@';
					this.finishHouse();
				}else if(this.isCrystalOnPointMovableToDirection(this.characterX - 1, this.characterY, LEFT)){
					this.map[this.characterY][this.characterX - 2] = '0';
				}else{
					return;
				}
				this.map[this.characterY][this.characterX - 1] = '*';
				if(this.map[this.characterY][this.characterX] == '$'){
					this.map[this.characterY][this.characterX] = '^';
				}else{
					this.map[this.characterY][this.characterX] = '+';
				}
				this.characterX -= 1;
			}
			if(input == RIGHT){
				if(this.isCrystalOnPointHasHouseOnDirection(this.characterX + 1, this.characterY, RIGHT)){
					this.map[this.characterY][this.characterX + 2] = '@';
					this.finishHouse();
				}else if(this.isCrystalOnPointMovableToDirection(this.characterX + 1, this.characterY, RIGHT)){
					this.map[this.characterY][this.characterX + 2] = '0';
				}else{
					return;
				}
				this.map[this.characterY][this.characterX + 1] = '*';
				if(this.map[this.characterY][this.characterX] == '$'){
					this.map[this.characterY][this.characterX] = '^';
				}else{
					this.map[this.characterY][this.characterX] = '+';
				}
				this.characterX += 1;
			}
			this.needsViewUpdate = true;
			this.increaseMove();
			return;
		}
		if(!this.isCharacterMovableToDirection(input)) return;
		this.needsViewUpdate = true;
		if(this.map[this.characterY][this.characterX] == '$'){
			this.map[this.characterY][this.characterX] = '^';
		}else{
			this.map[this.characterY][this.characterX] = '+';
		}
		if(input == UP) this.characterY -= 1;
		if(input == DOWN) this.characterY += 1;
		if(input == LEFT) this.characterX -= 1;
		if(input == RIGHT) this.characterX += 1;
		if(this.map[this.characterY][this.characterX] == '^'){
			this.map[this.characterY][this.characterX] = '$';
		}else{
			this.map[this.characterY][this.characterX] = '*';
		}
		this.increaseMove();
	}
}

HCPixmap characterMap, backgroundMap, brickMap, crystalMap, houseMap, redhouseMap;
PushPushGame currentGame;
final int kNumberOfStages = 2;
int currentStageNumber = 1;

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

void drawBasedOnStateMap () {
	if(currentGame.needsViewUpdate){
		clear();
		drawBackground();
		currentGame.drawAtBlock(0,0);
	}
}

void drawScore () {
	if(currentGame.displayFinished){
		clear();
		background(0);
		textSize(12 * viewScale);
		textAlign(CENTER);
		fill(255);
		text("STAGE" + currentGame.name, blockSize * viewSizeInBlocks * viewScale / 2, blockSize * viewSizeInBlocks * viewScale / 2 - 24 * viewScale);
		text("FINISHED!", blockSize * viewSizeInBlocks * viewScale / 2, blockSize * viewSizeInBlocks * viewScale / 2 - 13 * viewScale);
		textSize(9 * viewScale);
		text("MOVES : " + currentGame.moveCount, blockSize * viewSizeInBlocks * viewScale / 2, blockSize * viewSizeInBlocks * viewScale / 2 + 10 * viewScale);
		String message;
		if(currentGame.isNewBest){
			message = "NEW BEST!";
		}else{
			message = "BEST : " + currentGame.bestScore();
		}
		text(message, blockSize * viewSizeInBlocks * viewScale / 2, blockSize * viewSizeInBlocks * viewScale / 2 + 20 * viewScale);
		textSize(10);
		if(currentStageNumber == kNumberOfStages){
			message = "YOU CLEARED ALL STAGES!";
		}else{
			message = "PRESS ANY KEY TO CONTINUE";
		}
		text(message, blockSize * viewSizeInBlocks * viewScale / 2, blockSize * viewSizeInBlocks * viewScale - 4 * viewScale);
	}else{
		fill(0);
		textSize(7 * viewScale);
		textAlign(LEFT);
		text("MOVES:" + currentGame.moveCount + "  BEST:" + currentGame.bestScore(), viewScale, 8 * viewScale);
		textAlign(RIGHT);
		text("STAGE " + currentGame.name, blockSize * viewSizeInBlocks * viewScale - viewScale, 8 * viewScale);
	}
}

void draw () {
	drawBasedOnStateMap();
	drawScore();
}

void keyReleased () {
	if(currentGame.displayFinished){
		if(currentStageNumber != kNumberOfStages){
			currentStageNumber++;
			currentGame = new PushPushGame("" + currentStageNumber);
		}
	}
	if(keyCode == UP || keyCode == DOWN || keyCode == LEFT || keyCode == RIGHT){
		currentGame.moveCharacher(keyCode);
		return;
	}else if(key == 'r'){
		currentGame = new PushPushGame("" + currentStageNumber);
	}
}