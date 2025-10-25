/**
 * 韩文教程服务
 * 提供韩文字母学习数据：发音、笔顺、书写技巧
 */

interface KoreanCharacter {
  id: string;
  korean: string;
  name: string; // 字母名称，如"기역", "니은"等
  phonetic: string; // 发音
  pronunciation: string; // 标准中文读音
  strokeCount: number; // 笔划数
  strokes: string[]; // 笔顺描述
  tips: string[]; // 书写技巧
  similar?: string; // 相似字母
}

export class TutorialService {
  private static instance: TutorialService;
  private characters: KoreanCharacter[] = [];

  private constructor() {
    this.initializeCharacters();
  }

  static getInstance(): TutorialService {
    if (!TutorialService.instance) {
      TutorialService.instance = new TutorialService();
    }
    return TutorialService.instance;
  }

  /**
   * 初始化韩文字母数据
   */
  private initializeCharacters(): void {
    this.characters = [
      // 辅音（자음）
      {
        id: 'g_001',
        korean: 'ㄱ',
        name: '기역 (Giyeok)',
        phonetic: '[g]',
        pronunciation: 'g、k',
        strokeCount: 2,
        strokes: ['从上向下的竖', '从右上向左下的横折'],
        tips: [
          '首笔是垂直的竖线',
          '第二笔从右上开始，向左下折成横',
          '两笔形成一个"7"字形',
          '保持笔画清晰，不要连接'
        ],
        similar: 'ㅋ'
      },
      {
        id: 'n_001',
        korean: 'ㄴ',
        name: '니은 (Nieun)',
        phonetic: '[n]',
        pronunciation: 'n',
        strokeCount: 2,
        strokes: ['从上向下的竖', '从竖的右下向右的横'],
        tips: [
          '第一笔是垂直的竖线',
          '第二笔从竖线的下端向右延伸',
          '形成一个倒"L"形',
          '两笔应该在底部相交'
        ]
      },
      {
        id: 'd_001',
        korean: 'ㄷ',
        name: '디귿 (Digeut)',
        phonetic: '[d]',
        pronunciation: 'd、t',
        strokeCount: 3,
        strokes: ['从上向下的竖', '从顶端向右的横', '从右下向左的横'],
        tips: [
          '形状像"门"字',
          '左侧竖线要垂直',
          '上下两条横线要平行',
          '右侧为开放式，不闭合'
        ]
      },
      {
        id: 'r_001',
        korean: 'ㄹ',
        name: '리을 (Rieul)',
        phonetic: '[r/l]',
        pronunciation: 'r、l',
        strokeCount: 2,
        strokes: ['从上向下的竖', '从竖下方向右上的斜横折'],
        tips: [
          '第一笔是垂直的竖线',
          '第二笔是弯曲的，从下向上右延伸',
          '像一个向右弯曲的"L"',
          '书写时要流畅，不要生硬'
        ]
      },
      {
        id: 'm_001',
        korean: 'ㅁ',
        name: '미음 (Mieum)',
        phonetic: '[m]',
        pronunciation: 'm',
        strokeCount: 3,
        strokes: ['从上向下的竖', '从顶端向右的横', '从右下向左的竖'],
        tips: [
          '形状像一个"门"或"山"',
          '三条竖线要垂直平行',
          '顶部的横线要平直',
          '宽度适中，不要太窄'
        ]
      },
      {
        id: 'b_001',
        korean: 'ㅂ',
        name: '비읍 (Bieup)',
        phonetic: '[b]',
        pronunciation: 'b、p',
        strokeCount: 3,
        strokes: ['从上向下的竖', '从顶端向右的弧', '从弧下向左的弧'],
        tips: [
          '左侧是垂直的竖线',
          '右侧两个弧形，上下对称',
          '看起来像一个"B"字的镜像',
          '弧形要圆润，不要尖锐'
        ]
      },
      {
        id: 's_001',
        korean: 'ㅅ',
        name: '시옷 (Siot)',
        phonetic: '[s]',
        pronunciation: 's',
        strokeCount: 3,
        strokes: ['中间竖线', '上左斜线', '下右斜线'],
        tips: [
          '形状像一个"X"或"*"',
          '三条线应该在中心相交',
          '上斜线和下斜线要对称',
          '保持尖锐的角度'
        ]
      },
      {
        id: 'ng_001',
        korean: 'ㅇ',
        name: '응 (Eung)',
        phonetic: '[ng/ø]',
        pronunciation: 'ng',
        strokeCount: 1,
        strokes: ['一个完整的圆形'],
        tips: [
          '整体是一个圆形',
          '圆形要均匀对称',
          '不要过于倾斜',
          '线条要流畅闭合'
        ]
      },

      // 元音（모음）
      {
        id: 'a_001',
        korean: 'ㅏ',
        name: '아 (A)',
        phonetic: '[a]',
        pronunciation: 'a',
        strokeCount: 2,
        strokes: ['竖线', '从竖线右侧的两个横线'],
        tips: [
          '左侧是竖线',
          '右侧上下两个短横线',
          '类似一个侧放的"川"',
          '左竖要明显长于右侧横'
        ]
      },
      {
        id: 'e_001',
        korean: 'ㅑ',
        name: '야 (Ya)',
        phonetic: '[ja]',
        pronunciation: 'ya',
        strokeCount: 3,
        strokes: ['竖线', '从竖线右侧向下的横线', '从横线下向右的竖线'],
        tips: [
          '形状像"八"字',
          '左侧长竖，右侧两条线',
          '保持对称和平衡',
          '右侧竖线要直'
        ]
      },
      {
        id: 'o_001',
        korean: 'ㅓ',
        name: '어 (Eo)',
        phonetic: '[ʌ]',
        pronunciation: 'eo',
        strokeCount: 2,
        strokes: ['竖线', '从竖线右侧的两个横线'],
        tips: [
          '与"ㅏ"相似但笔划不同',
          '竖线在左侧',
          '横线在右侧上下分布',
          '保持清晰的字形'
        ]
      },
      {
        id: 'u_001',
        korean: 'ㅗ',
        name: '오 (O)',
        phonetic: '[o]',
        pronunciation: 'o',
        strokeCount: 2,
        strokes: ['竖线', '从竖线上方连接的横线'],
        tips: [
          '竖线在左侧',
          '横线在上方，向右延伸',
          '形成一个"L"形的倒置',
          '横线要平直'
        ]
      },
      {
        id: 'i_001',
        korean: 'ㅣ',
        name: '이 (I)',
        phonetic: '[i]',
        pronunciation: 'i',
        strokeCount: 1,
        strokes: ['一条竖线'],
        tips: [
          '最简单的元音',
          '一条笔直的竖线',
          '要垂直，不要倾斜',
          '长度要适中'
        ]
      }
    ];
  }

