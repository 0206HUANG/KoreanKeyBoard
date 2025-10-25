import { router } from '@kit.ArkUI';
import { DownloadService } from '../services/DownloadService';

/**
 * 点坐标接口
 */
interface Point {
  x: number;
  y: number;
}

/**
 * 词典条目接口
 */
interface DictionaryEntry {
  korean: string;
  chinese: string;
  phonetic?: string;
  example?: string;
  wordType?: string;
  frequency?: number;
}

/**
 * 识别记录接口
 */
interface RecognitionRecord {
  stroke: number;
  result: string;
}

/**
 * 韩文字母接口
 */
interface KoreanCharacter {
  id: string;
  korean: string;
  name: string;
  phonetic: string;
  pronunciation: string;
  strokeCount: number;
  strokes: string[];
  tips: string[];
  similar?: string;
}

/**
 * 在线字典结果接口
 */
interface OnlineDictResult {
  word: string;
  definitions: string[];
  examples: string[];
  source: string;
}

/**
 * 下载资源类
 */
/**
 * 下载资源接口
 */
interface DownloadResource {
  id: string;
  name: string;
  description: string;
  size: string;
  category: string;
  version: string;
  downloadUrl: string;
  isDownloaded: boolean;
  downloadProgress: number;
  downloadedAt?: number;
}

class DownloadResourceItem {
  id: string = '';
  name: string = '';
  description: string = '';
  size: string = '';
  category: string = '';
  version: string = '';
  downloadUrl: string = '';
  isDownloaded: boolean = false;
  downloadProgress: number = 0;
  downloadedAt?: number;

  constructor(resource?: DownloadResource) {
    if (resource) {
      this.id = resource.id;
      this.name = resource.name;
      this.description = resource.description;
      this.size = resource.size;
      this.category = resource.category;
      this.version = resource.version;
      this.downloadUrl = resource.downloadUrl;
      this.isDownloaded = resource.isDownloaded;
      this.downloadProgress = resource.downloadProgress;
      this.downloadedAt = resource.downloadedAt;
    }
  }
}

/**
 * 下载统计类
 */
class DownloadStats {
  totalCount: number = 0;
  downloadedCount: number = 0;
  totalSize: string = '0 MB';
}

/**
 * 韩笔输入宝 - 主应用页面
 * 功能: 韩文手写 + 键盘输入 + 词典查询 + 教程学习
 */
@Entry
@Component
struct Index {
  @State activeTab: number = 0;
  @State appTitle: string = '韩笔输入宝';
  private controller: TabsController = new TabsController();

  build() {
    Column() {
      // 顶部标题栏
      this.buildHeader()

      // Tab 导航和内容区域
      Tabs({ barPosition: BarPosition.End, controller: this.controller }) {
        // Tab 1: 手写输入
        TabContent() {
          HandwritingPage()
        }
        .tabBar(this.buildTabBar('✍️ 手写', 0))

        // Tab 2: 键盘输入
        TabContent() {
          KeyboardPage()
        }
        .tabBar(this.buildTabBar('⌨️ 键盘', 1))

        // Tab 3: 词典查询
        TabContent() {
          DictionaryPage()
        }
        .tabBar(this.buildTabBar('📚 词典', 2))

        // Tab 4: 教程
        TabContent() {
          TutorialPage()
        }
        .tabBar(this.buildTabBar('🎓 教程', 3))

        // Tab 5: 下载
        TabContent() {
          DownloadPage()
        }
        .tabBar(this.buildTabBar('⬇️ 下载', 4))
      }
      .onChange((index: number) => {
        this.activeTab = index;
      })
      .width('100%')
      .layoutWeight(1)
    }
    .width('100%')
    .height('100%')
    .backgroundColor($r('app.color.start_window_background'))
  }

  @Builder
  buildHeader() {
    Column() {
      Text(this.appTitle)
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .fontColor(Color.White)
        .textAlign(TextAlign.Center)
        .width('100%')
        .padding(16)
    }
    .width('100%')
    .backgroundColor('#000000')
  }

  @Builder
  buildTabBar(label: string, index: number) {
    Column() {
      Text(label)
        .fontSize(12)
        .fontColor(this.activeTab === index ? '#000000' : '#999999')
        .fontWeight(this.activeTab === index ? FontWeight.Bold : FontWeight.Normal)
    }
    .width('100%')
    .height(48)
    .justifyContent(FlexAlign.Center)
  }
}

/**
 * 手写输入页面
 */
@Component
struct HandwritingPage {
  @State isDrawing: boolean = false;
  @State inputText: string = '';
  @State realtimeText: string = ''; // 实时识别结果
  @State strokes: Array<Array<Point>> = [];
  @State canvasWidth: number = 400;
  @State canvasHeight: number = 300;
  @State recognitionHistory: Array<RecognitionRecord> = [];
  private canvasContext: CanvasRenderingContext2D | null = null;

