/**
 * 词典服务 - 管理韩文词典数据
 */

export interface DictionaryEntry {
  id?: number;
  korean: string;
  chinese: string;
  phonetic?: string;
  example?: string;
  wordType?: string;  // 词性: 名词, 动词, 形容词等
  frequency?: number; // 使用频率
}

export class DictionaryService {
  private static instance: DictionaryService;
  private dictionary: Map<string, DictionaryEntry[]> = new Map();

  private constructor() {
    this.initializeDictionary();
  }

  public static getInstance(): DictionaryService {
    if (!DictionaryService.instance) {
      DictionaryService.instance = new DictionaryService();
    }
    return DictionaryService.instance;
  }

  /**
   * 初始化词典数据
   * 在实际应用中，这些数据应该从本地数据库或文件加载
   */
  private initializeDictionary(): void {
    // 基础词汇
    const basicWords: DictionaryEntry[] = [
      // 问候
      {
        korean: '안녕하세요',
        chinese: '你好(敬语)',
        phonetic: '[an-nyeong-ha-se-yo]',
        wordType: '感叹词',
        example: '안녕하세요, 만나서 반갑습니다.',
        frequency: 10
      },
      {
        korean: '안녕',
        chinese: '嗨/再见(非正式)',
        phonetic: '[an-nyeong]',
        wordType: '感叹词',
        example: '안녕, 뭐 해?',
        frequency: 9
      },
      // 感谢
      {
        korean: '감사합니다',
        chinese: '谢谢(敬语)',
        phonetic: '[gam-sa-ham-ni-da]',
        wordType: '感叹词',
        example: '도와주셔서 감사합니다.',
        frequency: 10
      },
      {
        korean: '고마워',
        chinese: '谢谢(非正式)',
        phonetic: '[go-ma-weo]',
        wordType: '感叹词',
        example: '도와줘서 고마워.',
        frequency: 8
      },
      // 道歉
      {
        korean: '미안합니다',
        chinese: '对不起(敬语)',
        phonetic: '[mi-an-ham-ni-da]',
        wordType: '感叹词',
        example: '실수해서 미안합니다.',
        frequency: 7
      },
      {
        korean: '미안해',
        chinese: '对不起(非正式)',
        phonetic: '[mi-an-hae]',
        wordType: '感叹词',
        example: '기다리게 해서 미안해.',
        frequency: 7
      },
      // 常用词汇 - 家庭
      {
        korean: '가족',
        chinese: '家族/家人',
        phonetic: '[ga-jok]',
        wordType: '名词',
        example: '저는 가족을 사랑합니다.',
        frequency: 8
      },
      {
        korean: '엄마',
        chinese: '妈妈',
        phonetic: '[eom-ma]',
        wordType: '名词',
        example: '엄마, 안녕하세요.',
        frequency: 8
      },
      {
        korean: '아빠',
        chinese: '爸爸',
        phonetic: '[a-ppa]',
        wordType: '名词',
        example: '아빠는 회사에서 일해요.',
        frequency: 8
      },
      {
        korean: '오빠',
        chinese: '哥哥(女性说)',
        phonetic: '[o-ppa]',
        wordType: '名词',
        example: '오빠, 뭐 해?',
        frequency: 7
      },
      // 常用词汇 - 时间
      {
        korean: '오늘',
        chinese: '今天',
        phonetic: '[o-neul]',
        wordType: '名词',
        example: '오늘 날씨가 좋아요.',
        frequency: 9
      },
      {
        korean: '내일',
        chinese: '明天',
        phonetic: '[nae-il]',
        wordType: '名词',
        example: '내일 뭐 해?',
        frequency: 9
      },
      {
        korean: '어제',
        chinese: '昨天',
        phonetic: '[eo-je]',
        wordType: '名词',
        example: '어제 뭘 했어?',
        frequency: 8
      },
      // 常用词汇 - 动词
      {
        korean: '가다',
        chinese: '去',
        phonetic: '[ga-da]',
        wordType: '动词',
        example: '학교에 가요.',
        frequency: 9
      },
      {
        korean: '오다',
        chinese: '来',
        phonetic: '[o-da]',
        wordType: '动词',
        example: '집에 와요.',
        frequency: 8
      },
      {
        korean: '먹다',
        chinese: '吃',
        phonetic: '[meok-da]',
        wordType: '动词',
        example: '밥을 먹어요.',
        frequency: 9
      },
      {
        korean: '마시다',
        chinese: '喝',
        phonetic: '[ma-si-da]',
        wordType: '动词',
        example: '물을 마셔요.',
        frequency: 7
      },
      {
        korean: '자다',
        chinese: '睡觉',
        phonetic: '[ja-da]',
        wordType: '动词',
        example: '밤에 자요.',
        frequency: 8
      },
      {
        korean: '공부하다',
        chinese: '学习',
        phonetic: '[gong-bu-ha-da]',
        wordType: '动词',
        example: '한국어를 공부해요.',
        frequency: 8
      },
      // 常用词汇 - 形容词
      {
        korean: '좋다',
        chinese: '好',
        phonetic: '[jo-ta]',
        wordType: '形容词',
        example: '좋은 날씨예요.',
        frequency: 10
      },
      {
        korean: '나쁘다',
        chinese: '坏',
        phonetic: '[na-ppeu-da]',
        wordType: '形容词',
        example: '날씨가 나빠요.',
        frequency: 6
      },
      {
        korean: '크다',
        chinese: '大',
        phonetic: '[keu-da]',
        wordType: '形容词',
        example: '큰 집이에요.',
        frequency: 7
      },
      {
        korean: '작다',
        chinese: '小',
        phonetic: '[jak-da]',
        wordType: '形容词',
        example: '작은 개예요.',
        frequency: 7
      }
    ];

    // 将词汇按首字母索引
    for (const entry of basicWords) {
      const firstChar = entry.korean.charAt(0);
      if (!this.dictionary.has(firstChar)) {
        this.dictionary.set(firstChar, []);
      }
      this.dictionary.get(firstChar)!.push(entry);
    }
  }