  /**
   * 获取所有字母
   */
  getAllCharacters(): KoreanCharacter[] {
    return [...this.characters];
  }

  /**
   * 按分类获取字母（辅音/元音）
   */
  getCharactersByCategory(category: 'consonant' | 'vowel'): KoreanCharacter[] {
    const consonantIds = ['g_001', 'n_001', 'd_001', 'r_001', 'm_001', 'b_001', 's_001', 'ng_001'];
    const vowelIds = ['a_001', 'e_001', 'o_001', 'u_001', 'i_001'];

    const targetIds = category === 'consonant' ? consonantIds : vowelIds;
    return this.characters.filter(char => targetIds.includes(char.id));
  }

  /**
   * 获取单个字母详情
   */
  getCharacterById(id: string): KoreanCharacter | null {
    return this.characters.find(char => char.id === id) || null;
  }

  /**
   * 获取字母总数
   */
  getTotalCount(): number {
    return this.characters.length;
  }

  /**
   * 搜索字母
   */
  searchCharacters(query: string): KoreanCharacter[] {
    const lowerQuery = query.toLowerCase();
    return this.characters.filter(char =>
      char.korean.includes(query) ||
      char.name.toLowerCase().includes(lowerQuery) ||
      char.pronunciation.toLowerCase().includes(lowerQuery)
    );
  }

  /**
   * 获取学习进度建议
   */
  getLearningPath(): { consonants: number; vowels: number; difficulty: string } {
    return {
      consonants: this.getCharactersByCategory('consonant').length,
      vowels: this.getCharactersByCategory('vowel').length,
      difficulty: '建议先学元音，再学辅音'
    };
  }
}