  build() {
    Column({ space: 10 }) {
      Text('韩文手写输入')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .padding({ top: 16, left: 16 })

      // 画布区域 - 自定义画布容器
      Column() {
        Canvas()
          .width('100%')
          .height(300)
          .backgroundColor(Color.White)
          .border({ width: 1, color: '#CCCCCC' })
          .onTouch((event: TouchEvent) => {
            this.handleCanvasTouch(event);
          })
      }
      .width('100%')
      .padding({ top: 16, left: 16, right: 16 })

      // 笔画信息和清空提示
      if (this.strokes.length > 0) {
        Row() {
          Text(`✓ 已绘制 ${this.strokes.length} 笔`)
            .fontSize(12)
            .fontColor('#000000')
            .fontWeight(FontWeight.Bold)

          Row()
            .layoutWeight(1)

          Text('实时识别: ' + this.realtimeText)
            .fontSize(12)
            .fontColor('#27AE60')
            .fontWeight(FontWeight.Bold)
        }
        .width('100%')
        .padding({ left: 16, right: 16 })
      } else {
        Text('在画布上手指/鼠标滑动绘画')
          .fontSize(12)
          .fontColor('#999999')
          .padding({ left: 16, right: 16 })
      }

      // 实时识别历史
      if (this.recognitionHistory.length > 0) {
        Column() {
          Text('识别历史')
            .fontSize(12)
            .fontColor('#666666')
            .padding({ left: 12, top: 8 })

          Row() {
            ForEach(this.recognitionHistory, (item: RecognitionRecord, index: number) => {
              Column() {
                Text(`第${item.stroke}笔`)
                  .fontSize(10)
                  .fontColor('#999999')

                Text(item.result)
                  .fontSize(16)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#000000')
              }
              .width(50)
              .height(60)
              .justifyContent(FlexAlign.Center)
              .alignItems(HorizontalAlign.Center)
              .backgroundColor('#F5F5F5')
              .borderRadius(6)
              .margin({ right: 8 })
            }, (item: RecognitionRecord, index: number) => index.toString())

            Row().layoutWeight(1)
          }
          .width('100%')
          .padding(12)
          .backgroundColor('#FAFAFA')
          .borderRadius(8)
        }
        .width('100%')
        .margin({ left: 16, right: 16, top: 8 })
      }

      // 控制按钮
      Row({ space: 10 }) {
        Button('清空')
          .layoutWeight(1)
          .onClick(() => {
            this.clearCanvas();
          })

        Button('撤销')
          .layoutWeight(1)
          .onClick(() => {
            this.undoStroke();
          })

        Button('识别')
          .layoutWeight(1)
          .type(ButtonType.Capsule)
          .backgroundColor('#000000')
          .fontColor(Color.White)
          .onClick(() => {
            this.recognizeHandwriting();
          })
      }
      .width('100%')
      .padding(16)

      // 最终识别结果
      if (this.inputText) {
        Column() {
          Text('最终结果:')
            .fontSize(14)
            .fontColor('#666666')

          Text(this.inputText)
            .fontSize(28)
            .fontWeight(FontWeight.Bold)
            .fontColor('#000000')
            .padding(10)
            .backgroundColor('#F5F5F5')
            .borderRadius(8)
            .width('100%')
            .textAlign(TextAlign.Center)
        }
        .width('100%')
        .padding(16)
        .border({ width: 1, color: '#CCCCCC', radius: 8 })
        .margin({ left: 16, right: 16 })
      }

      Row().layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }

  // 处理Canvas触摸事件
  private handleCanvasTouch(event: TouchEvent) {
    const point = event.touches[0];
    const offsetX = point.x;
    const offsetY = point.y;

    switch (event.type) {
      case TouchType.Down:
        // 开始新的笔画
        this.strokes.push([]);
        const pt: Point = { x: offsetX, y: offsetY };
        this.strokes[this.strokes.length - 1].push(pt);
        this.isDrawing = true;
        this.inputText = ''; // 清空最终结果，但保留实时结果
        break;

      case TouchType.Move:
        // 继续绘画
        if (this.isDrawing && this.strokes.length > 0) {
          const lastStroke = this.strokes[this.strokes.length - 1];
          if (lastStroke) {
            const movePoint: Point = { x: offsetX, y: offsetY };
            lastStroke.push(movePoint);
          }
        }
        break;

      case TouchType.Up:
        // 结束笔画 - 自动实时识别
        this.isDrawing = false;
        if (this.strokes.length > 0) {
          this.realTimeRecognize();
        }
        break;

      case TouchType.Cancel:
        // 取消绘画
        this.isDrawing = false;
        break;
    }
  }

  // 实时识别（每笔结束时自动调用）
  private realTimeRecognize() {
    const strokeCount = this.strokes.length;
    let result = this.recognizeByStrokeCount(strokeCount);
    
    // 更新实时结果
    this.realtimeText = result;
    
    // 添加到历史记录
    const record: RecognitionRecord = {
      stroke: strokeCount,
      result: result
    };
    this.recognitionHistory.push(record);
  }

  // 根据笔画数识别文字
  private recognizeByStrokeCount(count: number): string {
    const recognitionMap: Record<number, string> = {
      1: 'ㄱ',
      2: 'ㄴ',
      3: '안',
      4: '녕',
      5: '하',
      6: '세',
      7: '요',
      8: '감',
      9: '사',
      10: '합'
    };
    
    return recognitionMap[count] || '?';
  }

  // 清空Canvas
  private clearCanvas() {
    this.strokes = [];
    this.inputText = '';
    this.realtimeText = '';
    this.recognitionHistory = [];
  }

  // 撤销最后一笔
  private undoStroke() {
    if (this.strokes.length > 0) {
      this.strokes.pop();
      this.inputText = '';
      
      // 更新实时识别结果
      if (this.strokes.length > 0) {
        const strokeCount = this.strokes.length;
        this.realtimeText = this.recognizeByStrokeCount(strokeCount);
        
        // 移除历史记录中的最后一项
        if (this.recognitionHistory.length > 0) {
          this.recognitionHistory.pop();
        }
      } else {
        this.realtimeText = '';
        this.recognitionHistory = [];
      }
    }
  }

  // 识别手写文字（手动触发）
  private recognizeHandwriting() {
    if (this.strokes.length === 0) {
      return;
    }

    // 使用最后一笔的识别结果作为最终结果
    const strokeCount = this.strokes.length;
    const result = this.recognizeByStrokeCount(strokeCount);
    this.inputText = result;

    // 在实际应用中，这里应该调用真实的OCR API
    // const result = await ocrService.recognizeHandwriting(this.strokes);
    // this.inputText = result.text;
  }
}

/**
 * 键盘输入页面
 */
@Component
struct KeyboardPage {
  @State koreaInput: string = '';
  @State inputHistory: string[] = [];

