#!/bin/bash

# 检查 mysqldump 和 mysql 是否存在
if ! command -v mysqldump &> /dev/null; then
    echo "❌ 错误：mysqldump 命令不存在，请安装 MySQL 客户端！"
    exit 1
fi

if ! command -v mysql &> /dev/null; then
    echo "❌ 错误：mysql 命令不存在，请安装 MySQL 客户端！"
    exit 1
fi

TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
# 本地数据库信息
LOCAL_HOST="127.0.0.1"
LOCAL_DB="thinkphp"
LOCAL_USER="root"
LOCAL_PASS="123456"

# 远程数据库信息
REMOTE_HOST="192.168.0.1"
REMOTE_DB="remote-thinkphp"
REMOTE_USER="root"
REMOTE_PASS="12345"

DUMP_FILE="/backup/${LOCAL_DB}_${TIMESTAMP}.sql"

echo "🚀 正在导出本地数据库 $LOCAL_DB..."
mysqldump -h $LOCAL_HOST -u $LOCAL_USER -p$LOCAL_PASS $LOCAL_DB > $DUMP_FILE

echo "🔍 检查远程数据库 $REMOTE_DB 是否存在..."
DB_EXISTS=$(mysql -h $REMOTE_HOST -u $REMOTE_USER -p$REMOTE_PASS -e "SHOW DATABASES LIKE '$REMOTE_DB';" | grep "$REMOTE_DB")
if [ -z "$DB_EXISTS" ]; then
    echo "❌ 远程数据库 $REMOTE_DB 不存在，请手动创建！"
    exit 1
fi

echo "📥 导入数据到远程数据库 $REMOTE_DB..."
mysql -h $REMOTE_HOST -u $REMOTE_USER -p$REMOTE_PASS $REMOTE_DB < $DUMP_FILE

echo "✅ 数据库迁移完成！🚀"
