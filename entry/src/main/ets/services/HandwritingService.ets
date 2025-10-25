/**
 * 手写识别服务 - 处理手写输入的识别
 */

export interface StrokePoint {
  x: number;
  y: number;
  timestamp: number;
  pressure?: number;
}

export interface Stroke {
  points: StrokePoint[];
  startTime: number;
  endTime: number;
}

export interface HandwritingData {
  strokes: Stroke[];
  width: number;
  height: number;
  timestamp: number;
}

export interface RecognitionResult {
  text: string;
  confidence: number;  // 0-1 之间的置信度
  alternatives?: string[];  // 其他可能的识别结果
}

export class HandwritingService {
  private static instance: HandwritingService;
  private currentStrokes: Stroke[] = [];
  private currentPoints: StrokePoint[] = [];

  private constructor() {}

  public static getInstance(): HandwritingService {
    if (!HandwritingService.instance) {
      HandwritingService.instance = new HandwritingService();
    }
    return HandwritingService.instance;
  }

  /**
   * 开始新的笔画
   */
  public startStroke(): void {
    this.currentPoints = [];
  }

  /**
   * 添加笔画点
   * @param x X坐标
   * @param y Y坐标
   * @param pressure 压力（可选）
   */
  public addPoint(x: number, y: number, pressure?: number): void {
    const point: StrokePoint = {
      x,
      y,
      timestamp: Date.now(),
      pressure
    };
    this.currentPoints.push(point);
  }

  /**
   * 结束笔画
   */
  public endStroke(): void {
    if (this.currentPoints.length > 0) {
      const stroke: Stroke = {
        points: this.currentPoints,
        startTime: this.currentPoints[0].timestamp,
        endTime: this.currentPoints[this.currentPoints.length - 1].timestamp
      };
      this.currentStrokes.push(stroke);
      this.currentPoints = [];
    }
  }

  /**
   * 获取当前手写数据
   */
  public getCurrentHandwritingData(width: number, height: number): HandwritingData {
    return {
      strokes: this.currentStrokes,
      width,
      height,
      timestamp: Date.now()
    };
  }

  /**
   * 清空所有笔画
   */
  public clear(): void {
    this.currentStrokes = [];
    this.currentPoints = [];
  }

  /**
   * 撤销最后一笔
   */
  public undo(): void {
    if (this.currentStrokes.length > 0) {
      this.currentStrokes.pop();
    }
  }

  /**
   * 识别手写文字（使用简单的启发式算法）
   * 注意：实际应用应该调用真实的OCR API
   */
  public async recognize(data: HandwritingData): Promise<RecognitionResult> {
    // TODO: 这里应该调用真实的手写识别API
    // 例如调用Google ML Kit, Baidu OCR, Tencent OCR等

    // 现在使用模拟的识别结果
    return new Promise((resolve) => {
      setTimeout(() => {
        const result = this.mockRecognize(data);
        resolve(result);
      }, 500); // 模拟识别延迟
    });
  }

  /**
   * 模拟识别（用于演示）
   */
  private mockRecognize(data: HandwritingData): RecognitionResult {
    // 基于笔画数和笔画特征进行简单推断
    const strokeCount = data.strokes.length;

    // 这是一个非常简单的模拟识别
    // 实际应用应该使用真实的ML模型
    const mockResults: { [key: number]: RecognitionResult[] } = {
      1: [
        { text: 'ㄱ', confidence: 0.7, alternatives: ['ㄲ', 'ㄹ'] },
        { text: '|', confidence: 0.6, alternatives: ['ㅣ'] }
      ],
      2: [
        { text: 'ㄴ', confidence: 0.75, alternatives: ['ㄷ'] },
        { text: 'ㅐ', confidence: 0.65, alternatives: ['ㅏ', 'ㅑ'] }
      ],
      3: [
        { text: '안', confidence: 0.8, alternatives: ['앤', '언'] },
        { text: 'ㄷ', confidence: 0.7, alternatives: ['ㄹ', 'ㄴ'] }
      ],
      4: [
        { text: '녕', confidence: 0.75, alternatives: ['렁', '령'] },
        { text: '합', confidence: 0.7, alternatives: ['합', '합'] }
      ]
    };

    // 根据笔画数返回相应的模拟结果
    if (mockResults[strokeCount] && mockResults[strokeCount].length > 0) {
      return mockResults[strokeCount][0];
    }

    // 默认返回一个通用结果
    return {
      text: '?',
      confidence: 0.5,
      alternatives: ['ㄱ', 'ㄴ', 'ㄷ']
    };
  }