  /**
   * 搜索词汇
   * @param query 搜索关键词（韩文或中文）
   * @returns 匹配的词汇列表
   */
  public search(query: string): DictionaryEntry[] {
    if (!query.trim()) {
      return [];
    }

    const results: DictionaryEntry[] = [];
    const lowercaseQuery = query.toLowerCase();

    // 遍历所有词汇
    for (const [_, entries] of this.dictionary) {
      for (const entry of entries) {
        // 精确匹配韩文
        if (entry.korean === query) {
          results.unshift(entry); // 精确匹配优先
        }
        // 韩文前缀匹配
        else if (entry.korean.startsWith(query)) {
          results.push(entry);
        }
        // 中文包含匹配
        else if (entry.chinese.includes(query)) {
          results.push(entry);
        }
        // 拼音包含匹配
        else if (entry.phonetic && entry.phonetic.toLowerCase().includes(lowercaseQuery)) {
          results.push(entry);
        }
      }
    }

    // 按频率排序（去重后）
    const uniqueResults = Array.from(new Map(results.map(r => [r.korean, r])).values());
    return uniqueResults.sort((a, b) => (b.frequency || 0) - (a.frequency || 0)).slice(0, 20);
  }

  /**
   * 获取随机单词（用于学习）
   * @param count 数量
   * @returns 随机单词列表
   */
  public getRandomWords(count: number = 10): DictionaryEntry[] {
    const allWords: DictionaryEntry[] = [];

    for (const [_, entries] of this.dictionary) {
      allWords.push(...entries);
    }

    const shuffled = allWords.sort(() => Math.random() - 0.5);
    return shuffled.slice(0, count);
  }

  /**
   * 获取高频词汇
   * @param count 数量
   * @returns 高频词汇列表
   */
  public getFrequentWords(count: number = 20): DictionaryEntry[] {
    const allWords: DictionaryEntry[] = [];

    for (const [_, entries] of this.dictionary) {
      allWords.push(...entries);
    }

    return allWords.sort((a, b) => (b.frequency || 0) - (a.frequency || 0)).slice(0, count);
  }

  /**
   * 按词性获取词汇
   * @param wordType 词性
   * @returns 该词性的词汇列表
   */
  public getWordsByType(wordType: string): DictionaryEntry[] {
    const results: DictionaryEntry[] = [];

    for (const [_, entries] of this.dictionary) {
      for (const entry of entries) {
        if (entry.wordType === wordType) {
          results.push(entry);
        }
      }
    }

    return results;
  }

  /**
   * 添加新词汇（用于自定义词库）
   * @param entry 词汇条目
   */
  public addEntry(entry: DictionaryEntry): void {
    if (!entry.korean) {
      return;
    }

    const firstChar = entry.korean.charAt(0);
    if (!this.dictionary.has(firstChar)) {
      this.dictionary.set(firstChar, []);
    }

    // 检查是否已存在
    const exists = this.dictionary.get(firstChar)?.some(e => e.korean === entry.korean);
    if (!exists) {
      this.dictionary.get(firstChar)!.push(entry);
    }
  }

  /**
   * 删除词汇
   * @param korean 韩文词
   */
  public deleteEntry(korean: string): void {
    if (!korean) {
      return;
    }

    const firstChar = korean.charAt(0);
    const entries = this.dictionary.get(firstChar);
    if (entries) {
      const index = entries.findIndex(e => e.korean === korean);
      if (index > -1) {
        entries.splice(index, 1);
      }
    }
  }

  /**
   * 获取所有词汇总数
   */
  public getTotalCount(): number {
    let count = 0;
    for (const [_, entries] of this.dictionary) {
      count += entries.length;
    }
    return count;
  }

  /**
   * 导出词典为JSON
   */
  public exportToJson(): string {
    const data: { [key: string]: DictionaryEntry[] } = {};
    for (const [key, entries] of this.dictionary) {
      data[key] = entries;
    }
    return JSON.stringify(data, null, 2);
  }
}

// 导出单例
export const dictionaryService = DictionaryService.getInstance();
