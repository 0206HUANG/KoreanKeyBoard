/**
 * 下载管理服务
 * 提供词库、教程等资源的下载和管理功能
 */

interface DownloadResource {
  id: string;
  name: string;
  description: string;
  size: string;
  category: string; // 'dict', 'tutorial', 'audio'
  version: string;
  downloadUrl: string;
  isDownloaded: boolean;
  downloadProgress: number; // 0-100
  downloadedAt?: number;
}

interface DownloadStats {
  totalCount: number;
  downloadedCount: number;
  totalSize: string;
}

interface CategoryItem {
  id: string;
  name: string;
  icon: string;
}

export class DownloadService {
  private static instance: DownloadService;
  private resources: DownloadResource[] = [];
  private downloadingIds: Set<string> = new Set();

  private constructor() {
    this.initializeResources();
  }

  static getInstance(): DownloadService {
    if (!DownloadService.instance) {
      DownloadService.instance = new DownloadService();
    }
    return DownloadService.instance;
  }

  /**
   * 初始化可下载资源列表
   */
  private initializeResources(): void {
    this.resources = [
      // 词库资源
      {
        id: 'dict_basic_001',
        name: '基础词库 (3000词)',
        description: '包含日常用语、问候、基础动词等3000个常用韩文词汇',
        size: '2.5 MB',
        category: 'dict',
        version: '1.0.0',
        downloadUrl: 'https://example.com/dict_basic_3000.zip',
        isDownloaded: false,
        downloadProgress: 0
      },
      {
        id: 'dict_advanced_001',
        name: '高级词库 (10000词)',
        description: '包含商务用语、学术词汇、成语等10000个进阶韩文词汇',
        size: '8.5 MB',
        category: 'dict',
        version: '1.0.0',
        downloadUrl: 'https://example.com/dict_advanced_10000.zip',
        isDownloaded: false,
        downloadProgress: 0
      },
      {
        id: 'dict_special_001',
        name: '专业词库 (医学/法律)',
        description: '包含医学、法律、技术等专业领域的韩文词汇5000个',
        size: '4.2 MB',
        category: 'dict',
        version: '1.0.0',
        downloadUrl: 'https://example.com/dict_special_5000.zip',
        isDownloaded: false,
        downloadProgress: 0
      },

      // 教程资源
      {
        id: 'tutorial_hangul_001',
        name: '韩文字母完整教程',
        description: '包含所有韩文字母（辅音、元音、双元音）的详细笔顺和发音',
        size: '3.2 MB',
        category: 'tutorial',
        version: '2.0.0',
        downloadUrl: 'https://example.com/tutorial_hangul.zip',
        isDownloaded: false,
        downloadProgress: 0
      },
      {
        id: 'tutorial_grammar_001',
        name: '基础语法教程',
        description: '包含韩文语法基础、时态、助词等内容，共50个课程',
        size: '5.1 MB',
        category: 'tutorial',
        version: '1.5.0',
        downloadUrl: 'https://example.com/tutorial_grammar.zip',
        isDownloaded: false,
        downloadProgress: 0
      },

      // 发音资源
      {
        id: 'audio_dict_001',
        name: '词库发音包',
        description: '3000个基础词汇的标准发音音频文件',
        size: '45.0 MB',
        category: 'audio',
        version: '1.0.0',
        downloadUrl: 'https://example.com/audio_dict_3000.zip',
        isDownloaded: false,
        downloadProgress: 0
      },
      {
        id: 'audio_phrases_001',
        name: '常用短语发音包',
        description: '500个常用韩文短语和表达的发音音频',
        size: '12.5 MB',
        category: 'audio',
        version: '1.0.0',
        downloadUrl: 'https://example.com/audio_phrases_500.zip',
        isDownloaded: false,
        downloadProgress: 0
      }
    ];
  }

  /**
   * 获取所有可下载资源
   */
  getAllResources(): DownloadResource[] {
    return [...this.resources];
  }

  /**
   * 按分类获取资源
   */
  getResourcesByCategory(category: string): DownloadResource[] {
    return this.resources.filter(r => r.category === category);
  }

  /**
   * 获取已下载的资源
   */
  getDownloadedResources(): DownloadResource[] {
    return this.resources.filter(r => r.isDownloaded);
  }

  /**
   * 获取单个资源详情
   */
  getResourceById(id: string): DownloadResource | null {
    return this.resources.find(r => r.id === id) || null;
  }

  /**
   * 下载资源
   */
  async downloadResource(id: string): Promise<boolean> {
    const resource = this.getResourceById(id);
    if (!resource || this.downloadingIds.has(id)) {
      return false;
    }

    this.downloadingIds.add(id);
    resource.downloadProgress = 0;

    try {
      // 模拟下载过程
      return new Promise((resolve) => {
        const interval = setInterval(() => {
          resource.downloadProgress += Math.random() * 30;
          if (resource.downloadProgress >= 100) {
            resource.downloadProgress = 100;
            resource.isDownloaded = true;
            resource.downloadedAt = Date.now();
            this.downloadingIds.delete(id);
            clearInterval(interval);
            resolve(true);
          }
        }, 800);
      });
    } catch (error) {
      console.error('下载失败:', error);
      this.downloadingIds.delete(id);
      return false;
    }
  }

  /**
   * 删除已下载的资源
   */
  deleteResource(id: string): boolean {
    const resource = this.getResourceById(id);
    if (resource && resource.isDownloaded) {
      resource.isDownloaded = false;
      resource.downloadProgress = 0;
      resource.downloadedAt = undefined;
      return true;
    }
    return false;
  }

  /**
   * 获取下载统计信息
   */
  getDownloadStats(): DownloadStats {
    const downloadedResources = this.getDownloadedResources();
    const stats: DownloadStats = {
      totalCount: this.resources.length,
      downloadedCount: downloadedResources.length,
      totalSize: this.calculateTotalSize(downloadedResources)
    };
    return stats;
  }

  /**
   * 计算总大小
   */
  private calculateTotalSize(resources: DownloadResource[]): string {
    return `${resources.length * 5} MB`;
  }

  /**
   * 获取资源分类列表
   */
  getCategories(): CategoryItem[] {
    const categories: CategoryItem[] = [
      { id: 'dict', name: '词库', icon: '📚' },
      { id: 'tutorial', name: '教程', icon: '🎓' },
      { id: 'audio', name: '发音', icon: '🔊' }
    ];
    return categories;
  }
}