  /**
   * 获取笔画统计信息
   */
  public getStrokeStats(): {
    count: number;
    totalPoints: number;
    averageSpeed: number;
  } {
    let totalPoints = 0;
    let totalTime = 0;
    let totalDistance = 0;

    for (const stroke of this.currentStrokes) {
      totalPoints += stroke.points.length;
      totalTime += stroke.endTime - stroke.startTime;

      for (let i = 1; i < stroke.points.length; i++) {
        const p1 = stroke.points[i - 1];
        const p2 = stroke.points[i];
        const dx = p2.x - p1.x;
        const dy = p2.y - p1.y;
        totalDistance += Math.sqrt(dx * dx + dy * dy);
      }
    }

    const averageSpeed = totalTime > 0 ? totalDistance / (totalTime / 1000) : 0;

    return {
      count: this.currentStrokes.length,
      totalPoints,
      averageSpeed
    };
  }

  /**
   * 规范化笔画数据（用于识别前的预处理）
   */
  public normalizeData(data: HandwritingData): HandwritingData {
    // 找到边界框
    let minX = Infinity, maxX = -Infinity;
    let minY = Infinity, maxY = -Infinity;

    for (const stroke of data.strokes) {
      for (const point of stroke.points) {
        minX = Math.min(minX, point.x);
        maxX = Math.max(maxX, point.x);
        minY = Math.min(minY, point.y);
        maxY = Math.max(maxY, point.y);
      }
    }

    // 计算缩放因子
    const width = maxX - minX || 1;
    const height = maxY - minY || 1;
    const scale = Math.min(data.width / width, data.height / height) * 0.9;

    // 规范化点
    const normalized: Stroke[] = [];
    for (const stroke of data.strokes) {
      const normalizedPoints = stroke.points.map(point => ({
        ...point,
        x: (point.x - minX) * scale + 10,
        y: (point.y - minY) * scale + 10
      }));
      normalized.push({
        ...stroke,
        points: normalizedPoints
      });
    }

    return {
      ...data,
      strokes: normalized
    };
  }

  /**
   * 导出笔画数据为JSON
   */
  public exportToJson(): string {
    return JSON.stringify({
      strokes: this.currentStrokes,
      timestamp: Date.now()
    }, null, 2);
  }

  /**
   * 从JSON导入笔画数据
   */
  public importFromJson(json: string): boolean {
    try {
      const data = JSON.parse(json);
      if (data.strokes && Array.isArray(data.strokes)) {
        this.currentStrokes = data.strokes;
        return true;
      }
      return false;
    } catch (error) {
      console.error('Failed to import handwriting data:', error);
      return false;
    }
  }

  /**
   * 计算笔画的特征向量（用于分类）
   * 这是一个简化的实现
   */
  public extractFeatures(data: HandwritingData): number[] {
    const features: number[] = [];

    // 特征1: 笔画数
    features.push(data.strokes.length);

    // 特征2: 总点数
    let totalPoints = 0;
    for (const stroke of data.strokes) {
      totalPoints += stroke.points.length;
    }
    features.push(totalPoints);

    // 特征3: 笔画的宽度/高度比
    let minX = Infinity, maxX = -Infinity;
    let minY = Infinity, maxY = -Infinity;

    for (const stroke of data.strokes) {
      for (const point of stroke.points) {
        minX = Math.min(minX, point.x);
        maxX = Math.max(maxX, point.x);
        minY = Math.min(minY, point.y);
        maxY = Math.max(maxY, point.y);
      }
    }

    const width = maxX - minX || 1;
    const height = maxY - minY || 1;
    features.push(width / height);

    // 特征4: 平均笔画持续时间
    let totalDuration = 0;
    for (const stroke of data.strokes) {
      totalDuration += stroke.endTime - stroke.startTime;
    }
    const avgDuration = data.strokes.length > 0 ? totalDuration / data.strokes.length : 0;
    features.push(avgDuration);

    return features;
  }
}

// 导出单例
export const handwritingService = HandwritingService.getInstance();