  build() {
    Column({ space: 10 }) {
      Text('韩文键盘输入')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .padding({ top: 16, left: 16 })

      // 输入框
      TextInput({ text: this.koreaInput })
        .width('90%')
        .height(50)
        .borderRadius(8)
        .backgroundColor(Color.White)
        .border({ width: 1, color: '#CCCCCC' })
        .margin({ top: 16, left: 16, right: 16 })
        .onChange((value: string) => {
          this.koreaInput = value;
        })

      // 自定义韩文键盘
      this.buildKoreanKeyboard()

      // 输入历史
      Text('输入历史')
        .fontSize(14)
        .fontWeight(FontWeight.Bold)
        .padding({ left: 16, top: 10 })

      List() {
        ForEach(this.inputHistory, (item: string) => {
          ListItem() {
            Text(item)
              .fontSize(14)
              .padding(10)
              .width('100%')
          }
        }, (item: string) => item)
      }
      .width('100%')
      .layoutWeight(1)
      .padding({ left: 16, right: 16 })

      Row().layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildKoreanKeyboard() {
    Column({ space: 5 }) {
      Text('快速输入')
        .fontSize(12)
        .fontColor('#999999')
        .padding({ left: 16 })

      // 韩文辅音行
      Row() {
        ForEach(['ㄱ', 'ㄴ', 'ㄷ', 'ㄹ', 'ㅁ', 'ㅂ', 'ㅅ', 'ㅇ'], (char: string) => {
          Button(char)
            .width(40)
            .height(40)
            .fontSize(14)
            .onClick(() => {
              this.koreaInput += char;
            })
            .margin(5)
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Start)

      // 韩文元音行
      Row() {
        ForEach(['ㅏ', 'ㅑ', 'ㅓ', 'ㅕ', 'ㅗ', 'ㅜ', 'ㅝ', 'ㅞ'], (char: string) => {
          Button(char)
            .width(40)
            .height(40)
            .fontSize(14)
            .onClick(() => {
              this.koreaInput += char;
            })
            .margin(5)
        })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })
      .justifyContent(FlexAlign.Start)

      Button('添加到历史')
        .width('90%')
        .margin({ top: 10, left: 16, right: 16 })
        .onClick(() => {
          if (this.koreaInput.trim()) {
            this.inputHistory.unshift(this.koreaInput);
            if (this.inputHistory.length > 20) {
              this.inputHistory.pop();
            }
          }
        })
    }
  }
}


/**
 * 词典查询页面
 */
@Component
struct DictionaryPage {
  @State searchText: string = '';
  @State searchResults: DictionaryEntry[] = [];
  @State activeTab: string = '本地';
  @State isSearching: boolean = false;
  @State onlineResults: OnlineDictResult[] = [];

  build() {
    Column({ space: 10 }) {
      Text('韩文词典')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .padding({ top: 16, left: 16 })

      // 词典源选择
      Row() {
        Button('本地')
          .type(ButtonType.Normal)
          .height(36)
          .padding({ left: 16, right: 16 })
          .backgroundColor(this.activeTab === '本地' ? '#000000' : '#F5F5F5')
          .fontColor(this.activeTab === '本地' ? Color.White : '#000000')
          .fontSize(12)
          .onClick(() => {
            this.activeTab = '本地';
            this.onlineResults = [];
          })
          .margin({ right: 8 })

        Button('在线')
          .type(ButtonType.Normal)
          .height(36)
          .padding({ left: 16, right: 16 })
          .backgroundColor(this.activeTab === '在线' ? '#000000' : '#F5F5F5')
          .fontColor(this.activeTab === '在线' ? Color.White : '#000000')
          .fontSize(12)
          .onClick(() => {
            this.activeTab = '在线';
            this.searchResults = [];
          })

        Row().layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12 })

      // 搜索框
      Row({ space: 10 }) {
        TextInput({ placeholder: '输入韩文或中文查询', text: this.searchText })
          .layoutWeight(1)
          .height(40)
          .borderRadius(20)
          .backgroundColor(Color.White)
          .border({ width: 1, color: '#CCCCCC' })
          .padding({ left: 15, right: 15 })
          .onChange((value: string) => {
            this.searchText = value;
          })

        Button('搜索')
          .width(70)
          .height(40)
          .borderRadius(20)
          .backgroundColor('#000000')
          .fontColor(Color.White)
          .onClick(() => {
            if (this.activeTab === '本地') {
              this.searchLocal();
            } else {
              this.searchOnline();
            }
          })
      }
      .width('100%')
      .padding({ left: 16, right: 16 })

      // 搜索中提示
      if (this.isSearching) {
        Column() {
          Text('搜索中...')
            .fontSize(14)
            .fontColor('#666666')
        }
        .width('100%')
        .height(100)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }

      // 本地搜索结果
      if (this.activeTab === '本地' && this.searchResults.length > 0) {
        List() {
          ForEach(this.searchResults, (item: DictionaryEntry) => {
            ListItem() {
              Column({ space: 5 }) {
                // 韩文词
                Text(item.korean)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#000000')

                // 中文释义
                Text(item.chinese)
                  .fontSize(14)
                  .fontColor('#666666')

                // 音标
                if (item.phonetic) {
                  Text(`发音: ${item.phonetic}`)
                    .fontSize(12)
                    .fontColor('#999999')
                }

                // 例句
                if (item.example) {
                  Column() {
                    Text('例句:')
                      .fontSize(12)
                      .fontColor('#666666')

                    Text(item.example)
                      .fontSize(13)
                      .fontColor('#333333')
                  }
                  .width('100%')
                  .padding(10)
                  .backgroundColor('#F5F5F5')
                  .borderRadius(5)
                }
              }
              .width('100%')
              .padding(12)
              .border({ width: 1, color: '#CCCCCC', radius: 8 })
            }
          }, (item: DictionaryEntry) => item.korean)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 10 })
      }

      // 在线搜索结果
      if (this.activeTab === '在线' && this.onlineResults.length > 0) {
        List() {
          ForEach(this.onlineResults, (item: OnlineDictResult) => {
            ListItem() {
              Column({ space: 8 }) {
                // 词汇标题
                Text(item.word)
                  .fontSize(18)
                  .fontWeight(FontWeight.Bold)
                  .fontColor('#000000')

                // 定义
                ForEach(item.definitions, (def: string, index: number) => {
                  Row() {
                    Text(`${index + 1}.`)
                      .fontSize(12)
                      .fontColor('#666666')
                      .fontWeight(FontWeight.Bold)
                      .width(20)

                    Text(def)
                      .fontSize(13)
                      .fontColor('#333333')
                      .layoutWeight(1)
                  }
                  .width('100%')
                }, (def: string, index: number) => index.toString())

                // 例句
                if (item.examples && item.examples.length > 0) {
                  Column() {
                    Text('例句')
                      .fontSize(12)
                      .fontColor('#666666')
                      .fontWeight(FontWeight.Bold)
                      .padding({ bottom: 6 })

                    ForEach(item.examples, (example: string) => {
                      Text(`• ${example}`)
                        .fontSize(12)
                        .fontColor('#555555')
                        .lineHeight(1.5)
                        .padding({ bottom: 4 })
                    }, (example: string) => example)
                  }
                  .width('100%')
                  .padding(10)
                  .backgroundColor('#F5F5F5')
                  .borderRadius(5)
                }

                // 数据来源
                Text(`📚 ${item.source}`)
                  .fontSize(10)
                  .fontColor('#999999')
              }
              .width('100%')
              .padding(12)
              .border({ width: 1, color: '#CCCCCC', radius: 8 })
            }
          }, (item: OnlineDictResult) => item.word)
        }
        .width('100%')
        .layoutWeight(1)
        .padding({ left: 16, right: 16, top: 10 })
      }

      // 无结果提示
      if ((this.activeTab === '本地' && this.searchResults.length === 0 && this.searchText) ||
          (this.activeTab === '在线' && this.onlineResults.length === 0 && this.searchText && !this.isSearching)) {
        Column() {
          Text('未找到相关词汇')
            .fontSize(14)
            .fontColor('#999999')
        }
        .width('100%')
        .height(100)
        .justifyContent(FlexAlign.Center)
        .alignItems(HorizontalAlign.Center)
      }

      Row().layoutWeight(1)
    }
    .width('100%')
    .height('100%')
  }

  // 本地搜索
  private searchLocal(): void {
    // 本地词库
    const localDict: DictionaryEntry[] = [
      {
        korean: '안녕하세요',
        chinese: '你好',
        phonetic: '[an-nyeong-ha-se-yo]',
        example: '안녕하세요, 반갑습니다.'
      },
      {
        korean: '감사합니다',
        chinese: '谢谢',
        phonetic: '[gam-sa-ham-ni-da]',
        example: '도와주셔서 감사합니다.'
      },
      {
        korean: '사랑',
        chinese: '爱',
        phonetic: '[sa-rang]',
        example: '나는 너를 사랑해.'
      }
    ];

    if (this.searchText) {
      this.searchResults = localDict.filter((item: DictionaryEntry) =>
        item.korean.includes(this.searchText) ||
        item.chinese.includes(this.searchText)
      );
    } else {
      this.searchResults = [];
    }
  }

  // 在线搜索
  private searchOnline(): void {
    if (!this.searchText) {
      return;
    }

    this.isSearching = true;

    // 模拟在线查询（实际应该调用真实API）
    setTimeout(() => {
      // 模拟在线词典数据
      const onlineDict: OnlineDictResult[] = [
        {
          word: '안녕',
          definitions: ['你好', '再见', '问候'],
          examples: ['안녕! 잘 지냈어?', '안녕, 내일 봐!'],
          source: '在线词典 - Naver Korean Dictionary'
        },
        {
          word: '감사',
          definitions: ['感谢', '谢谢'],
          examples: ['당신의 도움에 감사드립니다.', '항상 감사합니다.'],
          source: '在线词典 - Naver Korean Dictionary'
        }
      ];

      this.onlineResults = onlineDict.filter((item: OnlineDictResult) =>
        item.word.includes(this.searchText)
      );

      this.isSearching = false;
    }, 1000);
  }
}

/**
 * 词典条目接口 (已在文件顶部定义)
 */

/**
 * 韩文教程页面 - 字母学习
 */
@Component
struct TutorialPage {
  @State selectedCategory: string = '辅音';
  @State characters: KoreanCharacter[] = [];
  @State selectedCharacter: KoreanCharacter | null = null;
  @State allCharacters: KoreanCharacter[] = [];

