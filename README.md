# 俄罗斯方块 (Tetris Game)

一个使用Flutter开发的经典俄罗斯方块游戏，支持AI托管模式。

## 功能特性

- 🎮 **经典玩法**：完整的俄罗斯方块游戏体验
- 🤖 **AI托管模式**：智能AI自动玩游戏
- 🎯 **三种游戏模式**：
  - 手动游戏模式
  - AI托管模式（可查看操作）
  - AI自动演示模式
- 📊 **分数系统**：支持计分和等级系统
- ⏸️ **暂停/继续**：随时暂停游戏
- 🎨 **精美UI**：现代化的深色主题界面

## 游戏截图

游戏包含三种模式：
1. **开始游戏** - 手动控制，使用屏幕按钮控制方块移动
2. **AI托管模式** - AI自动操作，但仍可查看操作过程
3. **AI自动演示** - 纯AI展示模式

## AI算法说明

AI使用基于启发式评估的算法来选择最佳移动：

- **行消除优先**：优先消除最多的完整行
- **空洞惩罚**：避免创建难以填充的空洞
- **高度优化**：尽量保持游戏区域高度较低
- **平滑度优化**：减少列之间的高度差

## 如何运行

### 前置要求

- Flutter SDK 3.0.0 或更高版本
- Dart SDK
- Android Studio（用于Android开发）

### 运行步骤

1. 克隆项目：
```bash
git clone https://github.com/your-username/tetris-game.git
cd tetris-game
```

2. 获取依赖：
```bash
flutter pub get
```

3. 运行应用：
```bash
flutter run
```

## 构建APK

要构建发布版APK，需要配置Android SDK环境：

```bash
flutter build apk --release
```

生成的APK文件位于：`build/app/outputs/flutter-apk/app-release.apk`

## 游戏操作

在手动模式下，使用以下按钮控制：

- ⬅️ 左箭头：向左移动
- ➡️ 右箭头：向右移动
- ⬇️ 下箭头：加速下落
- 🔄 旋转按钮：旋转方块
- ⏩ 快进按钮：直接到底

## 项目结构

```
tetris/
├── lib/
│   └── main.dart          # 主游戏代码
├── android/               # Android平台配置
├── ios/                   # iOS平台配置
├── build/                 # 构建输出
└── pubspec.yaml          # 依赖配置
```

## 开发说明

- 游戏使用Flutter CustomPainter进行渲染
- AI算法实时计算最佳移动位置
- 支持热重载，便于开发调试

## License

MIT License

## 贡献

欢迎提交Issue和Pull Request！

## 致谢

感谢Flutter团队提供优秀的跨平台开发框架。
