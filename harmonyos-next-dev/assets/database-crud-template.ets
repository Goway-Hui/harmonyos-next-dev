/**
 * 数据库 CRUD 模板 — Preferences + RDB 操作
 * 适用于 HarmonyOS NEXT (API 20+)
 */
import { preferences } from '@kit.ArkData';
import { relationalStore } from '@kit.ArkData';
import { BusinessError } from '@kit.BasicServicesKit';

// ==================== 1. Preferences — 轻量键值存储 ====================
export class PreferencesHelper {
  private store: preferences.Preferences | null = null;

  async init(context: object): Promise<void> {
    this.store = await preferences.getPreferences(context, 'app_settings');
  }

  // 写入
  async set<T>(key: string, value: T): Promise<void> {
    if (!this.store) throw new Error('Preferences not initialized');
    await this.store.put(key, value);
    await this.store.flush();
  }

  // 读取
  async get<T>(key: string, defaultValue: T): Promise<T> {
    if (!this.store) throw new Error('Preferences not initialized');
    return await this.store.get(key, defaultValue) as T;
  }

  // 删除
  async delete(key: string): Promise<void> {
    if (!this.store) throw new Error('Preferences not initialized');
    await this.store.delete(key);
    await this.store.flush();
  }

  // 清空
  async clear(): Promise<void> {
    if (!this.store) throw new Error('Preferences not initialized');
    await this.store.clear();
    await this.store.flush();
  }
}

// ==================== 2. RDB — 关系型数据库 ====================

// 数据模型
interface User {
  id?: number;
  name: string;
  age: number;
  email: string;
  createdAt?: number;
}

export class DatabaseHelper {
  private rdbStore: relationalStore.RdbStore | null = null;

  async init(context: object): Promise<void> {
    this.rdbStore = await relationalStore.getRdbStore(context, {
      name: 'myapp.db',
      securityLevel: relationalStore.SecurityLevel.S1
    });

    // 建表
    await this.rdbStore.executeSql(
      `CREATE TABLE IF NOT EXISTS users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        age INTEGER NOT NULL DEFAULT 0,
        email TEXT,
        created_at INTEGER NOT NULL DEFAULT 0
      )`
    );
  }

  // ==================== CREATE ====================
  async insertUser(user: Omit<User, 'id'>): Promise<number> {
    if (!this.rdbStore) throw new Error('DB not initialized');
    let row = {
      name: user.name,
      age: user.age,
      email: user.email || '',
      created_at: Date.now()
    };
    let rowId = await this.rdbStore.insert('users', row);
    console.log(`Inserted user, rowId: ${rowId}`);
    return rowId;
  }

  async batchInsertUsers(users: Omit<User, 'id'>[]): Promise<void> {
    if (!this.rdbStore) throw new Error('DB not initialized');
    await this.rdbStore.beginTransaction();
    try {
      for (let user of users) {
        await this.rdbStore.insert('users', {
          name: user.name,
          age: user.age,
          email: user.email || '',
          created_at: Date.now()
        });
      }
      await this.rdbStore.commit();
    } catch (err) {
      await this.rdbStore.rollback();
      throw err;
    }
  }

  // ==================== READ ====================
  async queryAllUsers(): Promise<User[]> {
    if (!this.rdbStore) throw new Error('DB not initialized');
    let predicates = new relationalStore.RdbPredicates('users');
    predicates.orderByDesc('created_at');
    let resultSet = await this.rdbStore.query(predicates, ['id', 'name', 'age', 'email', 'created_at']);
    return this.parseResultSet<User>(resultSet);
  }

  async queryUserById(id: number): Promise<User | null> {
    if (!this.rdbStore) throw new Error('DB not initialized');
    let predicates = new relationalStore.RdbPredicates('users');
    predicates.equalTo('id', id);
    let resultSet = await this.rdbStore.query(predicates, ['id', 'name', 'age', 'email', 'created_at']);
    let users = this.parseResultSet<User>(resultSet);
    return users.length > 0 ? users[0] : null;
  }

  async queryUsersByAge(minAge: number, maxAge: number): Promise<User[]> {
    if (!this.rdbStore) throw new Error('DB not initialized');
    let predicates = new relationalStore.RdbPredicates('users');
    predicates.greaterThanOrEqualTo('age', minAge);
    predicates.lessThanOrEqualTo('age', maxAge);
    let resultSet = await this.rdbStore.query(predicates, ['id', 'name', 'age', 'email']);
    return this.parseResultSet<User>(resultSet);
  }

  async searchUsers(keyword: string): Promise<User[]> {
    if (!this.rdbStore) throw new Error('DB not initialized');
    let predicates = new relationalStore.RdbPredicates('users');
    predicates.like('name', `%${keyword}%`);
    predicates.or();
    predicates.like('email', `%${keyword}%`);
    let resultSet = await this.rdbStore.query(predicates, ['id', 'name', 'age', 'email']);
    return this.parseResultSet<User>(resultSet);
  }

