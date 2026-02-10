import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:math';

void main() {
  runApp(const TetrisApp());
}

class TetrisApp extends StatelessWidget {
  const TetrisApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '俄罗斯方块',
      theme: ThemeData.dark(),
      home: const MainMenu(),
    );
  }
}

class MainMenu extends StatelessWidget {
  const MainMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade900, Colors.purple.shade900],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '俄罗斯方块',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 10,
                      color: Colors.yellow,
                      offset: Offset(2, 2),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Icon(Icons.grid_on, size: 100, color: Colors.yellow),
              const SizedBox(height: 50),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GameScreen(aiMode: false)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  '开始游戏',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GameScreen(aiMode: true)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'AI托管模式',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const GameScreen(aiMode: true, showControls: false)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                  backgroundColor: Colors.purple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'AI自动演示',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  final bool aiMode;
  final bool showControls;

  const GameScreen({
    Key? key,
    required this.aiMode,
    this.showControls = true,
  }) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  static const int cols = 10;
  static const int rows = 20;
  static const double blockSize = 25.0;

  List<List<int>> board = [];
  List<List<int>> currentPiece = [];
  int currentX = 0;
  int currentY = 0;
  int currentColor = 0;
  int score = 0;
  int level = 1;
  int linesCleared = 0;
  bool gameOver = false;
  bool paused = false;
  Timer? gameTimer;
  Timer? aiTimer;

  final List<List<List<int>>> shapes = [
    [[1, 1, 1, 1]], // I
    [[1, 1], [1, 1]], // O
    [[1, 1, 1], [0, 1, 0]], // T
    [[1, 1, 1], [1, 0, 0]], // L
    [[1, 1, 1], [0, 0, 1]], // J
    [[1, 1, 0], [0, 1, 1]], // S
    [[0, 1, 1], [1, 1, 0]], // Z
  ];

  final List<Color> colors = [
    Colors.cyan,
    Colors.yellow,
    Colors.purple,
    Colors.orange,
    Colors.blue,
    Colors.green,
    Colors.red,
  ];

  @override
  void initState() {
    super.initState();
    initBoard();
    spawnPiece();
    startGame();
    if (widget.aiMode) {
      startAI();
    }
  }

  void initBoard() {
    board = List.generate(rows, (_) => List.filled(cols, 0));
  }

  void startGame() {
    gameTimer = Timer.periodic(
      Duration(milliseconds: 800 - (level - 1) * 50),
      (timer) {
        if (!paused && !gameOver) {
          moveDown();
        }
      },
    );
  }

  void startAI() {
    aiTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (!paused && !gameOver && widget.aiMode) {
        makeAIMove();
      }
    });
  }

  void makeAIMove() {
    int bestX = currentX;
    int bestRotation = 0;
    double bestScore = -double.infinity;

    for (int rotation = 0; rotation < 4; rotation++) {
      List<List<int>> testPiece = rotatePiece(currentPiece, rotation);
      
      for (int x = -testPiece[0].length + 1; x < cols; x++) {
        int y = 0;
        while (isValidMove(testPiece, x, y + 1)) {
          y++;
        }
        
        if (isValidMove(testPiece, x, y)) {
          double score = evaluatePosition(testPiece, x, y);
          if (score > bestScore) {
            bestScore = score;
            bestX = x;
            bestRotation = rotation;
          }
        }
      }
    }

    // 执行最佳移动
    setState(() {
      for (int i = 0; i < bestRotation; i++) {
        currentPiece = rotatePiece(currentPiece);
      }
      currentX = bestX;
      moveDown();
    });
  }

  double evaluatePosition(List<List<int>> piece, int x, int y) {
    List<List<int>> tempBoard = board.map((row) => List<int>.from(row)).toList();
    
    // 放置方块
    for (int i = 0; i < piece.length; i++) {
      for (int j = 0; j < piece[i].length; j++) {
        if (piece[i][j] != 0) {
          if (y + i >= 0 && y + i < rows && x + j >= 0 && x + j < cols) {
            tempBoard[y + i][x + j] = currentColor;
          }
        }
      }
    }

    double score = 0;
    
    // 检查消除行数
    int lines = 0;
    for (int i = 0; i < rows; i++) {
      if (tempBoard[i].every((cell) => cell != 0)) {
        lines++;
      }
    }
    score += lines * 100;

    // 惩罚空洞
    int holes = 0;
    for (int j = 0; j < cols; j++) {
      bool foundBlock = false;
      for (int i = 0; i < rows; i++) {
        if (tempBoard[i][j] != 0) {
          foundBlock = true;
        } else if (foundBlock && tempBoard[i][j] == 0) {
          holes++;
        }
      }
    }
    score -= holes * 30;

    // 奖励低高度
    int maxHeight = 0;
    for (int j = 0; j < cols; j++) {
      for (int i = 0; i < rows; i++) {
        if (tempBoard[i][j] != 0) {
          maxHeight = max(maxHeight, rows - i);
          break;
        }
      }
    }
    score -= maxHeight * 5;

    // 奖励平整度
    int bumpiness = 0;
    for (int j = 0; j < cols - 1; j++) {
      int h1 = 0, h2 = 0;
      for (int i = 0; i < rows; i++) {
        if (tempBoard[i][j] != 0) {
          h1 = rows - i;
          break;
        }
      }
      for (int i = 0; i < rows; i++) {
        if (tempBoard[i][j + 1] != 0) {
          h2 = rows - i;
          break;
        }
      }
      bumpiness += (h1 - h2).abs();
    }
    score -= bumpiness * 2;

    return score;
  }

  List<List<int>> rotatePiece(List<List<int>> piece, [int times = 1]) {
    List<List<int>> rotated = List.from(piece);
    for (int t = 0; t < times; t++) {
      List<List<int>> temp = [];
      for (int i = 0; i < rotated[0].length; i++) {
        temp.add([]);
        for (int j = rotated.length - 1; j >= 0; j--) {
          temp[i].add(rotated[j][i]);
        }
      }
      rotated = temp;
    }
    return rotated;
  }

  void spawnPiece() {
    int index = Random().nextInt(shapes.length);
    currentPiece = shapes[index].map((row) => List<int>.from(row)).toList();
    currentX = (cols - currentPiece[0].length) ~/ 2;
    currentY = 0;
    currentColor = index + 1;

    if (!isValidMove(currentPiece, currentX, currentY)) {
      gameOver = true;
      gameTimer?.cancel();
      aiTimer?.cancel();
    }
  }

  bool isValidMove(List<List<int>> piece, int newX, int newY) {
    for (int i = 0; i < piece.length; i++) {
      for (int j = 0; j < piece[i].length; j++) {
        if (piece[i][j] != 0) {
          int x = newX + j;
          int y = newY + i;
          if (x < 0 || x >= cols || y >= rows) return false;
          if (y >= 0 && board[y][x] != 0) return false;
        }
      }
    }
    return true;
  }

  void moveLeft() {
    if (isValidMove(currentPiece, currentX - 1, currentY)) {
      setState(() => currentX--);
    }
  }

  void moveRight() {
    if (isValidMove(currentPiece, currentX + 1, currentY)) {
      setState(() => currentX++);
    }
  }

  void moveDown() {
    if (isValidMove(currentPiece, currentX, currentY + 1)) {
      setState(() => currentY++);
    } else {
      lockPiece();
    }
  }

  void rotate() {
    List<List<int>> rotated = rotatePiece(currentPiece);
    if (isValidMove(rotated, currentX, currentY)) {
      setState(() => currentPiece = rotated);
    }
  }

  void drop() {
    while (isValidMove(currentPiece, currentX, currentY + 1)) {
      currentY++;
    }
    lockPiece();
  }

  void lockPiece() {
    for (int i = 0; i < currentPiece.length; i++) {
      for (int j = 0; j < currentPiece[i].length; j++) {
        if (currentPiece[i][j] != 0) {
          int y = currentY + i;
          int x = currentX + j;
          if (y >= 0) {
            board[y][x] = currentColor;
          }
        }
      }
    }
    clearLines();
    spawnPiece();
  }

  void clearLines() {
    int lines = 0;
    for (int i = rows - 1; i >= 0; i--) {
      if (board[i].every((cell) => cell != 0)) {
        board.removeAt(i);
        board.insert(0, List.filled(cols, 0));
        lines++;
        i++;
      }
    }
    if (lines > 0) {
      linesCleared += lines;
      score += [0, 100, 300, 500, 800][lines] * level;
      level = linesCleared ~/ 10 + 1;
    }
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    aiTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(widget.aiMode ? 'AI托管模式' : '俄罗斯方块'),
        actions: [
          IconButton(
            icon: Icon(paused ? Icons.play_arrow : Icons.pause),
            onPressed: () {
              setState(() => paused = !paused);
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                initBoard();
                score = 0;
                level = 1;
                linesCleared = 0;
                gameOver = false;
                spawnPiece();
              });
            },
          ),
        ],
      ),
      body: gameOver
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    '游戏结束',
                    style: TextStyle(fontSize: 40, color: Colors.red),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    '分数: $score',
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        initBoard();
                        score = 0;
                        level = 1;
                        linesCleared = 0;
                        gameOver = false;
                        spawnPiece();
                      });
                    },
                    child: const Text('重新开始'),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('返回菜单'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: CustomPaint(
                        size: Size(cols * blockSize, rows * blockSize),
                        painter: BoardPainter(
                          board: board,
                          currentPiece: currentPiece,
                          currentX: currentX,
                          currentY: currentY,
                          currentColor: currentColor,
                          colors: colors,
                          blockSize: blockSize,
                        ),
                      ),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.grey[900],
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Text('分数: $score', style: const TextStyle(fontSize: 20, color: Colors.white)),
                          Text('等级: $level', style: const TextStyle(fontSize: 20, color: Colors.white)),
                        ],
                      ),
                      if (widget.showControls) ...[
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              onPressed: moveLeft,
                              child: const Icon(Icons.arrow_left),
                            ),
                            Column(
                              children: [
                                ElevatedButton(
                                  onPressed: rotate,
                                  child: const Icon(Icons.rotate_right),
                                ),
                                const SizedBox(height: 10),
                                ElevatedButton(
                                  onPressed: moveDown,
                                  child: const Icon(Icons.arrow_downward),
                                ),
                              ],
                            ),
                            ElevatedButton(
                              onPressed: moveRight,
                              child: const Icon(Icons.arrow_right),
                            ),
                            ElevatedButton(
                              onPressed: drop,
                              child: const Icon(Icons.fast_forward),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: 10),
                      if (widget.aiMode)
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Colors.green.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            'AI托管中...',
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class BoardPainter extends CustomPainter {
  final List<List<int>> board;
  final List<List<int>> currentPiece;
  final int currentX;
  final int currentY;
  final int currentColor;
  final List<Color> colors;
  final double blockSize;

  BoardPainter({
    required this.board,
    required this.currentPiece,
    required this.currentX,
    required this.currentY,
    required this.currentColor,
    required this.colors,
    required this.blockSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制背景网格
    for (int i = 0; i < board.length; i++) {
      for (int j = 0; j < board[i].length; j++) {
        final rect = Rect.fromLTWH(j * blockSize, i * blockSize, blockSize - 1, blockSize - 1);
        canvas.drawRect(
          rect,
          Paint()
            ..color = board[i][j] != 0
                ? colors[board[i][j] - 1]
                : Colors.grey[800]!,
        );
        if (board[i][j] != 0) {
          canvas.drawRect(
            rect,
            Paint()
              ..color = Colors.white.withOpacity(0.3)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1,
          );
        }
      }
    }

    // 绘制当前方块
    for (int i = 0; i < currentPiece.length; i++) {
      for (int j = 0; j < currentPiece[i].length; j++) {
        if (currentPiece[i][j] != 0) {
          final x = (currentX + j) * blockSize;
          final y = (currentY + i) * blockSize;
          final rect = Rect.fromLTWH(x, y, blockSize - 1, blockSize - 1);
          canvas.drawRect(
            rect,
            Paint()..color = colors[currentColor - 1],
          );
          canvas.drawRect(
            rect,
            Paint()
              ..color = Colors.white.withOpacity(0.3)
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1,
          );
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