  onPageShow() {
    this.loadCharacters();
  }

  build() {
    Column() {
      // 标题
      Text('韩文字母教程')
        .fontSize(18)
        .fontWeight(FontWeight.Bold)
        .padding({ top: 16, left: 16 })

      // 分类选择
      Row() {
        Button('辅音')
          .type(ButtonType.Normal)
          .height(36)
          .padding({ left: 16, right: 16 })
          .backgroundColor(this.selectedCategory === '辅音' ? '#000000' : '#F5F5F5')
          .fontColor(this.selectedCategory === '辅音' ? Color.White : '#000000')
          .fontSize(12)
          .onClick(() => {
            this.selectedCategory = '辅音';
            this.updateCharacters();
          })
          .margin({ right: 8 })

        Button('元音')
          .type(ButtonType.Normal)
          .height(36)
          .padding({ left: 16, right: 16 })
          .backgroundColor(this.selectedCategory === '元音' ? '#000000' : '#F5F5F5')
          .fontColor(this.selectedCategory === '元音' ? Color.White : '#000000')
          .fontSize(12)
          .onClick(() => {
            this.selectedCategory = '元音';
            this.updateCharacters();
          })

        Row().layoutWeight(1)
      }
      .width('100%')
      .padding({ left: 16, right: 16, top: 12 })

      // 字母列表
      if (this.selectedCharacter === null) {
        Scroll() {
          Column() {
            ForEach(this.characters, (char: KoreanCharacter) => {
              this.buildCharacterListItem(char)
            }, (char: KoreanCharacter) => char.id)
          }
          .width('100%')
        }
        .layoutWeight(1)
      } else {
        // 字母详情
        Scroll() {
          Column() {
            this.buildCharacterDetail(this.selectedCharacter)
          }
          .width('100%')
          .padding(16)
        }
        .layoutWeight(1)
      }

      // 返回按钮（详情页面时显示）
      if (this.selectedCharacter !== null) {
        Button('← 返回列表')
          .width('100%')
          .height(44)
          .backgroundColor('#F5F5F5')
          .fontColor('#000000')
          .onClick(() => {
            this.selectedCharacter = null;
          })
          .margin({ bottom: 0 })
      }
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  buildCharacterListItem(char: KoreanCharacter) {
    Row() {
      Column() {
        Text(char.korean)
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#000000')

        Text(char.name)
          .fontSize(12)
          .fontColor('#666666')
          .margin({ top: 4 })
      }
      .alignItems(HorizontalAlign.Center)
      .width(60)

      Column() {
        Text(char.pronunciation)
          .fontSize(14)
          .fontColor('#000000')
          .fontWeight(FontWeight.Bold)

        Text(`${char.strokeCount} 笔`)
          .fontSize(11)
          .fontColor('#999999')
          .margin({ top: 2 })
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .padding({ left: 12 })
    }
    .width('100%')
    .padding(12)
    .margin({ left: 16, right: 16, bottom: 8 })
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .border({ width: 1, color: '#CCCCCC' })
    .onClick(() => {
      this.selectedCharacter = char;
    })
  }

  @Builder
  buildCharacterDetail(char: KoreanCharacter) {
    Column() {
      // 字母大显示
      Column() {
        Text(char.korean)
          .fontSize(80)
          .fontWeight(FontWeight.Bold)
          .fontColor('#000000')
      }
      .width('100%')
      .height(120)
      .justifyContent(FlexAlign.Center)
      .alignItems(HorizontalAlign.Center)
      .backgroundColor('#F5F5F5')
      .borderRadius(8)
      .margin({ bottom: 16 })

      // 基本信息
      this.buildInfoCard('名称', char.name)
      this.buildInfoCard('发音标记', char.phonetic)
      this.buildInfoCard('读音', char.pronunciation)
      this.buildInfoCard('笔划数', `${char.strokeCount}`)

      if (char.similar) {
        this.buildInfoCard('相似字母', char.similar)
      }

      // 笔顺
      Column() {
        Text('笔顺')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#000000')
          .padding({ bottom: 8 })

        ForEach(char.strokes, (stroke: string, index: number) => {
          Row() {
            Column() {
              Text(`第${index + 1}笔`)
                .fontSize(12)
                .fontColor('#FFFFFF')
                .fontWeight(FontWeight.Bold)
            }
            .width(40)
            .height(24)
            .justifyContent(FlexAlign.Center)
            .alignItems(HorizontalAlign.Center)
            .backgroundColor('#000000')
            .borderRadius(4)

            Text(stroke)
              .fontSize(12)
              .fontColor('#333333')
              .layoutWeight(1)
              .padding({ left: 8 })
          }
          .width('100%')
          .padding({ top: 6 })
          .alignItems(VerticalAlign.Center)
        }, (stroke: string, index: number) => index.toString())
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#FAFAFA')
      .borderRadius(8)
      .margin({ bottom: 16 })

      // 书写技巧
      Column() {
        Text('书写技巧')
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#000000')
          .padding({ bottom: 8 })

        ForEach(char.tips, (tip: string, index: number) => {
          Row() {
            Text(`${index + 1}.`)
              .fontSize(12)
              .fontColor('#666666')
              .fontWeight(FontWeight.Bold)
              .width(20)

            Text(tip)
              .fontSize(12)
              .fontColor('#333333')
              .layoutWeight(1)
          }
          .width('100%')
          .padding({ top: 6 })
        }, (tip: string, index: number) => index.toString())
      }
      .width('100%')
      .padding(12)
      .backgroundColor('#F5F5F5')
      .borderRadius(8)
    }
    .width('100%')
  }

  @Builder
  buildInfoCard(label: string, value: string) {
    Row() {
      Text(label)
        .fontSize(12)
        .fontColor('#666666')
        .width(60)

      Text(value)
        .fontSize(14)
        .fontColor('#000000')
        .fontWeight(FontWeight.Bold)
        .layoutWeight(1)
    }
    .width('100%')
    .padding(12)
    .margin({ bottom: 8 })
    .backgroundColor('#FFFFFF')
    .borderRadius(6)
    .border({ width: 1, color: '#CCCCCC' })
  }

  loadCharacters() {
    // 硬编码字母数据（实际应该从 TutorialService 加载）
    this.allCharacters = [
      // 辅音
      {
        id: 'g_001',
        korean: 'ㄱ',
        name: '기역 (Giyeok)',
        phonetic: '[g]',
        pronunciation: 'g、k',
        strokeCount: 2,
        strokes: ['从上向下的竖', '从右上向左下的横折'],
        tips: ['首笔是垂直的竖线', '第二笔从右上开始，向左下折成横', '两笔形成一个"7"字形', '保持笔画清晰，不要连接']
      },
      {
        id: 'n_001',
        korean: 'ㄴ',
        name: '니은 (Nieun)',
        phonetic: '[n]',
        pronunciation: 'n',
        strokeCount: 2,
        strokes: ['从上向下的竖', '从竖的右下向右的横'],
        tips: ['第一笔是垂直的竖线', '第二笔从竖线的下端向右延伸', '形成一个倒"L"形', '两笔应该在底部相交']
      },
      {
        id: 'd_001',
        korean: 'ㄷ',
        name: '디귿 (Digeut)',
        phonetic: '[d]',
        pronunciation: 'd、t',
        strokeCount: 3,
        strokes: ['从上向下的竖', '从顶端向右的横', '从右下向左的横'],
        tips: ['形状像"门"字', '左侧竖线要垂直', '上下两条横线要平行', '右侧为开放式，不闭合']
      },
      // 元音
      {
        id: 'a_001',
        korean: 'ㅏ',
        name: '아 (A)',
        phonetic: '[a]',
        pronunciation: 'a',
        strokeCount: 2,
        strokes: ['竖线', '从竖线右侧的两个横线'],
        tips: ['左侧是竖线', '右侧上下两个短横线', '类似一个侧放的"川"', '左竖要明显长于右侧横']
      },
      {
        id: 'e_001',
        korean: 'ㅑ',
        name: '야 (Ya)',
        phonetic: '[ja]',
        pronunciation: 'ya',
        strokeCount: 3,
        strokes: ['竖线', '从竖线右侧向下的横线', '从横线下向右的竖线'],
        tips: ['形状像"八"字', '左侧长竖，右侧两条线', '保持对称和平衡', '右侧竖线要直']
      },
      {
        id: 'o_001',
        korean: 'ㅓ',
        name: '어 (Eo)',
        phonetic: '[ʌ]',
        pronunciation: 'eo',
        strokeCount: 2,
        strokes: ['竖线', '从竖线右侧的两个横线'],
        tips: ['与"ㅏ"相似但笔划不同', '竖线在左侧', '横线在右侧上下分布', '保持清晰的字形']
      },
      {
        id: 'u_001',
        korean: 'ㅗ',
        name: '오 (O)',
        phonetic: '[o]',
        pronunciation: 'o',
        strokeCount: 2,
        strokes: ['竖线', '从竖线上方连接的横线'],
        tips: ['竖线在左侧', '横线在上方，向右延伸', '形成一个"L"形的倒置', '横线要平直']
      },
      {
        id: 'i_001',
        korean: 'ㅣ',
        name: '이 (I)',
        phonetic: '[i]',
        pronunciation: 'i',
        strokeCount: 1,
        strokes: ['一条竖线'],
        tips: ['最简单的元音', '一条笔直的竖线', '要垂直，不要倾斜', '长度要适中']
      }
    ];
    this.updateCharacters();
  }

  updateCharacters() {
    if (this.selectedCategory === '辅音') {
      this.characters = this.allCharacters.slice(0, 3);
    } else {
      this.characters = this.allCharacters.slice(3);
    }
  }
}

/**
 * 下载管理页面
 */
@Component
struct DownloadPage {
  @State selectedCategory: string = 'dict';
  @State resourceList: DownloadResourceItem[] = [];
  @State downloadStats: DownloadStats = new DownloadStats();
  private downloadService: DownloadService = DownloadService.getInstance();

  aboutToAppear() {
    this.updateStats();
    this.loadResources();
  }

  private loadResources(): void {
    const resources = this.downloadService.getResourcesByCategory(this.selectedCategory);
    this.resourceList = resources.map((resource: DownloadResource) => new DownloadResourceItem(resource));
  }

  private updateStats(): void {
    const statsData = this.downloadService.getDownloadStats();
    this.downloadStats.totalCount = statsData.totalCount;
    this.downloadStats.downloadedCount = statsData.downloadedCount;
    this.downloadStats.totalSize = statsData.totalSize;
  }

  private changeCategory(category: string): void {
    this.selectedCategory = category;
    this.loadResources();
  }

  private async startDownload(resourceId: string): Promise<void> {
    await this.downloadService.downloadResource(resourceId);
    this.loadResources();
  }

  private deleteResource(resourceId: string): void {
    this.downloadService.deleteResource(resourceId);
    this.loadResources();
  }

  build() {
    Column() {
      // 下载统计信息
      Column() {
        Row() {
          Column() {
            Text('总资源数')
              .fontSize(12)
              .fontColor('#999999')
            Text(this.downloadStats.totalCount.toString())
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#000000')
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)

          Divider()
            .strokeWidth(0)
            .vertical(true)
            .opacity(0)

          Column() {
            Text('已下载')
              .fontSize(12)
              .fontColor('#999999')
            Text(this.downloadStats.downloadedCount.toString())
              .fontSize(20)
              .fontWeight(FontWeight.Bold)
              .fontColor('#000000')
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)

          Divider()
            .strokeWidth(0)
            .vertical(true)
            .opacity(0)

          Column() {
            Text('占用空间')
              .fontSize(12)
              .fontColor('#999999')
            Text(this.downloadStats.totalSize)
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
              .fontColor('#000000')
              .margin({ top: 4 })
          }
          .layoutWeight(1)
          .alignItems(HorizontalAlign.Center)
        }
        .width('100%')
        .padding(12)
      }
      .width('100%')
      .backgroundColor('#F5F5F5')
      .borderRadius(8)
      .padding(16)

      Divider()
        .margin({ top: 16, bottom: 16 })

      // 分类选择
      Row() {
        Row() {
          Text('📚 词库')
            .fontSize(12)
            .fontColor(this.selectedCategory === 'dict' ? '#000000' : '#999999')
            .fontWeight(this.selectedCategory === 'dict' ? FontWeight.Bold : FontWeight.Normal)
            .onClick(() => this.changeCategory('dict'))
            .padding(8)
        }
        .layoutWeight(1)
        .backgroundColor(this.selectedCategory === 'dict' ? '#EEEEEE' : 'transparent')
        .borderRadius(4)
        .justifyContent(FlexAlign.Center)

        Row() {
          Text('🎓 教程')
            .fontSize(12)
            .fontColor(this.selectedCategory === 'tutorial' ? '#000000' : '#999999')
            .fontWeight(this.selectedCategory === 'tutorial' ? FontWeight.Bold : FontWeight.Normal)
            .onClick(() => this.changeCategory('tutorial'))
            .padding(8)
        }
        .layoutWeight(1)
        .backgroundColor(this.selectedCategory === 'tutorial' ? '#EEEEEE' : 'transparent')
        .borderRadius(4)
        .justifyContent(FlexAlign.Center)
        .margin({ left: 8, right: 8 })

        Row() {
          Text('🔊 发音')
            .fontSize(12)
            .fontColor(this.selectedCategory === 'audio' ? '#000000' : '#999999')
            .fontWeight(this.selectedCategory === 'audio' ? FontWeight.Bold : FontWeight.Normal)
            .onClick(() => this.changeCategory('audio'))
            .padding(8)
        }
        .layoutWeight(1)
        .backgroundColor(this.selectedCategory === 'audio' ? '#EEEEEE' : 'transparent')
        .borderRadius(4)
        .justifyContent(FlexAlign.Center)
      }
      .width('100%')
      .height(40)
      .margin({ bottom: 16 })

      // 资源列表
      List() {
        ForEach(this.resourceList, (resource: DownloadResourceItem) => {
          ListItem() {
            Column() {
              // 资源头部
              Row() {
                Column() {
                  Text(resource.name)
                    .fontSize(14)
                    .fontWeight(FontWeight.Bold)
                    .fontColor('#000000')
                  Text(resource.description)
                    .fontSize(12)
                    .fontColor('#666666')
                    .maxLines(1)
                    .textOverflow({ overflow: TextOverflow.Ellipsis })
                    .margin({ top: 4 })
                }
                .layoutWeight(1)
                .alignItems(HorizontalAlign.Start)

                Column() {
                  Text(resource.size)
                    .fontSize(12)
                    .fontColor('#999999')
                    .textAlign(TextAlign.End)
                  Text(`v${resource.version}`)
                    .fontSize(10)
                    .fontColor('#CCCCCC')
                    .margin({ top: 4 })
                    .textAlign(TextAlign.End)
                }
                .alignItems(HorizontalAlign.End)
              }
              .width('100%')
              .margin({ bottom: 12 })

              // 下载进度条或按钮
              if (resource.isDownloaded) {
                Row() {
                  Column() {
                    Text('✓ 已下载')
                      .fontSize(12)
                      .fontColor('#00AA00')
                      .fontWeight(FontWeight.Bold)
                  }
                  .layoutWeight(1)

                  Button('删除')
                    .fontSize(12)
                    .height(28)
                    .fontColor('#DD0000')
                    .backgroundColor('#FFE6E6')
                    .borderRadius(4)
                    .onClick(() => this.deleteResource(resource.id))
              }
              .width('100%')
              } else if (resource.downloadProgress > 0) {
                Column() {
                  Row() {
                    Text(`下载中 ${resource.downloadProgress.toFixed(0)}%`)
                      .fontSize(12)
                      .fontColor('#0066FF')
                      .layoutWeight(1)
                    Button('取消')
                      .fontSize(10)
                      .height(24)
                      .fontColor('#999999')
                      .backgroundColor('#F0F0F0')
                      .borderRadius(3)
                  }
                  .width('100%')
                  .margin({ bottom: 6 })

                  Stack() {
                    Column()
                      .width('100%')
                      .height(4)
                      .backgroundColor('#E6E6E6')
                      .borderRadius(2)

                    Column()
                      .width(resource.downloadProgress.toString() + '%')
                      .height(4)
                      .backgroundColor('#0066FF')
                      .borderRadius(2)
                      .align(Alignment.Start)
                  }
                  .width('100%')
                  .height(4)
                }
                .width('100%')
              } else {
                Row() {
                  Button('下载')
                    .fontSize(12)
                    .height(32)
                    .fontColor('#FFFFFF')
                    .backgroundColor('#000000')
                    .borderRadius(4)
                    .onClick(() => this.startDownload(resource.id))
                }
                .width('100%')
                .justifyContent(FlexAlign.End)
              }
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
            .border({
              width: 1,
              color: '#E6E6E6',
              radius: 8
            })
            .margin({ bottom: 8 })
          }
        })
      }
      .layoutWeight(1)
      .width('100%')
      .listDirection(Axis.Vertical)
      .scrollBar(BarState.On)
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#FFFFFF')
  }
}

/**
 * 词典条目接口 (已在文件顶部定义)
 */