  // ==================== UPDATE ====================
  async updateUser(user: User): Promise<number> {
    if (!this.rdbStore) throw new Error('DB not initialized');
    let predicates = new relationalStore.RdbPredicates('users');
    predicates.equalTo('id', user.id);
    let rows = await this.rdbStore.update({
      name: user.name,
      age: user.age,
      email: user.email
    }, predicates);
    console.log(`Updated ${rows} rows`);
    return rows;
  }

  // ==================== DELETE ====================
  async deleteUser(id: number): Promise<number> {
    if (!this.rdbStore) throw new Error('DB not initialized');
    let predicates = new relationalStore.RdbPredicates('users');
    predicates.equalTo('id', id);
    let rows = await this.rdbStore.delete(predicates);
    console.log(`Deleted ${rows} rows`);
    return rows;
  }

  async clearAllUsers(): Promise<void> {
    if (!this.rdbStore) throw new Error('DB not initialized');
    let predicates = new relationalStore.RdbPredicates('users');
    await this.rdbStore.delete(predicates);
  }

  // ==================== TOOLS ====================
  private parseResultSet<T>(resultSet: relationalStore.ResultSet): T[] {
    let results: T[] = [];
    while (resultSet.goToNextRow()) {
      let row: Record<string, object | number | string | boolean> = {};
      for (let i = 0; i < resultSet.columnCount; i++) {
        let colName = resultSet.getColumnName(i);
        let colType = resultSet.getColumnType(i);
        switch (colType) {
          case relationalStore.ColumnType.COLUMN_TYPE_INTEGER:
            row[colName] = resultSet.getLong(i);
            break;
          case relationalStore.ColumnType.COLUMN_TYPE_STRING:
            row[colName] = resultSet.getString(i);
            break;
          case relationalStore.ColumnType.COLUMN_TYPE_FLOAT:
            row[colName] = resultSet.getDouble(i);
            break;
          default:
            row[colName] = resultSet.getValue(i);
        }
      }
      results.push(row as unknown as T);
    }
    resultSet.close();
    return results;
  }

  // 获取统计信息
  async getUserCount(): Promise<number> {
    if (!this.rdbStore) throw new Error('DB not initialized');
    let resultSet = await this.rdbStore.querySql("SELECT COUNT(*) as count FROM users");
    if (resultSet.goToFirstRow()) {
      let count = resultSet.getLong(resultSet.getColumnIndex('count'));
      resultSet.close();
      return count;
    }
    resultSet.close();
    return 0;
  }
}

// ==================== 使用示例 ====================
@Entry
@Component
struct DatabaseDemo {
  private db: DatabaseHelper = new DatabaseHelper();
  private prefs: PreferencesHelper = new PreferencesHelper();

  @State users: User[] = [];
  @State userCount: number = 0;
  @State lastAction: string = '';

  aboutToAppear(): void {
    // 模拟时序 — 一般从 EntryAbility 传入 context
    // this.db.init(getContext(this));
    // this.prefs.init(getContext(this));
    // this.refreshList();
  }

  build() {
    Column({ space: 12 }) {
      Text('数据库 CRUD 示例')
        .fontSize(20)
        .fontWeight(FontWeight.Bold)

      Text(`用户总数: ${this.userCount}`).fontSize(14).fontColor('#666')
      Text(`最近操作: ${this.lastAction}`).fontSize(12).fontColor('#999')

      Row({ space: 8 }) {
        Button('插入示例').onClick(() => this.addSample())
        Button('查询全部').onClick(() => this.refreshList())
        Button('清空').onClick(() => this.clearAll())
      }

      List({ space: 8 }) {
        ForEach(this.users, (user: User) => {
          ListItem() {
            Row() {
              Text(`${user.name} (${user.age}岁)`).layoutWeight(1)
              Text(user.email).fontSize(12).fontColor('#666')
              Button('删')
                .fontColor('#F44336')
                .backgroundColor(Color.Transparent)
                .onClick(() => this.deleteUser(user.id!))
            }
            .width('100%')
            .padding(12)
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
          }
        })
      }
      .layoutWeight(1)
      .width('100%')
    }
    .width('100%')
    .height('100%')
    .padding(16)
    .backgroundColor('#f5f5f5')
  }

  async addSample(): Promise<void> {
    let id = await this.db.insertUser({
      name: `用户${Date.now() % 1000}`,
      age: 20 + Math.floor(Math.random() * 30),
      email: `user${Date.now() % 1000}@example.com`
    });
    this.lastAction = `插入用户 ID: ${id}`;
    await this.refreshList();
  }

  async refreshList(): Promise<void> {
    this.users = await this.db.queryAllUsers();
    this.userCount = await this.db.getUserCount();
  }

  async deleteUser(id: number): Promise<void> {
    await this.db.deleteUser(id);
    this.lastAction = `删除用户 ID: ${id}`;
    await this.refreshList();
  }

  async clearAll(): Promise<void> {
    await this.db.clearAllUsers();
    this.lastAction = '清空所有用户';
    await this.refreshList();
  }
}
