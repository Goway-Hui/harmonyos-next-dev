/**
 * 网络请求模板 — HTTP + 错误处理 + 加载状态
 * 适用于 HarmonyOS NEXT (API 20+)
 */
import { http } from '@kit.NetworkKit';
import { promptAction } from '@kit.ArkUI';
import { BusinessError } from '@kit.BasicServicesKit';

// ==================== API 基础配置 ====================
const API_BASE_URL = 'https://api.example.com/v1';
const REQUEST_TIMEOUT = 15000; // 15s

// ==================== 通用 API 响应类型 ====================
interface ApiResponse<T> {
  code: number;
  message: string;
  data: T;
}

// ==================== HTTP 客户端 ====================
class HttpClient {
  private static instance: HttpClient;
  private token: string = '';

  static getInstance(): HttpClient {
    if (!HttpClient.instance) {
      HttpClient.instance = new HttpClient();
    }
    return HttpClient.instance;
  }

  setToken(token: string): void {
    this.token = token;
  }

  clearToken(): void {
    this.token = '';
  }

  // ==================== GET 请求 ====================
  async get<T>(path: string, params?: Record<string, string | number>): Promise<ApiResponse<T>> {
    let url = this.buildUrl(path, params);
    return this.request<T>(url, http.RequestMethod.GET);
  }

  // ==================== POST 请求 ====================
  async post<T>(path: string, body?: object): Promise<ApiResponse<T>> {
    let url = this.buildUrl(path);
    return this.request<T>(url, http.RequestMethod.POST, body);
  }

  // ==================== PUT 请求 ====================
  async put<T>(path: string, body?: object): Promise<ApiResponse<T>> {
    let url = this.buildUrl(path);
    return this.request<T>(url, http.RequestMethod.PUT, body);
  }

  // ==================== DELETE 请求 ====================
  async delete<T>(path: string): Promise<ApiResponse<T>> {
    let url = this.buildUrl(path);
    return this.request<T>(url, http.RequestMethod.DELETE);
  }

  // ==================== 核心请求方法 ====================
  private async request<T>(
    url: string,
    method: http.RequestMethod,
    body?: object
  ): Promise<ApiResponse<T>> {
    let req = http.createHttp();
    try {
      let result = await req.request(url, {
        method: method,
        header: this.buildHeaders(),
        extraData: body ? JSON.stringify(body) : undefined,
        connectTimeout: REQUEST_TIMEOUT,
        readTimeout: REQUEST_TIMEOUT,
        expectDataType: http.HttpDataType.OBJECT
      });

      if (result.responseCode === 200) {
        return result.result as ApiResponse<T>;
      } else if (result.responseCode === 401) {
        // Token 过期，跳转登录
        this.handleUnauthorized();
        throw new Error('登录已过期，请重新登录');
      } else {
        throw new Error(`请求失败: ${result.responseCode}`);
      }
    } catch (err) {
      let error = err as BusinessError;
      if (error.code === 100003) {
        throw new Error('网络不可用，请检查网络连接');
      }
      throw err;
    } finally {
      req.destroy();
    }
  }

  // ==================== 构建请求头 ====================
  private buildHeaders(): Record<string, string> {
    let headers: Record<string, string> = {
      'Content-Type': 'application/json',
      'Accept': 'application/json'
    };
    if (this.token) {
      headers['Authorization'] = `Bearer ${this.token}`;
    }
    return headers;
  }

  // ==================== 构建 URL ====================
  private buildUrl(path: string, params?: Record<string, string | number>): string {
    let url = `${API_BASE_URL}${path.startsWith('/') ? path : `/${path}`}`;
    if (params) {
      let query = Object.entries(params)
        .map(([k, v]) => `${encodeURIComponent(k)}=${encodeURIComponent(v.toString())}`)
        .join('&');
      url += `?${query}`;
    }
    return url;
  }

  // ==================== 处理未授权 ====================
  private handleUnauthorized(): void {
    this.clearToken();
    // 跳转登录页
    promptAction.showToast({ message: '登录已过期' });
  }
}

// ==================== 业务 API 封装 ====================
class UserApi {
  private http = HttpClient.getInstance();

  // 登录
  async login(username: string, password: string): Promise<ApiResponse<{ token: string; user: object }>> {
    let result = await this.http.post<{ token: string; user: object }>('/auth/login', {
      username,
      password
    });
    if (result.code === 0 && result.data.token) {
      this.http.setToken(result.data.token);
    }
    return result;
  }

  // 获取用户信息
  async getUserInfo(userId: number): Promise<ApiResponse<object>> {
    return this.http.get<object>(`/user/${userId}`);
  }

  // 获取列表
  async getList(page: number, size: number): Promise<ApiResponse<object[]>> {
    return this.http.get<object[]>('/list', { page, size });
  }

  // 提交数据
  async submitData(data: object): Promise<ApiResponse<object>> {
    return this.http.post<object>('/submit', data);
  }
}

// ==================== 使用示例组件 ====================
@Entry
@Component
struct NetworkDemo {
  @State dataList: object[] = [];
  @State isLoading: boolean = false;
  @State errorMessage: string = '';

  private api = new UserApi();

  build() {
    Column({ space: 12 }) {
      // 标题
      Text('网络请求示例')
        .fontSize(24)
        .fontWeight(FontWeight.Bold)
        .width('100%')

      // 加载按钮
      Button('加载数据')
        .type(ButtonType.Capsule)
        .onClick(() => this.fetchData())

      // 加载状态
      if (this.isLoading) {
        LoadingProgress().width(32).height(32)
        Text('加载中...').fontSize(14).fontColor('#999')
      }

      // 错误提示
      if (this.errorMessage) {
        Text(this.errorMessage)
          .fontSize(14)
          .fontColor('#F44336')
          .padding(12)
          .backgroundColor('#FFEBEE')
          .borderRadius(8)
      }

      // 数据列表
      List({ space: 8 }) {
        ForEach(this.dataList, (item: Record<string, object>, index: number) => {
          ListItem() {
            Text(`Item ${index + 1}: ${JSON.stringify(item)}`)
              .fontSize(14)
              .padding(12)
              .backgroundColor('#FFFFFF')
              .borderRadius(8)
          }
        })
      }
      .layoutWeight(1)
      .width('100%')

      // 登录演示
      Button('模拟登录')
        .type(ButtonType.Capsule)
        .backgroundColor('#4CAF50')
        .fontColor(Color.White)
        .onClick(() => this.mockLogin())
    }
    .width('100%')
    .height('100%')
    .padding(24)
    .backgroundColor('#f5f5f5')
  }

  async fetchData(): Promise<void> {
    this.isLoading = true;
    this.errorMessage = '';

    try {
      let result = await this.api.getList(1, 10);
      if (result.code === 0) {
        this.dataList = result.data;
        promptAction.showToast({ message: `加载成功: ${result.data.length}条` });
      } else {
        this.errorMessage = result.message;
      }
    } catch (err) {
      this.errorMessage = (err as Error).message;
    } finally {
      this.isLoading = false;
    }
  }

  async mockLogin(): Promise<void> {
    try {
      let result = await this.api.login('demo', '123456');
      promptAction.showToast({ message: '登录成功' });
    } catch (err) {
      promptAction.showToast({ message: (err as Error).message });
    }
  }
}

// 导出单例供全局使用
export const httpClient = HttpClient.getInstance();
export const userApi = new UserApi();
